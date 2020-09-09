(use joy)
(import http)
(use ../src/db)
(use ../src/utils)

(route :get "/ping" :pages/ping)
(defn pages/ping [req]
  {:status 200
   :body "Hazal is here, making the containers flow"
   :headers {"Content-Type" "text/plain"}})

(route :post "/pipeline" :pages/pipeline)
(defn pages/pipeline [req]
  (let [original-body (req :body)
        model (get-in req [:query-string :model])
        endpoints (map (fn [x] (make-urls model x)) 
                       container-config)
        urls (map (fn [x] (x :endpoint)) endpoints)
        multi-endpoint-port (-> (filter (fn [x] (= (x :type) "multi")) endpoints)
                                (first)
                                (get :port)
                                (string))]
    
    # multi model containers do not load pre-load models
    # FIXME don't try to load model all the time, although maybe who cares
    (when (not (empty? multi-endpoint-port))
      (do
        (print "Loading model " model)
        (http/post 
          (string "localhost:" multi-endpoint-port "/models") 
          (string "{\"model_name\":\"" model "\", \"url\": \"/opt/ml/models/" model "\"}"))))

    (print "Chaining requests...")
    (let [res (reduce 
               (fn [body url] ((http/post url body) :body)) 
               original-body urls)]

      {:status 200
       :body res
       :headers {"Content-Type" "application/json"}})))

