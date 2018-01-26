/////////////////////
//// Definitions ////
/////////////////////
.z.ts:{.monitor.mon[]}

.z.ps:{[messageContent]
  update endTime:messageContent from `.monitor.table where handles = .z.w;
  update responseTime:`timespan$endTime - startTime from `.monitor.table where handles = .z.w;
  }

.monitor.mon:{
  handles:key .z.W;
  numRows:count handles;
  `.monitor.table upsert ([handles]startTime:numRows#.z.p;endTime:numRows#0Np;responseTime:numRows#0Nn);
  neg[handles]@\:"neg[.z.w](.z.p)";
  }

.monitor.table:([handles:`int$()]
  startTime:`timestamp$();
  endTime:`timestamp$();
  responseTime:`timespan$())

///////////////////
//// Execution ////
///////////////////
/ set the period in seconds
.monitor.period:30;
system"t ",string .monitor.period * 1000;
-1 "The information on the response time of the servers is updated every ", string[.monitor.period]," seconds and is contained in .monitor.table";
