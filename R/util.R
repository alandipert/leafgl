serializeColor <- function(hexColor) {
  stopifnot(is.character(hexColor) && length(hexColor) == 1)
  gsub("^#(.)(.)(.)$", "#\\1\\1\\2\\2\\3\\3", hexColor) %>%
    { col2rgb(.)[,1] } %>%
    stats::setNames(c("r", "g", "b")) %>%
    as.list()
}

