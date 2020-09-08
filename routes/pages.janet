(use joy)
(import http)


(route :get "/healthcheck" :pages/healthcheck)
(defn pages/healthcheck [req]
  [:h1 "/healthcheck"])


(route :post "/pipeline" :pages/pipeline)
(defn pages/pipeline [req]
  (let [body (req :body)
        res-pre (http/post "localhost:8888/invocations" body)
        res-inf (http/post "localhost:9999/models/contorion/invoke" (res-pre :body))]
    {:status 200
     :body (res-inf :body)
     :headers {"Content-Type" "application/json"}}))
