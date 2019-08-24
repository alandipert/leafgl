library(chromote)
library(later)

if (file.exists("/usr/bin/chromium-browser")) {
  Sys.setenv(CHROMOTE_CHROME="/usr/bin/chromium-browser")
}

fileBytes <- function(con) {
  readBin(con, "raw", n = file.size(con))
}

timeUntilLoaded <- function(myloop, url, expectedScreenshot) {
  expectedBytes <- fileBytes(expectedScreenshot)
  startTime <- Sys.time()
  b <- ChromoteSession$new()
  b$Page$navigate(url)
  b$Page$loadEventFired()
  takeScreenshot <- function() {
    cat(".")
    tf <- tempfile()
    screenshot <- b$screenshot(tf)
    on.exit(unlink(screenshot))
    newBytes <- fileBytes(screenshot)
    if (identical(newBytes, expectedBytes)) {
      # TODO figure out the right way to shutdown without seeing weird websocket messages
      b$close()
      b$parent$stop()
      cat("\nDone in ", Sys.time()-startTime, "\n")
    } else {
      later(takeScreenshot, delay = 0, loop = myloop)
    }
  }
  takeScreenshot()
}

main <- function(args) {
  if (length(args) != 2)
    stop("URL and reference screenshot are required arguments")

  privateLoop <- later::create_loop(FALSE)
  timeUntilLoaded(privateLoop, args[[1]], args[[2]])

  while(!later::loop_empty(privateLoop))
    later::run_now(loop = privateLoop)

  later::destroy_loop(privateLoop)
}

main(commandArgs(trailingOnly=TRUE))