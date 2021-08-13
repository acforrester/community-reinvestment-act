# Assemble the CRA database
# 
# AC Forrester
# 
# After assembling the CRA data, assemble each of the summary tables into
# a single database to call using SQLite. 
#
# Some example queries at the bottom of the script.
#
# *****************************************************************************

# load packages to use
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse,glue,RSQLite)

# ---------------------------------------------------------------------------- #
# MAKE THE DATABASE ---- 

# connect to the DB
db <- dbConnect(SQLite(), dbname="./data/cra_data_db.sqlite")

# append each year
for(year in 1997:2019){
  
  ## ----------------------------------------------------- ##
  ## LOAD IN AGGREGATE DATA
  
  dbWriteTable(conn      = db, 
               name      = "tract", 
               value     = glue("./data/aggr/tract_{year}.txt"), 
               sep       = "|",
               append    = T, 
               row.names = F, 
               header    = T)
  
  ## ----------------------------------------------------- ##
  ## LOAD IN TRANSMITTAL SHEET
  
  dbWriteTable(conn      = db, 
               name      = "ts", 
               value     = glue("./data/trans/ts_{year}.txt"), 
               sep       = "|",
               append    = T, 
               row.names = F, 
               header    = T)
  
}

# list tables to check
dbListTables(db)

# close conn
dbDisconnect(db)

# ---------------------------------------------------------------------------- #
# EXAMPLE QUERIES ---- 

# connect to the DB
db <- dbConnect(SQLite(), dbname="./data/cra_data_db.sqlite")


# 2019 small biz lending in DC

dbGetQuery(db, 'SELECT 
                  state,county,income_group,num_sbus,vol_sbus
                FROM 
                  tract 
                WHERE 
                  activity_year = 2019 AND 
                  action_taken = 1 AND
                  loan_type = 4 AND
                  state = "11" AND
                  county = "001" AND
                  report_level = "100"
               ')

# time series of small biz lending in the Chicago CBSA

chicago <- dbGetQuery(db, 'SELECT
                            activity_year,msamd,num_sbus,vol_sbus
                           FROM 
                            tract 
                           WHERE 
                           (msamd = "1600" OR msamd = "16984" OR msamd = "16974") AND
                            action_taken = 1 AND
                            loan_type = 4 AND
                            report_level = "210"
                      ')


chicago %>% 
  # assert sort order
  arrange(activity_year) %>% 
  # compute YoY growth (log)
  mutate(yoy = log(vol_sbus/lag(vol_sbus, 1))) %>% 
  # remove first year
  filter(activity_year > 1997) %>% 
  # let's plot
  ggplot(., aes(x = activity_year, y = yoy)) +
    geom_line() +
    geom_hline(aes(yintercept = 0)) +
    scale_x_continuous(breaks = seq(1998, 2020, 2)) +
    theme_light() +
    theme(plot.title = element_text(hjust = 0.5),
          plot.caption = element_text(hjust = 0)) +
    labs(title = "Growth in CRA Eligible Small Business Originations: 
                    Chicago Metropolitan Area",
         x = "Year",
         y = "Year-over-Year Change in Volume",
         caption = "Source: FFIEC")

# close conn
dbDisconnect(db)


## EOF