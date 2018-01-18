/////////////////////
//// RDB process ////
/////////////////////

/ in order to start the RDB process, run for example:
/ q tick/r.q :6010 :6012

/ if the operating system is not windows, then sleep for 1 second
if[not "w" = first string .z.o;system"sleep 1"];

/ define the .u.hdbDir variable containing the filehandle to the directory of the hdb
/ note that it is necessary to start a q process that will work as hdb, loading the hdb and listening to a certain port
/ for example, run:
/ q /path/to/hdb -p 6012
.u.hdbDir:"/path/to/hdb/";

/ define the upd function that is called remotely by the .u.pub function of the tickerplant
/ upd also runs when replaying the logfiles
upd:insert;

/ .u.x contains the tickerplant and hdb ports, defaults are 5010 and 5012 
.u.x:.z.x,(count .z.x)_(":5010";":5012");

/ .u.end is the function remotely called by the .u.end function of the tickerplant at the end of the day (EOD)
/ .u.end saves down the tables onto the disk, clears them out and reloads the hdb
/ x is the current date (.u.d, that is the .z.D of the tickerplant)
/ .Q.gc is not present in the original version on gitHub, but it is reasonable to run it at EOD
.u.end:{[x]
  t:tables`.;
  t@:where `g = attr each t@\:`sym;
  .Q.hdpf[`$":",.u.x 1;`:.;x;`sym];
  @[;`sym;`g#] each t;
  :.Q.gc[];   / here .Q.gc has been added with respect to the tick.q code on gitHub
  } 

/ .u.rep initializes the schema of the tables, replays the logfile and does the cd to the hdb folder
/ x is a general list composed by the tables passed by reference and the schemas; for example for one table (`trade;+`time`sym`volume!(`time$();`symbol$();`int$()))
/ y is the list of the count of the logfile and its filehandle (e.g. (5;`:journal/sym2018.01.15))
.u.rep:{[x;y]
  .[;();:;] .' x;   / here the original code was: (.[;();:;].) each x;
  if[null first y;:()];
  -11!y;
  :system"cd ",.u.hdbDir;
  } 

/ open a connection to the tickerplant and subscribe to all the tables and all the syms
/ the argument of the .u.rep function is of the form ((`trade;+`time`sym`volume!(`time$();`symbol$();`int$()));(5;`:journal/sym2018.01.15))
.u.rep . (hopen `$":",.u.x 0)"(.u.sub[`;`];`.u `i`L)";

