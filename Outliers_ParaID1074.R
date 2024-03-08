## Run a statistical analysis to highlight outliers in your parameter ID dataset.
# Once connected to the DB with connectionSQL
# Load necessary libraries
library(usethis)
library(devtools)
devtools::install_github("scheldemonitor/scheldemonitoR")
library(scheldemonitoR)

# Define a function to run outliers analysis over a specified parameter Id
run_outliers_analysis <- function(dataset_id, start_year, end_year) {
  # Import data
  Abiotic_data <- importAbioticData(dataset_id, start = start_year, end = end_year)
  tbl1 <- Abiotic_data
  
  # Function to find outliers in a column
  find_outliers <- function(parameter, col_name) {
    Q1 <- quantile(parameter, 0.25, na.rm = TRUE)
    Q3 <- quantile(parameter, 0.75, na.rm = TRUE)
    IQR <- Q3 - Q1
    lower_bound <- Q1 - 1.5 * IQR
    upper_bound <- Q3 + 1.5 * IQR
    
    # Find the indices of outliers
    outlier_indices <- which(parameter < lower_bound | parameter > upper_bound)
    
    if (length(outlier_indices) > 0) {
      # Create a data frame with the results
      result_df <- data.frame(ID = outlier_indices, ColumnName = col_name)
      return(result_df)
    } else {
      return(NULL)
    }
  }
  
  # Function to find outliers in numeric columns and handle non-numeric columns
  find_outliers_function <- function(tbl1) {
    # Initialize empty data frames to store results
    numeric_outliers <- data.frame(ID = integer(0), ColumnName = character(0))
    non_numeric_columns <- character(0)
    
    # Function to check if a column contains numeric values
    is_numeric_column <- function(column) {
      all(is.numeric(column))
    }
    
    # Loop through each column (parameter) and find outliers
    for (col_name in colnames(tbl1)) {
      # Skip columns to ignore
      column_values <- tbl1[[col_name]]
      
      # Check if the column contains numeric values
      if (is_numeric_column(column_values)) {
        outliers_for_column <- find_outliers(column_values, col_name)
        if (!is.null(outliers_for_column)) {
          numeric_outliers <- rbind(numeric_outliers, outliers_for_column)
        }
      } else {
        # Handle non-numeric values
        non_numeric_columns <- c(non_numeric_columns, col_name)
      }
    }
    
    # Return the results
    return(list(numeric_outliers = numeric_outliers, non_numeric_columns = non_numeric_columns))
  }
  
  # Call the outlier analysis function
  results <- find_outliers_function(tbl1)
  
  # Access the numeric outliers and non-numeric columns
  numeric_outliers <- results$numeric_outliers
  non_numeric_columns <- results$non_numeric_columns
  
  # Return the results
  return(list(numeric_outliers = numeric_outliers, non_numeric_columns = non_numeric_columns))
}

# Example usage:
#parameter_id <- 13592  # You can change this to any parameter Id you want to analyze
#start_year <- 2018
#end_year <- 2021



#result <- run_outliers_analysis(parameter_id, start_year, end_year)

#print(result)

 
