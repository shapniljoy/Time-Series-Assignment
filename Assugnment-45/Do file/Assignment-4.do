cd "F:\ECON 408\Practice do file\Assignments\Time-Series-Assignment\Assugnment-45\Do file"

clear all
set more off
set seed 10

set obs 150
gen t = _n
tsset t

set scheme white_tableau

* Step-1: Augmented Dicky Fuller Test of 2 variables
*----------------------------------------------------------------------

* Random Walk with a drift of 0.2

gen double e = rnormal()
gen y_drift = sum(0.2 + e)

tsline y_drift, ///
       lcolor(ebblue%70) lwidth(medthick) ///
	   title("{bf:Time Series Plot}", size(large)) ///
	   subtitle("Random Walk with a drift of 0.2") ///
	   xtitle("Time Period", size(medlarge)) ///
	   ytitle("Values", size(medlarge)) ///
	   ylabel(, labsize(medium)) ///
	   tlabel(, labsize(medium)) ///
	   graphregion(color(white)) xsize(8) ysize(4) ///
	   name(tsplot_hw4_1, replace)

graph export tsplot_hw4_1.png, name(tsplot_hw4_1) replace

varsoc y_drift, maxlag(12)
dfuller y_drift, trend lags(1)


* AR(1), rho = 0.96, deterministic trend of 0.2t.

gen double u = e in 1
replace u = 0.96*L.u + e in 2/L
gen double y_trend = 0.2*t + u


tsline y_drift, ///
       lcolor(ebblue%70) lwidth(medthick) ///
	   title("{bf:Time Series Plot}", size(large)) ///
	   subtitle("AR(1) Deterministic trend of 0.2t with rho = 0.96 ") ///
	   xtitle("Time Period", size(medlarge)) ///
	   ytitle("Values", size(medlarge)) ///
	   ylabel(, labsize(medium)) ///
	   tlabel(, labsize(medium)) ///
	   graphregion(color(white)) xsize(8) ysize(4) ///
	   name(tsplot_hw4_2, replace)

graph export tsplot_hw4_2.png, name(tsplot_hw4_2) replace


varsoc y_trend, maxlag(12)
dfuller y_trend, trend lags(1)


*Step-2: Generating and Simulating Mone-Carlo Simulation
*-------------------------------------------------------------------


capture program drop sim_power
program sim_power, rclass

        syntax [, obs(integer 150)]
		
		quietly {
			
			drop _all
			set obs `obs'
			gen t = _n
			tsset t
			
			* Random Walk with a drift of 0.2

            gen double e = rnormal()
            gen y_drift = sum(0.2 + e)
			dfuller y_drift, trend lags(1)
			
			return scalar t_drift = r(Zt)
			
			* AR(1), rho = 0.96, deterministic trend of 0.2t.
			gen double u = e in 1
            replace u = 0.96*L.u + e in 2/L
            gen double y_trend = 0.2*t + u
			dfuller y_trend, trend lags(1)
			
			return scalar t_trend = r(Zt)
			
}
end

simulate t_drift = r(t_drift) t_trend = r(t_trend),reps(1000) seed(10): sim_power, obs(150)


* STEP 3: Analyze and Visualize the T-statistic
*------------------------------------------------------------

gen reject_drift = (t_drift < -3.44)
gen reject_trend = (t_trend < -3.44)


display "--- SIMULATION RESULTS (PERCENTAGE OF REJECTIONS) ---"

sum reject_drift reject_trend


twoway ///
    (kdensity t_drift, lcolor(pink) lwidth(medthick)) ///
    (kdensity t_trend, lcolor(ebblue%70) lwidth(medthick)), ///
    title("Augmented Dickey-Fuller Test Power") ///
    subtitle("Overlap of t-statistic distributions (T=150)") ///
    xtitle("t-statistic") ///
    ytitle("Density") ///
	xlabel(,nogrid) ylabel(,nogrid) ///
    xline(-3.44, lcolor(black) lpattern(dash) lwidth(medthick)) ///
    legend(order(1 "Null: rho=1.00" 2 "Alt: rho=0.96") ///
	       col(1) pos(2) ring(0)) name(hw4_kdensity,replace)

graph export hw4_kdensity.png, name(hw4_kdensity) replace

