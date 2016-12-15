library(bit64)
EQCat2 <- fread("1981-2002.sum.txt")
EQCat2 <- EQCat2[V6 !=999 & V6>2.1]

# Convert the data
min <- EQCat2$V1%%100
hour <- (EQCat2$V1%/%100)%%100
day <- ((EQCat2$V1%/%100)%/%100)%%100
month <- (((EQCat2$V1%/%100)%/%100)%/%100)%%100
year <- ((((EQCat2$V1%/%100)%/%100)%/%100)%/%100)%%100

i2000 <- year<20
year[i2000] <- year[i2000] + 2000
year[!i2000] <- year[!i2000] + 1900

# Convert lat and long
latdegree <-strsplit(EQCat2$V3, split="n")
lat <- unlist(lapply(latdegree, function(X) { as.numeric(X[2])/60 + as.numeric(X[1])}))
londegree <-strsplit(EQCat2$V4, split="e")
lon <- unlist(lapply(londegree, function(X) { as.numeric(X[2])/60 + as.numeric(X[1])}))

# Define the data structure to be converted in ETAS cataloge
dt <- strptime(paste(year,month,day,hour,min), "%Y %m %d %H %M", tz = "GMT")
dates <- as.factor(as.Date(dt))
times <- as.factor(format(dt, "%H:%M"))
EQDat2 <- data.frame(date = dates, time=times, long= lon, lat = lat, Mag = EQCat2$V6)
EQDat2 <- EQDat2[complete.cases(EQDat2),]
id <- duplicated(EQDat2[,c("date","time")])
EQDat2 <- EQDat2[!id,]