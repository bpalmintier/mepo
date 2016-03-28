*Start Block Quote
$ontext
-------------------------------------------------
Update file that perturbs the generator parameters for a seperate unit representation in hopes
of speeding-up the MIP branch and bound.

Note: we perturb both the capital cost and the variable o&m costs to see the effect for cases
where only one of investments OR commitments are integer

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   July 2011

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-07-24  18:30  bpalmintier   Original version
  2  2011-09-29  17:10  bpalmintier   Major bug fix, now changes with each element (card is const)
-------------------------------------------------
$offtext

pGenData(G,'c_cap') = pGenData(G,'c_cap') * (1 + (ord(G) - card(G)/2)/card(G) * .0001);
pGenData(G,'c_var_om') = pGenData(G,'c_var_om') * (1 + (ord(G) - card(G)/2)/card(G) * .0001);

