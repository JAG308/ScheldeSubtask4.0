#### Taxonomic QualityControl
## Once connected to database with connnectionSQL code (con2).

library(dplyr)
library(worrms)

process_taxon_data <- function(connection) {
  # SQL Query
  query_taxon <- "
WITH naam_verschillend AS (
  SELECT T.id as taxon_id,T.aphiaId AS taxon_aphiaid,A.id AS aphia_id,
         T.name AS taxon_name,A.tu_displayname AS aphia_name
  FROM dbo.Taxon T
  LEFT JOIN dbo.import_aphia_tu A ON T.aphiaId=A.id
  WHERE T.name<>tu_displayname),
geen_aphiaid AS (
  SELECT T.id as taxon_id,T.aphiaId AS taxon_aphiaid,NULL AS aphia_id,
         T.name AS taxon_name,NULL AS aphia_name
  FROM dbo.Taxon T
  WHERE T.aphiaId IS NULL),
alles AS (
  SELECT * FROM naam_verschillend UNION ALL SELECT * FROM geen_aphiaid),
doe_een_voorstel AS (
  SELECT taxon_id,taxon_aphiaid,A.id AS voorstel_aphiaid,
        taxon_name,aphia_name,A.tu_displayname AS voorstel_name
  FROM alles T
  LEFT JOIN dbo.import_aphia_tu A ON LOWER(TRIM(T.taxon_name))=LOWER(TRIM(COALESCE(tu_displayname,'')))
)
SELECT * FROM doe_een_voorstel
ORDER BY Taxon_id,voorstel_aphiaid;
  "

# Execute SQL query
result_tax <- dbGetQuery(connection, query_taxon)
txn_qc <- as_tibble(result_tax)

# Filter out rows with NA values
filtered_table <- txn_qc %>%
  filter(!is.na(taxon_aphiaid) & !is.na(aphia_name))

# Print the number of filtered NA rows
cat("Number of filtered NA rows:", nrow(txn_qc) - nrow(filtered_table), "\n\n")

# Check aphiaID is correct in all rows of the dataset.
results <- vector("logical", length = nrow(filtered_table))

for (i in seq_len(nrow(filtered_table))) {
  row <- filtered_table[i, , drop = FALSE]
  
  tryCatch({
    # Use wm_id2name function to get the taxonomic name for the AphiaID
    taxonomic_name <- wm_id2name(row$taxon_aphiaid)
    
    # Check if the taxonomic name matches the aphia_name
    match_result <- taxonomic_name == row$aphia_name
    
    # Store the match result in the results vector
    results[i] <- all(match_result)
  }, error = function(e) {
    # Handle the error (optional), for now, just print a message
    cat(sprintf("Error in row %d: %s\n", i, e$message), "\n")
    # Set the result to FALSE or NA, depending on your preference
    results[i] <- FALSE
  })
}

# Print or use the results as needed
print(results)
table(results)
}

# Call the function with your database connection
# Assuming 'con2' is your database connection object
process_taxon_data(con2)

