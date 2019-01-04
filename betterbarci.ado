//! version 1.3 31DEC2018  DIME Analytics bbdaniels@gmail.com

// Betterbar - Stata module to produce bar graphs with standard error bars and cross-group comparisons.

// Confidence intervals alternative specification

	cap prog drop betterbarci
	prog def betterbarci

	syntax anything [using] [if] [in] [fw iw aw pw] , [*]

	betterbar `anything' `using' `if' `in' [`weight'`exp'] , `options' ci

	end

// That's all!
