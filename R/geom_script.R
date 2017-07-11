# file for creating the quake geoms:
# 1 geom: timeline plot of earthquakes showing dots for each one within xmin and xmax days
# 2 geom: annotations above timeline labeling the earthquakes
# use stat to subset the data or the x largest earthquakes as required

#library(ggplot2)
#library(grid)


#' A geom for adding a timeline plot
#'
#' This geom plots a timeline, with circles showing the dates when the event occurred.
#' It is intended for the purposes of graphically exploring the NOAA Significant
#' Earthquake Database (included in this package), but can show any data with a column
#' of valid \code{date} objects
#'
#' @section Aesthetics:
#' \code{geom_timeline} understands the following aesthetics (required are in bold):
#' \itemize{
#'   \item \storng{\code{x}}
#'   \item \code{y}
#'   \item \code{color}
#'   \item \code{fill}
#'   \item \code{size}
#'   \item \code{alpha}
#' }
#'
#' @inheritParams ggplot2::geom_point
#'
#' @param x_min (optional) A Date object of the earliest data to be plotted
#' @param x_max (optional) A Date object of the latest data to be plotted
#' @param stat (optional) Stat Override the defailt Stat transformation of 'timeline'
#'
geom_timeline <- function(mapping = NULL, data = NULL, stat = 'timeline',
                          position = 'identity', na.rm = FALSE, show.legend = NA,
                          inherit.aes = TRUE, x_min = NULL, x_max = NULL, ...) {
    ggplot2::layer(
        geom = GeomTimeline, mapping = mapping, data = data, stat = stat,
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(na.rm = na.rm, x_min = x_min, x_max = x_max, ...)
    )
}

# allow for circle grob to be passed easily to the legend
my_draw_key_circle <- function(data, params, size) {
    print(data)
    grid::circleGrob(r = data$size/18,
                     gp = gpar(
                         col = data$color,
                         fill = alpha(data$fill, data$alpha)
                     ))
}

GeomTimeline <- ggplot2::ggproto('GeomTimeline', Geom,
        required_aes = c('x'),
        default_aes = aes(y = NULL, color = 'black',
                          fill = 'black', size = 5,, alpha = 0.3),
        draw_key = my_draw_key_circle,
        draw_group = function(data, panel_params, coord) {
            coords <- coord$transform(data, panel_params)
            debug_me <<- coords
            grid::circleGrob(
                coords$x,
                coords$y,
                r = coords$size / 200,
                gp = grid::gpar(
                    col = coords$colour,
                    fill = coords$fill,
                    alpha = coords$alpha

                )
            )
        }
)

geom_timeline_label <- function(mapping = NULL, data = NULL, stat = 'timeline_label',
                          position = 'identity', na.rm = FALSE, show.legend = NA,
                          inherit.aes = TRUE, x_min = NULL, x_max = NULL,
                          top_x_mag = NULL, ...) {
    ggplot2::layer(
        geom = GeomTimelineLabel, mapping = mapping, data = data, stat = stat,
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(na.rm = na.rm, top_x_mag = top_x_mag,
                      x_min = x_min, x_max = x_max, ...)
    )
}

GeomTimelineLabel <- ggplot2::ggproto('GeomTimelineLabel', Geom,
             required_aes = c('x', 'label'),
             default_aes = aes(y = NULL, magnitude = NULL, color = 'black',
                               lty = 1, lwd = 1),
             draw_key = draw_key_abline,
             draw_group = function(data, panel_params, coord) {
                 coords <- coord$transform(data, panel_params)
                 debug_me <<- coords
                 grid::gList(
                     grid::segmentsGrob(
                         coords$x, coords$y,
                         coords$x, coords$y + .15,
                         gp = grid::gpar(
                             col = coords$colour,
                             lty = coords$lty,
                             lwd = coords$lwd

                        )
                    ),
                    grid::textGrob(
                        coords$label,
                        coords$x,
                        coords$y + .15,
                        just = c('left', 'center'),
                        rot = 45,
                        gp = grid::gpar(
                            fontsize = grid::unit(8, "char")
                        )
                    )

                )
             }
)


stat_timeline <- function(mapping = NULL, data = NULL, geom = 'timeline',
                          position = 'identity', na.rm = FALSE, show.legend = NA,
                          inherit.aes = TRUE, x_min, x_max, ...) {
    ggplot2::layer(
        stat = StatTimeline, mapping = mapping, data = data, stat = stat,
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(x_min = x_min, x_max = x_max, na.rm = na.rm, ...)
    )
}

# all this stat does is filter the data so that x is between x_min and x_max
StatTimeline <- ggplot2::ggproto('StatTimeline',Stat,
        required_aes = c('x'),
        compute_group = function(data, scales, params, x_min, x_max) {
            if(!('y' %in% names(data))) {
                data$y <- 1
            }
            # print(names(data))
            return(data[data$x >= x_min & data$x <= x_max,])
        }
)

stat_timeline_label <- function(mapping = NULL, data = NULL, geom = 'timeline_label',
                          position = 'identity', na.rm = FALSE, show.legend = NA,
                          inherit.aes = TRUE, top_x_mag = NULL,
                          x_min = NULL, x_max = NULL, ...) {
    ggplot2::layer(
        stat = StatTimelineLabel, mapping = mapping, data = data, stat = stat,
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(top_x_mag = top_x_mag,
                      x_min = x_min, x_max = x_max, na.rm = na.rm, ...)
    )
}

# all this stat does is filter the data so that x is between x_min and x_max
StatTimelineLabel <- ggplot2::ggproto('StatTimelineLabel',Stat,
     required_aes = c('x'),
     compute_group = function(data, scales, params, top_x_mag, x_min, x_max) {
         if(!('y' %in% names(data))) {
             data$y <- 1
         }
         if(!is.null(x_min)) {
             data <- data[data$x >=x_min, ]
         }
         if(!is.null(x_max)) {
             data <- data[data$x <= x_max, ]
         }

         if(is.null(top_x_mag) | !('magnitude' %in% names(data))){
             return(data)
         } else {
             data <- data[order(data$magnitude, decreasing = TRUE),][1:top_x_mag,]
             return(data)
         }
     }
)
