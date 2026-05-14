cd "F:\ECON 408\Practice do file"

capture log close
log using "Homework-1.log", replace text

clear all
set seed 1000

* Task 1: 
*-------------------------------------------------------------------------------


import excel "USD to BDT.xlsx", firstrow clear

rename Close Ex_Rate
label variable Ex_Rate "Exchange Rate"

replace Date = dofc(Date)
format Date %td

bcal create bus_cal, from(Date) gen(time) replace
format time %tbbus_cal
tsset time


* Task 2: 
*-------------------------------------------------------------------------------
set scheme s2color

// tsline Ex_Rate, ///
//        lcolor(navy) lwidth(medthick) ///
// 	   title("{bf:Daily Exchange Rate Trend (2011-2025)}", size(large)) ///
// 	   xtitle("Year", size(medlarge)) ///
// 	   ytitle("Rate (BDT)", size(medlarge)) ///
// 	   ylabel(, labsize(medium)) ///
// 	   xlabel(, format(%tdCY) labsize(medium)) ///
// 	   graphregion(color(white)) ///
// 	   xsize(8) ysize(4) ///
// 	   name(tsplot, replace) note("Source: Google Finance", size(smallmed))
//
// graph export Hw_1_tsplot.emf, name(tsplot) replace


* Task 3: 
*-------------------------------------------------------------------------------

gen Diff_Ex = D.Ex_Rate


* Task 4: 
*-------------------------------------------------------------------------------

* Step 1: Stationarity Check


// tsline Diff_Ex

dfuller Diff_Ex

* Step 2: Empirical ACF and PACF check

ac Diff_Ex, name(acf_plot,replace) lags(20) 
pac Diff_Ex, name(pacf_plot,replace) lags(20)
graph combine acf_plot pacf_plot, title("ACF and PACF of Diff_Ex") xsize(8) ysize(4)

* MA(1) , ARMA(1,1) , ARMA(1,2) , AR(2) , ARMA(2,1)


qui arima Diff_Ex, ar(1) ma(1)
estat ic

qui arima Diff_Ex, ar(1) ma(1/2)
estat ic

qui arima Diff_Ex, ar(1/2) ma(1/2)
estat ic

qui arima Diff_Ex, ar(1/2) ma(1)
estat ic

qui arima Diff_Ex, ar(1/3) ma(1/3)
estat ic

* ARMA(3,2) Model has the lowest AIC and BIC

* Step 3: Estimation

arima Diff_Ex, ar(1/3) ma(1/2)
estat ic
estat aroots
predict res , residuals

ac res, name(acf_res,replace) lags(20) 
pac res, name(pacf_res,replace) lags(20)
graph combine acf_res pacf_res, title("ACF and PACF of Residuals") xsize(8) ysize(4)

wntestq res, lags(10)


log close