# Load and clean up the NOAA data, and put .rdata into the data directory

# need devtools, dplyr, readr

library(devtools)
library(dplyr)
library(lubridate)
library(readr)
library(stringr)

# read in the raw data
raw_NOAA <- readr::read_delim('./data-raw/signif.txt',delim = '\t')

# a function for converting the dates
# needs to handle BCE dates (negative), missing months, missing years
eq_good_date <- function(yr, mnth, dy) {
    # first set BCE flag
    BCE <- FALSE
    if(yr < 0) {
        BCE <- TRUE
    }

    # no year values are ever missing, so just pad to 4, eliminating the neg
    yr_str <- stringr::str_pad(abs(yr), 4, "left","0")

    # assume missing month or day are just 1
    if(is.na(mnth)) {
        mnth <- 1
    }

    if(is.na(dy)) {
        dy <- 1
    }

    # pad month and day to 2 digits
    mnth_str <- stringr::str_pad(mnth, 2, "left","0")
    dy_str <- stringr::str_pad(dy, 2, "left","0")

    # handle the easy case first, CE dates
    if(!BCE) {
        return(lubridate::ymd(paste(yr_str, mnth_str, dy_str, sep = "-")))
    }

    # oh no, fell through, gotta deal with BCE conversion . . .
    # so first, R doesn't handle BCE dates well.  For example--there is no
    # such thing as year 0, but R has one in its Date class.  In addition,
    # need to parse through manual numeric conversion

    # method is this--find fictional year 0 in numeric terms, find
    # CE equivalent date in numeric terms, subtract the second from the first,
    # and return the resulting date class object.  Date math will still need to be
    # adjusted should it be required later--it's either this or have the date appear strange

    origin <- as.numeric(lubridate::ymd("0000-01-01"))
    CE_equivalent <- as.numeric(lubridate::ymd(paste(yr_str, mnth_str, dy_str, sep = "-")))
    return(as.Date(origin - CE_equivalent, origin = lubridate::origin))
}

# location name cleaning function
eq_location_clean <- function(loc_nm) {
    # remove the country and colon, convert to title case
    clean_name <- gsub("^.*:\\s*","",loc_nm)
    clean_name <- gsub(",([[:alpha:]])",", \\1", clean_name)

    clean_name <- tolower(clean_name)
    clean_name <- sapply(clean_name, title_case, USE.NAMES = FALSE)
    return(clean_name)
}

title_case <- function(char_vect) {
    # convert to title case, handling parentheses
    words <- strsplit(char_vect, " ")[[1]]
    is_paren <- substring(words, 1,1) == "("
    front <- toupper(substring(words,1,1))
    front[is_paren] <- paste0("(", toupper(substring(words[is_paren],2,2)))
    back <- substring(words, 2)
    back[is_paren] <- substring(words[is_paren],3)
    return(paste0(front, back, collapse = " "))

}

# overall data cleaning function
eq_clean_data <- function(raw_data) {
    # need to do the following:
    # 1. create DATE, and make sure it is date class
    # 2. make sure LONGITUDE and LATTITUDE are numeric; drop NA lat/lon
    # 3. clean location name
    clean_data <- raw_data %>%
        mutate(DATE = eq_good_date(YEAR, MONTH, DAY)) %>%
        filter(!is.na(LATITUDE) & !is.na(LONGITUDE)) %>%
        mutate(LONGITUDE = as.numeric(LONGITUDE), LATITUDE = as.numeric(LATITUDE)) %>%
        mutate(LOCATION_NAME = eq_location_clean(LOCATION_NAME))

    return(clean_data)
}
