## -----------------------------------------------------------------------------
##
## [ PROJ ] staterbin
## [ FILE ] make_example_figures.R
## [ AUTH ] Benjamin Skinner; bskinner@neh.gov
## [ INIT ] 25 March 2025
##
## -----------------------------------------------------------------------------

## libraries (also requires sf and viridis be installed)
libs <- c("tidyverse")
sapply(libs, require, character.only = TRUE)

## paths
args <- commandArgs(trailingOnly = TRUE)
root <- ifelse(length(args) == 0, file.path(".."), args)
fig_dir <- file.path(root, "figures")
geo_dir <- file.path(root, "geo")
scr_dir <- file.path(root, "scripts")

## -----------------------------------------------------------------------------
## read in data
## -----------------------------------------------------------------------------

## geojson file
dfg <- sf::st_read(file.path(geo_dir, "staterbin.geojson"))

## topojson file
dft <- sf::st_read(file.path(geo_dir, "staterbin.topojson"))

## -----------------------------------------------------------------------------
## create fake data
## -----------------------------------------------------------------------------

dfg <- dfg |>
  mutate(bin = sample(1:5, nrow(dfg), replace = TRUE))

dft <- dft |>
  mutate(bin = sample(1:5, nrow(dft), replace = TRUE))

## -----------------------------------------------------------------------------
## create plots
## -----------------------------------------------------------------------------

## geojson
gg <- dfg |>
  ggplot(aes(label = stabbr)) +
  geom_sf(aes(fill = as_factor(bin))) +
  geom_sf_text() +
  viridis::scale_fill_viridis("", option = "A", discrete = TRUE, alpha = 0.5) +
  theme_void()

## topojson
gt <- dft |>
  ggplot(aes(label = stabbr)) +
  geom_sf(aes(fill = as_factor(bin))) +
  geom_sf_text() +
  viridis::scale_fill_viridis("", option = "A", discrete = TRUE, alpha = 0.5) +
  theme_void()

## -----------------------------------------------------------------------------
## save plots
## -----------------------------------------------------------------------------

## geojson
ggsave(file.path(fig_dir, "geojson_figure.png"),
       gg,
       width = 16,
       height = 9,
       units = "in",
       dpi = "retina",
       bg = "white")

## topojson
ggsave(file.path(fig_dir, "topojson_figure.png"),
       gt,
       width = 16,
       height = 9,
       units = "in",
       dpi = "retina",
       bg = "white")

## -----------------------------------------------------------------------------
## end script
################################################################################
