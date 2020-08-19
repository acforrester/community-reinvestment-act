
get_cra_data <- function(years, files, zip_dest)
{

  # apply
  lapply(files, function(file){
    
    # zip file base
    zip_base <- paste0(zip_dest, '/', file, '/zip')  
    
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
        zip_name <- paste0(sprintf('%02.0f', year %% 100), 'exp_', file, '.zip')
        
        # file name
        zip_comb <- paste0(zip_base, '/', zip_name)
        url_comb <- paste0(url_base, '/', zip_name)
        
      }
      else {
        
        # census URL
        url_base <- 'https://www.ffiec.gov/Census/Census_Flat_Files'
        
        # file name
        zip_comb <- paste0(zip_base, '/', 'census', year, '.zip')
        
        # change URL for 1990-2007 or 2008-onward
        if(year %in% 1990:2007){
          url_comb <- paste0(url_base, '/Zip%20Files/', year, '.zip')
        }
        else {
          url_comb <- paste0(url_base, '/', 'census', year, '.zip')
        }
         
      }
      
      # download the file
      if(!file.exists(zip_comb)){
        
        download.file(url_comb, zip_comb, mode = 'wb')
        
      }
      
    })    
    
  })
  
}
  

