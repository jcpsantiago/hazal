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
        multi-endpoint-port (-> (filter 
                                  (fn [x] (= (x :type) "multi")) 
                                  endpoints)
                                (first)
                                (get :port)
                                (string))]
    
    # multi model containers do not load pre-load models
    (if (and 
          (not (model-loaded? loaded-models model)) 
          (not (empty? multi-endpoint-port)))
      (do
        (print "Loading model " model)
        (let [res-loaded (http/post 
                          (string "localhost:" multi-endpoint-port "/models") 
                          (string "{\"model_name\":\"" model "\", \"url\": \"/opt/ml/models/" model "\"}"))]
          # FIXME should probably be 404, but the sagemaker contract only
          # specifies a 404 response for the GET /models/<model name> endpoint
          (if (= (res-loaded :status) 507)
            (do
              (print "Model not found!")
              {:status 404
               :body "Model not found!"
               :headers {"Content-Type" "text/plain"}})
            (do
              (print "Adding " model " to list of loaded models")
              (set loaded-models
                   (array/concat loaded-models model))
              (chain-containers original-body urls)))))

      (chain-containers original-body urls)))) 
