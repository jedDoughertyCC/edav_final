#Grapical output of sleep days
ggplot(merged_lists,
      aes(secs_since_sleep/(60*60),X2)) +
      # geom_point(aes(alpha = duration/(60*60*9)))
      geom_line(aes(group = graph_date,colour = Wake.up,alpha = duration/(60*60*20))) +
      # geom_smooth() +
      facet_grid(stressful_day ~ worked_out)


ggplot(merged_lists,aes(secs_since_sleep,X2)) +
       geom_line() +
       facet_grid(graph_date ~ .)

ggplot(merged_lists,aes(hour_and_min, X2, group = graph_date, colour = )) + geom_line() + 
    facet_grid(hour ~ .)

ggplot(merged_lists,aes(hour_and_min,X2,group = graph_date,
                        colour = happy)) + geom_line(alpha = .6) +
                        facet_grid(hour ~ .) +
                        theme_solarized(light = TRUE) +
                        scale_colour_solarized("red") +
                        geom_vline(x = 8)

sleep_by_hour <- ggplot(merged_lists,aes(hour_and_min,X2,group = graph_date,
                        colour = happy)) + geom_line(size = 1.0,alpha = .7) +
                        facet_grid(hour ~ .) +
                        theme_solarized(light = FALSE) +
                        scale_colour_solarized("red") +
                        geom_vline(x = 8)

hours_of_sleep <- ggplot(merged_lists,aes(secs_since_sleep/(60*60),X2,group = graph_date,
                        colour = happy)) + geom_line(size = 1.0,alpha = .7) +
                        facet_grid(hours_of_sleep ~ .) +
                        theme_solarized(light = FALSE) +
                        scale_colour_solarized("red")
