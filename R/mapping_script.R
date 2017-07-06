# interactive ggmap for assignment
library(leaflet)

eq_map_old <- function(data, annot_col = NULL) {
    lt <- max(min(data$LONGITUDE) - 5, -180)
    rt <- min(max(data$LONGITUDE) + 5, 180)
    bt <- min(data$LATITUDE) - 5
    tp <- max(data$LATITUDE) + 5
    my_box <- c(left = lt, bottom = bt, right = rt, top = tp)
    my_map <- get_stamenmap(bbox = my_box,
                            zoom = 3,
                            maptype = "toner")
}

eq_map <- function(data, annot_col = NULL) {
    mp <- data %>% leaflet() %>%
        addTiles()
    if(!is.null(annot_col)) {
        mp <- mp %>% addCircleMarkers(lng = ~LONGITUDE,
                         lat = ~LATITUDE,
                         radius = ~EQ_PRIMARY,
                         weight = 1,
                         popup = data[[annot_col]])
    } else {
        mp <- mp %>% addCircleMarkers(lng = ~LONGITUDE,
                                      lat = ~LATITUDE,
                                      radius = ~EQ_PRIMARY,
                                      weight = 1)
    }
}

eq_create_label <- function(data) {

    aStr <- paste('<b>Location:</b>',data[['LOCATION_NAME']])
    bStr <- paste('<b>Magnatude:</b>', data[['EQ_PRIMARY']])
    cStr <- paste('<b>Total deaths:</b>', data[['TOTAL_DEATHS']])

    aStr[is.na(data[['LOCATION_NAME']])] <- ''
    bStr[is.na(data[['EQ_PRIMARY']])] <- ''
    cStr[is.na(data[['DEATHS']])] <- ''

    return(paste(aStr, bStr, cStr, sep = '<br/>'))


}

m <- raw_NOAA %>%
    eq_clean_data() %>%
    dplyr::filter(COUNTRY == "MEXICO" & lubridate::year(DATE) >= 2000) %>%
    dplyr::mutate(popup_text = eq_create_label(.)) %>%
    eq_map(annot_col = 'popup_text')
