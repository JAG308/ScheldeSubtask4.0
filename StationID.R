
# Script to retrieve station's locations by parameter Id

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


# Retrieve dataset with station names, their coordinates and their parameter IDs measured by each one.

resultStation1 <- dbGetQuery(con2, queryStation1)
StationQC1 <- as_tibble(resultStation1)
StationQC1

# Join current dataset with the unique stations dataset obtained by the "Stations" QC script

colnames(StationQC1)[3]<- 'station_name'
Stations <- unique_stations3[,3]

MERGED <- inner_join(Stations, StationQC1, by = "station_name")
MERGED <- MERGED[complete.cases(MERGED$longitude, MERGED$latitude), ]
MERGED <- st_as_sf(MERGED, coords = c("longitude", "latitude"), crs = 4326)

# Create function to map stations

generate_map <- function(df, selected_paramid) {
  filtered_data <- df[df$paramid == selected_paramid, ]
  
  mapview(filtered_data, zcol = "station_name", col.regions = "red", alpha.regions = 0.8, legend = FALSE)
}

}

# Run function and mapview() on parameter ID of interest.

Station_IDplot()
generate_map(MERGED, selected_paramid = 1292)
