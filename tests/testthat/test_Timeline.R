library(QuakeCoursera)
library(readr)
library(lubridate)
library(ggplot2)
library(dplyr)

context("Timeline functions")
data(clean_NOAA)

xmin <- ymd("2000-01-01")
xmax <- ymd("2017-07-01")

plt <- ggplot(clean_NOAA[clean_NOAA$COUNTRY=="USA" | clean_NOAA$COUNTRY=="CANADA",],
               aes(x = DATE, y = COUNTRY)) +
    geom_timeline(x_min = xmin, x_max = xmax, aes(size = EQ_PRIMARY))

plt2 <- plt + geom_timeline_label(aes(label = LOCATION_NAME, magnatude = EQ_PRIMARY),
                                  x_min = xmin, x_max = xmax, top_x_mag = 5)


test_that("Base geom_timeline, no labels",{
    expect_is(plt, "ggplot")
    # note that this tests the stat as well, this is where data is filtered
    expect_equal(min(year(as.Date(layer_data(plt)$x, origin = origin))), 2000)
})


test_that("Labeled using geom_timeline_label",{
    expect_is(plt2, "ggplot")
    # note that this tests the stat as well, this is where data is filtered
    expect_lte(nrow(layer_data(plt2)), 2000)
})
