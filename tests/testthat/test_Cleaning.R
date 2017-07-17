library(QuakeCoursera)
library(readr)
library(lubridate)
context("Cleaning functions")
raw_NOAA <- read_delim('signif.txt', delim = '\t')

test_that("Clean data is delivered correctly",{
    test_NOAA <- eq_clean_data(raw_NOAA)
    expect_is(test_NOAA, "tbl_df")
    expect_is(test_NOAA$DATE, "Date")
    expect_is(test_NOAA$LATITUDE, "numeric")
    expect_is(test_NOAA$LONGITUDE, "numeric")
    expect_is(test_NOAA$EQ_PRIMARY, "numeric")
    expect_is(test_NOAA$TOTAL_DEATHS, "numeric")
    expect_equal(length(grep(":", test_NOAA$LOCATION_NAME)),0)
})


test_that("eq_good_date is making dates correctly",{
    expect_equal(QuakeCoursera:::eq_good_date(2017,7,1),
                 ymd("2017-07-01"))
})


test_that("eq_location_clean is stripping out the countries and fixing case",{
    expect_failure(expect_match(
        QuakeCoursera:::eq_location_clean("USA: san francisco"),
        ":"
    ))
    expect_equal(QuakeCoursera:::eq_location_clean("USA: sAn fRancisco"),
                 "San Francisco")
})

test_that("title_case is working as advertised",{
    expect_equal(QuakeCoursera:::title_case("this is not title case"),
                 "This Is Not Title Case")
    expect_equal(QuakeCoursera:::title_case("THIS IS NOT TITLE CASE"),
                 "This Is Not Title Case")
})
