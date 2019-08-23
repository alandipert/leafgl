library(mapview)
library(leaflet)
library(leafgl)
library(sf)
library(shiny)

n <- 1e4
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
         addMouseCoordinates() %>%
         setView(lng = 10.5, lat = 49.5, zoom = 6) %>%
         addLayersControl(overlayGroups = "pts")

  output$map <- renderLeaflet(m)
}

shinyApp(ui, server, options = list(port = 8028))
