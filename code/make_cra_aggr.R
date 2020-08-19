make_cra_aggr <- function(years, zip_base, csv_base)
{
  
  # requires `tidyverse`
  require(tidyverse)
  
  # apply over years
  lapply(years, function(year){
    
    # zip file name
    zip_name <- paste0(sprintf('%02.0f', year %% 100), 'exp_', 'aggr', '.zip')
    
    
    # make directories
    if(!file.exists(csv_base)){
      dir.create(csv_base, recursive = T)
    }
    
    
    ## ----------------------------------------------------- ##
    ## SET COL NAMES
    
    # tract column names
    area_names <- c('table_id'          , 'activity_year'     , 'loan_type', 
                    'action_taken_type' , 'state_code'        , 'county_code', 
                    'msamd'             , 'census_tract'      , 'split_county', 
                    'population_class'  , 'income_group'      , 'report_level',
                    'num_loans_100k'    , 'vol_loans_100k'    , 'num_loans_250k', 
                    'vol_loans_250k'    , 'num_loans_1mil'    , 'vol_loans_1mil', 
                    'num_loans_1mil_rev', 'vol_loans_1mil_rev', 'filler')
    
    # county/bank
    cnty_names <- c('table_id', 'activity_year', 'loan_type', 'action_taken_type',
                    'state_code', 'county_code', 'msamd', 'respondent_id',
                    'agency_code', 'num_lenders', 'report_level', 
                    'num_loans_total', 'vol_loans_total', 
                    'num_loans_1mil_rev', 'vol_loans_1mil_rev', 'filler')
    
    ## --------------------------------------------------- ##
    ## SET WIDTHS BY YEAR
    
    if(year == 1996){
      area_width <- c(4, 4, 1, 1, 2, 3, 4, 7, 1, 1, 3, 3, rep(c(6,8), times = 4), 23)
    }
    if(year %in% 1997:2003){
      area_width <- c(5, 4, 1, 1, 2, 3, 4, 7, 1, 1, 3, 3, rep(c(6,8), times = 4), 23)
      cnty_width <- c(5, 4, 1, 1, 2, 3, 4, 10, 1, 5, 3, 6, 8, 6, 8, 47)
    }
    if(year %in% 2004:2020){
      area_width <- c(5, 4, 1, 1, 2, 3, 5, 7, 1, 1, 3, 3, rep(10, times = 8), 29)
      cnty_width <- c(5, 4, 1, 1, 2, 3, 5, 10, 1, 5, 3, rep(10, times = 4), 65)
    }
    
    ## ----------------------------------------------------- ##
    ## FLAT FILE YEARS 1996-2015
    
    if(year %in% 1996:2015){
      
      
      ## --------------------------------------------------- ##
      ## PRE LOAD DATA
      
      # zip file
      zip_file <- paste0(zip_base, '/', zip_name)
      
      # load data
      dat <- read_file(zip_file)
      
      
      ## --------------------------------------------------- ##
      ## ORIGINATIONS BY TRACT (1996-2015)
      
      # output CSV
      csv_name <- paste0(csv_base, '/', 'aggr_tract_', year, '.csv')
      
      # tables to keep
      table_keep <- c('A1-1', 'A2-1', 'A2-1', 'A2-2')
      
      # make setup
      setup <- fwf_widths(area_width, area_names)
      
      # read/subset
      dat_aggr <- read_fwf(dat, setup) %>% 
        filter(table_id %in% table_keep) %>% 
        select(-filler)
      
      # write csv
      write_csv(dat_aggr, csv_name, na = '')
      
      # clean up
      rm(dat_aggr); gc()
      
      ## --------------------------------------------------- ##
      ## ORIGINATIONS BY COUNTY/BANK (1997-2015)
      
      if(year %in% 1997:2015){
        
        # output CSV
        csv_name <- paste0(csv_base, '/', 'aggr_cnty_', year, '.csv')
        
        # tables to keep
        table_keep <- c('A1-1a', 'A2-1a', 'A2-1a', 'A2-2a')
        
        # make setup
        setup <- fwf_widths(cnty_width, cnty_names)
        
        # read/subset
        dat_aggr <- read_fwf(dat, setup) %>% 
          filter(table_id %in% table_keep) %>% 
          select(-filler)
        
        # write csv
        write_csv(dat_aggr, csv_name, na = '')
        
        # clean up
        rm(dat_aggr); gc()
        
      }
      
    }
    
    ## ----------------------------------------------------- ##
    ## YEARS 2016-PRESENT
    
    if(year %in% 2016:2020){
      
      ## --------------------------------------------------- ##
      ## HELPER FUNCTION
      
      read_cra_tables <- function(table){
        dat_name <- paste0(zip_base, '/', 'cra', year, '_Aggr_', table, '.dat')
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
      ## ORIGINATIONS BY TRACT (2016-PRESENT)
      
      # output CSV
      csv_name <- paste0(csv_base, '/', 'aggr_tract_', year, '.csv')
      
      # tables to keep
      table_keep <- c('A11', 'A12', 'A21', 'A22')
      
      # make setup
      setup <- fwf_widths(area_width, area_names)
      
      # read in each file
      dat_aggr <- lapply(table_keep, read_cra_tables) %>% bind_rows()
      
      # write csv
      write_csv(dat_aggr, csv_name, na = '')
      
      # clean up
      rm(dat_aggr); gc()
      
      ## --------------------------------------------------- ##
      ## ORIGINATIONS BY COUNTY/BANK (2016-PRESENT)
      
      # output CSV
      csv_name <- paste0(csv_base, '/', 'aggr_cnty_', year, '.csv')
      
      # tables to keep
      table_keep <- c('A11a', 'A12a', 'A21a', 'A22a')
      
      # make setup
      setup <- fwf_widths(cnty_width, cnty_names)
      
      # read in each file
      dat_aggr <- lapply(table_keep, read_cra_tables) %>% bind_rows()
      
      # write csv
      write_csv(dat_aggr, csv_name, na = '')
      
      # clean up
      rm(dat_aggr); gc()
      
    }
    
  })
 
}




