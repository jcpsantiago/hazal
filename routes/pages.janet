(use joy)
(import http)
(use ../src/db)

(defn make-urls [model conf]
  (let [t (conf :type) 
        p (conf :port)
        e (if (= t "single")
            (string "localhost:" p "/invocations")
            (string "localhost:" p "/models/" model "/invoke"))]
    e))


(route :get "/ping" :pages/ping)
(defn pages/ping [req]
  {:status 200
   :body "Hazal is here, making the containers flow"
   :headers {"Content-Type" "text/plain"}})

(route :post "/pipeline" :pages/pipeline)
(defn pages/pipeline [req]
  (let [original-body (req :body)
        model (get-in req [:query-string :model])
        urls (map (fn [x] (make-urls model x)) 
                  container-config)
        res (reduce 
              (fn [body url] ((http/post url body) :body)) 
              original-body urls)]
    {:status 200
     :body res
     :headers {"Content-Type" "application/json"}}))

