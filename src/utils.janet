(import ./db :as db)
(import http)
(import sh)
(import json :as json)

(defn make-urls [model conf]
  (let [t (conf :type) 
        p (conf :port)
        e (if (= t "single")
            (string "localhost:" p "/invocations")
            (string "localhost:" p "/models/" model "/invoke"))]
    {:type t
     :port p
     :endpoint e}))


(defn model-loaded? [loaded-models model]
  (any? (map |(= model $) loaded-models)))


(defn post-to-container! [tab url]
  (let [body (-> (tab :latest-res))
        res (-> ((http/post url body) :body))]
    (put tab :latest-res res)
    (array/push (tab :responses) res)
    tab))
 

(defn chain-containers [original-body urls container-names]
  (print "Chaining requests...")
  (let [res (reduce
              post-to-container!
              @{:responses @[] 
                :latest-res original-body} 
              urls)
        enc (->> (res :responses) 
                 (map json/decode)
                 (zipcoll container-names))]
    {:status 200
     :body (json/encode enc)
     :headers {"Content-Type" "application/json"}}))


(defn docker-running? [container]
  (->> (sh/$< docker ps --filter (string "name=" container) --format "{{.Names}}")
       (string/replace "\n" "")
       empty?
       not))


(defn container-ports [container-name]
  (sh/$< docker ps --filter (string "name=" container-name) --format "{{.Ports}}"))


(defn add-conn-details [container]
  (let [container-name (container :container)
        splits (->> (container-ports container-name) 
                    (string/split ":") 
                    (map |(string/split "-" $))
                    flatten)
        host-ports (zipcoll [:host :port] splits)]
    (merge container host-ports)))


(defn set-container-info! [containers]
  (let [merged (map |(add-conn-details $) containers)]
    (set db/container-config merged)))
