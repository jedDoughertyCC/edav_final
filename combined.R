reporter <- read.csv("reporter-export.csv", stringsAsFactors = FALSE)
sleep <- read.csv("sleep_day_data.csv", stringsAsFactors = FALSE)



sleep$Sleep.quality <- as.numeric(gsub("%","",sleep$Sleep.quality))
sleep$Hours.in.bed <- sapply(strsplit(sleep$Time.in.bed,":"),
  function(x) {
    x <- as.numeric(x)
    x[1]+x[2]/60
    }
)

ggplot(sleep,aes(Time.in.bed,Sleep.quality, color = Wake.up)) + geom_point()


reporter$date <- as.Date(as.character(as.POSIXct(reporter$Timestamp.of.Report..GMT.)))
sleep$date <- as.Date(as.character(as.POSIXct(sleep$Start)))

combined <- merge(reporter,sleep, by = "date", all = TRUE)


combined$alcohol <- grepl("Drinking",combined$What.are.you.doing.)

drinking_to_sleep <- ddply(combined,~date,summarise,drinks=any(alcohol),
                           hours_of_sleep = mean(Hours.in.bed),quality = min(Wake.up))

ggplot(drinking_to_sleep, aes(drinks,hours_of_sleep,color= quality)) + geom_point()
