# Once cconnected to the DB with connectionSQL

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
SELECT   originalParameterName, originalParameterUnit,COUNT(*) AS unitcount --COUNT(DISTINCT originalParameterUnit ),STRING_AGG(originalParameterUnit,',')
FROM alleparameters
--GROUP BY originalParameterName, parameterid, originalParameterUnit
GROUP BY originalParameterName, originalParameterUnit
ORDER BY originalParameterName, originalParameterUnit
"
           
resultUnit <- dbGetQuery(con2, queryUnit)
UnitQC <- as_tibble(resultUnit)
UnitQC

# Now select parameter of interest.

UnitQC %>% filter(UnitQC$originalParameterName == 'Name_of_your_parameter')
