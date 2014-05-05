library(RJSONIO)

x <- fromJSON("~/edav_final/data1.json")

x[[1]]

one_day <- data.frame(t(data.frame(x$graph)))


ggplot(one_day,aes(one_day[,1],one_day[,2])) + geom_line() + geom_point()
