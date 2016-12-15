library(data.table)
# Read Data
EQCat <- fread("CPTI15_v1.5.csv",drop = 41)

EQData <- EQCat[,.(Year,Mo,Da,Ho,Mi,LatDef,LonDef,EpicentralArea,MwDef)]
# Replace comma with dot for Latitude, Longitude and Magnitude and convert in numeric
EQData$LatDef <- gsub(",", ".", EQData$LatDef)
EQData$LatDef <- as.numeric(EQData$LatDef)

EQData$LonDef <- gsub(",", ".", EQData$LonDef)
EQData$LonDef <- as.numeric(EQData$LonDef)

EQData$MwDef <- gsub(",", ".", EQData$MwDef)
EQData$MwDef <- as.numeric(EQData$MwDef)

# Remove cases where the Month is not available
EQData <- EQData[!is.na(EQData$Mo),]

# Fill cases where Day, Hour Minute are NA
EQData$Da[is.na(EQData$Da)] <- 1
EQData$Ho[is.na(EQData$Ho)] <- 0
EQData$Mi[is.na(EQData$Mi)] <- 0

# As some Lat and Long are empty, let's utilize the field EpicentralArea instead where lat and long are missing
EQData[is.na(EQData$LonDef), c("LonDef", "LatDef") := geocode(EQData[is.na(EQData$LonDef), EpicentralArea])]
# Google can't map 15 locations, so we will remove those from the data set.
EQData <- EQData[!is.na(EQData$LonDef),]
# Let's remove negative values of LonDef coming from some Google conversion.
EQData <- EQData[EQData$LonDef>=0,]
# Let's remove all cases where MwDef is not available.
EQData <- EQData[!is.na(EQData$MwDef) ,]

dt <- strptime(paste(EQData$Year,EQData$Mo,EQData$Da,EQData$Ho,EQData$Mi), "%Y %m %d %H %M", tz = "GMT")
dates <- as.factor(as.Date(dt))
times <- as.factor(format(dt, "%H:%M"))

data <- data.frame(date = dates, time = times, long = EQData$LonDef, lat = EQData$LatDef, mag = EQData$MwDef)
data <- data[complete.cases(data),]

# As there are 14 events that are simultaneaus - not accepted by ETAS - we leave only the first one
id <- duplicated(data[,c("date","time")])
data <- data[!id,]

# Get data from 2003 to 31-03-2005 to bridge the gap between dataset 2 and 3.

day <- as.numeric(format(strptime(as.character(data$date), "%Y-%m-%d", tz = "GMT"), "%Y"))

day2 <- strptime(as.character(data$date, tz = "GMT"), "%Y-%m-%d")

day_min <- strptime("2003-01-01", "%Y-%m-%d", tz = "GMT")
day_max <- strptime("2005-03-31", "%Y-%m-%d", tz = "GMT")

iday <- day2 >= day_min & day2 <= day_max

