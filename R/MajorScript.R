### Main script sourcing QC scripts for the Schelde Monitor database.
### Each section sources a function onto the script to run a quality control measurement over a specific parameter ID

    ############ Connection to the Schelde Monitor DB  #############

source("https://raw.githubusercontent.com/scheldemonitor/QualityControlSM/main/R/SQLconnection.R")

con2 <- dbConnect(odbc::odbc(), "SQLServer_DS")


    ################# HEATMAPS ################

#The function assess the frequency of sampling of the given parameter over the time range specified in the function "importAbioticData"
    
source("https://raw.githubusercontent.com/scheldemonitor/QualityControlSM/main/R/heatmaps.R")

# Function heatmapsQC with a specified parameter Id
run_heatmap_with_parameter <- function(parameter_id) {
  # Call heatmapsQC function with the specified parameter Id
  all_data <- importAbioticData(parameter_id, start = 2018, end = 2024)
  
  # plot available data
  all_availability_figures <- heatmapDataAvailability(all_data, "parameter", "year")
  
  return(all_availability_figures)
}

# Set parameter Id
parameter_id <- 357 # You can change this to any parameter Id you want to visualize
heatmap_figures <- run_heatmap_with_parameter(parameter_id)

heatmap_figures


   ###############  OUTLIERS  ###############

# Run a statistical analysis to highlight outliers in your parameter ID dataset.

source("https://raw.githubusercontent.com/scheldemonitor/QualityControlSM/main/R/OutliersFinder.R")

# Example usage:
parameter_id <- 357  # You can change this to any parameter Id you want to analyze
start_year <- 2018
end_year <- 2024

result <- run_outliers_analysis(parameter_id, start_year, end_year)

print(result)

   ################  Units  ###############

# Returns how many units are used to described certain parameter

source("https://raw.githubusercontent.com/scheldemonitor/QualityControlSM/main/R/Unit.R")

UnitQC %>% filter(UnitQC$parameterid == '357')


###############  AphiaID  ############### 

# Assessment of the AphiaIDs of the whole database and tests returns the species with AphiaIDs not matching with the Aphias from WORMS DB

source("https://raw.githubusercontent.com/scheldemonitor/QualityControlSM/main/R/AphiaID.R")


##############  Stations #############

# Assessment and standarisation of all stationss present in the DB removing duplicates in coordinates, station names, and misplaces stations.

source("https://raw.githubusercontent.com/scheldemonitor/QualityControlSM/main/R/.stations.R")

mapview(unique_stations_sf, legend = NULL)

############ Stations by Id #############

# Retrieve those stations where the parameter targeted has been measured.

source("https://github.com/scheldemonitor/QualityControlSM/blob/main/R/StationID.R")

generate_map(MERGED, selected_paramid = 357)
