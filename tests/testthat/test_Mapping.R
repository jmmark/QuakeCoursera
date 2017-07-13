library(QuakeCoursera)
library(readr)
library(lubridate)
library(ggplot2)
library(dplyr)
library(leaflet)
context("Testing mapping functions")

data(clean_NOAA)

mp <- clean_NOAA %>% filter(year(DATE) >= 2000 & COUNTRY == "MEXICO") %>%
    eq_map(annot_col = "DATE")

test_that("A leaflet object is returned",{
    expect_is(mp, "leaflet")
})

test_that("The html object is built correctly",{
    expect_match(eq_create_label(clean_NOAA)[13],'<br/>')
})
