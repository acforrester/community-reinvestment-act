

 

year <- 2018

csv_base <- '../data/trans/csv'
zip_base <- '../data/trans/zip'



make_cra_trans <- function(years, zip_base, csv_base)
{
  
  # apply over years
  lapply(years, function(year){
    
    # zip file name
    zip_name <- paste0(sprintf('%02.0f', year %% 100), 'exp_', 'trans', '.zip')
    
    # zip file
    zip_file <- paste0(zip_base, '/', zip_name)
    
    # make directories
    if(!file.exists(csv_base)){
      dir.create(csv_base, recursive = T)
    }
    
    ## ----------------------------------------------------- ##
    ## SET COL NAMES
    
    if(year == 1996){
      
      # column names
      trans_names <- c('respondent_id', 'agency_code', 'activity_year', 
                       'respondent_name', 'respondent_address', 
                       'respondent_city', 'respondent_state', 
                       'respondent_zip', 'tax_id')
      # column widths
      trans_widths <- c(10, 1, 4, 30, 40, 25, 2, 10, 10)
      
    } else {
      
      # column names
      trans_names <- c('respondent_id', 'agency_code', 'activity_year', 
                       'respondent_name', 'respondent_address', 
                       'respondent_city', 'respondent_state', 
                       'respondent_zip', 'tax_id', 'id_rssd', 'assets')
      
      # column widths
      trans_widths <- c(10, 1, 4, 30, 40, 25, 2, rep(10, 4))
      
    }
    
    ## --------------------------------------------------- ##
    ## TRANSMITTAL SHEET
    
    # output CSV
    csv_name <- paste0(csv_base, '/', 'transmittal_', year, '.csv')
    
    # make setup
    setup <- fwf_widths(trans_widths, trans_names)
    
    # read/subset
    dat_trans <- read_fwf(zip_file, setup)
    
    # write csv
    write_csv(dat_trans, csv_name, na = '')
    
    # clean up
    rm(dat_trans); gc()
    
  })
  
}

