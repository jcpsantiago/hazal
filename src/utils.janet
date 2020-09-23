(import ./db :as db)
(import http)
(import sh)

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


(defn chain-containers [original-body urls]
  (print "Chaining requests...")
  (let [res (reduce 
             (fn [body url] ((http/post url body) :body)) 
             original-body urls)]
    {:status 200
     :body res
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
