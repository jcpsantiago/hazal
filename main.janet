(use joy)
(use ./routes/pages)
(import ./src/db :as db)
(import ./src/utils :as utils)
(import sh)


(def app (-> (handlers pages/pipeline)
             (query-string)
             (body-parser)))
             # (server-error)
             # (x-headers)
             # (not-found)))
             # (logger)))


(defn main [_filename & args]
  (if (empty? (first args))
    (print "Please provide a configuration file")
    (do
      (let [containers (-> (first args) slurp parse)
            container-names (->> containers flatten (map |($ :container)))
            running? (map utils/docker-running? container-names)]
        (if (all true? running?)
          (do
            (print "All containers are ready!")
            (print "Getting host and port of each container...")
            (utils/set-container-info! containers)
            (print "Starting server...")
            (server app (or (env :port) 9001)))
          (print "Not all containers are running!"))))))
