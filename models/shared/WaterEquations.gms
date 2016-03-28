
$ontext
----------------------------------------------------
  Add Water limitations to StaticCapPlan family of electricity capacity planning models
  
  Important: NOT a standalone model. Include these additional equations using:
   $include %shared_dir&WaterEquations.gms
   
  Additional command-line parameters
           --h2o_limit=(Inf)     System wide maximum water use [Tgal]. Only computed for gens
                                  with specified water usage (h2o_withdraw_var)
           --h2o_cost=(0)        System wide water cost [$/kgal]. Only computed for gens
                                  with specified water usage (h2o_withdraw_var)

  WARNING: only water use for making power is included. Cooling requirements during startup 
   fuel use are not included
	
  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   August 2011

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-08-02  16:05  bpalmintier   Original Version
  2  2011-08-17  16:05  bpalmintier   Added Water cost
  3  2011-08-17  16:10  bpalmintier   Extracted WaterDataSetup.gms for proper data ordering
  4  2012-01-26  11:10  bpalmintier   Added scenario support for stochastic UC, multi-period planning, etc.
  5  2012-03-07  12:05  bpalmintier   Added support for partial period simulation through D_SIM
  6  2012-05-02  10:45  bpalmintier   Separate demand (D) into blocks (B) and time sub-periods (T)
  7  2012-12-08  00:50  bpalmintier   Rescale units to Tgal (& GW)
-----------------------------------------------------
$offtext

*================================*
*         Declarations           *
*================================*

* Expand Sets as needed
sets
    G           "[DUPLICATE] set of generation"
    B           "[DUPLICATE] Demand blocks (e.g. weeks or ldc)"
	T			"[DUPLICATE] Demand time sub-periods (e.g. hours or ldc sub-blocks)"
    B_SIM(B)    "[DUPLICATE] demand blocks used in simulation"
    S           "[DUPLICATE] set of scenarios"
    GEN_PARAMS  "[ADDITIONS] generation table parameters"
        /
        h2o_withdraw_var "Water withdrawl per MWh                    [gal/MMBTU]"
        h2o_withdraw_max "Maximum water withdrawl by generation type [Tgal]"
       /

* Subsets for special purposes
    G_H2O_LIMIT(G, S)      "Generators to include in water limits"
;

* ======  Declare the data parameters. Actual data imported from include files
parameters
    pGen(G, GEN_PARAMS, S)  "[DUPLICATE] Table of generator parameters"

    pH2oCost        (S)           "Per-unit water cost                              [$/kgal]"
    pH2oWithdrawCap (S)           "System-wide water withdrawl limit, for super simple limits    [Tgal]"
;

* ======  Declare Variables
positive variables
    vPwrOut           (B,T, G, S)    "[DUPLICATE] Energy generation per period per gen [GWh]"
    vH2oWithdrawPerGen(   G, S)    "Water withdrawls for each generator      [Tgal]"
;

* ======  Declare Equations
equations
    eH2oWithdrawPerGen   (G, S) "Compute waterwithdrawls for each generator"
    eH2oWithdrawPerGenMax(G, S) "Limit water withdrawls for each generator"
    eH2oWithdrawMax      (   S) "System-wide withdrawl limits"
;

*================================*
*     The Actual Equations       *
*================================*
* Important: we must be included into a larger model, so no objective function defined

eH2oWithdrawPerGen(G, S)$( B_SIM(B)
                           and G_H2O_LIMIT(G) )
* Units & Scaling:                      external        this eq.
*   1000x   vH2oWithdrawPerGen          Tgal            Ggal
*   1/1e6x  pGen('h2o_withdraw_var')    gal/MMBTU  to   Ggal/G-BTU
*   1x      pGen('heatrate')            MMBTU/MWh  to   G-BTU/GWh
*   1x      vPwrOut                     GW
*   1x      Demand(dur)                 hr
    .. vH2oWithdrawPerGen(G, S)*1e3 =e= sum( (B,T), vPwrOut(B,T, G, S))
                                    * pDemand(B_SIM, T, 'dur', S) 
                                    * pGen(G, 'heatrate', S)
                                    * pGen(G, 'h2o_withdraw_var', S)/1e6;

*Only compute max for gens with finite withdrawl limits
eH2oWithdrawPerGenMax(G, S)$( B_SIM(B)
                              and G_H2O_LIMIT(G) 
                              and pGen(G, 'h2o_withdraw_max', S) < Inf )
    .. vH2oWithdrawPerGen(G, S) =l= pGen(G, 'h2o_withdraw_max', S);
    
eH2oWithdrawMax(S)
* Units & Scaling:                  
*   1x  vH2oWithdrawPerGen          Tgal
*   1x  pH2oWithdrawCap             Tgal
    .. sum( (G_H2O_LIMIT), vH2oWithdrawPerGen(G_H2O_LIMIT, S) ) =l= pH2oWithdrawCap(S);
    