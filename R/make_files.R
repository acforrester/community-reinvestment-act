# Assemble Community Reinvestment Act data
# 
# AC Forrester
# 
# Take the fixed width text files and convert them into pipe delimited files
# for future manipulation.  Data are diveded into 3 reports:
#  1. Aggregate data    - lending by census tract and by county/bank
#  2. Disclosure data   - lending by county/bank, lending in/put of assessment
#                         areas, assessment area delineations by census tract/
#                         bank
#  3. Transmittal sheet - lenders reporting in each year with identifiers to 
#                         match with additional Fed/FDIC/FFIEC data 
#
# The functions are called at the end of the file.  Prior versions of these
# functions have been coalesced into a single script.
#
# *****************************************************************************

# ---------------------------------------------------------------------------- #
# DISCLOSURE DATA ---- 

makeCRAdiscl <- function(years,
                         tables_to_load = c("county", 
                                            "aa_activity",
                                            "cmmty_dev",
                                            "aa_areas"))
{
  
  # requires `tidyverse` and `glue`
  require(tidyverse)
  require(glue)
  
  # apply over years 
  lapply(years, function(year){
    
    # can pre-load prior flat files
    if(year < 2016){
      
      zip_file <- read_file_raw(
        glue("./data/discl/zip/{sprintf('%02.0f', year %% 100)}exp_discl.zip")
      )
      
    } else if(year >= 2016) {
      
      zip_file <- glue("./data/discl/zip/{sprintf('%02.0f', year %% 100)}exp_discl.zip")
      
    }
  
    # apply over requested tables
    lapply(tables_to_load, function(table){
      
      # ------------------------------------------------------------------------ #
      # Loans by county
      
      if(table == "county") {
        
        # tables to subset (remove `-` in post 2015 data)
        tables_to_keep <- c("D1-1", "D1-2", "D2-1", "D2-2")
        if(year > 2015) tables_to_keep <- gsub("-", "", tables_to_keep) 
        
        ## ----------------------------------------------------- ##
        ## SET COL TYPES
        
        cra_types = cols(
          
          agency_code   = "i",
          activity_year = "i",
          action_taken  = "i",
          num_100k      = "d",
          vol_100k      = "d",
          num_250k      = "d",
          vol_250k      = "d",
          num_1mil      = "d",
          vol_1mil      = "d",
          num_sbus      = "d",
          vol_sbus      = "d",
          num_affl      = "d",
          vol_affl      = "d",
          .default      = "c"
        )
        
        ## ----------------------------------------------------- ##
        ## SET COL NAMES
        
        if(year == 1996){
          
          cra_cols <- fwf_cols(
            table_id       = c(  1,  4),
            respondent_id  = c(  5, 14),
            agency_code    = c( 15, 15),
            activity_year  = c( 16, 19),
            loan_type      = c( 20, 20),
            action_taken   = c( 21, 21),
            state          = c( 22, 23),
            county         = c( 24, 26),
            msamd          = c( 27, 30),
            aa_num         = c( 31, 34),
            partial_county = c( 35, 35),
            split_county   = c( 36, 36),
            pop_group      = c( 37, 37),
            income_group   = c( 38, 40),
            report_level   = c( 42, 43),
            num_100k       = c( 44, 49),
            vol_100k       = c( 50, 57),
            num_250k       = c( 58, 63),
            vol_250k       = c( 64, 71),
            num_1mil       = c( 72, 77),
            vol_1mil       = c( 78, 85),
            num_sbus       = c( 86, 91),
            vol_sbus       = c( 92, 99),
            num_affl       = c(100,105),
            vol_affl       = c(106,113)
          )
          
        }
        else if(year %in% 1997:2003){
          
          cra_cols <- fwf_cols(
            table_id       = c(  1,  5),
            respondent_id  = c(  6, 15),
            agency_code    = c( 16, 16),
            activity_year  = c( 17, 20),
            loan_type      = c( 21, 21),
            action_taken   = c( 22, 22),
            state          = c( 23, 24),
            county         = c( 25, 27),
            msamd          = c( 28, 31),
            aa_num         = c( 32, 35),
            partial_county = c( 36, 36),
            split_county   = c( 37, 37),
            pop_group      = c( 38, 38),
            income_group   = c( 39, 41),
            report_level   = c( 42, 44),
            num_100k       = c( 45, 50),
            vol_100k       = c( 51, 58),
            num_250k       = c( 59, 64),
            vol_250k       = c( 65, 72),
            num_1mil       = c( 73, 78),
            vol_1mil       = c( 79, 86),
            num_sbus       = c( 87, 92),
            vol_sbus       = c( 93,100),
            num_affl       = c(101,106),
            vol_affl       = c(107,114)
          )
          
        }
        else if(year > 2003) {
          
          cra_cols <- fwf_cols(
            table_id       = c(  1,  5),
            respondent_id  = c(  6, 15),
            agency_code    = c( 16, 16),
            activity_year  = c( 17, 20),
            loan_type      = c( 21, 21),
            action_taken   = c( 22, 22),
            state          = c( 23, 24),
            county         = c( 25, 27),
            msamd          = c( 28, 32),
            aa_num         = c( 33, 36),
            partial_county = c( 37, 37),
            split_county   = c( 38, 38),
            pop_group      = c( 39, 39),
            income_group   = c( 40, 42),
            report_level   = c( 43, 45),
            num_100k       = c( 46, 55),
            vol_100k       = c( 56, 65),
            num_250k       = c( 66, 75),
            vol_250k       = c( 76, 85),
            num_1mil       = c( 86, 95),
            vol_1mil       = c( 96,105),
            num_sbus       = c(106,115),
            vol_sbus       = c(116,125),
            num_affl       = c(126,135),
            vol_affl       = c(135,145)
          )
          
        }
        
      }
      
      # ------------------------------------------------------------------------ #
      # Assessment Area Activity
      
      if (table == "aa_activity") {
        
        # tables to subset (remove `-` in post 2015 data)
        tables_to_keep <- c("D3-0", "D4-0")
        if(year > 2015) tables_to_keep <- gsub("-0", "", tables_to_keep)
        
        ## ----------------------------------------------------- ##
        ## SET COL TYPES
        
        if (year== 1996) {
          
          cra_types = cols(
            agency_code   = "i",
            activity_year = "i",
            loan_type     = "i",
            num_orig      = "d",
            vol_orig      = "d",
            num_prchsd    = "d",
            vol_prchsd    = "d",
            .default      = "c"
          )
          
        } else if (year > 1996) {
          
          cra_types = cols(
            agency_code   = "i",
            activity_year = "i",
            loan_type     = "i",
            num_orig      = "d",
            vol_orig      = "d",
            num_small     = "d",
            vol_small     = "d",
            num_prchsd    = "d",
            vol_prchsd    = "d",
            .default      = "c"
          )
          
        }
        
        ## ----------------------------------------------------- ##
        ## SET COL NAMES
        
        if(year == 1996) {
          
          cra_cols <- fwf_cols(
            table_id       = c(  1,  4),
            respondent_id  = c(  5, 14),
            agency_code    = c( 15, 15),
            activity_year  = c( 16, 19),
            loan_type      = c( 20, 20),
            state          = c( 21, 22),
            county         = c( 23, 25),
            msamd          = c( 26, 29),
            aa_num         = c( 30, 33),
            partial_county = c( 34, 34),
            split_county   = c( 35, 35),
            report_level   = c( 36, 37),
            num_orig       = c( 38, 43),
            vol_orig       = c( 44, 51),
            num_prchsd     = c( 52, 57),
            vol_prchsd     = c( 58, 65)
          )
          
        } else if (year %in% 1997:2003) {
          
          cra_cols <- fwf_cols(
            table_id       = c(  1,  5),
            respondent_id  = c(  6, 15),
            agency_code    = c( 16, 16),
            activity_year  = c( 17, 20),
            loan_type      = c( 21, 21),
            state          = c( 22, 23),
            county         = c( 24, 26),
            msamd          = c( 27, 30),
            aa_num         = c( 31, 34),
            partial_county = c( 35, 35),
            split_county   = c( 36, 36),
            report_level   = c( 37, 38),
            num_orig       = c( 39, 44),
            vol_orig       = c( 45, 52),
            num_small      = c( 53, 58),
            vol_small      = c( 59, 66),
            num_prchsd     = c( 67, 72),
            vol_prchsd     = c( 73, 80)
          )
          
        } else if (year > 2003) {
          
          cra_cols <- fwf_cols(
            table_id       = c(  1,  5),
            respondent_id  = c(  6, 15),
            agency_code    = c( 16, 16),
            activity_year  = c( 17, 20),
            loan_type      = c( 21, 21),
            state          = c( 22, 23),
            county         = c( 24, 26),
            msamd          = c( 27, 31),
            aa_num         = c( 32, 35),
            partial_county = c( 36, 36),
            split_county   = c( 37, 37),
            report_level   = c( 38, 39),
            num_orig       = c( 40, 49),
            vol_orig       = c( 50, 59),
            num_small      = c( 60, 69),
            vol_small      = c( 70, 79),
            num_prchsd     = c( 80, 89),
            vol_prchsd     = c( 90, 99)
          )
          
        }
        
      }
      
      # ------------------------------------------------------------------------ #
      # Community Development and Consortium/Third-Party Activity
      
      if (table == "cmmty_dev") {
        
        tables_to_keep <- c("D5-0")
        if(year > 2015) tables_to_keep <- gsub("-0", "", tables_to_keep)
        
        ## ----------------------------------------------------- ##
        ## SET COL TYPES
        
        cra_types = cols(
          agency_code   = "i",
          activity_year = "i",
          loan_type     = "i",
          num_of_loans  = "d",
          vol_of_loans  = "d",
          num_affil     = "d",
          vol_affil     = "d",
          .default      = "c"
        )
        
        ## ----------------------------------------------------- ##
        ## SET COL NAMES
        
        if (year == 1996) {
          cra_cols <- fwf_cols(
            table_id       = c(  1,  4),
            respondent_id  = c(  5, 14),
            agency_code    = c( 15, 15),
            activity_year  = c( 16, 19),
            loan_type      = c( 20, 20),
            num_of_loans   = c( 21, 26),
            vol_of_loans   = c( 27, 34),
            num_affil      = c( 35, 40),
            vol_affil      = c( 41, 48)
          )
        } else if (year %in% 1997:2003) {
          cra_cols <- fwf_cols(
            table_id       = c(  1,  5),
            respondent_id  = c(  6, 15),
            agency_code    = c( 16, 16),
            activity_year  = c( 17, 20),
            loan_type      = c( 21, 21),
            num_of_loans   = c( 22, 27),
            vol_of_loans   = c( 28, 35),
            num_affil      = c( 36, 41),
            vol_affil      = c( 42, 49)
          )
        } else if (year > 2003) {
          cra_cols <- fwf_cols(
            table_id       = c(  1,  5),
            respondent_id  = c(  6, 15),
            agency_code    = c( 16, 16),
            activity_year  = c( 17, 20),
            loan_type      = c( 21, 21),
            num_of_loans   = c( 22, 31),
            vol_of_loans   = c( 32, 41),
            num_affil      = c( 42, 51),
            vol_affil      = c( 52, 61),
            action_taken   = c( 62, 62)
          )
        }
        
      }
      
      # ------------------------------------------------------------------------ #
      # Assessment Area Delineations
      
      if(table == "aa_areas") {
        
        tables_to_keep <- c("D6-0")
        if(year > 2015) tables_to_keep <- gsub("-0", "", tables_to_keep)
        
        ## ----------------------------------------------------- ##
        ## SET COL TYPES
        
        cra_types = cols(
          agency_code   = "i",
          activity_year = "i",
          .default      = "c"
        )
        
        ## ----------------------------------------------------- ##
        ## SET COL NAMES
        
        if (year == 1996) {
          
          cra_cols <- fwf_cols(
            table_id       = c(  1,  4),
            respondent_id  = c(  5, 14),
            agency_code    = c( 15, 15),
            activity_year  = c( 16, 19),
            state          = c( 20, 21),
            county         = c( 22, 24),
            msamd          = c( 25, 28),
            census_tract   = c( 29, 35),
            aa_num         = c( 36, 39),
            partial_county = c( 40, 40),
            split_county   = c( 41, 41),
            pop_group      = c( 42, 42),
            income_group   = c( 43, 45),
            loan_indicator = c( 46, 46)
          )
          
        } else if (year %in% 1997:2003) {
          
          cra_cols <- fwf_cols(
            table_id       = c(  1,  5),
            respondent_id  = c(  6, 15),
            agency_code    = c( 16, 16),
            activity_year  = c( 17, 20),
            state          = c( 21, 22),
            county         = c( 23, 25),
            msamd          = c( 26, 29),
            census_tract   = c( 30, 36),
            aa_num         = c( 37, 40),
            partial_county = c( 41, 41),
            split_county   = c( 42, 42),
            pop_group      = c( 43, 43),
            income_group   = c( 44, 46),
            loan_indicator = c( 47, 47)
          )
          
        } else if (year > 2003) {
          
          cra_cols <- fwf_cols(
            table_id       = c(  1,  5),
            respondent_id  = c(  6, 15),
            agency_code    = c( 16, 16),
            activity_year  = c( 17, 20),
            state          = c( 21, 22),
            county         = c( 23, 25),
            msamd          = c( 26, 30),
            census_tract   = c( 31, 37),
            aa_num         = c( 38, 41),
            partial_county = c( 42, 42),
            split_county   = c( 43, 43),
            pop_group      = c( 44, 44),
            income_group   = c( 45, 47),
            loan_indicator = c( 48, 48)
            
          )
        }
        
      }
      
      # ------------------------------------------------------------------------ #
      # Write as pipe delimited files
      
      if (year < 2016) {
        
        read_fwf(zip_file,
                 col_positions = cra_cols,
                 col_types = cra_types) %>% 
          # keep relevant tables
          filter(table_id %in% tables_to_keep) %>% 
          # write the piped file
          write_delim(.,
                      glue("./data/discl/{table}_{year}.txt"),
                      delim = "|",
                      na = "")    
        
      } else {
        
        map_df(tables_to_keep, function(file){
          txt_file <- glue("cra{year}_Discl_{file}.dat")
          foo <- read_fwf(
            unzip(zip_file, txt_file),
            col_positions = cra_cols,
            col_types = cra_types
          )
        }) %>% write_delim(.,
                           glue("./data/discl/{table}_{year}.txt"),
                           delim = "|",
                           na = "")
        
      }
      
      # clean up
      gc(full = T, verbose = F)
      
    }) # end over tables
    
    rm(zip_file)
    
  }) # end over years
  
}

# ---------------------------------------------------------------------------- #
# AGGREGATE FILE ---- 

# TO-DO -> pre-load the pre-2015 zipped data

# TO-DO -> add `tables to keep` similar to disclosure function

makeCRAaggr <- function(years) {
  
  # requires `tidyverse` and `glue`
  require(tidyverse)
  require(glue)
  
  # apply over years
  lapply(years, function(year){
    
    # zip file name
    zip_file <- glue("./data/aggr/zip/{sprintf('%02.0f', year %% 100)}exp_aggr.zip")
    
    # ------------------------------------------------------------------------ #
    # Loans by county
    
    ## ----------------------------------------------------- ##
    ## SET COL TYPES
    
    cra_types = cols(
      activity_year = "i",
      loan_type     = "i",
      action_taken  = "i",
      num_100k      = "d",
      vol_100k      = "d",
      num_250k      = "d",
      vol_250k      = "d",
      num_1mil      = "d",
      vol_1mil      = "d",
      num_sbus      = "d",
      vol_sbus      = "d",
      .default      = "c"
    )
    
    ## ----------------------------------------------------- ##
    ## SET COL NAMES
    
    if(year == 1996){
      cra_cols <- fwf_cols(
        table_id       = c(  1,  4),
        activity_year  = c(  5,  8),
        loan_type      = c(  9,  9),
        action_taken   = c( 10, 10),
        state          = c( 11, 12),
        county         = c( 13, 15),
        msamd          = c( 16, 19),
        census_tract   = c( 20, 26),
        split_county   = c( 27, 27),
        pop_group      = c( 28, 28),
        income_group   = c( 29, 31),
        report_level   = c( 32, 34),
        num_100k       = c( 35, 40),
        vol_100k       = c( 41, 48),
        num_250k       = c( 49, 54),
        vol_250k       = c( 55, 62),
        num_1mil       = c( 63, 68),
        vol_1mil       = c( 69, 76),
        num_sbus       = c( 77, 82),
        vol_sbus       = c( 83, 90)
      )
    } else if (year %in% 1997:2003) {
      cra_cols <- fwf_cols(
        table_id       = c(  1,  5),
        activity_year  = c(  6,  9),
        loan_type      = c( 10, 10),
        action_taken   = c( 11, 11),
        state          = c( 12, 13),
        county         = c( 14, 16),
        msamd          = c( 17, 20),
        census_tract   = c( 21, 27),
        split_county   = c( 28, 28),
        pop_group      = c( 29, 29),
        income_group   = c( 30, 32),
        report_level   = c( 33, 35),
        num_100k       = c( 36, 41),
        vol_100k       = c( 42, 49),
        num_250k       = c( 50, 55),
        vol_250k       = c( 56, 63),
        num_1mil       = c( 64, 69),
        vol_1mil       = c( 70, 77),
        num_sbus       = c( 78, 83),
        vol_sbus       = c( 84, 91)
        ) 
      } else if (year > 2003) {
        cra_cols <- fwf_cols(
          table_id       = c(  1,  5),
          activity_year  = c(  6,  9),
          loan_type      = c( 10, 10),
          action_taken   = c( 11, 11),
          state          = c( 12, 13),
          county         = c( 14, 16),
          msamd          = c( 17, 21),
          census_tract   = c( 22, 28),
          split_county   = c( 29, 29),
          pop_group      = c( 30, 30),
          income_group   = c( 31, 33),
          report_level   = c( 34, 36),
          num_100k       = c( 37, 46),
          vol_100k       = c( 47, 56),
          num_250k       = c( 57, 66),
          vol_250k       = c( 67, 76),
          num_1mil       = c( 77, 86),
          vol_1mil       = c( 87, 96),
          num_sbus       = c( 97,106),
          vol_sbus       = c(107,116) 
        )
      }
    
    ## ----------------------------------------------------- ##
    ## WRITE AS PIPE DELIM FILES
    
    if (year < 2016) {
      read_fwf(zip_file,
               col_positions = cra_cols,
               col_types = cra_types) %>%
        # keep relevant tables
        filter(table_id %in% c("A1-1", "A1-2", "A2-1", "A2-2")) %>% 
        # write the piped file
        write_delim(.,
                    glue("./data/aggr/tract_{year}.txt"),
                    delim = "|",
                    na = "")    
    } else {
      map_df(c("A11", "A12", "A21", "A22"), function(file){
        txt_file <- glue("cra{year}_Aggr_{file}.dat")
        foo <- read_fwf(
          unzip(zip_file, txt_file),
          col_positions = cra_cols,
          col_types = cra_types
        )
      }) %>% write_delim(.,
                         glue("./data/aggr/tract_{year}.txt"),
                         delim = "|",
                         na = "")
    }
    
    # clean up
    gc(full = T)
    
    # ------------------------------------------------------------------------ #
    # Loans by lenders in area
    
    ## ----------------------------------------------------- ##
    ## SET COL TYPES
    
    cra_types = cols(
      activity_year  = "i",
      loan_type      = "i",
      action_taken   = "i",
      agency_code    = "i",
      num_of_lenders = "i", 
      num_loans      = "d",
      vol_loans      = "d",
      num_small      = "d",
      vol_small      = "d",
      .default       = "c"
    )
    
    ## ----------------------------------------------------- ##
    ## SET COL NAMES
    
    if (year %in% 1997:2003) {
      
      cra_cols <- fwf_cols(
        table_id       = c(  1,  5),
        activity_year  = c(  6,  9),
        loan_type      = c( 10, 10),
        action_taken   = c( 11, 11),
        state          = c( 12, 13),
        county         = c( 14, 16),
        msamd          = c( 17, 20),
        respondent_id  = c( 21, 30),
        agency_code    = c( 31, 31),
        num_of_lenders = c( 32, 36),
        report_level   = c( 37, 39),
        num_loans      = c( 40, 45),
        vol_loans      = c( 46, 53),
        num_small      = c( 54, 59),
        vol_small      = c( 60, 67)
      )
      
    } else if (year > 2003) {
      
      cra_cols <- fwf_cols(
        table_id       = c(  1,  5),
        activity_year  = c(  6,  9),
        loan_type      = c( 10, 10),
        action_taken   = c( 11, 11),
        state          = c( 12, 13),
        county         = c( 14, 16),
        msamd          = c( 17, 21),
        respondent_id  = c( 22, 31),
        agency_code    = c( 32, 32),
        num_of_lenders = c( 33, 37),
        report_level   = c( 38, 40),
        num_loans      = c( 41, 50),
        vol_loans      = c( 51, 60),
        num_small      = c( 61, 70),
        vol_small      = c( 71, 80)
      )
      
    }
    
    ## ----------------------------------------------------- ##
    ## WRITE AS PIPE DELIM FILES
    
    if (year %in% 1997:2015) {
      read_fwf(zip_file,
               col_positions = cra_cols,
               col_types = cra_types) %>%
        # keep relevant tables
        filter(table_id %in% c("A1-1a", "A1-2a", "A2-1a", "A2-2a")) %>% 
        # write the piped file
        write_delim(.,
                    glue("./data/aggr/area_{year}.txt"),
                    delim = "|",
                    na = "")    
    } else if (year > 2015) {
      map_df(c("A11a", "A12a", "A21a", "A22a"), function(file){
        txt_file <- glue("cra{year}_Aggr_{file}.dat")
        foo <- read_fwf(
          unzip(zip_file, txt_file),
          col_positions = cra_cols,
          col_types = cra_types
        )
      }) %>% write_delim(.,
                         glue("./data/aggr/area_{year}.txt"),
                         delim = "|",
                         na = "")
    }
    
    # clean up
    gc(full = T)
    
  })

}

# ---------------------------------------------------------------------------- #
# TRANSMITTAL SHEET ---- 

makeCRAtrans <- function(years) {
  
  # requires `tidyverse` and `glue`
  require(tidyverse)
  require(glue)
  
  # apply over years
  lapply(years, function(year){
    
    # zip file name
    zip_file <- glue("./data/trans/zip/{sprintf('%02.0f', year %% 100)}exp_trans.zip")
    
    # ------------------------------------------------------------------------ #
    # Transmittal sheet
    
    ## ----------------------------------------------------- ##
    ## SET COL NAMES/TYPES
    
    if (year == 1996){
      
      cra_types = cols(
        activity_year  = "i",
        agency_code    = "i",
        .default       = "c"
      )
    
      cra_cols <- fwf_cols(
        respondent_id    = c(  1, 10),
        agency_code      = c( 11, 11),
        activity_year    = c( 12, 15),
        respondent_name  = c( 16, 45),
        respondent_addr  = c( 46, 85),
        respondent_city  = c( 86,110),
        respondent_state = c(111,112),
        respondent_zip   = c(113,122),
        tax_id           = c(123,132)
      )
      
    } else if (year > 1996) {
      
      cra_types = cols(
        activity_year  = "i",
        agency_code    = "i",
        rssdid         = "i", 
        assets         = "d",
        .default       = "c"
      )
      
      cra_cols <- fwf_cols(
        respondent_id    = c(  1, 10),
        agency_code      = c( 11, 11),
        activity_year    = c( 12, 15),
        respondent_name  = c( 16, 45),
        respondent_addr  = c( 46, 85),
        respondent_city  = c( 86,110),
        respondent_state = c(111,112),
        respondent_zip   = c(113,122),
        tax_id           = c(123,132),
        rssdid           = c(133,142),
        assets           = c(143,152)
      )
      
    }

    ## ----------------------------------------------------- ##
    ## WRITE AS PIPE DELIM FILES
    
    read_fwf(zip_file,
             col_positions = cra_cols,
             col_types     = cra_types) %>%
      # write the piped file
      write_delim(.,
                  glue("./data/trans/ts_{year}.txt"),
                  delim = "|",
                  na = "")  
        
    # clean up
    gc(full = T)
    
  })

}

# ---------------------------------------------------------------------------- #
# ADDITIONAL FUNCTIONS ---- 

cleanCRAfiles <- function() {
  files_to_kill <- list.files(".", pattern = ".dat")
  suppressMessages(lapply(files_to_kill, file.remove))
}

# ---------------------------------------------------------------------------- #
# MAKE ALL CRA FILES ---- 

# latest year
max_year <- 2019

# aggregate data
makeCRAaggr(1996:max_year)

# transmittal sheet
makeCRAtrans(1996:max_year)

# disclosure data
makeCRAdiscl(1996:2019, tables_to_load = c("county", "aa_activity",
                                           "aa_areas", "cmmty_dev"))
# clean up
cleanCRAfiles()

## EOF