(use joy)
(use ./routes/pages)
(use ./src/db)
(import sh)


(def app (-> (handlers pages/pipeline pages/ping)
            (extra-methods)
            (query-string)
            (body-parser)
            # (json-body-parser)
            # (server-error)
            # (x-headers)
            # (static-files)
            (not-found)))
            # (logger)))

(defn docker-running? [container]
  (->> (sh/$< docker ps --filter (string "name=" container) --format "{{.Names}}")
       (string/replace "\n" "")
       (empty?)
       (not)))


(defn main [script & args]
  (set 
    container-config 
    (merge container-config (-> (first args) slurp parse)))

  (let [containers (map (fn [t] (t :container)) (flatten container-config))
        running? (map docker-running? containers)]
    (if (all true? running?)
      (do
        (print "All containers are ready! Starting server...")
        (server app (env :port)))
      (print "Not all containers are running!"))))
