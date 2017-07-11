#' Combine the year, month, and day columns in the NOAA earthquake data into a single date
#'
#' Individual year, month, and day columns make filtering the data difficult.  This function
#' combines them into a single date object.  Only to be used internally to the package.
#'
#' @param yr integer of the year the earthquake occurred.  Negative numbers indicate BCE
#' @param mnth integer of the month (1-12)
#' @param dy integer of the day of the month
#'
#' @return a single date object
#'
#' @details Note that R date objects do not handle BCE dates well.  For example, they assume
#'  a year 0 exists, when in fact dates go from 1 BCE to 1 CE, with no 0 in between.  Therefore,
#'  date differences between BCE and CE will not be correct.  However, date ranges should still be
#'  accurately reflected.
#'
#'  Not all entries have date details beyond year, in that case the date is
#'  January 1 of the appropriate year
#'
#' @examples
#' eq_good_date(2017, 7, 1)
#'
#' @importFrom lubridate ymd origin
#' @importFrom stringr str_pad
eq_good_date <- function(yr, mnth, dy) {

    # create a BCE mask
    BCE <- (yr < 0)

    # no year values are ever missing, so just pad to 4, eliminating the neg
    yr_str <- stringr::str_pad(abs(yr), 4, "left","0")

    # assume missing month or day are just 1
    mnth[is.na(mnth)] <- 1
    dy[is.na(dy)] <- 1

    # pad month and day to 2 digits
    mnth_str <- stringr::str_pad(mnth, 2, "left","0")
    dy_str <- stringr::str_pad(dy, 2, "left","0")

    # handle the easy case first, CE dates
    good_dates <- (lubridate::ymd(paste(yr_str, mnth_str, dy_str, sep = "-")))


    # now, unfortunately, gotta deal with BCE conversion . . .
    # so first, R doesn't handle BCE dates well.  For example--there is no
    # such thing as year 0, but R has one in its Date class.  In addition,
    # need to parse through manual numeric conversion

    # method is this--find fictional year 0 in numeric terms, find
    # CE equivalent date in numeric terms, subtract the second from the first,
    # and return the resulting date class object.  Date math will still need to be
    # adjusted should it be required later--it's either this or have the date appear strange

    orig <- as.numeric(lubridate::ymd("0000-01-01"))
    CE_equivalent <- as.numeric(good_dates)
    good_dates[BCE] <- as.Date(orig - (CE_equivalent[BCE] - orig), origin = lubridate::origin)
    return(good_dates)
}

#' Clean up location names in the NOAA earthquake database
#'
#' The LOCATION_NAME column in the NOAA database starts out life including
#' the country name, as well as other formatting issues.  Use this function
#' to strip out and reformat the region for convenient labeleing
#'
#' @param loc_nm String containing original location name from the NOAA earthquake file
#'
#' @return A string removing the country name, fixing spacing, and converting
#' to Title Case
#'
#' @examples
#' eq_location_clean("USA: san francisco")
eq_location_clean <- function(loc_nm) {
    # remove the country and colon, convert to title case
    clean_name <- gsub("^.*:\\s*","",loc_nm)
    clean_name <- gsub(",([[:alpha:]])",", \\1", clean_name)

    clean_name <- tolower(clean_name)
    clean_name <- sapply(clean_name, title_case, USE.NAMES = FALSE)
    return(clean_name)
}

#' Convert a string to Title Case
#'
#' Have 'a string like this'? This function turns it into 'A String Like This'
#'
#' @param char_vect A character vector of the string to be converted to title case
#'
#' @return A character vector that is now Title Case
#'
#' @examples
#' title_case('this is not title case')
#' title_case('THIS IS NOT TITLE CASE EITHER')
title_case <- function(char_vect) {
    # convert to title case, handling parentheses
    words <- strsplit(char_vect, " ")[[1]]
    is_paren <- substring(words, 1,1) == "("
    front <- toupper(substring(words,1,1))
    front[is_paren] <- paste0("(", toupper(substring(words[is_paren],2,2)))
    back <- tolower(substring(words, 2))
    back[is_paren] <- tolower(substring(words[is_paren],3))
    return(paste0(front, back, collapse = " "))

}

#' Clean the raw NOAA earthquake data to interface well with the other functions
#' in this package
#'
#' The NOAA earthquake database that is included with this package is already
#' clean and ready to use with the other functions.  However, that data is frozen
#' as of July 1, 2017.  More up-to-date data can be cleaned up using this function
#'
#' @param raw_data A data frame containing the raw NOAA earthquake data.  The
#' function assumes the data has been read in using \code{readr::read_delim}
#' with the option \code{delim = '\\t'}
#'
#' @return A data frame of cleaned data, ready to be used in the visualization
#' functions included in this package
#'
#' @details
#' The raw data is available \href{https://www.ngdc.noaa.gov/nndc/struts/form?t=101650&s=1&d=1}{here}
#' The data cleanup does the following:
#' 1. create DATE, and make sure it is date class
#' 2. make sure LONGITUDE and LATTITUDE are numeric; drop NA lat/lon
#' 3. clean location name
#' 4. make sure magnatude measures are numeric
#' 5. make sure deaths are numeric
#'
#' @examples
#' # assumes the raw NOAA Significant Earthquake Database is available in
#' # your working directory as 'raw_NOAA.txt'
#' clean_NOAA <- eq_clean_data(readr::read_delim('raw_NOAA.txt', delim = '\\t'))
#'
#' @export
#' @importFrom dplyr mutate filter
eq_clean_data <- function(raw_data) {
    # need to do the following:
    # 1. create DATE, and make sure it is date class
    # 2. make sure LONGITUDE and LATTITUDE are numeric; drop NA lat/lon
    # 3. clean location name
    # 4. make sure magnatude measures are numeric
    # 5. make sure deaths are numeric
    clean_data <- raw_data %>%
        dplyr::mutate(DATE = eq_good_date(YEAR, MONTH, DAY)) %>%
        dplyr::filter(!is.na(LATITUDE) & !is.na(LONGITUDE)) %>%
        dplyr::mutate(LONGITUDE = as.numeric(LONGITUDE), LATITUDE = as.numeric(LATITUDE)) %>%
        dplyr::mutate(LOCATION_NAME = eq_location_clean(LOCATION_NAME)) %>%
        dplyr::mutate(EQ_PRIMARY = as.numeric(EQ_PRIMARY),
               EQ_MAG_MW = as.numeric(EQ_MAG_MW),
               EQ_MAG_MS = as.numeric(EQ_MAG_MS),
               EQ_MAG_MB = as.numeric(EQ_MAG_MB),
               EQ_MAG_ML = as.numeric(EQ_MAG_ML),
               EQ_MAG_MFA = as.numeric(EQ_MAG_MFA),
               EQ_MAG_UNK = as.numeric(EQ_MAG_UNK),
               DEATHS = as.numeric(DEATHS),
               TOTAL_DEATHS = as.numeric(TOTAL_DEATHS))

    return(clean_data)
}
