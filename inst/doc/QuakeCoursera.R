## ----echo = FALSE, messages = FALSE--------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
options(tibble.print_min = 4L, tibble.print_max = 4L)
library(QuakeCursera)
library(ggplot2)
library(dplyr)
library(readr)
library(leaflet)

## ------------------------------------------------------------------------
data('clean_NOAA')

## ----eval = FALSE--------------------------------------------------------
#  clean_NOAA <- readr::read_delim('signif.txt',delim = '\t') %>%
#      eq_clean_data()

## ------------------------------------------------------------------------
QuakeCoursera:::eq_good_date(2017, 7, 11)
QuakeCoursera:::eq_good_date(-2000, 1, 1)

## ------------------------------------------------------------------------
QuakeCoursera:::eq_location_clean("USA:  sAn francisco")

## ------------------------------------------------------------------------
QuakeCoursera:::title_case('this is now title case')
QuakeCoursera:::title_case('THIS IS NOW TITLE CASE TOO')

