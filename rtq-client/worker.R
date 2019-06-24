
library(config)
library(redux)
library(jsonlite)
library(rtq)

redisConf <- redis_config(
    host = Sys.getenv("REDIS_HOST", config::get("redis")$host),
    port = Sys.getenv("REDIS_PORT", config::get("redis")$port))

tqIn <- RedisTQ(redisConf, config::get(c("queue", "input")))
tqOut <- RedisTQ(redisConf, config::get(c("queue", "output")))

repeat {
  
  itemJSON <- NULL
  
  itemJSON <- tryCatch(leaseTask(tqIn), warning = message)
  
  if (!is.null(itemJSON)) {
    
    message("processing: ", itemJSON)
    
    item <- fromJSON(itemJSON)
    
    # prepare template
    template <- switch(item$report,
        "testReport" = system.file("templates", "report.Rmd",
            package = "deRuiterStyle"),
        stop("unknown report type"))
    templateFile <- file.path(getwd(), basename(template))
    file.copy(template, templateFile)
    
    # render report
    outputFile <- tempfile("report_", tmpdir = getwd(), fileext = ".html") 
    rmarkdown::render(templateFile, output_file = outputFile)
    
    # store in s3
    item$s3uri = sprintf("s3://aph-data/reports/test/%s", basename(outputFile))
    put_object(outputFile, item$s3uri)
    
    createTask(tqOut, item)
    
    completeTask(tqIn, itemJSON)
    
  }
  
  if (!existsTask(tqIn)) break;
  
}

message(sprintf("no more tasks... shutting down in %s seconds", config::get("pause-length")))

Sys.sleep(config::get("pause-length"))
