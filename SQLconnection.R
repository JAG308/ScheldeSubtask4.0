# Connecting to database from R studio.


library(DBI)
library(RODBC)
library(odbc)
library(dplyr)
library(dbplyr)

# Previous the 1st and 2nd way, it is needed to set up 
##1st way

#con <- odbcConnect("SQLServer_DS")
#sqlQuery(con, "Select * FROM dbo.Parameter")

##2nd way

con2 <- dbConnect(odbc::odbc(), "SQLServer_DS")
                 
##3rd way (This way connects directly with the "dataportal" database.

#con3 <- dbConnect(odbc::odbc(),
                 Driver    = "SQL Server", 
                 Server    = "sql17",
                 Database  = "dataportal",
                 UID       = "rshiny",
                 trusted_connection = 'yes',
                 Port      = 1433)
