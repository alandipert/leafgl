library(promises)

if (file.exists("/usr/bin/chromium-browser")) {
  Sys.setenv(CHROMOTE_CHROME="/usr/bin/chromium-browser")
}

timeUntilReady <- function(url, mapId = 'map') {
  session <- chromote::ChromoteSession$new()
  session$Console$enable()
  startTime <- Sys.time()
  id <- as.character(sample(.Machine$integer.max, 1))
  promises::promise(function(resolve, reject) {
    session$Console$messageAdded(function(e) {
      if (e$message$text == id) resolve(Sys.time() - startTime)
    })
    session$Page$navigate(url, wait_ = FALSE) %...>% {
      session$Page$domContentEventFired(wait_ = FALSE)
    } %...>% {
      session$Runtime$evaluate(sprintf("
      (() => {
        new MutationObserver((mutations, observer) => {
          console.debug('%s');
          observer.disconnect();
        }).observe(document.getElementById('%s'), { childList: true });
      })();
      ", id, mapId))
    }
  })
}

# TODO Should be able to specify a timeout and exit 1 if exceeded
main <- function(args, quitOnDone = TRUE) {
  if (length(args) != 2) stop("URL and map id arguments are required")
  url <- args[[1]]
  mapId <- args[[2]]

  timeUntilReady(url, mapId) %...>% {
    cat(., "\n")
    # TODO figure out a way to clean up session without emitting websocketpp
    # garbage message
    if (quitOnDone) quit(save = "no", status = 0)
  }

  while(!later::loop_empty()) later::run_now()
}

main(commandArgs(trailingOnly=TRUE))
