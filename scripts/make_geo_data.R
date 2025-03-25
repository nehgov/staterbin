## -----------------------------------------------------------------------------
##
## [ PROJ ] staterbin
## [ FILE ] make_geo_data.R
## [ AUTH ] Benjamin Skinner; bskinner@neh.gov
## [ INIT ] 20 March 2025
##
## -----------------------------------------------------------------------------

## libraries
## (also requires sf, geojsonio, and crosswalkr are installed)
libs <- c("tidyverse")
sapply(libs, require, character.only = TRUE)

## paths
args <- commandArgs(trailingOnly = TRUE)
root <- ifelse(length(args) == 0, file.path(".."), args)
geo_dir <- file.path(root, "geo")
scr_dir <- file.path(root, "scripts")

## -----------------------------------------------------------------------------
## functions
## -----------------------------------------------------------------------------

## function to create rounded corner squares of a specific size
##
## The outer_side is the length of the main square, representing the limits of
## the final size. The corner radius is the size of the radius of the four
## circles that are tangent to the outer circle in the corners. The radius is
## the line that extends from the corner of an inner square / center point of
## the circle to the edge (tangent) of the outer square.
##
## A larger corner radius value will make the corners more rounded.

rsquare_from_point <- function(sfpoint, outer_side = 1,
                               corner_radius_frac = 1/3) {
  a <- outer_side
  r <- a * corner_radius_frac
  x <- sf::st_coordinates(sfpoint)[,1]
  y <- sf::st_coordinates(sfpoint)[,2]
  pol <- vector("list", length(x))
  for (i in 1:length(pol)) {
    ## make circle centroids (corners of inner square)
    ul <- c(x[i] - a/2 + r, y[i] + a/2 - r)
    ur <- c(x[i] + a/2 - r, y[i] + a/2 - r)
    lr <- c(x[i] + a/2 - r, y[i] - a/2 + r)
    ll <- c(x[i] - a/2 + r, y[i] - a/2 + r)
    ## make circle tangent points (t := top; b := bottom)
    tul <- c(ul + c(0,r))
    tur <- c(ur + c(0,r))
    rur <- c(ur + c(r,0))
    rlr <- c(lr + c(r,0))
    blr <- c(lr - c(0,r))
    bll <- c(ll - c(0,r))
    lll <- c(ll - c(r,0))
    lul <- c(ul - c(r,0))
    ## make circles
    ulc <- sf::st_buffer(sf::st_point(ul), r)
    urc <- sf::st_buffer(sf::st_point(ur), r)
    lrc <- sf::st_buffer(sf::st_point(lr), r)
    llc <- sf::st_buffer(sf::st_point(ll), r)
    ## make polygon from strings
    inner_hex_str <- list(rbind(tul, tur, rur, rlr, blr, bll, lll, lul, tul))
    hex <- sf::st_polygon(inner_hex_str)
    ## join
    out <- purrr::reduce(list(hex, ulc, urc, lrc, llc), sf::st_union)
    pol[[i]] <- sf::st_cast(out, "POLYGON")
  }
  return(sf::st_sfc(pol))
}

## -----------------------------------------------------------------------------
## point data
## -----------------------------------------------------------------------------

centroids <- tibble(stabbr = c("AL", "AK", "AZ", "AR", "CA", "CO",
                               "CT", "DC", "DE", "FL", "GA", "HI",
                               "ID", "IL", "IN", "IA", "KS", "KY",
                               "LA", "ME", "MD", "MA", "MI", "MN",
                               "MS", "MO", "MT", "NE", "NV", "NH",
                               "NJ", "NM", "NY", "NC", "ND", "OH",
                               "OK", "OR", "PA", "RI", "SC", "SD",
                               "TN", "TX", "UT", "VT", "VA", "WA",
                               "WV", "WI", "WY", "PR", "VI", "AS",
                               "GU", "MP"),
                    x = c(9L, 2L, 4L, 7L, 3L, 5L, 12L, 11L, 12L,
                          11L, 10L, 2L, 4L, 8L, 8L, 7L, 6L, 8L, 7L,
                          13L, 11L, 12L, 9L, 7L, 8L, 7L, 5L, 6L,
                          4L, 13L, 11L, 5L, 11L, 9L, 6L, 9L, 6L,
                          3L, 10L, 13L, 10L, 6L, 8L, 6L, 4L, 12L,
                          10L, 3L, 9L, 8L, 5L, 13L, 13L, 1L, 1L,
                          1L),
                    y = c(2L, 8L, 3L, 3L, 4L, 4L, 5L, 3L, 4L, 1L,
                          2L, 1L, 6L, 6L, 5L, 5L, 3L, 4L, 2L, 8L,
                          4L, 6L, 6L, 6L, 2L, 4L, 6L, 4L, 5L, 7L,
                          5L, 3L, 6L, 3L, 6L, 5L, 2L, 5L, 5L, 5L,
                          3L, 5L, 3L, 1L, 4L, 7L, 4L, 6L, 4L, 7L,
                          5L, 2L, 1L, 1L, 2L, 3L)) |>
  sf::st_as_sf(coords = c("x", "y")) |>
  left_join(crosswalkr::sttercrosswalk |>
              select(stabbr, stfips)) |>
  arrange(stfips) |>
  mutate(id = row_number()) |>
  select(id, stfips, stabbr, geometry)

## -----------------------------------------------------------------------------
## make map
## -----------------------------------------------------------------------------

sqdf <- centroids |>
  mutate(geometry = rsquare_from_point(geometry, 0.9, 0.9/3))

## -----------------------------------------------------------------------------
## write
## -----------------------------------------------------------------------------

## geojson (lightweight)
sf::st_write(sqdf, dsn = file.path(geo_dir, "staterbin.geojson"),
             delete_dsn = TRUE, layer = "staterbin", append = FALSE)

## topojson (very lightweight)
geojsonio::topojson_write(sqdf, geometry = "polygon",
                          file = file.path(geo_dir, "staterbin.topojson"),
                          quantization = 1e4,
                          object_name = "staterbin")

## -----------------------------------------------------------------------------
## end script
################################################################################
