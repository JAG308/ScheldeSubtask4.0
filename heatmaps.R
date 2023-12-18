
#install.packages("devtools")
library(devtools)

devtools::install_github("scheldemonitor/scheldemonitoR")
library(usethis)
library(scheldemonitoR)

# Run the function. In this case we are trying parameters 9694, 949 and 1074

heatmapsQC <- function() {
  # 9694 is the parameter id for high tide in NAP
  tide_data <- importAbioticData(9694, start = 2018, end = 2021)
  
  # plot available data
  tide_availability_figures <- heatmapDataAvailability(tide_data, "high tide", "year", "station")
  
  # Example with abiotic data ---------------------------------------------------------
  # abiotic data #949 & 1074
  fytoplankton_data <- importBioticData(1074, start = 2013, end = 2015, source = "imis")
  
  # correct datetime columname
  colnames(fytoplankton_data)[colnames(fytoplankton_data) == "observationdate"] <- "datetime"
  
  # plot available data
  heatmap_fyto <- heatmapDataAvailability(fytoplankton_data, "high tide", "year", "station")
  
  # Return the created plots
  return(list(tide_availability_figures = tide_availability_figures, heatmap_fyto = heatmap_fyto))
}

# Call the function to run the analysis
result <- heatmapsQC()

# Access the results
result$tide_availability_figures
result$heatmap_fyto
