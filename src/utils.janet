(import http)

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
  (any? (map (fn [x] (= model x)) loaded-models)))


(defn chain-containers [original-body urls]
  (print "Chaining requests...")
  (let [res (reduce 
             (fn [body url] ((http/post url body) :body)) 
             original-body urls)]
    {:status 200
     :body res
     :headers {"Content-Type" "application/json"}}))
