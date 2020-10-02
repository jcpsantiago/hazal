(use joy)
(use ./routes/pages)
(import ./src/db :as db)
(import ./src/utils :as utils)


(def app (-> (handlers pages/pipeline)
             (query-string)
             (body-parser)))
             # (server-error)
             # (x-headers)
             # (not-found)))
             # (logger)))


(defn runserver [args]
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
      (print "Not all containers are running!"))))


(defn main [_filename & args]
  (cond
    (empty? args) 
    (print "Please provide a configuration file")

    (> (length args) 1) 
    (do 
      (print "Only one configuration file need, ignoring further arguments") 
      (runserver args))

    :true (runserver args)))
