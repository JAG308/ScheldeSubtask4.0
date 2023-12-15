# Connecting to database from R studio.

connectDB <- function(connection) {}

library(DBI)
library(RODBC)
library(odbc)
library(dplyr)
library(dbplyr)

# Previous the 1st way, you need to set up the conection to the database

# 1st way (This way connects directly with the "dataportal" database.

#con1 <- dbConnect(odbc::odbc(), "SQLServer_DS")

##2nd way 

con2 <- dbConnect(odbc::odbc(),
Driver    = "SQL Server", 
Server    = "sql17",
Database  = "dataportal",
UID       = "rshiny",
trusted_connection = 'yes',
Port      = 1433)

}
                 

