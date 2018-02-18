histNormalDistr:{[groupNum]
	decimals:1;
	groupPopulation:50;
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
	standardDistr:(`$"," vs ssr["," sv string key standardDistr;"-0,";"0,"])!(occurrences#\:`$"|"),'(maxOccurrences - occurrences)#\:`;

	/ change the possible value -0 with 0 in the classes variable and cast it to symbol
	classes:`$"," vs ssr["," sv string classes;"-0,";"0,"];
	:(classes!count[classes]#enlist maxOccurrences#`),standardDistr;
	}
