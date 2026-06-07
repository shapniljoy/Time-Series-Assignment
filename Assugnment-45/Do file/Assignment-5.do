
cd "F:\ECON 408\Practice do file\Assignments\Time-Series-Assignment\Assugnment-45\Do file"

clear all
set more off
set seed 10
	
drop _all
set obs 500
gen t = _n
tsset t

forvalues i = 1/500 {
			gen double u_`i' = rnormal()
			gen double y_`i' = sum(u_`i') 
}
			
gen t_stat = .
gen r2 = .
 
forvalues i = 2/500 {
	quietly reg y_1 y_`i'
	replace t_stat =  _b[y_`i'] / _se[y_`i'] in `i'
	replace r2 = e(r2) in `i'
}

gen reject = (abs(t_stat) > 1.96)

display "Target False Rejection Rate: 0.05 (5%)"
sum reject

display "Average R-squared of completely independent variables:"
sum r2 

set scheme white_tableau

histogram r2, ///
    width(0.05) ///
    fcolor(ebblue%70) /// 
    lcolor(white) lwidth(vthin) ///
    normal ///
	normopts(lcolor(pink)) ///
    title("Spurious Regression: R-squared Distribution", color(black) size(medlarge)) ///
    xtitle("Estimated R-squared") ///
    ytitle("Density") 


	
twoway ///
    (kdensity t_stat,  recast(area) fcolor(ebblue%70) lcolor(white) lwidth(medthick)) ///
    (function y = normalden(x), range(-15 15) lcolor(red) lwidth(medthick) lpattern(dash)), ///
    title("Spurious Regression t-statistic Distribution") ///
    subtitle("500 Independent Random Walks (T=500)") ///
    xtitle("OLS t-statistic for Beta") ///
    ytitle("Density") ///
    legend(order(1 "Simulated t-stat" 2 "Standard Normal") col(1) pos(2) ring(0)) ///
    xline(-1.96 1.96, lcolor(black) lpattern(dot)) 

