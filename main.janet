(use joy)
(use ./routes/pages)
(use ./src/db)
(use ./src/utils)
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


(defn main [_filename & args]
  (if (empty? (first args))
    (print "Please provide a configuration file")
    (do
      (let [containers (-> (first args) slurp parse)
            container-names (map |($ :container) (flatten container-config))
            running? (map docker-running? container-names)]
        (if (all true? running?)
          (do
            (print "All containers are ready!")
            (print "Getting host and port of each container...")
            (set-container-info! containers)
            (print "Starting server...")
            (server app (env :port)))
          (print "Not all containers are running!"))))))
