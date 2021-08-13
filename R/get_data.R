# Download Community Reinvestment Act data
# 
# AC Forrester
# 
# Collect all of the zipped CRA flat files.
#
# The function is called at the end of the file.  
#
# *****************************************************************************

# load packages to use
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse,glue)

# ---------------------------------------------------------------------------- #
# COLLECT DATA ---- 

getCRAdata <- function(zip_dest, 
                       years, 
                       files = c('aggr', 'trans', 'discl', "census"))
{

  # apply
  lapply(files, function(file){
    
    # zip file base
    zip_base <- glue("{zip_dest}/{file}/zip")
    # make directory
    if(!file.exists(zip_base)){
      dir.create(zip_base, recursive = T)
    }    
    
    # apply over years
    lapply(years, function(year){
      # main files
      if(file %in% c('aggr', 'trans', 'discl')){
        # FFIEC URL
        url_base <- 'https://www.ffiec.gov/cra/xls'
        # zip name
        zip_name <- glue("{substr(year, 3, 4)}exp_{file}.zip")
        # file name
        zip_comb <- glue("{zip_base}/{zip_name}")
        url_comb <- glue("{url_base}/{zip_name}")
        
      }
      else if (file %in% "census"){
        # census URL
        url_base <- 'https://www.ffiec.gov/Census/Census_Flat_Files'
        # file name
        zip_comb <- glue("{zip_base}/census{year}.zip")
        
        # change URL for 1990-2007 or 2008-onward
        if(year %in% 1990:2007){
          url_comb <- glue("{url_base}/Zip%20Files/{year}.zip")
        }
        else {
          url_comb <- glue("{url_base}/census{year}.zip")
        }
         
      }
      
      # download the file
      if(!file.exists(zip_comb)){
        download.file(url_comb, zip_comb, mode = 'wb')
      }
      
    })    
    
  })
  
}
  

# ---------------------------------------------------------------------------- #
# CALL FUNCTION ---- 

# last year to get
max_year <- 2019

# go get the data
getCRAdata("./data", 1996:max_year, c('aggr', 'trans', 'discl', "census"))

## EOF