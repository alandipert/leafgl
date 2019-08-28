# leafgl benchmarking tools

This directory contains example applications and code for conducting Leaflet and leafgl performance measurements. In particular, we are interested in measuring the amount of time it takes to render various large data sets: the time elapsed between when the browser first receives the Leaflet/leafgl markup and code, to when the user sees rendering has completed. It is our goal as we add features to leafgl to weigh any new features or changes against their performance impact, since our #1 feature *is* performance.

## Measurement methodology

Our methodology is simple: given a test app, we load up the app and determine how long it takes for a child to appear in the DOM element containing the Leaflet map. Experimentation has shown that this moment corresponds to when WebGL-rendered graphics appear on the page.

This is done using [chromote][chromote], an R package that allows driving a browser and doing this kind of thing with R code.

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
    
### Perform a measurement

You can use the `benchmark.R` tool to measure rendering time.

> Note: Before proceeding, you should close any unneeded applications to free up memory and CPU cycles on your machine. Activity during the test might skew your results.

    Rscript ./benchmark.R http://localhost:8028 map
    
`map` here should correspond to the id you use for your `leafglOutput()` in your Shiny app.
    
Your measurement will appear in seconds and the program will exit.

[chromote]: https://github.com/rstudio/chromote 
[processx]: https://github.com/r-lib/processx