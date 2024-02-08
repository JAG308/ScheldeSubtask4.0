### Main code that withdraws all others functions and allows Quality Control of specific parameters.

################# HEATMAPS ################

source("https://raw.githubusercontent.com/JAG308/ScheldeSubtask4.0/main/heatmaps.R")

# Function heatmapsQC with a specified parameter Id
run_heatmap_with_parameter <- function(parameter_id) {
  # Call heatmapsQC function with the specified parameter Id
  all_data <- importAbioticData(parameter_id, start = 2018, end = 2021)
  
  # plot available data
  all_availability_figures <- heatmapDataAvailability(all_data, "high tide", "year", "station")
  
  return(all_availability_figures)
}

# Set parameter Id
parameter_id <- 4939 # You can change this to any parameter Id you want to visualize
heatmap_figures <- run_heatmap_with_parameter(parameter_id)

heatmap_figures


############### OUTLIERS ###############

source("https://raw.githubusercontent.com/JAG308/ScheldeSubtask4.0/main/Outliers_ParaID1074.R")

# Example usage:
parameter_id <- 13449  # You can change this to any parameter Id you want to analyze
start_year <- 2018
end_year <- 2021


result <- run_outliers_analysis(parameter_id, start_year, end_year)

print(result)



