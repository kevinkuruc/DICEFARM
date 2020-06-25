cd "C:\Users\Kevin\Documents\GitHub\DICEFARM"
set more off
* Source: https://ourworldindata.org/grapher/meat-consumption-vs-gdp-per-capita?yScale=log&time=2010..
import delimited "data\MeatVsGDP.csv", clear
rename meatsupplyperpersonkilogramspery Meat
drop if year == "1000 BCE"
drop if year == "2000 BCE"
drop if year == "3000 BCE"
drop if year == "4000 BCE"
drop if year == "5000 BCE"
drop if year == "6000 BCE"
drop if year == "7000 BCE"
drop if year == "8000 BCE"
drop if year == "9000 BCE"
drop if year == "10000 BCE"
#delimit ;
local noncountries ANT BES BIH COK ESH 
OWID_CIS OWID_CZS OWID_KOS OWID_MNS OWID_PYA OWID_SRM 
OWID_USS OWID_WRL OWID_YGS;
#delimit cr
foreach n in `noncountries'{
 drop if code=="`n'"
}
drop if Meat==.
destring year, replace
preserve
gen totMeat = Meat*totalpopulation
gen totGDP = gdppercapita*totalpopulation
keep if year>1989
keep if year<2014
collapse (sum) totMeat totGDP totalpopulation, by(year)
gen Meat = totMeat/totalpopulation
gen GDPcap = totGDP/totalpopulation
gen lnMeat = log(Meat)
gen lnGDP = log(GDPcap)
# delimit ;
scatter lnMeat lnGDP, mlabel(year) ytitle("Per Capita Meat Cons. (log kg)") xtitle("Global GDP per Capita (log)")
title("a. Time-Series");
# delimit cr
graph export "TimeSeries.svg", replace
reg lnMeat lnGDP
restore
keep if year == 2017
gen lnGDP = log(gdppercapita)
gen lnMeat = log(Meat)
#delimit ;
twoway (scatter lnMeat lnGDP, mlabel(code)),
ytitle("Per Capita Meat Cons. (log kg)")
xtitle("GDP per Capita (log)")
title("b. Cross-Section (2017)")
legend(off);
graph export "CrossSection.svg", replace;
regress lnMeat lnGDP;

