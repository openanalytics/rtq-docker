
library(rtq)

redisConf <- redux::redis_config(
    host = Sys.getenv("REDIS_HOST"),
    port = Sys.getenv("REDIS_PORT"))

tq <- RedisTQ(redisConf, "demo")

message("worker ready and listening!")

repeat {
  
  itemJSON <- NULL
  
  itemJSON <- tryCatch(leaseTask(tq), warning = message)
  
  if (!is.null(itemJSON)) {
    
    message("processing: ", itemJSON)
    
    item <- jsonlite::fromJSON(itemJSON)
    
    # your processing code here
    Sys.sleep(1)
    message("done processing: ", itemJSON)
    
    completeTask(tq, itemJSON)
    
  }
  
}
