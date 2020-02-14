
log using inductionrisk_setup3.log, replace

************** create national and state-level induction risk *******************

*** main variables created: Using average annual inductions 19-22 over own cohort size
* risk - national induction risk 
* staterisk - state-level induction risk
* nationalrisk - total national induction risk from state-level data
* nationalrisk_ - total national induction risk from state-level data, excluding own state
*
* Versions of above using biannual variation
* staterisk6m
* nationalrisk6m
* nationalrisk6m_
*
* Using biannual variation but alternate averaging method of total inductions over total cohort size
* staterisk6mt
* nationalrisk6mt
* nationalrisk6mt_
* 
* Constructing risk as average of four years of inductions over cohort 17 size 
* staterisk6ma
* nationalrisk6ma
* nationalrisk6ma_
*
* Notes: We have induction totals from 1955 to 1972, annual up to 1966, every six months for '67 on.
* We have state level enrollments at age 17 for 1961 on.
* Therefore we can compute national risk for 1955-71 and state level risk for 1961-1972.
* Year of state enrollments has been adjusted to match year of inductions, so enrollments in 1961 were
* the number of 17 year olds in a state two years prior. Inductions in 1971 were actual numbers inducted in 1971.
*
***


clear
set mem 100m
set more off

****************************************
*** generate national induction risk ***
****************************************

use national_inductions, clear
sort birthyear

*summ

**** create national-level risk ***
gen avg_ind_nat= (ind_nat + ind_nat[_n+1] + ind_nat[_n+2]  + ind_nat[_n+3])/ 4
gen risk=avg_ind_nat/cohort_size
replace risk=0 if birthyear>=1955 & birthyear<=1959
replace avg_ind_nat=0 if birthyear>=1955 & birthyear<=1959

summ

sort birthyear
save temp, replace


*******************************************
*** generate state-level induction risk ***
*******************************************

clear
use state_inductions

*summ

**** reshape annual inductions and enrollment data ***
gen int id=_n
gen byte ind1973=0
gen byte ind1974=0
gen byte ind1975=0
reshape long ind enr, i(id state abbrev) j(birthyear)

*summ

replace birthyear=birthyear-19
drop id

**** generate national-level inductions and enrollment from the state data ***
bys birthyear: egen ind_tot=total(ind)
bys birthyear: egen enr_tot=total(enr)

gen ind_tot_=ind_tot-ind
gen enr_tot_=enr_tot-enr

**** create national-level risk from the state data ***
sort statefip birthyear
by statefip: gen avg_ind= (ind + ind[_n+1] + ind[_n+2]  + ind[_n+3])/ 4 
gen avg_tot_ind= (ind_tot + ind_tot[_n+1] + ind_tot[_n+2]  + ind_tot[_n+3])/ 4 
gen avg_tot_ind_= (ind_tot_ + ind_tot_[_n+1] + ind_tot_[_n+2]  + ind_tot_[_n+3])/ 4 
drop if avg_ind==.

**** create state-level risk ***
gen staterisk=avg_ind/enr
gen nationalrisk=avg_tot_ind/enr_tot
gen nationalrisk_=avg_tot_ind_/enr_tot_

******** restrict to 1942-53 **********
* NOTE dropping gets rid of any later birthyears that have wrong totals due to non-restriction of forward sums above
drop if birthyear<1942 | birthyear>1953

*** merge national-level data ***
sort birthyear
merge birthyear using temp
drop _merge

fillin state birthyear
drop _fillin
sort birthyear
merge birthyear using temp, update
drop _merge
drop if state==""
erase temp.dta
sort statefip birthyear
save inductions, replace

*table birthyear, c(mean risk mean nationalrisk mean nationalrisk_ mean staterisk)

*summ

**** generate short inductions data
rename statefip bplg
keep birthyear bplg staterisk nationalrisk nationalrisk_ risk
drop if bplg==.
sort bplg birthyear
save inductions_short, replace

summ


*************************************************************************
*** generate state-level induction risk using 6 month level variation ***
*************************************************************************

clear
use state_inductions_aw

summ

**** reshape annual inductions and enrollment data into 6 month level data for each state and year combo ***
gen int id=_n

forvalues x = 55/66 {
  gen ind19`x'1 = ind19`x'/2
  gen ind19`x'2 = ind19`x'/2
  drop ind19`x'
  }
  
forvalues x = 61/72 {
  gen enr19`x'1 = enr19`x'/2
  gen enr19`x'2 = enr19`x'/2
  drop enr19`x'
  }  
  
gen byte ind19731=0
gen byte ind19741=0
gen byte ind19751=0
gen byte ind19761=0
gen byte ind19732=0
gen byte ind19742=0
gen byte ind19752=0

*summ

reshape long ind enr, i(id state abbrev) j(birthyear)
*summ

gen birthyear6m = birthyear
gen birth6m = birthyear
replace birthyear = int(birthyear/10)
summ birthyear
replace birth6m = birth6m - (birthyear*10)
summ birthyear6m birthyear birth6m
replace birthyear=birthyear-19
replace birthyear6m =birthyear6m-190
summ birthyear birthyear6m
drop id

**** generate national-level inductions and enrollment from the state data ***
bys birthyear6m: egen ind_tot6m=total(ind)
bys birthyear6m: egen enr_tot6m=total(enr)

gen ind_tot6m_=ind_tot6m-ind
gen enr_tot6m_=enr_tot6m-enr

**** create national-level risk from the state data ***
sort statefip birthyear6m
by statefip: gen avg_ind6m= (ind+ind[_n+1]+ind[_n+2]+ind[_n+3]+ind[_n+4]+ind[_n+5]+ind[_n+6]+ind[_n+7])/ 8
gen avg_tot_ind6m= (ind_tot6m+ind_tot6m[_n+1]+ind_tot6m[_n+2]+ind_tot6m[_n+3]+ind_tot6m[_n+4]+ind_tot6m[_n+5]+ind_tot6m[_n+6]+ind_tot6m[_n+7])/ 8
gen avg_tot_ind6m_= (ind_tot6m_+ind_tot6m_[_n+1]+ind_tot6m_[_n+2]+ind_tot6m_[_n+3]+ind_tot6m_[_n+4]+ind_tot6m_[_n+5]+ind_tot6m_[_n+6]+ind_tot6m_[_n+7])/ 8
drop if avg_ind6m==.

**** create state-level risk ***
gen staterisk6m=avg_ind6m/enr
gen nationalrisk6m=avg_tot_ind6m/enr_tot6m
gen nationalrisk6m_=avg_tot_ind6m_/enr_tot6m_


******** restrict to 1942-53 **********
drop if birthyear<1942 | birthyear>1953


**** generate short inductions data
rename statefip bplg
keep bplg birthyear6m staterisk6m nationalrisk6m nationalrisk6m_ 
drop if bplg==.
sort bplg birthyear6m
save inductions_short6m, replace

summ

*************************************************************************
*** generate state-level induction risk using 6 month level variation ***
*** put greater weight on age 19 inductions, less on later years			***
*************************************************************************

clear
use state_inductions_aw

summ

**** reshape annual inductions and enrollment data into 6 month level data for each state and year combo ***
gen int id=_n

forvalues x = 55/66 {
  gen ind19`x'1 = ind19`x'/2
  gen ind19`x'2 = ind19`x'/2
  drop ind19`x'
  }
  
forvalues x = 61/72 {
  gen enr19`x'1 = enr19`x'/2
  gen enr19`x'2 = enr19`x'/2
  drop enr19`x'
  }  
  
gen byte ind19731=0
gen byte ind19741=0
gen byte ind19751=0
gen byte ind19761=0
gen byte ind19732=0
gen byte ind19742=0
gen byte ind19752=0

*summ

reshape long ind enr, i(id state abbrev) j(birthyear)
*summ

gen birthyear6m = birthyear
gen birth6m = birthyear
replace birthyear = int(birthyear/10)
summ birthyear
replace birth6m = birth6m - (birthyear*10)
summ birthyear6m birthyear birth6m
replace birthyear=birthyear-19
replace birthyear6m =birthyear6m-190
summ birthyear birthyear6m
drop id

**** generate national-level inductions and enrollment from the state data ***
bys birthyear6m: egen ind_tot6m=total(ind)
bys birthyear6m: egen enr_tot6m=total(enr)

gen ind_tot6m_=ind_tot6m-ind
gen enr_tot6m_=enr_tot6m-enr

**** create national-level risk from the state data ***
sort statefip birthyear6m
by statefip: gen avg_ind6m= (0.5*(ind+ind[_n+1])+0.25*(ind[_n+2]+ind[_n+3])+0.15*(ind[_n+4]+ind[_n+5])+0.10*(ind[_n+6]+ind[_n+7]))/ 8
gen avg_tot_ind6m= (0.5*(ind_tot6m+ind_tot6m[_n+1])+0.25*(ind_tot6m[_n+2]+ind_tot6m[_n+3])+0.15*(ind_tot6m[_n+4]+ind_tot6m[_n+5])+0.10*(ind_tot6m[_n+6]+ind_tot6m[_n+7]))/ 8
gen avg_tot_ind6m_= (0.5*(ind_tot6m_+ind_tot6m_[_n+1])+0.25*(ind_tot6m_[_n+2]+ind_tot6m_[_n+3])+0.15*(ind_tot6m_[_n+4]+ind_tot6m_[_n+5])+0.10*(ind_tot6m_[_n+6]+ind_tot6m_[_n+7]))/ 8
drop if avg_ind6m==.

**** create state-level risk ***
gen staterisk6mwt=avg_ind6m/enr
gen nationalrisk6mwt=avg_tot_ind6m/enr_tot6m
gen nationalrisk6mwt_=avg_tot_ind6m_/enr_tot6m_


******** restrict to 1942-53 **********
drop if birthyear<1942 | birthyear>1953


**** generate short inductions data
rename statefip bplg
keep bplg birthyear6m staterisk6mwt nationalrisk6mwt nationalrisk6mwt_ 
drop if bplg==.
sort bplg birthyear6m
save inductions_short6mwt, replace

summ

*******************************************************************************
*** generate state-level induction risk using 6 month level variation       ***
*** construct average risk as total inductions over total cohort size 19-22 ***
*******************************************************************************

clear
use state_inductions_aw

**** reshape annual inductions and enrollment data into 6 month level data for each state and year combo ***
gen int id=_n

forvalues x = 55/66 {
  gen ind19`x'1 = ind19`x'/2
  gen ind19`x'2 = ind19`x'/2
  drop ind19`x'
  }
  
forvalues x = 61/72 {
  gen enr19`x'1 = enr19`x'/2
  gen enr19`x'2 = enr19`x'/2
  drop enr19`x'
  }  
  
gen byte ind19731=0
gen byte ind19741=0
gen byte ind19751=0
gen byte ind19761=0
gen byte ind19732=0
gen byte ind19742=0
gen byte ind19752=0

reshape long ind enr, i(id state abbrev) j(birthyear)

gen birthyear6m = birthyear
gen birth6m = birthyear
replace birthyear = int(birthyear/10)
summ birthyear
replace birth6m = birth6m - (birthyear*10)
summ birthyear6m birthyear birth6m
replace birthyear=birthyear-19
replace birthyear6m =birthyear6m-190
summ birthyear birthyear6m
drop id

**** generate national-level inductions and enrollment from the state data ***
bys birthyear6m: egen ind_tot6m=total(ind)
bys birthyear6m: egen enr_tot6m=total(enr)

gen ind_tot6m_=ind_tot6m-ind
gen enr_tot6m_=enr_tot6m-enr

**** create national-level risk from the state data ***
sort statefip birthyear6m
by statefip: gen all_ind6m = (ind+ind[_n+1]+ind[_n+2]+ind[_n+3]+ind[_n+4]+ind[_n+5]+ind[_n+6]+ind[_n+7])
gen all_tot_ind6m = (ind_tot6m+ind_tot6m[_n+1]+ind_tot6m[_n+2]+ind_tot6m[_n+3]+ind_tot6m[_n+4]+ind_tot6m[_n+5]+ind_tot6m[_n+6]+ind_tot6m[_n+7])
gen all_tot_ind6m_ = (ind_tot6m_+ind_tot6m_[_n+1]+ind_tot6m_[_n+2]+ind_tot6m_[_n+3]+ind_tot6m_[_n+4]+ind_tot6m_[_n+5]+ind_tot6m_[_n+6]+ind_tot6m_[_n+7])
drop if all_ind6m ==.

by statefip: gen all_enr6m = (enr+enr[_n+1]+enr[_n+2]+enr[_n+3]+enr[_n+4]+enr[_n+5]+enr[_n+6]+enr[_n+7])
gen all_tot_enr6m = (enr_tot6m+enr_tot6m[_n+1]+enr_tot6m[_n+2]+enr_tot6m[_n+3]+enr_tot6m[_n+4]+enr_tot6m[_n+5]+enr_tot6m[_n+6]+enr_tot6m[_n+7])
gen all_tot_enr6m_ = (enr_tot6m_+enr_tot6m_[_n+1]+enr_tot6m_[_n+2]+enr_tot6m_[_n+3]+enr_tot6m_[_n+4]+enr_tot6m_[_n+5]+enr_tot6m_[_n+6]+enr_tot6m_[_n+7])


**** create state-level risk ***
gen staterisk6mt = all_ind6m/all_enr6m
gen nationalrisk6mt = all_tot_ind6m/all_tot_enr6m
gen nationalrisk6mt_ = all_tot_ind6m_/all_tot_enr6m_


******** restrict to 1942-53 **********
drop if birthyear<1942 | birthyear>1953


**** generate short inductions data
rename statefip bplg
keep bplg birthyear6m staterisk6mt nationalrisk6mt nationalrisk6mt_ 
drop if bplg==.
sort bplg birthyear6m
save inductions_short6mt, replace

summ

* Right now missing for 19502 onwards because don't have cohort size data for these years
summ birthyear6m if staterisk6mt==.
summ if nationalrisk6mt==.

***************************************************************************************
*** generate state-level induction risk using 6 month level variation               ***
*** construct average risk as average risk of ind/cohort size for next four cohorts ***
***************************************************************************************

clear
use state_inductions_aw

**** reshape annual inductions and enrollment data into 6 month level data for each state and year combo ***
gen int id=_n

forvalues x = 55/66 {
  gen ind19`x'1 = ind19`x'/2
  gen ind19`x'2 = ind19`x'/2
  drop ind19`x'
  }
  
forvalues x = 61/72 {
  gen enr19`x'1 = enr19`x'/2
  gen enr19`x'2 = enr19`x'/2
  drop enr19`x'
  }  
  
gen byte ind19731=0
gen byte ind19741=0
gen byte ind19751=0
gen byte ind19761=0
gen byte ind19732=0
gen byte ind19742=0
gen byte ind19752=0

* Assign fake cohort sizes so denominator defined in 19731 onwards
gen byte enr19731=1
gen byte enr19741=1
gen byte enr19751=1
gen byte enr19761=1
gen byte enr19732=1
gen byte enr19742=1
gen byte enr19752=1

reshape long ind enr, i(id state abbrev) j(birthyear)

gen birthyear6m = birthyear
gen birth6m = birthyear
replace birthyear = int(birthyear/10)
summ birthyear
replace birth6m = birth6m - (birthyear*10)
summ birthyear6m birthyear birth6m
replace birthyear=birthyear-19
replace birthyear6m =birthyear6m-190
summ birthyear birthyear6m
drop id

**** generate national-level inductions and enrollment from the state data ***
bys birthyear6m: egen ind_tot6m=total(ind)
bys birthyear6m: egen enr_tot6m=total(enr)

gen ind_tot6m_=ind_tot6m-ind
gen enr_tot6m_=enr_tot6m-enr

**** create national-level risk from the state data ***
sort statefip birthyear6m
gen sr = ind / enr
gen nr = ind_tot6m / enr_tot6m
gen nr_ = ind_tot6m_ / enr_tot6m_

by statefip: gen staterisk6ma = (sr+sr[_n+1]+sr[_n+2]+sr[_n+3]+sr[_n+4]+sr[_n+5]+sr[_n+6]+sr[_n+7])/8
gen nationalrisk6ma = (nr+nr[_n+1]+nr[_n+2]+nr[_n+3]+nr[_n+4]+nr[_n+5]+nr[_n+6]+nr[_n+7])/8
gen nationalrisk6ma_ = (nr_+nr_[_n+1]+nr_[_n+2]+nr_[_n+3]+nr_[_n+4]+nr_[_n+5]+nr_[_n+6]+nr_[_n+7])/8

*drop if all_ind6m ==.


******** restrict to 1942-53 **********
drop if birthyear<1942 | birthyear>1953


**** generate short inductions data
rename statefip bplg
keep bplg birthyear6m staterisk6ma nationalrisk6ma nationalrisk6ma_ 
drop if bplg==.
sort bplg birthyear6m
save inductions_short6ma, replace

summ

log close
