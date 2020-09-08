(use joy)
(import http)


(route :get "/healthcheck" :pages/healthcheck)
(defn pages/healthcheck [req]
  [:h1 "/healthcheck"])


(route :post "/pipeline" :pages/pipeline)
(defn pages/pipeline [req]
  (let [original-body (req :body)
        targets ["localhost:8888/invocations" "localhost:9999/models/contorion/invoke"]
        res (reduce (fn [body url] ((http/post url body) :body)) original-body targets)]
    {:status 200
     :body res
     :headers {"Content-Type" "application/json"}}))
