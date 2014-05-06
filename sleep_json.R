library(RJSONIO)

#Locations to pull files from
long_loc <- "~/edav_final/sleepdays/"
import.csv <- "~/edav_final/sleepdata.csv"

#Names of files
filenames <- list.files(path = long_loc)

#limits to only json files in folder
f <- filenames[ grep(".json", filenames)]

#function to read in a csv file
read_sleep_csv <- function(filename){
    x <- read.csv("sleepdata.csv",sep = ";")
    x$ate_late <- grepl("Ate late",x$Sleep.Notes)
    x$drank_coffee <- grepl("Drank coffee",x$Sleep.Notes)
    x$stressful_day <- grepl("Stressful day",x$Sleep.Notes)
    x$worked_out <- grepl("Worked out",x$Sleep.Notes)
    x$start_date <- as.POSIXct(gsub("T"," ",x$Start))
    return(x)
}

read_json <- function(filename){
    x <- fromJSON(filename)
    one_day <- data.frame(t(data.frame(x$graph)))
    one_day$rating <- x$rating
    one_day$heartrate <- x$heartrate
    one_day$graph_date <- x$graph_date
    one_day$start_tick_tz <- x$end_tick_tz
    one_day$start_tick <- x$start_tick
    one_day$stop_tick_tz <- x$stop_tick_tz
    one_day$start_local <- x$start_local
    one_day$stop_local <- x$stop_local
    one_day$duration<- x$stats_duration
    one_day$wakups <- x$stats_wakeups
    one_day$mph <- x$stats_mph
    one_day$steps <- x$steps
    one_day$sleep_quality <- x$stats_sq
    one_day$start_date <- as.POSIXct(
                          gsub("T"," ",one_day$start_local))
    one_day$secs_since_sleep <-
      (one_day$duration/100)*one_day$X1
    one_day$heartrate <- as.numeric(gsub(" bpm", "",one_day$heartrate))
    one_day$steps <- as.numeric(gsub(" steps", "",one_day$steps))
    one_day$rec_time <- one_day$start_date + one_day$secs_since_sleep
    print(nrow(one_day))
    one_day
}



##sets up import for each file

#reads sleep csv
metadata <- read_sleep_csv(import.csv)


#imports list of json files
import.list <- lapply(paste(long_loc,f,sep = ""), read_json)

#binds the files together and saves them to full_list
full_list <- do.call("rbind", import.list)

#create new x axis value for time of sleep

#remove a day when I counted double
#"Wednesday 19-20 Mar, 2014"
filtered_list <- full_list[full_list$graph_date != "Wednesday 19-20 Mar, 2014",]

merged_lists <- merge(filtered_list,metadata, by = "start_date")

#Grapical output of sleep days
ggplot(merged_lists,
      aes(secs_since_sleep/(60*60),X2)) +
      # geom_point(aes(alpha = duration/(60*60*9)))
      geom_line(aes(group = graph_date,colour = Wake.up,alpha = duration/(60*60*20))) +
      # geom_smooth() +
      facet_grid(stressful_day ~  worked_out)


ggplot(merged_lists,aes(rec_time,X2)) + geom_line() + facet_grid(.~graph_date)

