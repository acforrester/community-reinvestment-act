



merge_cra_discl <- function()
{
  
  
  
}

year <- 2004

# set csv bases
csv_discl <- '../data/discl/csv'
csv_trans <- '../data/trans/csv'


# file names
discl_file <- paste0(csv_discl, '/', 'discl_county_', year, '.csv')
trans_file <- paste0(csv_trans, '/', 'transmittal_' , year, '.csv')
# subset cols
keep_cols <- c('respondent_id', 'agency_code', 'respondent_name', 'id_rssd')

# append assets if 1997 onwards
if(year > 1996) keep_cols <- c(keep_cols, 'assets')


## --------------------------------------------------- ##
## MERGE DISCLOSURE DATA

# load/subset disclosure file
dat_discl <- read_csv(discl_file) %>% 
  filter(!is.na(state_code), !is.na(county_code), is.na(report_level))

# load and subset the transmittal sheet
dat_trans <- read_csv(trans_file)[keep_cols]

# combine the disclosure and transmittal sheet
dat_comb <- left_join(dat_discl, dat_trans, by = c('respondent_id', 'agency_code')) %>% 
  select('table_id', keep_cols, everything())


## --------------------------------------------------- ##
## MERGE AGGREGATE DATA

## to-do











