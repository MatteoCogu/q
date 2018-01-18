/////////////////////////////
//// Tickerplant process ////
/////////////////////////////

/ in order to start the tickerplant process, run for example:
/ q tick.q sym journal -p 6010 -t 30000

/
global variables used:
.u.w - dictionary of tables -> (handle;syms)
.u.i - msg count in logfile
.u.j - total msg count (logfile plus those held in buffer)
.u.t - table names
.u.L - logfile name, e.g. `:./sym2018.01.15
.u.l - handle to the logfile
.u.d - date (.z.D)
\

/ load the schema of the tables (load tick/sym.q if other parameters are not passed, otherwise specify the q file where the schema is defined and pass it as first parameter when running this script)
system"l tick/",(src:first .z.x,enlist"sym"),".q";

/ if the port is not specified start listening to port number 5010
if[not system"p";system"p 5010"];

/ load the tick/u.q script
\l tick/u.q

/ open the .u namespace and define the functions of the tickerplant
\d .u

/ .u.ld is related to the logging process
/ .u.ld is called by .u.tick
/ the argument of the function is .u.d that is nothing but .z.D
ld:{[x]
  if[not type key L::`$(-10_string L),string x;
    .[L;();:;()]];
  i::j::-11!(-2;L);
  if[0 <= type i;
    -2(string L)," is a corrupt log. Truncate to length ",(string last i)," and restart";
    exit 1];
  :hopen L;
  }

/ .u.tick is the main function that runs on the tickerplant
/ x is the src variable defined above (e.g. "sym")
/ y is the name of the folder where the logs will be daily written (e.g. "journal")
tick:{[x;y]
  init[];
  if[not min(`time`sym ~ 2#key flip value@) each t;
    '`timesym];
  @[;`sym;`g#] each t;
  d::.z.D;
  if[l::count y;
    L::`$":",y,"/",x,10#".";
    l::ld d];
  }

/ .u.endofday is called by .u.ts (that is periodically called by the timer)
/ .u.endofday is a niladic function
/ .u.endofday calls the .u.end function of the tickerplant (also the rdb process has its own .u.end)
endofday:{
  end d;
  d+:1;
  if[l;
    hclose l;
    l::0(`.u.ld;d)];
  }

/ .u.ts is called by .z.ts that is periodically called by the timer of the tickerplant
/ the argument is .z.D
ts:{[x]
  if[d < x;
    if[d < x - 1;
      system"t 0";
      '"more than one day?!"];
    :endofday[]];
  }

/ batching mode
/ the tickerplant publishes the data received by the feedhandler in "batches" accordingly to the timer
/ if the timer of the tickerplant is already set, define the .z.ts and .u.upd functions in the following way
/ the .z.ts function calls the .u.pub and .u.ts functions
/ t is a table passed by reference
/ x is the list of the values pushed from the feedhandler to the tickerplant
/ the x argument of the .u.upd function should be in the form (1 2;`a`b;("ab";"cd")) in the case of 2 records to send to the TP
/ in batching mode the .u.pub function is called periodically
if[system"t";
  .z.ts:{
    pub'[t;value each t];
    @[`.;t;@[;`sym;`g#]0#];
    i::j;
    :ts .z.D;
    };
  upd:{[t;x]
    if[not -19h = type first first x;   / here -19h is set since we want the time field to be of time type, but, for example, put -12h if you want timestamps
      if[d < "d"$a:.z.P;
        .z.ts[]];
      a:"t"$a;    / here do not cast if you want to use timestamps or cast accordingly to what you need
      x:$[0h > type first x;a,x;(enlist(count first x)#a),x]];
    t insert x;
    if[l;
      l enlist (`upd;t;x);
      :j+:1];
    }];

/ non-batching mode
/ the tickerplant publishes the data as soon as it is received from the feedhandler
/ the timer of the tickerplant is initially not set, but then it is set every second
/ the .z.ts function is set equal to the .u.ts function (passing .z.D as argument of the .u.ts function)
/ t is a table passed by reference
/ x is the list of the values pushed from the feedhandler to the tickerplant
/ the x argument of the .u.upd function should be in the form (1 2;`a`b;("ab";"cd")) in the case of 2 records to send to the TP
/ in non-batching mode the .u.pub function is called when the .u.upd function is called
if[not system"t";system"t 1000";
  .z.ts:{ts .z.D};
  upd:{[t;x]
    ts"d"$a:.z.P;
    if[not -19h = type first first x;
      a:"t"$a;
      x:$[0h > type first x;a,x;(enlist(count first x)#a),x]];
    f:key flip value t;
    pub[t;$[0h > type first x;enlist f!x;flip f!x]];
    if[l;
      l enlist (`upd;t;x);
      :i+:1];
    }];

\d .

/ run the .u.tick function
/ src is the variable defined at the beginning of the script (e.g. "sym")
/ .z.x 1 is the name of the folder where the logs will be daily written (e.g. "journal")
.u.tick[src;.z.x 1];

