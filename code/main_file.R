## ============================================================================
## make_cra_census.R
## ============================================================================
## Author: AC Forrester
## ============================================================================
## This script downloads the Community Reinvestment Act disclosure data from 
## the FFIEC, reads them, and converts them from fixed width into CSV's.

library(tidyverse)

# Collect CRA data --------------------------------------------------------

# which files to get?
get_files <- c('census')

# collect the data
get_cra_data(1990:1995, get_files, '../data')


# Make the Aggregate files ------------------------------------------------

# locations
csv_base <- '../data/aggr/csv'
zip_base <- '../data/aggr/zip'

# make the aggregate files
make_cra_aggr(1996:2018, zip_base, csv_base)


# Make the Disclosure files -----------------------------------------------

# locations
csv_base <- '../data/discl/csv'
zip_base <- '../data/discl/zip'

# make the disclosure files
make_cra_discl(2003:2018, zip_base, csv_base)


# Make the Transmittal Sheet ----------------------------------------------

# locations
csv_base <- '../data/trans/csv'
zip_base <- '../data/trans/zip'

# make the transmittal sheet
make_cra_trans(1996:2018, zip_base, csv_base)
