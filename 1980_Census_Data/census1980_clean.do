capture log close
clear all

log using "1980_Census_Data\census1980_clean.log", replace

********************************************************************************
*Author: Zach Swaziek
*Date: January 2020
*
*This do-file recreates Table 1 in "The Impact of College on Migration:
*Evidence from the Vietnam Generation" by Ofer Malamud and Abigail Wozniak
*
*Datasources: 1980 5% Census Sample downloaded from IPUMS - restricted to males
*			  Remaining files from Abigal Wozniak's website:
*					cohortsize_c60.dta - Cohort size by birthyear and birthplace
*					blanchard_katz.dta - Employment/Pop data by birthyear/place
*					inductions_short6m.dta - National and State induction risk
*
*Output: Table 1: Summary Statistics for 1980 Census
********************************************************************************

use "1980_Census_Data\census_1980.dta" 

rename birthyr birthyear

gen bplg =  bpl

***COHORT SIZE MERGE************************************************************

merge m:1 birthyear bplg using "1980_Census_Data\cohortsize_c60"
drop if _merge == 2 | _merge == 1
drop _merge

***EPOP MERGE*******************************************************************

*Variable for year turned 19
gen year19 = birthyear + 19
merge m:1 year19 bplg using "1980_Census_Data\blanchard_katz"
drop if _merge == 2 | _merge == 1
drop _merge

***GROUP QUARTERS***************************************************************

fre gqtype
*Drop group quarters 
drop if gq == 3 | gq == 4

***BIRTH YEAR*******************************************************************

*Drop if born outside of 1942-1953 (restrictions from paper)
drop if birthyear < 1942 | birthyear > 1953

fre birthqtr
*Create variable to split up year into two halves
gen birthhalf = 1
replace birthhalf = 2 if birthqtr == 3 | birthqtr == 4

tostring birthyear, gen(biyr)
tostring birthhalf, gen(bihf)
gen birthyear6m1 = biyr + bihf
destring birthyear6m1, gen(birthyear6m)
drop biyr bihf birthyear6m1

***BIRTHPLACE/MIGRATION*********************************************************

fre bpl
*Drop if born outside the U.S. or born in D.C.
drop if bpl > 56 | bpl == 11
*Drop if living in DC
drop if statefip == 11 
*Create variable for if living outside birth state (1), or living in same (0)
gen moved_bpl = 0
replace moved_bpl = 1 if bpl != statefip 
lab var moved_bpl "Living outside of birth state"

fre citizen
*keep if citizen == 0

***EDUCATION********************************************************************

fre educd

*Create variable for years of schooling
gen school_yrs = 0
replace school_yrs = 1 if educd == 14
replace school_yrs = 2 if educd == 15
replace school_yrs = 3 if educd == 16
replace school_yrs = 4 if educd == 17
replace school_yrs = 5 if educd == 22
replace school_yrs = 6 if educd == 23
replace school_yrs = 7 if educd == 25
replace school_yrs = 8 if educd == 26
replace school_yrs = 9 if educd == 30
replace school_yrs = 10 if educd == 40
replace school_yrs = 11 if educd == 50
replace school_yrs = 12 if educd == 60
replace school_yrs = 12 if educd == 65
replace school_yrs = 13 if educd == 70
replace school_yrs = 14 if educd == 80
replace school_yrs = 15 if educd == 90
replace school_yrs = 16 if educd == 100
replace school_yrs = 17 if educd == 110
replace school_yrs = 18 if educd == 111
replace school_yrs = 19 if educd == 112
replace school_yrs = 20 if educd == 113
lab var school_yrs "Years of schooling"

*Create variable for years of college
gen coll_yrs = 0
replace coll_yrs = 0 if educd == 65
replace coll_yrs = 1 if educd == 70
replace coll_yrs = 2 if educd == 80
replace coll_yrs = 3 if educd == 90
replace coll_yrs = 4 if educd == 100
replace coll_yrs = 5 if educd == 110
replace coll_yrs = 6 if educd == 111
replace coll_yrs = 7 if educd == 112
replace coll_yrs = 8 if educd == 113
lab var coll_yrs "Years of college"

*Create variable that equals 1 if have some college or more, 0 if not
gen coll_atd = 0
replace coll_atd = 1 if educd >= 65
lab var coll_atd "College attendance"

*Create var for college completion (if have 4 years of college or more)
gen coll_compl = 0
replace coll_compl = 1 if school_yrs >= 16
lab var coll_compl "College completion"

***RACE*************************************************************************

fre raced
*Create variable that equals 1 if Black, 0 if not
gen black = 0
replace black = 1 if raced == 200
lab var black "Black"

*Create variable that equals 1 if other non-white, 0 if not
*Non-white includes spanish write_in (coded as 110 in raced)
gen other_nw = 0
replace other_nw = 1 if raced == 110 | raced > 200 | hispand != 0
lab var other_nw "Other nonwhite"

***VETERAN STATUS***************************************************************

fre vetstatd
gen veteran = 0
replace veteran = 1 if vetstatd == 20
lab var veteran "Veteran status"

preserve

***DROPPING BY DATA QUALITY FLAGS***********************************************
 
*https://usa.ipums.org/usa/flags.shtml
*Greater than 3 is a "hot deck allocation," which means was allocated
*based on similar household
*qage qsex qbpl qeduc qempstat qvetper within 102
*qage qeduc qvetstat qbpl - best guess!
foreach y in qage qeduc qvetstat qbpl {
fre `y' 
drop if `y' > 2
}

*For population variable
gen i = 1

*Variable for population by halfyear-birthyear-birthplace
*Will be used to weight averages/standard deviations
bysort bpl birthyear birthhalf: egen bpl_byr_bh_pop = total(i)

*Uncollapsed summaries
sum moved_bpl school_yrs coll_yrs coll_compl coll_atd veteran age ///
		 black other_nw

*Collapse to mean by birth state and birth year
collapse (mean) moved_bpl school_yrs coll_yrs coll_compl coll_atd veteran age ///
		 black other_nw lnsize lnstatesize epop epopstate bpl_byr_bh_pop, by(bplg birthyear6m) 

*Merge in state/national induction risk by birth state and birthyear
merge 1:1 birthyear6m bplg using "Induction_Risk_Data\inductions_short6m.dta"

***COLLAPSED SUMMARY STATS - TABLE 1********************************************

*Note that these are not exact replications
*Mean is weighted by the birth state/birth (half) year/population
sum moved_bpl school_yrs coll_yrs coll_compl coll_atd veteran ///
		nationalrisk6m staterisk6m age black other_nw lnsize lnstatesize ////
		epop epopstate [aw = bpl_byr_bh_pop]

restore 

log close




