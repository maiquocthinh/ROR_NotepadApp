Rails.application.config.session_store :redis_store,
                                       servers: [
                                         {
                                           host: ENV['REDIS_HOST'],
                                           port: ENV['REDIS_PORT'],
                                           db: ENV['REDIS_DB'],
                                           namespace: "session"
                                         },
                                       ],
                                       expire_after: ENV['SESSION_EXPIRE_AFTER'].to_i.minutes,
                                       key: ENV['SESSION_KEY']

