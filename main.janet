(use joy)
(use ./routes/pages)
(import sh)


(def app (-> (handlers pages/pipeline pages/healthcheck)
            # (extra-methods)
            (query-string)
            # (body-parser)
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

(defn main [& args]
  (let [containers (-> "containers.config" slurp parse)
        running? (map docker-running? containers)]
    (if (all true? running?)
      (do
        (print "All containers are ready!")
        (server app (env :port)))
      (print "Not all containers are running!"))))
