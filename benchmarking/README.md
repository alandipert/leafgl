# leafgl benchmarking tools

This directory contains example applications and code for conducting Leaflet and leafgl performance measurements. In particular, we are interested in measuring the amount of time it takes to render various large data sets: the time elapsed between when the browser first receives the Leaflet/leafgl markup and code, to when the user sees rendering has completed. It is our goal as we add features to leafgl to weigh any new features or changes against their performance impact, since our #1 feature *is* performance.

## Measurement methodology

Our methodology is simple: given a test app, we load up the app and take a screenshot of it (the "reference" screenshot) after rendering has completed. This is done manually on an app-by-app and developer-by-developer basis.

Then, we load the app again, continuously screenshotting it and marking the time the screenshot was taken. When the latest screenshot matches the reference screenshot, we know the data has been rendered. The time elapsed is our measurement.

This is all done using [chromote][chromote], an R package that allows driving a browser and doing this kind of thing with R code.

## Measurement caveats

Timings are dependent on at least:

* The particular app code under test
* The developer's machine
* What other stuff was going on during the test (swapping, CPU load, etc)
* Platform and chromote browser
* Probably lots of other things

...and as such, are highly subjective. Results from different machines can't meaningfully be compared.

It's not a bad idea to get this going on Travis, but as virtualized infrastructure the Travis build machines are subject to wild performance swings. That said, we won't really know if it's worthwhile to run this stuff on Travis until we try, so we should at least try. We might then be able to use Travis's API, or its integration with Datadog, to view historical timings and trends.

## Taking a measurement

### Start the app under test

First, start the test application on a known port. For example, at the command line, you can run this in project directory:

    Rscript benchmarking/apps/points01.R 8028
    
Alternatively, you can run it from R with the [`processx`][processx] package like this:

    library(processx)
    app <- process$new("Rscript", c("benchmarking/apps/points01.R", "8028"))
    
Either way, you should be able to see the app by visiting http://localhost:8028.

### Take a reference screenshot

Next we need to take a reference screenshot using chromote.

> Note: If you're on Linux, you needn't install Google Chrome. You can get away with chromium (the `chromium-browser` package on Ubuntu). However, you might need to run this snippet before proceeding: `Sys.setenv(CHROMOTE_CHROME="/usr/bin/chromium-browser")`. See the [chromote docs](https://github.com/rstudio/chromote#specifying-which-browser-to-use) for details.

First, make a chromote instance:

    b <- chromote::ChromoteSession$new()
    b$Page$navigate("http://localhost:8028")
    
See what chromote sees by running this:

    b$view()
    
> Note: `b$view()` might not work if you're using Firefox, or if you're using RStudio Pro. As an alternative you can just wait for awhile until you think the app is probably done, and take a screenshot. If the screenshot doesn't show rendering completed, wait longer and take another one.
    
When the app has completed rendering, take a screenshot:

    b$screenshot("reference.png")
    
### Perform a measurement

Now that you have a reference image, you can use the `benchmark.R` tool to measure rendering time.

> Note: Before proceeding, you should close any unneeded applications to free up memory and CPU cycles on your machine. Activity during the test might skew your results.

    Rscript ./benchmark.R http://localhost:8028 reference.png
    
Dots should be printed while it's working, and then it should print "Done" with an elapsed time. That's your measurement.

[chromote]: https://github.com/rstudio/chromote 
[processx]: https://github.com/r-lib/processx