//! version 1.2.0 31DEC2018  DIME Analytics bdaniels@worldbank.org

// Confidence intervals alternative specification

	cap prog drop betterbarci
	prog def betterbarci

	syntax anything [using] [if] [in] [fw iw aw pw] , [*]

	betterbar `anything' `using' `if' `in' [`weight'`exp'] , `options' ci

	end

// That's all!
