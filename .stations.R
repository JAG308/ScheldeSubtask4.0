######## Station names QC

#Once connected to the ScheldeMonitor DB with the SQL connection code
# Retrieve quality control station table from the database.

Station_QualityC <- function(connection) {

queryStation <- "
WITH location AS (
    SELECT stationName,location.Lat AS latitude,location.Long AS longitude
    FROM Serie
    WHERE stationName IS NOT NULL
  UNION ALL
    SELECT stationName,location.Lat AS latitude,location.Long as longitude
    FROM ValAclass
    WHERE stationName IS NOT NULL
  UNION ALL
    SELECT stationName,location.Lat AS latitude,location.Long as longitude
    FROM ValAVariableStat
    WHERE stationName IS NOT NULL
  UNION ALL
    SELECT stationName,location.Lat AS latitude,location.Long as longitude
    FROM ValBclass
    WHERE stationName IS NOT NULL
  UNION ALL
    SELECT stationName,location.Lat AS latitude,location.Long as longitude
    FROM ValBVariableStat
    WHERE stationName IS NOT NULL
  UNION ALL
    SELECT stationName,location.Lat AS latitude,location.Long as longitude
    FROM ValXVariable
    WHERE stationName IS NOT NULL

),rounded AS (
  SELECT stationName,
    -- atal cijfers na de komma: 4 = 5 a 10m
    CAST(latitude AS NUMERIC(10,4)) AS latitude,
    CAST(longitude AS NUMERIC(10,4)) AS longitude
  FROM location
  --Activeer om te begrenzen tot BE/NL, maar je verliest ook de 0 en null en onzinnige waarden
  --WHERE latitude BETWEEN 49.5 AND 53.6 AND longitude BETWEEN 2.5 AND 7.1
  )
SELECT latitude,longitude,stationName,COUNT(*) AS aantal FROM rounded
GROUP BY latitude,longitude,stationName
ORDER BY latitude,longitude,stationName;
"

resultStation <- dbGetQuery(con2, queryStation)
StationQC <- as_tibble(resultStation)
StationQC


#### Now compare stations from your dataset with the stations StationQC.

### Remove ~400 lines with NA values from DB Station list

StationClean <- na.omit(StationQC)

#Create bin with coordinates range
bin_size <- 0.15

#Create list where coordinates are summarized in bins and the most frequent station names representing them.

StationClean <- StationClean %>%
  mutate(lat_bin = cut(latitude, breaks = seq(floor(min(latitude)), ceiling(max(latitude)), bin_size), include.lowest = TRUE),
         lon_bin = cut(longitude, breaks = seq(floor(min(longitude)), ceiling(max(longitude)), bin_size), include.lowest = TRUE))

grouped_Station <- StationClean %>%
  group_by(lat_bin, lon_bin) %>%
  summarise(stationName = names(sort(table(stationName), decreasing = TRUE)[1]),  # Keep the most frequent station name
            latitude = mean(latitude),
            longitude = mean(longitude))

grouped_Station

# Standarise both tables so they have the same format.
# Both tables should have the columns: 'latitude', 'longitude', 'stationName'

SdStation <- grouped_Station %>% relocate(latitude, .before=lat_bin)
SdStation <- SdStation %>% relocate(longitude, .before=lat_bin)
SdStation <- SdStation %>% relocate(stationName, .before=lat_bin)
SdStation <- SdStation[,1:3]

StationQC <- StationQC[,1:3]

#### Once the input table and the DB table look alike
####### Now run the Quality Control

# Assuming your dataframes are named SdStation and StationQC

# Initialize a variable to count total mismatches
total_mismatches <- 0

# Initialize a list to store details of mismatches
mismatch_details <- list()

# Iterate over each row in StationQC
for (i in 1:nrow(StationQC)) {
  # Extract stationName and corresponding coordinates from StationQC
  current_qc_station <- StationQC[i, ]
  stationName_qc <- current_qc_station$stationName
  lat_qc <- current_qc_station$latitude
  lon_qc <- current_qc_station$longitude
  
  # Find all rows in SdStation with the same stationName
  corresponding_rows <- SdStation %>% filter(stationName == stationName_qc)
  
  # Check if coordinates match
  if (nrow(corresponding_rows) > 0) {
    lat_sd <- corresponding_rows$latitude
    lon_sd <- corresponding_rows$longitude
    
    # Check if any of the coordinates match
    if (any(lat_sd == lat_qc & lon_sd == lon_qc, na.rm = TRUE)) {
      # Coordinates match, continue to the next row in StationQC
      next
    }
  }
  
  # Update the total count of mismatches
  total_mismatches <- total_mismatches + 1
  
  # Store details of mismatches
  mismatch_details[[stationName_qc]] <- current_qc_station
}

### Display the total number of mismatches
cat("Total number of rows with mismatched coordinates: ", total_mismatches, "\n")

### Display details of each mismatch
if (total_mismatches > 0) {
  cat("Details of mismatched rows by station in StationQC:\n")
  print(mismatch_details)
}
}


Station_QualityC(con2)

