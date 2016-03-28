
$ontext
----------------------------------------------------
  Helper script to add water limit & use data to summary file for Advanced Power models
  
	
  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   August 2011

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-08-03  00:55  bpalmintier   Original Version
  2  2011-08-18  12:55  bpalmintier   Added water cost
  3  2012-01-26  15:35  bpalmintier   Updated for scenario (S) support used with stochastic UC, multi-period planning, etc.
  4  2012-12-08  00:50  bpalmintier   Rescale units to Tgal (& GW)
-----------------------------------------------------
$offtext

*====== Start with any additional calculations that might be needed
PARAMETERS
    pH2oWithdrawPerGen(G, S)  "Water withdrawls per gen, scaled to      [Tgal]"
    pH2oWithdrawTotal    (S)  "Total water withdrawls for the system    [Tgal]"
    ;

pH2oWithdrawPerGen(G, S)$G_H2O_LIMIT(G) = vH2oWithdrawPerGen.l(G, S);

pH2oWithdrawTotal(S) = sum( (G_H2O_LIMIT), vH2oWithdrawPerGen.l(G_H2O_LIMIT) );
    
*====== Now write additional data to the summary files
* file has 2 columns: name, data
* name should include units and be in a MATLAB & MySQL identifier friendly format. That is 
* beginning with a letter and onlycontaining alphanumeric characters and underscores (MATLAB)
* format is:
*     name_with_underscore_unit, value

*- Start with our flag status -
$batinclude %shared_dir%writeFlagState calc_water

*- Additional output data -
* -- Loop over all scenarios
* We assume that %scen_prefix% has already been setup (by writeSummary)
loop (S) do

* total withdrawl
    put %scen_prefix%"H2O_withdraw_total_Tgal," pH2oWithdrawTotal(S) /

* withdrawl by plant type
$batinclude %util_dir%put2csv "" "list" pH2oWithdrawPerGen(G, S) G %scen_prefix%"H2O_withdraw_Tgal_"


*- Additional input data -
    put %scen_prefix% "in_H2O_withdraw_cap_Tgal," pH2oWithdrawCap(S) /
    put %scen_prefix% "in_H2O_cost_usd_kgal," pH2oCost(S) /
*Shadow price for water cap. Scale from Musd/Tgal to $/kGal
    put %scen_prefix% "H2O_limit_shadow_usd_kgal," (-eH2oWithdrawMax.m(S)/1e3) /

endloop;