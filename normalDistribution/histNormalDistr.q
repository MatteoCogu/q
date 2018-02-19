/////////////////////////////
//// Normal Distribution ////
/////////////////////////////
/ the following function creates a normal distribution taking advantage of the Central Limit Theorem (CLT)

// IDEA:
/ the idea is to have a population with stochastic variables X (e.g. X can be 0 or 1 with equal probability)
/ and then put together some of the occurrences in groups of equal number n
/ the CLT states that:
/ for n -> + infinite
/ the probability distribution of the AVERAGE of X approaches the normal (Gaussian) distribution

// Arguments of the function
/ number of the groups (groupNum)
/ population in each group (groupPopulation)
/ flag for standardizing the normal distribution (average 0, standard deviation 1)	////// TODO //////
/ flag for displaying the result as a dictionary (`d) or a table (`t) (displayMode)
/ flag for displaying the value of the classes (displayClasses)

/ good console size numbers:
/ \c 55 150
/ example of parameters to run:
/ histNormalDistr[500;200;`t;0]

histNormalDistr:{[groupNum;groupPopulation;displayMode;displayClasses]
	/ parameters
	decimals:1;	////// TODO: add an argument to set the decimals in the calculations and to display //////
	$[displayMode ~ `d;
	[displayChar:`$"|";
	displayCharClass:`$"-"];
	displayMode ~ `t;
	[displayChar:`$"-";
	displayCharClass:`$"|"];
	'`$"No valid entry for the displayMode argument (type `d for a dictionary or `t for a table output)."];

	gaussianDistr:group asc (sum each groupPopulation cut (groupNum*groupPopulation)?2i)%groupPopulation;
	gaussianDistr:key[gaussianDistr]!occurrences:count each value gaussianDistr;
	maxOccurrences:max occurrences;

	/ standardization
	average:(sum key[gaussianDistr]*'occurrences)%sum occurrences;
	standDev:sqrt (sum occurrences*'(key[gaussianDistr] - average) xexp 2)%sum occurrences;
	standardDistr:("F"$.Q.f[decimals;] each (key[gaussianDistr] - average)%standDev)!occurrences;

	/ histogram logic
	classes:"F"$.Q.f[decimals;] each tmp + (til 1 + `long$(10 xexp decimals)*(max key standardDistr) - tmp:min key standardDistr)%10 xexp decimals;
	
	/ from right to left:
	/ make the dictionary a rectangular dictionary
	/ use - to represent the histogram
	/ change the possible value -0 with 0 in the standardDistr variable and cast it to symbol
	standardDistr:(`$"," vs ssr["," sv string key standardDistr;"-0,";"0,"])!(occurrences#\:displayChar),'(maxOccurrences - occurrences)#\:`;

	/ change the possible value -0 with 0 in the classes variable and cast it to symbol
	classes:`$"," vs ssr["," sv string classes;"-0,";"0,"];
	$[displayClasses;
   classesToDisplay:classes;
   classesToDisplay:count[classes]#displayCharClass];

	/ plot
	if[displayMode ~ `d;
	:classesToDisplay!value (classes!count[classes]#enlist maxOccurrences#`),standardDistr];
	if[displayMode ~ `t;
	:flip classesToDisplay!value (classes!count[classes]#enlist maxOccurrences#`),standardDistr];
	}

