///////////////////////////////////////////////
//// Utility functions for the tickerplant ////
///////////////////////////////////////////////

/ open the .u namespace and define the utility functions used in tick.q by the tickerplant
\d .u

/ .u.init is called by .u.tick when the script tick.q is run
init:{
  :w::t!(count t::tables`.)#();
  }

/ .u.del is called by .z.pc every time a handle is closed
/ x is a table passed by reference
/ y is the handle that has been closed
/ .u.del is also called from the .u.sub function
del:{[x;y]
  :w[x]_:w[x;;0]?y;
  }

/ x is the handle that has been closed
.z.pc:{[x]
  :del[;x] each t;
  }

/ the .u.sel function is called by the .u.pub and .u.add functions
/ x is the name of a table
/ y is the list of the syms a process wants to subscribe to
sel:{[x;y]
  $[` ~ y;
    :x;
    :select from x where sym in y];
  }

/ the .u.pub function is called by either the .z.ts function (batching mode) or the .u.upd function (non-batching mode)
/ t is a table passed by reference
/ x is the name of the table
/ w is a dictionary of the tables, handles and syms (w is .u.w in the end)
/ the logic is: if there are records to be published to a table t, call asynchronously the upd function defined on the subscribers side
pub:{[t;x]
  {[t;x;w]
    if[count x:sel[x;] w 1;
      :(neg first w)(`upd;t;x)]}[t;x] each w t;
  }

/ .u.add is called by the .u.sub function
/ x is a table passed by reference
/ y is the list of syms a process wants to subscribe to
/ .u.add calls the .u.sel function
add:{[x;y]
  $[(count w x) > i:w[x;;0]?.z.w;
    .[`.u.w;(x;i;1);union;y];
    w[x],:enlist(.z.w;y)];
  :(x;$[99h = type v:value x;sel[v;] y;0#v]);
  }

/ .u.sub is called remotely by the processes that want to subscribe to the tickerplant
/ .u.sub calls itself, the .u.del and .u.add functions
/ x is either a table a process wants to subscribe to or ` if the process wants to subscribe to all the tables
/ y is the list of syms a process wants to subscribe to
sub:{[x;y]
  if[x ~ `;
    :sub[;y] each t];
  if[not x in t;'x];
  del[x;] .z.w;
  :add[x;y];
  }

/ .u.end is called by the .u.endofday function of the tickerplant
/ x is .u.d, that is .z.D
/ the .u.end function called remotely is the .u.end function defined on the subscribers side
end:{[x]
  :(neg union/[w[;;0]])@\:(`.u.end;x);
  }

\d .

