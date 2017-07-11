
#' Create an interactive map of historical earthquakes
#'
#' Create an interactive map of historical earthquakes using the NOAA earthquake
#' database included with this package.  Earthquakes are plotted as circles with their
#' radii proportional to the magnatude of the earthquakes. Optionally, labels can be passed
#' which will pop up when the earthquake is clicked on the map
#'
#' This function uses of the popular \code{leaflet} package, which creates interactive
#' html maps within R
#'
#' @param data A dataframe with earthquake location columns \code{LATITUDE} and \code{LONGITUDE},
#'   and magnatude column \code{EQ_PRIMARY}.  The included EQ_NOAA dataframe is already
#'   correctly formateed, and is intended to be used with this function
#' @param annot_col The character name of the column in \code{data} containing a character
#'   vector of optional popup text to be shown when the earthquake is clicked.  Defaults to
#'   NULL, where no label is shown
#'
#' @return An html map object, to which further Leaflet objects can be added
#'
#' @examples
#' data('EQ_NOAA') %>%
#'   dplyr::filter(COUNTRY == "MEXICO" & lubridate::year(DATE) >= 2000) %>%
#'   eq_map(annot_col = "DATE")
#' data('EQ_NOAA') %>%
#'   dplyr::filter(COUNTRY == "MEXICO" & lubridate::year(DATE) >= 2000) %>%
#'   dplyr::mutate(popup_text = eq_create_label(.)) %>%
#'   eq_map(annot_col = "DATE")
#'
#' @seealso \pkg{leaflet}
#'
#' @references NOAA earthquake database: \url{https://www.ngdc.noaa.gov/nndc/struts/form?t=101650&s=1&d=1}
#'
#' @export
#' @importFrom dplyr mutate filter
#' @importFrom magrittr "%>%"
#' @import leaflet
#'
eq_map <- function(data, annot_col = NULL) {
    mp <- data %>% leaflet::leaflet() %>%
        leaflet::addTiles()
    if(!is.null(annot_col)) {
        mp <- mp %>% leaflet::addCircleMarkers(lng = ~LONGITUDE,
                         lat = ~LATITUDE,
                         radius = ~EQ_PRIMARY,
                         weight = 1,
                         popup = data[[annot_col]])
    } else {
        mp <- mp %>% leaflet::addCircleMarkers(lng = ~LONGITUDE,
                                      lat = ~LATITUDE,
                                      radius = ~EQ_PRIMARY,
                                      weight = 1)
    }
}

#' Build an html label for earthquakes
#'
#' Create a nicely formatted HTML label for use with \code{\link{eq_map}} showing
#' Location, Magnatude, and Total Deaths.  Missing values are skipped in the created label
#'
#' @param data A dataframe containing location names in column \code{LOCATION_NAME},
#'   earthquake magnatude in column\code{EQ_PRIMARY}, and total deaths caused in column
#'   \code{TOTAL_DEATHS}.  The included EQ_NAA dataframe is already correctly formatted
#'
#' @return A character vector of formatted html strings to label the popups in
#'   \code{\link{eq_map}}
#'
#' @examples
#' eq_create_label(data.frame(
#'        LOCATION_NAME = "Nowhere",
#'        EQ_PRIMARY = 0.0, TOTAL_DEATHS = 0))
#'
#'
#' @seealso \code{\link{eq_map}}, \pkg{leaflet}
#' @export
#'
eq_create_label <- function(data) {
    # stitch together the HTML: bold label
    aStr <- paste('<b>Location:</b>',data[['LOCATION_NAME']])
    bStr <- paste('<b>Magnatude:</b>', data[['EQ_PRIMARY']])
    cStr <- paste('<b>Total deaths:</b>', data[['TOTAL_DEATHS']])

    # pull out entire row for missing data
    aStr[is.na(data[['LOCATION_NAME']])] <- ''
    bStr[is.na(data[['EQ_PRIMARY']])] <- ''
    cStr[is.na(data[['TOTAL_DEATHS']])] <- ''

    # assemble with line breaks
    return(paste(aStr, bStr, cStr, sep = '<br/>'))


}

