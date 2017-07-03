plt <- ggplot(data = test_NOAA[test_NOAA$COUNTRY == "USA" |
                                   test_NOAA$COUNTRY == "CHINA",],
              aes(x = DATE, y = COUNTRY))

xmin <- ymd("2000-01-01")
xmax <- ymd("2017-07-01")

plt <- plt + geom_timeline(aes(size = EQ_PRIMARY), x_min = xmin, x_max = xmax)

plt <- plt + geom_timeline_label(aes(label = LOCATION_NAME,
                                     magnitude = EQ_PRIMARY),x_min = xmin, x_max = xmax,
                                 top_x = 5)

print(plt)
