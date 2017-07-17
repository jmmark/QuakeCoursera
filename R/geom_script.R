
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
#'   \item \strong{\code{x}}
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
#' @param stat (optional) Stat Override the default Stat transformation of 'timeline'
#'
#'
#' @details This is a general purpose timeline plotting geom, particularly tuned to
#'   the NOAA Significant Earthquake Database included with this package.  Each event
#'   with an associated date will be plotted as a circle on the timeline, so long as
#'   the event lies between \code{x_min} and \code{x_max}.
#'
#'   Additional optional aesthetics make the geom much more useful.  An optional
#'   \code{y} aesthetic allows the comparison of different timelines over the same range.
#'   Size can show how big an event was (such as an earthquake), and color/fill and alpha
#'   can convey yet more information
#'
#' @examples
#' data('clean_NOAA')
#' NOAA <- clean_NOAA
#' plot_NOAA <- NOAA[NOAA$COUNTRY=="USA" | NOAA$COUNTRY=="CANADA",]
#' xmin <- lubridate::ymd("2010-01-01")
#' xmax <- lubridate::ymd("2017-07-01")
#' plt <- ggplot2::ggplot(data = plot_NOAA, ggplot2::aes(x = DATE, y = COUNTRY)) +
#'   geom_timeline(ggplot2::aes(size = EQ_PRIMARY), x_min = xmin, x_max = xmax) +
#'   ggplot2::theme_minimal()
#' print(plt)
#'
#' @export
#' @import ggplot2
#' @importFrom lubridate ymd
geom_timeline <- function(mapping = NULL, data = NULL, stat = 'timeline',
                          position = 'identity', na.rm = FALSE, show.legend = NA,
                          inherit.aes = TRUE, x_min = NULL, x_max = NULL, ...) {
    ggplot2::layer(
        geom = GeomTimeline, mapping = mapping, data = data, stat = stat,
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(na.rm = na.rm, x_min = x_min, x_max = x_max, ...)
    )
}

#' Allow geom_timeline to draw a useful legend
#'
#' This function is completely internal to geom_timeline, and
#' is not of use elsewhere
#'
#' @param data The dataframe passed to the drawing key
#' @param params The params passed from the geom
#' @param size The size of the legend key
#'
#' @examples
#' # no examples appropriate, this function is completely internal to geom_timeline
my_draw_key_circle <- function(data, params, size) {
    grid::circleGrob(r = data$size/18,

                     gp = grid::gpar(
                         col = data$color,
                         fill = alpha(data$fill, data$alpha),
                         lwd = 0.1
                     ))
}

#' Create the ggproto object for geom_timeline
#'
#' This function creates the ggproto Geom object to plot the necessary grid grob for
#' \code{geom_timeline}
#'
#' @examples
#' data('clean_NOAA')
#' NOAA <- clean_NOAA
#' plot_NOAA <- NOAA[NOAA$COUNTRY=="USA" | NOAA$COUNTRY=="CANADA",]
#' xmin <- lubridate::ymd("2010-01-01")
#' xmax <- lubridate::ymd("2017-07-01")
#' plt <- ggplot2::ggplot(data = plot_NOAA, ggplot2::aes(x = DATE, y = COUNTRY)) +
#'   geom_timeline(ggplot2::aes(size = EQ_PRIMARY), x_min = xmin, x_max = xmax) +
#'   ggplot2::theme_minimal()
#' print(plt)
#'
#' @import ggplot2 grid
#' @importFrom lubridate ymd
GeomTimeline <- ggplot2::ggproto('GeomTimeline', ggplot2::Geom,
        required_aes = c('x'),
        default_aes = ggplot2::aes(y = NULL, color = 'black',
                          fill = 'black', size = 5, alpha = 0.3),
        draw_key = my_draw_key_circle,
        draw_group = function(data, panel_params, coord) {
            coords <- coord$transform(data, panel_params)
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

#' A geom for labeling the timeline plot from \code{\link{geom_timeline}}
#'
#' This geom labels the timeline created from \code{\link{geom_timeline}}.  It draws
#' vertical lines up from the points on the timeline, with labels for the particular event.
#' You have the option of only labeleing the top \code{x} number of events sorted by a given
#' amount
#'
#' @section Aesthetics:
#' \code{geom_timeline} understands the following aesthetics (required are in bold):
#' \itemize{
#'   \item \strong{\code{x}}
#'   \item \strong{\code{label}} The labels to be added
#'   \item \code{y}
#'   \item \code{magnatude} The feature whose value determines the top \code{x} to be labeled
#'   \item \code{color}
#'   \item \code{fill}
#'   \item \code{size}
#'   \item \code{alpha}
#' }
#'
#' @inheritParams ggplot2::geom_point
#' @inheritParams geom_timeline
#'
#' @param top_x_mag The top \code{x} labels to plot.  For example, if earthquake
#'   occurrences are being plotted, and you only want to label the top 5, pass some
#'   measure of magnatude in the aes slot and pass 5 here
#'
#'
#'
#' @examples
#' data('clean_NOAA')
#' NOAA <- clean_NOAA
#' plot_NOAA <- NOAA[NOAA$COUNTRY=="USA" | NOAA$COUNTRY=="CANADA",]
#' xmin <- lubridate::ymd("2010-01-01")
#' xmax <- lubridate::ymd("2017-07-01")
#' plt <- ggplot2::ggplot(data = plot_NOAA, ggplot2::aes(x = DATE, y = COUNTRY)) +
#'   geom_timeline(ggplot2::aes(size = EQ_PRIMARY), x_min = xmin, x_max = xmax) +
#'   geom_timeline_label(ggplot2::aes(label = LOCATION_NAME, magnatude = EQ_PRIMARY),
#'      x_min = xmin, x_max = xmax, top_x_mag = 5) +
#'   ggplot2::theme_minimal()
#' print(plt)
#'
#' @export
#' @import ggplot2
#' @importFrom lubridate ymd
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

#' Create the ggproto object for geom_timeline_label
#'
#' This function creates the ggproto Geom object to plot the necessary grid grob for
#' \code{geom_timeline_label}
#'
#' @examples
#' data('clean_NOAA')
#' NOAA <- clean_NOAA
#' plot_NOAA <- NOAA[NOAA$COUNTRY=="USA" | NOAA$COUNTRY=="CANADA",]
#' xmin <- lubridate::ymd("2010-01-01")
#' xmax <- lubridate::ymd("2017-07-01")
#' plt <- ggplot2::ggplot(data = plot_NOAA, ggplot2::aes(x = DATE, y = COUNTRY)) +
#'   geom_timeline(ggplot2::aes(size = EQ_PRIMARY), x_min = xmin, x_max = xmax) +
#'   geom_timeline_label(ggplot2::aes(label = LOCATION_NAME, magnatude = EQ_PRIMARY),
#'      x_min = xmin, x_max = xmax, top_x_mag = 5) +
#'   ggplot2::theme_minimal()
#' print(plt)
#'
#' @import ggplot2
#' @importFrom lubridate ymd
GeomTimelineLabel <- ggplot2::ggproto('GeomTimelineLabel', ggplot2::Geom,
             required_aes = c('x', 'label'),
             default_aes = ggplot2::aes(y = NULL, magnatude = NULL, color = 'black',
                               fill = 'black', alpha = 0.3, lty = 1, lwd = 1),
             draw_key = my_draw_key_circle,
             draw_group = function(data, panel_params, coord) {
                 coords <- coord$transform(data, panel_params)
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

#' The stat to enable geom_timeline to use date ranges as parameters
#'
#' This stat transforms the data passed to geom_timeline to ensure that only dates between
#' parameters \code{x_min} and \code{x_max} are actually plotted.  No further
#' transormations occur
#'
#' @inheritParams ggplot2::stat_identity
#' @inheritParams geom_timeline
#'
#' @examples
#' data('clean_NOAA')
#' NOAA <- clean_NOAA
#' plot_NOAA <- NOAA[NOAA$COUNTRY=="USA" | NOAA$COUNTRY=="CANADA",]
#' xmin <- lubridate::ymd("2010-01-01")
#' xmax <- lubridate::ymd("2017-07-01")
#' plt <- ggplot2::ggplot(data = plot_NOAA, ggplot2::aes(x = DATE, y = COUNTRY)) +
#'   geom_timeline(ggplot2::aes(size = EQ_PRIMARY), x_min = xmin, x_max = xmax) +
#'   ggplot2::theme_minimal()
#' print(plt)
#'
#' @export
#' @import ggplot2
#' @importFrom lubridate ymd
stat_timeline <- function(mapping = NULL, data = NULL, geom = 'timeline',
                          position = 'identity', na.rm = FALSE, show.legend = NA,
                          inherit.aes = TRUE, x_min, x_max, ...) {
    ggplot2::layer(
        stat = StatTimeline, mapping = mapping, data = data, geom = geom,
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(x_min = x_min, x_max = x_max, na.rm = na.rm, ...)
    )
}

#' Create the ggproto object for stat_timeline
#'
#' This function creates the ggproto Stat object transform the data to effectively
#' plot the necessary grid grob for \code{stat_timeline}
#'
#' @examples
#' data('clean_NOAA')
#' NOAA <- clean_NOAA
#' plot_NOAA <- NOAA[NOAA$COUNTRY=="USA" | NOAA$COUNTRY=="CANADA",]
#' xmin <- lubridate::ymd("2010-01-01")
#' xmax <- lubridate::ymd("2017-07-01")
#' plt <- ggplot2::ggplot(data = plot_NOAA, ggplot2::aes(x = DATE, y = COUNTRY)) +
#'   geom_timeline(ggplot2::aes(size = EQ_PRIMARY), x_min = xmin, x_max = xmax) +
#'   ggplot2::theme_minimal()
#' print(plt)
#'
#' @import ggplot2 grid
#' @importFrom lubridate ymd
StatTimeline <- ggplot2::ggproto('StatTimeline', ggplot2::Stat,
        required_aes = c('x'),
        compute_group = function(data, scales, params, x_min, x_max) {
            if(!('y' %in% names(data))) {
                data$y <- 1
            }
            return(data[data$x >= x_min & data$x <= x_max,])
        }
)

#' The stat to enable geom_timeline_label to use date ranges and top x labels as parameters
#'
#' This stat transforms the data passed to geom_timeline to ensure that only dates between
#' parameters \code{x_min} and \code{x_max} are actually plotted, and that only the
#' top \code{x} events are labeled.  No further transormations occur
#'
#' @inheritParams ggplot2::stat_identity
#' @inheritParams geom_timeline
#' @inheritParams geom_timeline_label
#'
#' @examples
#' data('clean_NOAA')
#' NOAA <- clean_NOAA
#' plot_NOAA <- NOAA[NOAA$COUNTRY=="USA" | NOAA$COUNTRY=="CANADA",]
#' xmin <- lubridate::ymd("2010-01-01")
#' xmax <- lubridate::ymd("2017-07-01")
#' plt <- ggplot2::ggplot(data = plot_NOAA, ggplot2::aes(x = DATE, y = COUNTRY)) +
#'   geom_timeline(ggplot2::aes(size = EQ_PRIMARY), x_min = xmin, x_max = xmax) +
#'   geom_timeline_label(ggplot2::aes(label = LOCATION_NAME, magnatude = EQ_PRIMARY),
#'      x_min = xmin, x_max = xmax, top_x_mag = 5) +
#'   ggplot2::theme_minimal()
#' print(plt)
#'
#' @export
#' @import ggplot2
#' @importFrom lubridate ymd
stat_timeline_label <- function(mapping = NULL, data = NULL, geom = 'timeline_label',
                          position = 'identity', na.rm = FALSE, show.legend = NA,
                          inherit.aes = TRUE, top_x_mag = NULL,
                          x_min = NULL, x_max = NULL, ...) {
    ggplot2::layer(
        stat = StatTimelineLabel, mapping = mapping, data = data, geom = geom,
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(top_x_mag = top_x_mag,
                      x_min = x_min, x_max = x_max, na.rm = na.rm, ...)
    )
}

#' Create the ggproto object for stat_timeline_label
#'
#' This function creates the ggproto Stat object to transform the data to effectively
#' plot the necessary grid grob for \code{stat_timeline}
#'
#' @examples
#' data('clean_NOAA')
#' NOAA <- clean_NOAA
#' plot_NOAA <- NOAA[NOAA$COUNTRY=="USA" | NOAA$COUNTRY=="CANADA",]
#' xmin <- lubridate::ymd("2010-01-01")
#' xmax <- lubridate::ymd("2017-07-01")
#' plt <- ggplot2::ggplot(data = plot_NOAA, ggplot2::aes(x = DATE, y = COUNTRY)) +
#'   geom_timeline(ggplot2::aes(size = EQ_PRIMARY), x_min = xmin, x_max = xmax) +
#'   geom_timeline_label(ggplot2::aes(label = LOCATION_NAME, magnatude = EQ_PRIMARY),
#'      x_min = xmin, x_max = xmax, top_x_mag = 5) +
#'   ggplot2::theme_minimal()
#' print(plt)
#'
#' @import ggplot2
#' @importFrom lubridate ymd
StatTimelineLabel <- ggplot2::ggproto('StatTimelineLabel',ggplot2::Stat,
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

         if(is.null(top_x_mag) | !('magnatude' %in% names(data))){
             return(data)
         } else {
             data <- data[order(data$magnatude, decreasing = TRUE),][1:min(top_x_mag,nrow(data)),]
             return(data)
         }
     }
)
