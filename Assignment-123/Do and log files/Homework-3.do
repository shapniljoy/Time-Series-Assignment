cd "F:\ECON 408\Practice do file"

capture log close
log using "Homework-3.log" , replace text

clear all
set seed 1000

use "HOMEWORK 3.dta" , clear

rename t time
tsset time


*                             Identification
********************************************************************************

*(1) Time Series plot of variable y
//----------------------------------


set scheme white_tableau

tsline y, ///
       lcolor(navy) lwidth(medthick) ///
	   title("{bf:Time Series Plot of y}", size(large)) ///
	   xtitle("Time Period", size(medlarge)) ///
	   ytitle("Values", size(medlarge)) ///
	   ylabel(, labsize(medium)) ///
	   tlabel(, labsize(medium)) ///
	   graphregion(color(white)) xsize(8) ysize(4) ///
	   name(tsplot_hw3, replace)

graph export tsplot_hw3.png, name(tsplot_hw3) replace


*(2) Stationarity Test
//---------------------


varsoc y , maxlag(12)
dfuller y, lags(4)



*(3) ACF and PACF
//----------------


set scheme s2color

ac y, name(acf_plot,replace) lags(20)
pac y, name(pacf_plot, replace) lags(20)
graph combine acf_plot pacf_plot, name(ACF_and_PACF_hw3, replace) ///
      title("ACF and PACF of y") xsize(8) ysize(4)
 
graph export ACF_and_PACF_hw3.png, name(ACF_and_PACF_hw3) replace

* Assumed models: ARMA(2,3) , ARMA(3,2), ARMA(3,3), ARMA(3,4), ARMA(4,3)

qui arima y, ar(1/2) ma(1/3)
estat ic

qui arima y, ar(1/3) ma(1/2)
estat ic

qui arima y, ar(1/3) ma(1/3)
estat ic

qui arima y, ar(1/3) ma(1/4)
estat ic

qui arima y, ar(1/4) ma(1/3)
estat ic

* ARMA(2,3) has the lowest AIC and BIC



*                                  Estimation 
********************************************************************************

arima y, ar(1/2) ma(1/3)
estat ic
estat aroots


*                                 Diagnostic Test
********************************************************************************


predict res , residuals

ac res, name(res_acf, replace) lags(20)
pac res , name(res_pacf, replace) lags(20)
graph combine res_acf res_pacf , xsize(8) ysize(4) title("ACF and PACF of Residual") ///
name(res_acf_pacf_hw3, replace)

graph export res_acf_pacf_hw3.png, name(res_acf_pacf_hw3) replace

wntestq res


*                              10 Days Ahead Forecast
********************************************************************************


keep if time <= 100
qui arima y, ar(1/2) ma(1/3)
tsappend, add(10)

capture drop y_forecast y_mse y_se ci_lower ci_upper
predict y_forecast, y dynamic(101)
predict y_mse, mse dynamic(101)

gen y_se = sqrt(y_mse)
gen ci_lower = y_forecast - 1.96 * y_se
gen ci_upper = y_forecast + 1.96 * y_se

qui replace y_forecast = y if time == 100
qui replace ci_lower = y if time == 100
qui replace ci_upper = y if time == 100

list time y_forecast ci_lower ci_upper if time >=99 & time <= 103


set scheme white_tableau

twoway (rarea ci_lower ci_upper time if time >= 100, color("gs12") lwidth(medthick)) ///
       (line y time if time <= 100 & time >= 1, lcolor("33 37 41") lwidth(medthin)) ///
       (line y_forecast time if time >= 100, lcolor("255 68 69") lpattern(dash) lwidth(medthick)), ///
       xline(100, lcolor(gs10) lwidth(medthick) lpattern(shortdash)) ///
	   graphregion(color(white)) ///
       title("{bf:ARMA(2,3): Historical Data vs. Dynamic Forecast}", color("108 117 125")) ///
       xtitle("Time Period", color("108 117 125"))  ///
       ytitle("Value", color("108 117 125")) ///
       legend(order(2 "Actual Data" 1 "95% CI" 3 "Forecast") pos(11) ring(0) ///
	   cols(1) color("108 117 125") ) ///
	   ylabel(, format(%9.0f) nogrid) ///
	   xlabel(0(25)100 110, labsize(small)) ///
	   xsize(6.5) ysize(4) name(forecast_plot,replace)
	   
graph export forecast_plot.png, name(forecast_plot) replace

log close 