library(data.table)

# load and merge data
files <- list.files(pattern = "Terremoti")
temp <- lapply(files, fread)

EQCat3 <- rbindlist(temp)

# Extract only the useful information for the ETAS
# data, time, long, lat, mag

data <- strptime(EQCat3$Time, "%Y-%m-%dT%H:%M:%S", tz = "UTC")
day <- as.factor(as.Date(data))
time <- as.factor(format(data,"%H:%M"))


EQDat3 <- data.frame(date = day, time = time, long = EQCat3$Longitude, lat = EQCat3$Latitude, 
                     mag = EQCat3$Magnitude)

saveRDS(EQDat3, "DS_3")

