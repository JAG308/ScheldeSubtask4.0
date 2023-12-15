
####### Identify outliers 


Outliers_QualityC <- function(connection) {

## Retrieve table from database
## First you need to connect to database with 'ConnectionSQL' code

queryUnit <- "
SELECT *
FROM boeien.dbo.Havengeul_GSM_EXOData
"

tbl <- dbGetQuery(con2, queryUnit)
tbl1 <- as.data.frame(tbl)
tbl1



### Function to identify outliers 
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

# Initialize an empty data frame to store the results
outlier_results <- data.frame(ID = integer(0), ColumnName = character(0))

# Loop through each column (parameter) and find outliers
for (col_name in colnames(tbl1)) {
  outliers_for_column <- find_outliers(tbl1[[col_name]], col_name)
  if (!is.null(outliers_for_column)) {
    outlier_results <- rbind(outlier_results, outliers_for_column)
  }
}

## Print the data frame containing outliers locations
##Obtain the number of rows where there has been an outlier per column
print(outlier_results)

#Obtain a table with a summary of the total outliers detected per column
table(outlier_results$ColumnName)

}

