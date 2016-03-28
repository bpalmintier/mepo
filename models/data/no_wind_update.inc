*Start Block Quote
$ontext
-------------------------------------------------
Set wind current and max capacity to wind

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT/NREL
   March 2013

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2013-03-21  21:00  bpalmintier   Original version
-------------------------------------------------
$offtext

*Zero out current wind capacity
pGen(G, 'cap_cur', S)$(pGen(G,'fuel',S)=wind) = 0;

*Prevent any new wind from being built
pGen(G, 'cap_max', S)$(pGen(G,'fuel',S)=wind) = 0;