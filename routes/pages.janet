(use joy)
(import http)
(import ../src/db :as db)
(import ../src/utils :as utils)


(route :get "/ping" :pages/ping)
(defn pages/ping [req]
  {:status 200
   :body "Hazal is here, making the containers flow"
   :headers {"Content-Type" "text/plain"}})


(route :post "/pipeline" :pages/pipeline)
(defn pages/pipeline [req]
  (let [container-names (->> db/container-config
                             (map |($ :container))
                             (map keyword))
        original-body (req :body)
        model (get-in req [:query-string :model])
        endpoints (map |(utils/make-urls model $) 
                       db/container-config)
        urls (map |($ :endpoint) endpoints)
        multi-endpoint-port (-> (filter 
                                  |(= ($ :type) "multi") 
                                  endpoints)
                                (first)
                                (get :port)
                                (string))]
    
    # multi model containers do not load pre-load models
    (if (and 
          (not (utils/model-loaded? db/loaded-models model)) 
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
              (print (string "Model " model " not found!"))
              {:status 404
               :body (string "Model " model " not found!")
               :headers {"Content-Type" "text/plain"}})
            (do
              (print "Adding " model " to list of loaded models")
              (set db/loaded-models
                   (array/concat db/loaded-models model))
              (utils/chain-containers original-body urls container-names)))))

      (utils/chain-containers original-body urls container-names)))) 
