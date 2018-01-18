trade:([]time:`time$();sym:`symbol$();price:`float$())
quote:([]time:`time$();sym:`symbol$();ask:`float$();bid:`float$())

/
/ feedhandler
h:hopen`::6010;
neg[h](`.u.upd;`trade;(`time$first 1?24*60*60*1000;upper first 1?`3;`float$first 1?100));
neg[h](`.u.upd;`quote;(`time$3?24*60*60*1000;upper 3?`3;`float$3?100;`float$3?100));
\
