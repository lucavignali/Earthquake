# Read data
library(plyr)

# load and merge data
files <- list.files(pattern = "200[3:4:5].csv")

temp <- lapply(files, fread)

EQCat4 <- rbindlist(temp)

# The actual magnitude is the herafter calculated Magnitude
EQCat4$DM <- EQCat4$DM/10

# Consider only complete cases
EQCat4 <- EQCat4[complete.cases(EQCat4),]

# Remove all cases with magnitued lower than 2.
EQCat4 <- EQCat4[DM > 2]

# Convert Month name in number.
EQCat4$Month <- match(EQCat4$Month,month.abb)

d <- strptime(paste(EQCat4$Year,EQCat4$Month,EQCat4$Day,EQCat4$HHMMSS), "%Y %m %d %H%M%S", tz = "GMT")
day <- as.factor(as.Date(d))
time <- as.factor(format(d,"%H:%M"))

EQDat4 <- data.frame(date = day, time = time, long = EQCat4$Lon, lat = EQCat4$Lat, mag = EQCat4$DM)
