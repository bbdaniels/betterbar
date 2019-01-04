//! version 1.3 31DEC2018  DIME Analytics bbdaniels@gmail.com

// Betterbar - Stata module to produce bar graphs with standard error bars and cross-group comparisons.

cap prog drop betterbar
prog def betterbar

	// Version compatibility
	if `c(version)' >= 15 local la "la(center)"
	version 13.1

syntax anything 				/// Variable list
	[if] [in] [fw iw aw pw], 	///
	[Over(varname)]				/// Determines groups for comparison at the lowest level
	[by(varname)]				/// Separate variables across higher groups
	[Vertical]					/// Horizontal bar is the default
	[ci]						/// Plots standard error bars
	[n]							/// Adds sample sizes in legend
	[BARlab]					/// Labels bars with means
	[format(string asis)]		/// Formats for bar means
	[*]							/// Allows any normal options for twoway graphs

// Prep

qui {
preserve
marksample touse
	keep if `touse'

// Setup

	// Clean for weights
	local anything = subinstr("`anything'","[]","",.)

	// If no by or over - fill in
		if "`by'" == "" {
			tempname fakebyvar
			gen `fakebyvar' = 1
			local by = "\`fakebyvar'"
			local byoff = 1
		}
		else local byoff = 0

		if "`over'" == "" {
			tempname fakeovervar
			gen `fakeovervar' = 1
			local over = "\`fakeovervar'"
			label def fakeover 1 "Total"
				label val `fakeovervar' fakeover
		}

	// Save this dataset for loops
	tempfile allData
		save `allData' , replace

	// Initialize results dataset
	clear
		tempfile results
		save `results' , emptyok

	// Horizonal-vertical settings
	if "`vertical'" == "" local horizontal "horizontal"
	if "`horizontal'" != "" {
		local reverse "yscale(reverse)"
		local axis y
	}
	else {
		local axis x
	}

// Get means and bounds

	// Loop over by-groups
	use `allData' , clear
	levelsof `by' , local(bylevels)
	foreach bylevel in `bylevels' {
		// Mean respecting over-groups
		use `allData' , clear
		foreach var in `anything' {
			count if `by' == `bylevel' & `var' < .
			if `r(N)' == 0 replace `var' = 0 if `by' == `bylevel'
		}
		keep if `by' == `bylevel'
		mean `anything' [`weight'`exp'] , over(`over' , nolabel)

		mat a = r(table)
		clear
		svmat a , n(eqcol)
		rename * stat_*

		gen `by' = `bylevel'

		local x = 0
		foreach var of varlist stat_* {
			replace `var' = `x' in 9
			local ++x
		}

		append using `results'
		save `results' , replace
	}

// Set up graphing points

	// Find means and bounds
		gen type = mod(_n,9)
		reshape long stat_ , i(`by' type) j(n) string

	// Sort order
		tempvar temp
		gen `temp' = stat_ if type == 0
		bys n: egen order = min(`temp')
		drop `temp'

		gen so = 0
		local n = -1
		foreach item in `anything' {
			replace so = `n' if strpos(n,"`item'") == 1
			local --n
		}
		sort `by' so n order type
		keep if type == 1 | type == 5 | type == 6
		drop if stat_ == 0 | stat_ == .
		gen place = _n - mod(_n,3)
			replace place = place - 3 if mod(_n,3) == 0
			drop order
			reshape wide stat_ , i(n `by') j(type)
			sort place

	// Gaps
		local x = 0
		count
		forvalues i = 1/`r(N)' {
			if `by'[`i'] != `by'[`=`i'-1'] local x = `x'+3
			replace place = place + `x' - 1 in `i'
		}

	// Save statistics dataset
	save `results' , replace

// Prep the graph

	// Graph commands with info from base dataset
	use `allData' , clear
		local x = 0
		levelsof `over' , local(olevels)
		foreach level in `olevels' {
			local ++x
			local theLabel : label (`over') `level'
			count if `over' == `level'
			if "`n'" != "" local theN " (N=`r(N)')"
			local theBars `"`theBars' (bar stat_1 place if n == "`level'" , barw(2) fi(100) lw(thin) `la' lc(white) `horizontal' ) "'
			local theLegend `"`theLegend' `x' "`theLabel'`theN'""'
		}
		// Get variable labels
		foreach var in `anything' {
			local `var' : var label `var'
		}
		// By-labels
		foreach level in `bylevels' {
			local `level' : label (`by') `level'
		}

	// Use statistics dataset for final graph
	use `results' , clear

		// Set up CI plot
		if "`ci'" == "ci" local ++x
		if "`ci'" == "ci" local ciplot `"(rspike stat_5 stat_6 place , lc(black) `horizontal' legend(label(`x' "95% CI")))"'
		local ++x

		// Set up bar labels
		gen lab = strofreal(stat_1,"%9.2f")
		if "`format'" != "" replace lab = strofreal(stat_1,"`format'")
		if "`barlab'" != "" & "`ci'" == "ci" & "`vertical'" == "" local blabplot "(scatter place stat_6  , m(none) mlab(lab) mlabpos(3) mlabc(black) )"
		if "`barlab'" != "" & "`ci'" == ""   & "`vertical'" == "" local blabplot "(scatter place stat_1  , m(none) mlab(lab) mlabpos(3) mlabc(black) )"
		if "`barlab'" != "" & "`ci'" == "ci" & "`vertical'" != "" local blabplot "(scatter stat_6 place , m(none) mlab(lab) mlabpos(3) mlabc(black) )"
		if "`barlab'" != "" & "`ci'" == ""   & "`vertical'" != "" local blabplot "(scatter stat_1 place , m(none) mlab(lab) mlabpos(3) mlabc(black) )"

		// Set up variable names
		gen var = ""
		foreach var in `anything' {
			replace var = "``var''" if strpos(n,"`var'") == 1
			replace n = subinstr(n,"`var'","",1) if strpos(n,"`var'") == 1
		}

		// Gaps
		count
		forvalues i = 2/`r(N)' {
			if var[`i'] != var[`=`i'-1'] replace place = place + 3 if _n >= `i'
		}

		// Set up by-levels
		foreach level in `bylevels' {
			foreach var in `anything' {
				su place if `by' == `level' & var == "``var''"
				if `byoff' != 1 & "`r(mean)'" != "" local varlabs `"`varlabs' `r(mean)' "``level'': ``var''"  "'
				else if "`r(mean)'" != "" local varlabs `"`varlabs' `r(mean)' "``var''"  "'
			}
		}

// Make the graph

	gen zero = 0

	tw ///
		`theBars' 	///
		`ciplot' 	///
		`blabplot' 	///
		(scatter zero zero , m (none) ) ///
		, xtitle(" ") ytitle(" ") `reverse' legend(order(`theLegend')) ///
			`axis'lab(`varlabs' , angle(0) nogrid notick) ylab(,angle(0)) ///
			`options'

// end qui
}
end
// Have a lovely day!
