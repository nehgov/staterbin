## -----------------------------------------------------------------------------
##
## [ PROJ ] stateterbin
## [ FILE ] make_data.R
## [ AUTH ] Benjamin Skinner; bskinner@neh.gov
## [ INIT ] 20 March 2025
##
## -----------------------------------------------------------------------------

## libraries
libs <- c("tidyverse", "sf")
sapply(libs, require, character.only = TRUE)

## paths
args <- commandArgs(trailingOnly = TRUE)
root <- ifelse(length(args) == 0, file.path(".."), args)
dat_dir <- file.path(root, "data")
fig_dir <- file.path(root, "figures")
geo_dir <- file.path(root, "geo")
scr_dir <- file.path(root, "scripts")

## -----------------------------------------------------------------------------
## functions
## -----------------------------------------------------------------------------

## function to create rounded corner squares of a specific size

rsquare_from_point <- function(sfpoint, outer_side = 1, corner_radius = 1/10) {
  a <- outer_side
  r <- corner_radius
  x <- st_coordinates(sfpoint)[,1]
  y <- st_coordinates(sfpoint)[,2]
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
    ulc <- st_buffer(st_point(ul), r)
    urc <- st_buffer(st_point(ur), r)
    lrc <- st_buffer(st_point(lr), r)
    llc <- st_buffer(st_point(ll), r)
    ## make polygon from strings
    hex <- st_polygon(list(rbind(tul, tur, rur, rlr, blr, bll, lll, lul, tul)))
    ## join
    out <- Reduce("st_union", list(hex, ulc, urc, lrc, llc))
    pol[[i]] <- st_cast(out, "POLYGON")
  }
  return(st_sfc(pol))
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
  st_as_sf(coords = c("x", "y"))

## -----------------------------------------------------------------------------
## make map
## -----------------------------------------------------------------------------

sqdf <- centroids |>
  mutate(geometry = rsquare_from_point(geometry, 0.9, .25))

ggplot(sqdf) + geom_sf()

## -----------------------------------------------------------------------------
## write
## -----------------------------------------------------------------------------

st_write(sqdf, dsn = file.path(geo_dir, "staterbin.geojson"),
         layer = "staterbin.geojson")

## -----------------------------------------------------------------------------
## end script
################################################################################
