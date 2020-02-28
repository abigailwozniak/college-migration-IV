## Repository Structure
*This repository contains the following directories:*

- **\1980_Census_Data**
  - Contains do-file and data sets that construct the main 1980 Census data set used for estimation in the paper.
- **\Inductions_Data** 
  - Contains do-file and data sets that construct the final inductions data set (**inductions.dta**), as well as datasets that contain variations of measures of induction risk (see do-file for risk measures).  
- **\Enr_PDF_YYYY_YY**
  - Original PDF versions of school enrollment data from 1960 to 1970.

## 1980 Census Data 

*This folder contains Stata do-files and data to construct the main 1980 Census estimating sample in Table 1 of the paper using raw Census data downloaded from IPUMS.org. It contains the following files:*

- **census_1980.dta** – raw 1980 Census 5% Sample from IPUMS. The sample is restricted to men aged 25 to 40.
- **census1980_clean.do** – cleans **census_1980.dta** and merges cohort size, employment-population, and induction data to create one of the final 1980 Census data sets (**census1980_cleaned.dta**). The do-file also creates Table 1 before saving **census1980_cleaned.dta**. The following files are merged in to create the final dat aset:
  - **blanchard_katz.dta** – state-level unemployment insurance rates (epop and epopstate) sorted by bplg and year19 
  -	**cohortsize_c60.dta** – 1960 cohort size at the birthyear and statebirthyear level (lnsize and lnstatesize) sorted by bplg and birthyear.
  - **inductions_short6m.dta** – a short version of **inductions.dta** (containing only birthyear, bplg, staterisk, nationalrisk, nationalrisk_, and risk)

## Induction Risk Data 

*This folder contains Stata do-files and data to create our birth state - birth year measures of Vietnam conflict induction risk:*

- **inductionrisk_setup3.do** – generates national-level and state-level induction risk by birth year and by six-month birth interval. Creates data sets with various definitions of induction risk. 
  - *This do-file uses the following data sets:*
    - **national_inductions.dta** – national level inductions and cohort size by birth year for birth years 1935 to 1959. Note that inductions for 1955 onwards equal zero. Created from **inductions.xls**.
    - **state_inductions.dta** – state level inductions and enrollments by calendar year. Created from **state_level_inductions_enrollments.xls** (see below). 
    - **state_inductions_aw.dta** – state level inductions and enrollments by six months of calendar year.  Created from **state_level_inductions_enrollments_aw.xlsx**.
  - *This do-file creates the following data sets:*
    - **inductions.dta** – final data set created by **inductionrisk_setup3.do**.
    - **inductions_short.dta** – a short version of inductions.dta containing only birthyear, bplg, staterisk, nationalrisk, nationalrisk_, and risk.  Note that risk is equivalent to the measure in C&L 2000. Our nationalrisk is created by aggregating up state level induction totals and enrollments and is not exactly equal to risk but is very close. See **inductionrisk_setup3.do** for constructions.
    - **inductions_short6m.dta**, **inductions_short6mt.dta**, **inductions_short6ma.dta** – versions with different definitions of induction risk.

*The full set of raw data that we put together to construct the data sets on induction risk:*

- **inductions.xls** – national-level induction rates and cohort sizes from C&L (data from David Card) and SSS website.
- **state_level_enrollments.xls** – state-level 10th and 11th grade enrollments from 1961-1969, and secondary totals for 1959-1960.
- **state_level_inductions.xls** – state-level inductions from 1954-1972, raw and corrected. State level inductions processed and received in paper form from SSS in two batches. First batch reports annual induction numbers by state and year or six-month period. Second batch reports cumulative induction totals by state and year. Corrections made for obvious data entry mistakes. Edited observations are highlighted in “corrected” tab. “Inductions_final” tab contains calculated annual total inductions by state for 1955 to 1972.
- **state_level_inductions_enrollments.xls** – final tabulations of state-level induction and enrollment counts. Combines data from state_level_inductions “Inductions_final” tab and state_level_enrollments. “Combined” tab contains state level annual induction and enrollment numbers where indYYYY is inductions from “Inductions_final” tab and enrYYYY is the following: Secondary enrollment/4 if YYYY=1959 or 1960 from state_level_enrollments, and 11th grade enrollment for YYYY=1961 to 1969. “Combined and Adjusted” tab shifts enrYYYY to enr(year 19=YYYY+2) for matching and division by year a cohort turned 19. “Combined and Adjusted” tab data form state_inductions.dta.

**NOTE:** There are also “AW” versions of the above, which carry the six-month level variation through instead of collapsing it.
