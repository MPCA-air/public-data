library(tidyverse)
library(RODBC)
library(RPostgreSQL)
library(lubridate)

years <- 1999:as.numeric(format(Sys.time(), "%Y"))

creds <- read_csv("C:\\Users\\dkvale\\Desktop\\credentials.csv")

# Connect to WAIR database
con <-  dbConnect(RPostgreSQL::PostgreSQL(),  
                  dbname   = 'wair', 
                  host     = 'eiger', 
                  port     = 5432, 
                  user     = creds$wair_user, 
                  password = creds$wair_pwd)



sort(dbListTables(con))

dbGetQuery(con, "select schemaname, viewname from pg_catalog.pg_views;")


# Fetch monitoring site table
sites <- dbGetQuery(con, 
                    statement = "SELECT * FROM aqs.site",
                    as.is = TRUE,
                    colClasses = "character")


# Create site ID
sites <- sites %>% 
           rowwise() %>% 
           mutate(site_catid = paste(stateid,
                                     paste0(paste0(rep(0, (3 - nchar(as.character(cntyid)))), collapse = ""), cntyid), 
                                     paste0(paste0(rep(0, (4 - nchar(as.character(siteid)))), collapse = ""), siteid), sep = "-"))


# Join cities
cities <- dbGetQuery(con, 
                     statement = "SELECT * FROM aqs.city_fips",
                     as.is = TRUE)

sites <- left_join(sites, select(cities, cityid, city_name))



# Drop columns
names(sites)

sites <- select(sites, site_catid, city_name, everything(), -gid_cc, -cityid, -id_site, -the_geom)


# Drop sites closed before year 2000
sites <- filter(sites, is.na(terminated) | as.Date(terminated) > as.Date("2000-01-01"))


# SAVE
write_csv(sites, "Monitoring sites/aqs_monitoring_sites_2000_to_current.csv", na = "")
