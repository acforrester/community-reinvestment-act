# Community Reinvestment Act Data

This repository is a project to collect lending data reported through the Community Reinvestment Act (CRA) and make it available in a usable form.  The codes here are designed to collect, assemble, and lightly clean the flat files released by the Federal Financial Institutions Examinations Council (FFIEC).  These data provide the number and volume of small business and small farm loans originated and purchased by covered institutions and are further broken down by loan amount and business' gross annual revenue.

## CRA Datasets

The CRA lending data are broken down into a series of 3 reports: the aggregate data, disclosure data, and transmittal sheet.  The following text describes each of the CRA datasets in more detail.

### Aggregate Data
Hence the name, the 'aggregate' data provide aggregated data on the number and volume of small business and farm loans originated and purchased.  These data provide lending counts and volumes by Census tract -- lowest level of geography available in the CRA.  From 1997 onwards the aggregate data provide the aforementioned information by bank by county.

### Disclosure Data
Disclosure data include key information on lending by banks within and outside their CRA assessment areas.  These data include measures of small business and farm lending by bank, community development and consortium or third party lending, and assessment area delineations by bank.  These data are particulary useful for determining banks' lending activity by county and identifying their assessment areas by Census tract.

### Transmittal Sheet
The transmittal sheet provides a register of all institutions that submitted data in a given year.  It provides information that can be used to link the CRA with other data, such as HMDA, Call Reports, FDIC Summary of Deposits, etc.  The data themselves include the institution's primary regulator, address, and state.  From 1997 onwards the transmittal sheet provides the institution's Federal Reserve RSSD and assets from the last Call or Thrift Financial Report.

## Metadata

| Table ID 	| Table Name 	| Summary Level 	| Years Available 	|
|----------	|------------	|-------------	  |-----------------	|
| A1-1      | Small Business Loans by County - Originations 	             | Tract      | 1996-2018  |
| A1-2      | Small Business Loans by County - Purchases                    | Tract | 1996-2018 |
| A2-1      | Small Farm Loans by County - Originations                     | Tract | 1996-2018 |
| A2-2      | Small Farm Loans by County - Purchases                        | Tract | 1996-2018 |
| A1-1a     | Small Business Lenders in Area - Originations                 | Bank/County | 1997-2018 |
| A1-2a     | Small Business Lenders in Area - Purchases                    | Bank/County | 1997-2018 |
| A2-1a     | Small Farm Lenders in Area - Originations                     | Bank/County | 1997-2018 |
| A2-2a     | Small Farm Lenders in Area - Purchases                        | Bank/County | 1997-2018 |
| D1-1      | Small Business Loans by County - Originations                 | Bank/County | 1996-2018 |
| D1-2      | Small Business Loans by County - Purchases                    | Bank/County | 1996-2018 |
| D2-1      | Small Farm Loans by County - Originations                     | Bank/County | 1996-2018 |
| D2-2      | Small Farm Loans by County - Purchases                        | Bank/County | 1996-2018 |
| D3        | Assessment Area/Non Assessment Area Activity - Small Business | Bank/County | 1996-2018 |
| D4        | Assessment Area/Non Assessment Area Activity - Small Farm     | Bank/ County  | 1996-2018 |
| D5        | Community Development/Consortium-Third Party Activity         | Bank | 1996-2018 |
| D6        | Assessment Area(s) by Tract                                   | Bank/Tract  | 1996-2018 |

## A Note on Geography
A caveat to the CRA (and HMDA) data is that the geographic units, either Census tract or county, are reported in nominal terms.  While this is less of an issue for counties, which tend to be geographically consistent over time, it can be a inescapable problem for more granular analyses with Census tracts.  While Census tracts are designed to be relatively permanent geographic boundaries, the Census Bureau revises some tract delineations with each round of the Decennial Census.  It is therefore important to account for such changes by harmonizing the tract boundaries.  The most common way to do this uses either the [Longitudinal Tract Database](https://s4.ad.brown.edu/projects/diversity/Researcher/Bridging.htm) or [relationship files from the Census Bureau](https://www.census.gov/geographies/reference-files/2010/geo/relationship-files.html).

## Changelog
- 08-XX-2020 - Initial commit with codes.
