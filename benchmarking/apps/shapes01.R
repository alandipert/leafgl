library(leaflet)
library(leafgl)
library(sf)
library(colourvalues)
library(shiny)

# Use interactively to creat .rda file
makeData <- function(
    n = 1e4,
    file = sprintf("ch_landuse_%s.rda", formatC(n, format = "e", digits = 0))
  ) {
  # via https://download.geofabrik.de/europe/switzerland.html
  ch_lu <- st_read("~/switzerland-latest-free.shp/gis_osm_landuse_a_free_1.shp")
  ch_lu <- if (is.na(n)) ch_lu else ch_lu[1:n,]
  ch_lu <- ch_lu[, 3] # don't handle NAs so far
  ch_lu <- sf::st_cast(ch_lu, "POLYGON")
  cols <- colour_values_rgb(ch_lu$fclass, include_alpha = FALSE) / 255
  data <- list(data = ch_lu, cols = cols)
  save("data", file = file, compress = TRUE)
}

ui <- fluidPage(
  leafglOutput('map')
)

server <- function(input, output, session) {
  #load("ch_landuse_1e+04.rda")
  load("ch_landuse_1e+05.rda")
  cat("Finished loading data\n")
  m <- leaflet() %>%
    addProviderTiles(provider = providers$CartoDB.DarkMatter) %>%
    addGlPolygons(data = data$data, color = data$cols, popup = "fclass") %>%
    setView(lng = 8.3, lat = 46.85, zoom = 9)
  cat("Built map\n")
  output$map <- renderLeaflet(m)
}

host <- "127.0.0.1"
port <- 5656

args <- commandArgs(trailingOnly=TRUE)

if (length(args) == 1) {
  port <- as.numeric(args[[1]])
} else if (length(args) == 2) {
  host <- args[[1]]
  port <- as.numeric(args[[2]])
} else {
  stop("Missing host/port")
}

shinyApp(ui, server, options = list(host = host, port = port))
