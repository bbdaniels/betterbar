{smcl}
{* Dec 31st 2018}
{hline}
Help for {hi:betterbar} version 1.3
{hline}

{title:Description}

{p}{cmd:betterbar} and {cmd:betterbarci} produce bar graphs with standard error bars and cross-group comparisons.

{title:Syntax}

{p 2 4}{cmd:betterbar} {help varlist} [{help if}] [{help in}] [{help weight}], [{it:options}] [{help twoway_options}]

{synoptset 16 tabbed}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opth by(varname)}}Produces top-level grouping of bars by specified variable.{p_end}
{synopt:{opth o:ver(varname)}}Produces bottom-level grouping of bars.{p_end}
{break}
{synopthdr:Graph Options}
{synopt:{opt n}}Adds group sizes to legend.{p_end}
{synopt:{opt ci}}Includes 95% confidence intervals around the means. Alternately specify {bf: betterbarci}.{p_end}
{synopt:{opt bar:lab}}Labels the bars with the mean values.{p_end}
{synopt:{opth format(format)}}Format the bar labels. {p_end}
{synopt:{opt v:ertical}}Produces vertical bars. The default is horizontal.{p_end}
{synoptline}
{p 4 6 2}{p_end}

{title:Example}

{inp}    {stata sysuse auto.dta , clear:sysuse auto.dta , clear}
{inp}    	{stata xtile temp = rnormal() , n(4):xtile temp = rnormal() , n(4)}
{inp}    	{stata label def temp 1 "1" 2 "Two" 3 "Tres" 4 "IV":label def temp 1 "1" 2 "Two" 3 "Tres" 4 "IV"}
{inp}    	{stata label val temp temp:label val temp temp}
{inp}    	{stata replace price = . if temp == 1:replace price = . if temp == 1}
{inp}    {stata betterbarci price mpg, over(foreign) n by(temp) bar format(%9.2f):betterbarci price mpg, over(foreign) n by(temp) bar format(%9.2f)}

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{title:Contributing}

{p}{bf: betterbar} is open for development on {browse "https://bbdaniels.github.io/stata-code/betterbar/":GitHub}.
Submit bugs and feature requests {browse "https://github.com/bbdaniels/betterbar/issues":here}.
If you like {bf:betterbar}, be sure to visit my {browse "http://bbdaniels.github.io":homepage}
and {browse "https://gist.github.com/bbdaniels/a3c9f9416f1d16d6f3c6e8cf371f1d89":Stata boilerplate code}.{p_end}
