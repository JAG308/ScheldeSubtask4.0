
#Script to retrieve station's locations by parameter Id

Station_IDplot<- function(connection) {

#install.packages("tibble")
#install.packages("dplyr")
#install.packages("dbscan")
#install.packages("DescTools")
library(ggplot2)
library(dbscan)
library(dplyr)
library(DescTools)
library(tibble)
library(dplyr)
library(sf)
library(mapview)
queryStation1 <- "
---sql17stage.vliz.be/dataportal.dbo  , 2:04m, about  959 427 records
WITH
location AS (SELECT
             Serie.id AS serieId
             , SerPar.parameterId AS paramid
             , stationName
             , location.Lat AS latitude
             , location.Long AS longitude
             FROM Serie
             JOIN SerPar ON Serie.id = SerPar.serieId
             WHERE stationName IS NOT NULL
             UNION ALL
             SELECT
             SerPar.serieId
             , SerPar.parameterId AS paramid
             , stationName
             , location.Lat AS latitude
             , location.Long as longitude
             FROM ValAclass
             JOIN SerPar ON serParId = SerPar.id
             WHERE stationName IS NOT NULL
             UNION ALL
             SELECT
             SerPar.serieId
             , SerPar.parameterId AS paramid
             , stationName
             , location.Lat AS latitude
             , location.Long as longitude
             FROM ValAVariableStat
             JOIN SerPar ON serParId = SerPar.id
             WHERE stationName IS NOT NULL
             UNION ALL
             SELECT
             SerPar.serieId
             , SerPar.parameterId AS paramid
             , stationName
             , location.Lat AS latitude
             , location.Long as longitude
             FROM ValBclass
             JOIN SerPar ON serParId = SerPar.id
             WHERE stationName IS NOT NULL
             UNION ALL
             SELECT
             SerPar.serieId
             , SerPar.parameterId AS paramid
             , stationName
             , location.Lat AS latitude
             , location.Long as longitude
             FROM ValBVariableStat
             JOIN SerPar ON serParId = SerPar.id
             WHERE stationName IS NOT NULL
             UNION ALL
             SELECT
             SerPar.serieId
             , SerPar.parameterId AS paramid
             , stationName
             , location.Lat AS latitude
             , location.Long as longitude
             FROM ValXVariable
             JOIN SerPar ON serParId = SerPar.id
             WHERE stationName IS NOT NULL),
rounded AS (SELECT
            stationName
            , paramid
            -- atal cijfers na de komma: 4 = 5 a 10m
            , CAST(latitude AS NUMERIC(10, 4)) AS latitude
            , CAST(longitude AS NUMERIC(10, 4)) AS longitude
            FROM location
            JOIN [dp_serie_dpcontext] dpc ON dpc.seriesid = serieId AND dpc.dataportalContext = 1
            --Activeer om te begrenzen tot BE/NL, maar je verliest ook de 0 en null en onzinnige waarden
            --WHERE latitude BETWEEN 49.5 AND 53.6 AND longitude BETWEEN 2.5 AND 7.1
)
SELECT
latitude
, longitude
, stationName
, paramid
, COUNT(*) AS aantal
FROM rounded
GROUP BY latitude, longitude, stationName,paramid
ORDER BY latitude, longitude, stationName,paramid;
"

resultStation <- dbGetQuery(con2, queryStation1)
StationQC <- as_tibble(resultStation)
StationQC

## Remove ~400 lines with NA values from the DB list of stations

StationClean <- na.omit(StationQC)

# List these stations with NA values

rows_with_na <- StationQC[rowSums(is.na(StationQC)) > 0, ]


# Extract station names from the filtered rows
station_names_with_na <- rows_with_na$stationName

# Print message
cat("Stations with NA values:", length(station_names_with_na), "\n")
print(station_names_with_na)

# Assuming your dataframe is named 'StationClean' with columns: station_name, latitude, longitude

# Create a matrix of coordinates (latitude and longitude)
coords <- StationClean[, c("latitude", "longitude")]

# Set the maximum distance between two points to be considered as part of the same cluster
# Adjust this epsilon value based on your preferences
epsilon <- 0.0005  # 0.0005 degrees equals to ~50m of distance. Stations placed at less than 50m distance from each other are considered as the same station.

# Apply DBSCAN clustering
dbscan_result <- dbscan(coords, eps = epsilon, minPts = 1)  # minPts is the minimum number of points required to form a cluster

# Extract cluster assignments
cluster_ids <- dbscan_result$cluster

# Create a new dataframe with one record per unique station (cluster)
unique_stations <- data.frame(
  station_name = StationClean$stationName,
  cluster_id = cluster_ids
)
cluster_ids
# Remove duplicated stations based on cluster ID
unique_stations <- unique(unique_stations)

# Optionally, you can calculate the centroid of each cluster if needed
centroids <- aggregate(coords, by = list(cluster_ids), FUN = mean)
colnames(centroids) <- c("cluster_id", "latitude", "longitude")

# Merge centroids with unique stations dataframe if needed
unique_stations <- merge(unique_stations, centroids, by = "cluster_id", all.x = TRUE)

# Remove duplicates
unique_stations2 <- unique(unique_stations[c("station_name", "latitude", "longitude")])
unique_stations2 <- unique_stations %>%
  group_by(latitude, longitude) %>%
  summarise(station_name = names(sort(table(station_name), decreasing = TRUE)[1])) %>%
  ungroup()

# Output the unique stations dataframe
print(unique_stations2)

# Return update of number of stations

cat("Stations within 50 meters of each other have been clustered, being considered as a unique station. From", 
    nrow(StationClean), "stations in StationClean, to", 
    nrow(unique_stations2), "unique stations after clustering.\n")


#### NOW WE FILTER THE STATIONS OUTSIDE OUR BOUNDING BOX


# Load required libraries
library(mapview)
library(sf)

# Convert unique_stations2 to sf object
unique_stations22 <- st_as_sf(unique_stations2, coords = c('longitude', 'latitude'), crs = 4326)

# Crop the spatial object
filtered_points2 <- st_crop(unique_stations22, xmin = 2.32, xmax = 5.25, ymin = 50.8, ymax = 52)

# Extract coordinates left out
left_out_points <- unique_stations2[!unique_stations22$geometry %in% filtered_points2$geometry | 
                                      !unique_stations22$geometry %in% filtered_points2$geometry, ]

# Convert filtered_points2 to a data frame with three columns

filtered_points_df <- unique_stations2[unique_stations22$geometry %in% filtered_points2$geometry | 
                                         unique_stations22$geometry %in% filtered_points2$geometry, ]

# Print the left out coordinates
cat("Stations outside the Schelde estuary area:", nrow(left_out_points), "\n")
print(left_out_points$station_name)

# Print current number of stations left.

cat("Total number of stations after removing NA, clustering them within 50m range, duplicated stations with same coordinates:", nrow(filtered_points_df), "\n")


### Remove duplicates of station names. OPTIONAL

unique_stations3 <- filtered_points_df[!duplicated(filtered_points_df$station_name), ]

# filter stations by ID

resultStation1 <- dbGetQuery(con2, queryStation1)
StationQC1 <- as_tibble(resultStation1)
StationQC1

colnames(StationQC1)[3]<- 'station_name'
Stations <- unique_stations3[,3]

MERGED <- inner_join(Stations, StationQC1, by = "station_name")
MERGED <- MERGED[complete.cases(MERGED$longitude, MERGED$latitude), ]
MERGED <- st_as_sf(MERGED, coords = c("longitude", "latitude"), crs = 4326)


generate_map <- function(df, selected_paramid) {
  filtered_data <- df[df$paramid == selected_paramid, ]
  
  mapview(filtered_data, zcol = "station_name", col.regions = "red", alpha.regions = 0.8, legend = FALSE)
}

}

Station_IDplot()
generate_map(MERGED, selected_paramid = 1292)
