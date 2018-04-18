library(tidyverse)


# Load current MET site list
mets <- read_csv("MET data/MN area MET sites.csv")


## Add active years
met_file_folder <- "X:\\Agency_Files\\Outcomes\\Risk_Eval_Air_Mod\\Air_Modeling\\MNwx Observations\\Single site files"

years <- list.files(met_file_folder) %>% as.numeric()

mets <- mets %>% rowwise() %>% mutate(years = list(c(NA)))

mets$years

for (i in years) {
  
  sites_active <- list.files(paste0(met_file_folder, "/", i)) %>% substring(1,3)
  
  mets <- mets %>% 
            rowwise() %>% 
            mutate(years = if_else(`Call Sign` %in% sites_active, list(c(years, i)), list(years)))
  
}


# Find Min and Max year
mets <- mets %>% 
          rowwise() %>% 
          mutate(start_year = min(unlist(years), na.rm = T),
                 end_year   = max(unlist(years), na.rm = T),
                 years      = list(years[!is.na(years)]),
                 years      = ifelse(length(years) < 1, NA, paste0(unlist(years), collapse = " ")))


# Replace INF
mets$start_year[mets$start_year == Inf] <- NA
mets$end_year[mets$end_year == -Inf] <- NA


# Save results
write_csv(mets, "MET data/MN area MET sites2.csv")


