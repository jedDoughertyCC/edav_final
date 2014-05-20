library(RJSONIO)
library(scales)
library(lubridate)
library(ggthemes)
library(reshape2)
library(sqldf)
#Locations to pull files from
long_loc <- "~/edav_final/sleepdays/"
import.csv <- "~/edav_final/sleepdata.csv"
import.reporter <- "~/edav_final/reporter-export.csv"
#Names of files
filenames <- list.files(path = long_loc)

#limits to only json files in folder
f <- filenames[ grep(".json", filenames)]

# read_reporter_json <- function(filename){
# x <- fromJSON("reporter-export.json")

# read report data as csv
read_reporter_csv <- function(filename){
  y <- read.csv(filename)
  colnames(y) <- c("GMT_timestamp","local_timestamp","latitude","longitude",
                      "weather","photos","decible_level","audio_desc","steps",
                      "people","learn","activity","sleep","working","coffees",
                      "location","alcohol","stress","drugs")
  y[y$stress == '',]$stress <- "Nothing!"
  y[y$people == '',]$people <- "Alone"
  y$timestamp     <- as.POSIXct(gsub("T"," ",
                            y$GMT_timestamp),
                            tz = "UTC")
  attr(y$timestamp, "tzone") <- "America/New_York"
  return(y)
}

#function to read in a csv file
read_sleep_csv <- function(filename){
    x <- read.csv("sleepdata.csv",sep = ";")
    x$ate_late      <- grepl("Ate late",x$Sleep.Notes)
    x$drank_coffee  <- grepl("Drank coffee",x$Sleep.Notes)
    x$stressful_day <- grepl("Stressful day",x$Sleep.Notes)
    x$worked_out    <- grepl("Worked out",x$Sleep.Notes)
    x$start_date    <- as.POSIXct(gsub("T"," ",x$Start))
    x$happy         <- x$Wake.up == ":)"
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
    one_day$hours_of_sleep <- round(one_day$duration/(60*60))
    one_day$heartrate <- as.numeric(gsub(" bpm", "",one_day$heartrate))
    one_day$steps <- as.numeric(gsub(" steps", "",one_day$steps))
    one_day$rec_time <- one_day$start_date + one_day$secs_since_sleep
    one_day$hour_and_min <- hour(one_day$rec_time) + minute(one_day$rec_time)/60
    one_day$hour <- hour(one_day$start_date)
    one_day$hour_text <- paste(sort(unique(one_day$hour)),
                               " o'clock",sep = "")
    one_day <- one_day[one_day$hours_of_sleep > 2,]
    return(one_day)
}
##sets up import for each file


#reads sleep csv
metadata <- read_sleep_csv(import.csv)

#reads reporter csv
reporter <- read_reporter_csv(import.reporter)
reporter$drugs <- NULL

#imports list of json files
import.list <- lapply(paste(long_loc,f,sep = ""), read_json)

#binds the files together and saves them to full_list
full_list <- do.call("rbind", import.list)

#create new x axis value for time of sleep

#remove a day when I counted double
#"Wednesday 19-20 Mar, 2014"
filtered_list <- full_list[full_list$graph_date != "Wednesday 19-20 Mar, 2014",]

merged_lists <- merge(filtered_list,metadata, by = "start_date")

#give the reporter data the id of the following sleep day
x <- unique(merged_lists[,c("start_date","happy")])

x$id <- paste("night",1:nrow(x),sep ="")
 
names(x) <- c("day","happy","id")

reporter$id <- "no_night"

for(i in 1:nrow(reporter)){
  for(j in 1:nrow(x)){
    if(reporter[i,]$timestamp <= x[j,]$day &
       reporter[i,]$timestamp > x[j,]$day - 60*60*24){
          reporter[i,]$id <- x[j,]$id
    }
  }
}

#queries reporter info to get information for each night of sleep
r_and_m <- sqldf("
select x.id sleep_id,
sum(CASE WHEN
    (activity LIKE '%Drinking%' OR
     activity LIKE '%Coke%' OR
     activity LIKE '%shrooms%' OR
     activity LIKE '%molly%')
    THEN 1
    ELSE 0 END) drinking,
happy
from x
left outer join reporter on
x.id = reporter.id
group by sleep_id
order by sleep_id
;", drv = "SQLite")

r_and_m[r_and_m$drinking == "1" &
        r_and_m$happy == FALSE,]$drinking <- "smalldrinksad"
r_and_m[r_and_m$drinking == "1" &
        r_and_m$happy == TRUE,]$drinking  <- "smalldrinkhappy"
r_and_m[r_and_m$drinking == "2" &
        r_and_m$happy == FALSE,]$drinking <- "muchdrinksad"
r_and_m[r_and_m$drinking == "2" &
        r_and_m$happy == TRUE,]$drinking  <- "muchdrinkhappy"
r_and_m[r_and_m$drinking == "0" &
        r_and_m$happy == FALSE,]$drinking <- "nodrinksad"
r_and_m[r_and_m$drinking == "0" &
        r_and_m$happy == TRUE,]$drinking  <- "nodrinkhappy"

simple_graph_output <- data.frame(merged_lists$hour_and_min,
                                  merged_lists$X2,
                                  merged_lists$graph_date)

colnames(simple_graph_output) <- c("timestamp","sleep","the_day")
write.csv(simple_graph_output,"simple_sleep_output.csv",row.names = FALSE)
a<- seq(3000,1,by = -100)
b<-101 # Or some other number
a<-sapply(a, function (x) rep(x,b))
a<-as.vector(a)


layer_graph_output <- data.frame(merged_lists$graph_date,
                                  merged_lists$hour_and_min,
                                  merged_lists$X2 + a)

colnames(layer_graph_output) <- c("the_day","reading","level")

layer_form <- dcast(layer_graph_output,the_day ~ reading,function(x){as.character(min(x))},fill="")
sleep_id <- paste("night",1:nrow(layer_form),sep = "")
layer_form <- cbind(sleep_id, layer_form)

write.csv(layer_form,"layer_output.csv",row.names = FALSE)
write.csv(r_and_m,"sleep_days.csv",row.names = FALSE)
