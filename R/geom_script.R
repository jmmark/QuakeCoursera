# file for creating the quake geoms:
# 1 geom: timeline plot of earthquakes showing dots for each one within xmin and xmax days
# 2 geom: annotations above timeline labeling the earthquakes
# use stat to subset the data or the x largest earthquakes as required

library(ggplot2)
library(grid)

geom_timeline <- function(mapping = NULL, data = NULL, stat = 'timeline',
                          position = 'identity', na.rm = FALSE, show.legend = NA,
                          inherit.aes = TRUE, x_min, x_max, ...) {
    ggplot2::layer(
        geom = GeomTimeline, mapping = mapping, data = data, stat = stat,
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(na.rm = na.rm, x_min = x_min, x_max = x_max, ...)
    )
}

GeomTimeline <- ggplot2::ggproto('GeomTimeline', Geom,
        required_aes = c('x'),
        default_aes = aes(y = NULL, color = 'black',
                          fill = 'black', size = .05, alpha = 0.3),
        draw_key = draw_key_path,
        draw_group = function(data, panel_params, coord) {
            coords <- coord$transform(data, panel_params)
            debug_me <<- coords
            grid::circleGrob(
                coords$x,
                coords$y,
                r = coords$size / 100,
                gp = grid::gpar(
                    col = coords$colour,
                    fill = coords$fill,
                    alpha = coords$alpha

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
