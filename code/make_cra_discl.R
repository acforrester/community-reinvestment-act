make_cra_discl <- function(years, zip_base, csv_base)
{
  
  # requires `tidyverse`
  require(tidyverse)
  
  # apply over years 
  lapply(years, function(year){
    
    # zip file name
    zip_name <- paste0(sprintf('%02.0f', year %% 100), 'exp_', 'discl', '.zip')
    
    # make directories
    if(!file.exists(csv_base)){
      dir.create(csv_base, recursive = T)
    }
    
    ## ----------------------------------------------------- ##
    ## SET COL NAMES
    
    # county/bank
    county_names <- c('table_id'      , 'respondent_id', 'agency_code',
                      'activity_year' , 'loan_type', 'action_taken_type',
                      'state_code'    , 'county_code', 'msamd', 'assessment_area_num',
                      'partial_county', 'split_county', 'population_class',
                      'income_group'  , 'report_level', 
                      'num_loans_100k', 'vol_loans_100k',
                      'num_loans_250k', 'vol_loans_250k',
                      'num_loans_1mil', 'vol_loans_1mil',
                      'num_loans_1mil_rev', 'vol_loans_1mil_rev',
                      'num_affiliate' , 'vol_affiliate')
    
    # assessment area activity
    if(year == 1996){
      
      activity_names <- c('table_id', 'respondent_id', 'agency_code', 
                          'activity_year', 'loan_type', 'state_code', 
                          'county_code', 'msamd', 
                          'assessment_area_num', 'partial_county', 'split_county',
                          'report_level', 'num_originated', 'vol_originated',
                          'num_purchased', 'vol_purchased', 'filler')
      
    } else {
      
      activity_names <- c('table_id', 'respondent_id', 'agency_code', 
                          'activity_year', 'loan_type', 'state_code',
                          'county_code', 'msamd', 
                          'assessment_area_num', 'partial_county', 'split_county',
                          'report_level', 'num_originated', 'vol_originated',
                          'num_originated_1mil_grev', 'vol_originated_1mil_grev',
                          'num_purchased', 'vol_purchased', 'filler')
    }
    
    # community dev/consortium
    commdev_names <- c()
    
    # assessment areas
    assess_names <- c('table_id', 'respondent_id', 'agency_code', 'activity_year',
                      'state_code', 'county_code', 'msamd', 'census_tract', 
                      'assessment_area_num', 'partial_county', 'split_county',
                      'population_class', 'income_group', 'loan_indicator', 'filler')
    
    ## --------------------------------------------------- ##
    ## SET WIDTHS BY YEAR
    
    if(year == 1996){
      county_width <- c(4, 10, 1, 4, 1, 1, 2, 3, 4, 4, 1, 1, 1, 3, 3, rep(c(6,8), times = 5))
      #comdev_width <- c()
      #active_width <- c()
      assess_width <- c(4, 10, 1, 4, 2, 3, 4, 7, 4, 1, 1, 1, 3, 1, 60)
      
    } else if(year %in% 1997:2003){
      county_width <- c(5, 10, 1, 4, 1, 1, 2, 3, 4, 4, 1, 1, 1, 3, 3, rep(c(6,8), times = 5))
      #comdev_width <- c()
      #active_width <- c()
      assess_width <- c(5, 10, 1, 4, 2, 3, 4, 7, 4, 1, 1, 1, 3, 1, 67)
      
    } else  if(year %in% 2004:2020){
      county_width <- c(5, 10, 1, 5, 1, 1, 2, 3, 4, 4, 1, 1, 1, 3, 3, rep(10, times = 10))
      #comdev_width <- c()
      #active_width <- c()
      assess_width <- c(4, 10, 1, 4, 2, 3, 5, 7, 4, 1, 1, 1, 3, 1, 96)
      
    }
    
    # flat file years
    if (year %in% 1996:2015){
      
      ## --------------------------------------------------- ##
      ## PRE LOAD DATA
      
      # zip file
      zip_file <- paste0(zip_base, '/', zip_name)
      
      # load data
      dat <- read_file(zip_file)
      
      
      ## --------------------------------------------------- ##
      ## ORIGINATIONS BY COUNTY/BANK (1996-2015)
      
      # output CSV
      csv_name <- paste0(csv_base, '/', 'discl_county_', year, '.csv')
      
      # tables to keep
      table_keep <- c('D1-1', 'D2-1', 'D2-1', 'D2-2')
      
      # make setup
      setup <- fwf_widths(county_width, county_names)
      
      # read/subset
      dat_discl <- read_fwf(dat, setup) %>% 
        filter(table_id %in% table_keep) %>% 
        mutate(across(starts_with(c('num', 'vol')), as.numeric))
      
      # write csv
      write_csv(dat_discl, csv_name, na = '')
      
      # clean up
      rm(dat_discl); gc()
      
      
      ## --------------------------------------------------- ##
      ## ASSESSMENT AREA ACTIVITY (1996-2015)
      
      
      # to-do
      
      
      ## --------------------------------------------------- ##
      ## COMMUNITY DEV./CONSORTIUM ACTIVITY (1996-2015)
      
      
      # to-do
      
      
      ## --------------------------------------------------- ##
      ## ASSESSMENT AREAS BY TRACT/BANK (1996-2015)
      
      # output CSV
      csv_name <- paste0(csv_base, '/', 'discl_assess_', year, '.csv')
      
      # tables to keep
      table_keep <- c('D6-0')
      
      # make setup
      setup <- fwf_widths(assess_width, assess_names)
      
      # read/subset
      dat_discl <- read_fwf(dat, setup, col_types = cols(.default = 'c')) %>% 
        filter(table_id %in% table_keep) %>% 
        select(-filler)
      
      # write csv
      write_csv(dat_discl, csv_name, na = '')
      
      # clean up
      rm(dat_discl); gc()
      
      
    }
    
    
    ## ----------------------------------------------------- ##
    ## YEARS 2016-PRESENT
    
    if(year %in% 2016:2020){
      
      ## --------------------------------------------------- ##
      ## HELPER FUNCTION
      
      read_cra_tables <- function(table){
        dat_name <- paste0(zip_base, '/', 'cra', year, '_Discl_', table, '.dat')
        dat <- read_fwf(dat_name, setup, col_types = cols(.default = "c"))
        file.remove(dat_name)
        return(dat)
      }
      
      
      ## --------------------------------------------------- ##
      ## UNZIP DATA TO ZIP DIRECTORY
      
      # zip file
      zip_file <- paste0(zip_base, '/', zip_name)
      
      # unzip files
      unzip(zip_file, exdir = zip_base)
      
      
      ## --------------------------------------------------- ##
      ## ORIGINATIONS BY COUNTY/BANK (2016-PRESENT)
      
      # output CSV
      csv_name <- paste0(csv_base, '/', 'discl_county_', year, '.csv')
      
      # tables to keep
      table_keep <- c('D11', 'D12', 'D21', 'D22')
      
      # make setup
      setup <- fwf_widths(county_width, county_names)
      
      # read in each file
      dat_discl <- lapply(table_keep, read_cra_tables) %>% bind_rows()
      
      # write csv
      write_csv(dat_discl, csv_name, na = '')
      
      # clean up
      rm(dat_discl); gc()
      
      
      ## --------------------------------------------------- ##
      ## ASSESSMENT AREA ACTIVITY (1996-2015)
      
      
      # to-do
      
      
      ## --------------------------------------------------- ##
      ## COMMUNITY DEV./CONSORTIUM ACTIVITY (1996-2015)
      
      
      # to-do
      
      
      ## --------------------------------------------------- ##
      ## ASSESSMENT AREAS BY TRACT/BANK (2016-PRESENT)
      
      # output CSV
      csv_name <- paste0(csv_base, '/', 'discl_assess_', year, '.csv')
      
      # tables to keep
      table_keep <- c('D6')
      
      # make setup
      setup <- fwf_widths(assess_width, assess_names)
      
      # read in each file
      dat_discl <- lapply(table_keep, read_cra_tables) %>% bind_rows()
      
      # write csv
      write_csv(dat_discl, csv_name, na = '')
      
      
    }
  
    })
     
}

  
     
    
    














