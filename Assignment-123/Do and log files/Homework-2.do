cd "F:\ECON 408\Practice do file"

capture log close
log using "Homework-2.log", replace text

* (1) Biased ARMA(2,1) Model Simulation
*-------------------------------------------------------------------------------

clear all
set seed 1000

capture postclose buffer
postfile buffer beta_L1 beta_L2 alpha_L1 using arma22_misspecified.dta, replace

forvalues i = 1/1000 {
    qui drop _all
	qui set obs 500
	qui gen time = _n
	qui tsset time
	
	qui gen double e = rnormal()
	qui gen double y = e in 1
	qui replace y = 0.4*L1.y + e + 0.5*L1.e in 2
	qui replace y = 0.4*L1.y + 0.3*L2.y + e + 0.5*L1.e + 0.3*L2.e in 3/L
	qui arima y, ar(1/2) ma(1)
	post buffer (_b[ARMA:L1.ar]) (_b[ARMA:L2.ar]) (_b[ARMA:L1.ma])

}

postclose buffer
use arma22_misspecified.dta,clear

sum beta_L1 beta_L2 alpha_L1

set scheme white_tableau
graph set window fontface "Arial Narrow" 
	   
* AR(1) Plot
kdensity beta_L1, lcolor(navy) lpattern(solid) lwidth(medthick) ///
         xline(0.4, lcolor(black) lpattern(shortdash)) ///
		 name(g1, replace) title("{bf:AR(1) Parameter}") ///
		 xtitle("Estimated Value") ///
		 xlabel(0 0.4 0.5 1 1.5 2 ,labsize(medium) nogrid) ///
		 ylabel(, labsize(medium) nogrid) note(" ") 

* AR(2) Plot
kdensity beta_L2, lcolor(maroon) lpattern(solid) lwidth(medthick) ///
         xline(0.3, lcolor(black) lpattern(shortdash)) ///
		 name(g2, replace) title("{bf:AR(2) Parameter}") ///
		 xtitle("Estimated Value") ///
		 xlabel(-1 -0.5 0 0.3 0.5 1 ,labsize(medium) nogrid) ///
		 ylabel(, labsize(medium) nogrid) note(" ")

* MA(1) Plot		 
kdensity alpha_L1, lcolor(forest_green) lpattern(solid) lwidth(medthick) ///
         xline(0.5, lcolor(black) lpattern(shortdash)) ///
		 name(g3, replace) title("{bf:MA(1) Parameter}") ///
		 xtitle("Estimated Value") xlabel( ,labsize(medium) nogrid) ///
		 note(" ") ylabel(, labsize(medium) nogrid)

* Combine Graph		 
graph combine g1 g2 g3, /// 
      rows(1) title("{bf:Simulation Results: ARMA(2,1)}") ///
	  xsize(8) ysize(4) ///
	  note("Black dashed line represents the true parameter") ///
	  name(Biased, replace)

graph export Biased_arma.emf, name(Biased) replace



* (2) Unbiased Correct ARMA(2,2) Model Simulation
*-------------------------------------------------------------------------------

clear all
set seed 1000

capture postclose buffer
postfile buffer beta_L1 beta_L2 alpha_L1 alpha_L2 using arma22_correct_model.dta, replace

forvalues i = 1/1000 {
    qui drop _all
	qui set obs 500
	qui gen time = _n
	qui tsset time
	
	qui gen double e = rnormal()
	qui gen double y = e in 1
	qui replace y = 0.4*L1.y + e + 0.5*L1.e in 2
	qui replace y = 0.4*L1.y + 0.3*L2.y + e + 0.5*L1.e + 0.3*L2.e in 3/L
	arima y, ar(1/2) ma(1/2)
	matlist e(b)
	post buffer (_b[ARMA:L.ar]) (_b[ARMA:L2.ar]) (_b[ARMA:L.ma]) (_b[ARMA:L2.ma])

}

postclose buffer
use arma22_correct_model.dta,clear

sum beta_L1 beta_L2 alpha_L1 alpha_L2

set scheme white_tableau
graph set window fontface "Arial Narrow"


* AR(1) Plot
kdensity beta_L1, lcolor(navy) lpattern(solid) lwidth(medthick) ///
    xline(0.4, lcolor(black) lpattern(shortdash)) ///
    name(g1, replace) title("{bf:AR(1) Parameter}") ///
    xtitle("Estimated Value" ,size(medium)) ytitle(, size(medium)) note(" ") ///
    xlabel(0 0.4 0.5 1 1.5, labsize(medium) nogrid) ylabel(, labsize(medium) nogrid)

* AR(2) Plot
kdensity beta_L2, lcolor(maroon) lpattern(solid) lwidth(medthick) ///
    xline(0.3, lcolor(black) lpattern(shortdash)) ///
    name(g2, replace) title("{bf:AR(2) Parameter}") ///
    xtitle("Estimated Value", size(medium)) ytitle(,size(medium)) note(" ") ///
    xlabel(-0.5 0 0.3 0.5, labsize(medium) nogrid) ylabel(, labsize(medium) nogrid)

* MA(1) Plot
kdensity alpha_L1, lcolor(forest_green) lpattern(solid) lwidth(medthick) ///
    xline(0.5, lcolor(black) lpattern(shortdash)) ///
    name(g3, replace) title("{bf:MA(1) Parameter}") ///
    xtitle("Estimated Value", size(medium)) ytitle(,size(medium)) note(" ") ///
    xlabel(-0.5 0 0.5 1, labsize(medium) nogrid) ylabel(, labsize(medium) nogrid)

* MA(2) Plot
kdensity alpha_L2, lcolor(purple) lpattern(solid) lwidth(medthick) ///
    xline(0.3, lcolor(black) lpattern(shortdash)) ///
    name(g4, replace) title("{bf:MA(2) Parameter}") ///
    xtitle("Estimated Value",size(medium)) ytitle(,size(medium)) note(" ") ///
    xlabel(0 0.3 0.5, labsize(medium) nogrid) ylabel(, labsize(medium) nogrid)

* Combine into 2x2 Grid
graph combine g1 g2 g3 g4, ///
    rows(2) cols(2) ///
    title("{bf:Simulation Results: Correctly Specified ARMA(2,2)}") ///
    note("Black dashed line represents the true parameter", size(small)) ///
    xsize(8) ysize(4) name(CorrectModel, replace)


graph export ARMA_Correct.emf, name(CorrectModel) replace



log close