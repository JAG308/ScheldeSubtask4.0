# Connecting to database from R studio.

# Install necessary packages

#install.packages(c("DBI", "ROBDC", "odbc"))
library(DBI)
library(RODBC)
library(odbc)


# It connects directly with the "dataportal" database.

con2 <- dbConnect(odbc::odbc(),
Driver    = "SQL Server", 
Server    = "sql17",
Database  = "dataportal",
UID       = "rshiny",
trusted_connection = 'yes',
Port      = 1433)


### Now you can start running the Quality Control functions.


