# Once connected to the DB with connectionSQL
# Retrieve table with parameter names and their unit counts. 
# Install necessary packages
library (tibble) 
library(dplyr)

# Retrieve table with parameter names and their unit counts. 

Units_qualityC <- function(connection) {
  # SQL Query
  queryUnit <- "
WITH  alleparameters AS (
  SELECT 
	SP.originalParameterUnit,P.unit,
    P.id AS parameterid,
    SP.conversionFactor,
    SP.originalParameterName
  FROM dbo.SerPar SP
  JOIN dbo.Parameter P ON SP.parameterId=P.id
  WHERE SP.originalParameterUnit<>P.unit)
SELECT   originalParameterName, parameterid, originalParameterUnit,COUNT(*) AS unitcount --COUNT(DISTINCT originalParameterUnit ),STRING_AGG(originalParameterUnit,',')
FROM alleparameters
--GROUP BY originalParameterName, parameterid, originalParameterUnit
GROUP BY originalParameterName, originalParameterUnit, parameterid
ORDER BY originalParameterName, originalParameterUnit, parameterid
"

  resultUnit <- dbGetQuery(con2, queryUnit)
	}
  UnitQC <- as_tibble(resultUnit)
  UnitQC


Units_qualityC(con2)


# Now select parameter of interest.

#UnitQC %>% filter(UnitQC$parameterid == '357')
