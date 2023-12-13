#### Taxonomic QualityControl
## Once connected to database with connnectionSQL code.

queryTaxon <- "
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
resultTax <- dbGetQuery(con2, queryTaxon)
TxnQC <- as_tibble(resultTax)
TxnQC

# Install worms package

install.packages("worrms")
library('worrms')

library(dplyr)

# Filter out rows with NA values
filtered_table <- TxnQC %>%
  filter(!is.na(taxon_aphiaid) & !is.na(aphia_name))

# Print the number of filtered NA rows
cat("Number of filtered NA rows:", nrow(TxnQC) - nrow(filtered_table), "\n\n")

## Check aphiaID only first row

#Filter NAs
filtered_table <- TxnQC %>%
  filter(!is.na(taxon_aphiaid) & !is.na(aphia_name))

# Check the first row
first_row_match <- with(filtered_table, {
  first_row_id <- taxon_aphiaid[1]
  first_row_name <- aphia_name[1]
  
  # Use wm_id2name function to get the taxonomic name for the AphiaID
  taxonomic_name <- wm_id2name(first_row_id) 
  
  # Check if the taxonomic name matches the aphia_name
  match_result <- taxonomic_name == first_row_name
  
  # Return the match result
  match_result
})


print(first_row_match)


# Now loop over all the rows.

# Create vector to store your logical values.
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
  # Handle the error (optional), just print a message
  cat(sprintf("Error in row %d: %s\n", i, e$message), "\n")
  # Set the result to FALSE (or NA)
  results[i] <- FALSE
})
}
# Print() to see a list of TRUE/FALSE outputs. Table() for a summmary
print(results)
table(results)
