library(leaflet)
library(leafgl)
library(sf)
library(shiny)

set.seed(51)

n <- 1e6
df1 <- data.frame(id = 1:n, x = rnorm(n, 10, 3), y = rnorm(n, 49, 1.8))
pts <- st_as_sf(df1, coords = c("x", "y"), crs = 4326)

ui <- fluidPage(
  # https://stackoverflow.com/a/36471739/3998203
  tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
  leafglOutput('map')
)

server <- function(input, output, session) {
  m <- leaflet() %>%
         addProviderTiles(provider = providers$CartoDB.DarkMatter) %>%
         addGlPoints(data = pts) %>%
         setView(lng = 10.5, lat = 49.5, zoom = 6) %>%
         addLayersControl(overlayGroups = "pts")
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
