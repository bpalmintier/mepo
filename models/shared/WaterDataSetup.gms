
$ontext
----------------------------------------------------
  Handle Water related pre-solve data setup for StaticCapPlan family
----------------------------------------------------
 Handle Water related pre-solve data setup for StaticCapPlan family of electricity capacity planning models  

  Important: NOT a standalone model. See WaterEquations.gms for more information
	
  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   August 2011

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-08-17  16:05  bpalmintier   Extracted from WaterEquations.gms v2
  2  2011-08-17  15:55  bpalmintier   Added water cost
  3  2012-01-26  11:10  bpalmintier   Added scenario support for stochastic UC, multi-period planning, etc.
-----------------------------------------------------
$offtext

*================================*
*        Handle The Data         *
*================================*
* ===== Command Line Parameters
* Set the annual water withdrawl limit from the command line. Or set to the default
* if not defined
$ifthen set h2o_limit
    pH2oWithdrawCap(S)=%h2o_limit%;
$else
    pH2oWithdrawCap(S)=Inf;
$endif    

* Set the water price from the command line. Or set to the default
* if not defined
$ifthen set h2o_cost
    pH2oCost(S)=%h2o_cost%;
$else
    pH2oCost(S)=0;
$endif    

* ====== Calculate subsets
*only compute water limits for those plants with defined water usage
G_H2o_LIMIT(G)$( pGen(G,'h2o_withdraw_var', S) > 0 ) = yes;
