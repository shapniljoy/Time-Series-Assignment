cd "F:\ECON 408\Practice do file"


clear all
set seed 1000

* Task 1: 
*-------------------------------------------------------------------------------


import excel "USD to BDT.xlsx", firstrow clear

rename Close Ex_Rate
label variable Ex_Rate "Exchange Rate"

replace Date = dofc(Date)
format Date %td
tsset Date


* Task 2: 
*-------------------------------------------------------------------------------
set scheme cleanplots

tsline Ex_Rate, ///
       lcolor(navy) lwidth(medthick) ///
	   title("{bf:Daily Exchange Rate Trend (2011-2025)}", size(large)) ///
	   xtitle("Year", size(medlarge)) ///
	   ytitle("Rate (BDT)", size(medlarge)) ///
	   ylabel(, labsize(medium)) ///
	   tlabel(01jan2011 01jan2016 01jan2021 01jan2026, format(%tdcY) labsize(medium)) ///
	   graphregion(color(white)) xsize(8) ysize(4) ///
	   name(tsplot, replace) note("Source: Google Finance")

graph export Hw_1_tsplot.emf, name(tsplot) replace


* Task 3: 
*-------------------------------------------------------------------------------

bcal create bus_cal, from(Date) gen(time) replace
format time %tbbus_cal
tsset time
gen Diff_Ex = D.Ex_Rate


* Task 4: 
*-------------------------------------------------------------------------------

* Step 1: Stationarity Check

tsset Date 

set scheme cleanplots

tsline Diff_Ex, ///
       lcolor(navy) lwidth(medthick) ///
	   title("{bf:Daily Diff_Ex Plot (2011-2025)}", size(large)) ///
	   xtitle("Year", size(medlarge)) ///
	   ytitle("Rate (BDT)", size(medlarge)) ///
	   ylabel(, labsize(medium)) ///
	   tlabel(01jan2011 01jan2016 01jan2021 01jan2026, format(%tdcY) labsize(medium)) ///
	   graphregion(color(white)) xsize(8) ysize(4) ///
	   name(Diff_Ex_plot, replace) 

graph export Diff_Ex_plot.emf, name(Diff_Ex_plot) replace

dfuller Diff_Ex
tsset time

* Step 2: Empirical ACF and PACF check
set scheme s2color

ac Diff_Ex, name(acf_plot,replace) lags(20) 
pac Diff_Ex, name(pacf_plot,replace) lags(20)
graph combine acf_plot pacf_plot, title("ACF and PACF of Diff_Ex") xsize(8) ysize(4) name(acf_pacf_plot, replace)

graph export hw_1_acf_pacf_plot.emf, name(acf_pacf_plot) replace

*ARMA(2,3) , ARMA(3,2) , ARMA(3,3) , ARMA(3,4), ARMA(4,3)


qui arima Diff_Ex, ar(1/2) ma(1/3)
estat ic

qui arima Diff_Ex, ar(1/3) ma(1/2)
estat ic

qui arima Diff_Ex, ar(1/3) ma(1/3)
estat ic

qui arima Diff_Ex, ar(1/3) ma(1/4)
estat ic

qui arima Diff_Ex, ar(1/4) ma(1/3)
estat ic


* ARMA(3,2) Model has the lowest AIC and BIC

* Step 3: Estimation

arima Diff_Ex, ar(1/3) ma(1/2)
estat ic
estat aroots , name(arootshw1, replace)
graph export arootshw1.emf, name(arootshw1) replace
predict res , residuals

ac res, name(acf_res,replace) lags(10) 
pac res, name(pacf_res,replace) lags(10)
graph combine acf_res pacf_res, title("ACF and PACF of Residuals") xsize(8) ysize(4) name(hw1_res_ac_pac_plot,replace)
graph export hw1_res_ac_pac_plot.emf, name(hw1_res_ac_pac_plot) replace


wntestq res, lags(10)


