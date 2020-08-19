## ============================================================================
## make_cra_census.R
## ============================================================================
## Author: AC Forrester
## ============================================================================
## This script reads in the CRA Census flat files and saves them as a CSV.
## It also subsets the Census data to include variables relevant to the CRA 
## and HMDA, i.e. tract median family income, minority population, etc.


## IN PROGRESS

make_cra_census <- function()
{
  
  require(tidyverse)
  
}


census_width <- c(4, 4, 2, 3, 6, 8, 8, 6, 8, 6, 8, 8, rep(8, 7), 3, 1, 1, 1, 1)

census_names <- c('as_of_date', 'msamd', 'state_code', 'county_code',
                  'census_tract', 'population', 'minority_population', 
                  'percent_minority', 'median_family_income', 'tract_to_msa',
                  'hud_area_median_income', 'owner_occupied', 
                  'year_built_1990', 'year_built_1978', 'year_built_1974',
                  'year_built_1969', 'year_built_1959', 'year_built_1949',
                  'year_built_1939', 'median_age', 'central_city_flag',
                  'small_county_flag', 'duplicate_tract_flag',
                  'demographic_data_flag')


setup <- fwf_widths(census_width, census_names)



dat <- read_fwf('../data/census/zip/census1990.zip', setup)













