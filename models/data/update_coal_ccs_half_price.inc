
$ontext
-------------------------------------------------
SALE on Coal CCS! 50% off today only!!
Update file to drop the price of Coal CCS by a factor of 2

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   June 2012

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2012-06-15  00:15  bpalmintier   Original version
-------------------------------------------------
$offtext

pGen('new_coal_st_ccs','c_cap',S) = 0.5 * pGen('new_coal_st_ccs','c_cap',S);