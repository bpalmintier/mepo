
$ontext
----------------------------------------------------
Common Planning Margin Formulation for Advanced Power Family of models
----------------------------------------------------
  Simple shared equation for planning margin
  
  Note: the command line parameter --plan_margin is assumed to have already been checked
  by the caller.

Additional control variables:
   --capacity_G      Alias to specify total capacity by generator. This allows easy use of either
                      vCapInUse(G) or pGen(G, 'cap_cur') for expansion or operation only
                      optimizations respectively. If not set by the caller, we assume operations
                      only and set it to pGen(G,'cap_cur').

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   November 2011

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-11-15  01:25  bpalmintier   Extracted from StaticCapPlan v68
  2  2012-01-25  23:55  bpalmintier   Added scenario support for stochastic UC, multi-period planning, etc.
  3  2012-02-04  01:30  bpalmintier   Assume plan_margin flag checked by caller Added declarations for all referenced parameters
-----------------------------------------------------
$offtext

*================================*
*  Additional Control Variables  *
*================================*

$if NOT set capacity_G $setglobal capacity_G pGen(G,'cap_cur',S)

*================================*
*         Declarations           *
*================================*

* ======  Declare the data parameters. Actual data imported from include files
sets
* Sets for table parameters

    GEN_PARAMS  "generation table parameters"
       /
        cap_credit  "Capacity Credit during peak block           [p.u.]"
       /

* Sets for data, actual definitions can be found in include files
    G           "generation types (or generator list)"
    S           "scenarios for multi-period and stochastic problems"

parameters
* Data Tables
    pGen   (G, GEN_PARAMS, S)       "table of generator data"
* Additional Parameters
    pDemandMax (S)              "Maximum demand level          [GW]"

scalars
    pPlanReserve                "planning reserve              [p.u.]"
    ;

$ifthen set plan_margin_penalty
positive variables
    vUnderPlanReserve(S)        "Firm capacity below required planning reserve [GW]"
$endif

* ======  Declare Equations
equations
    ePlanMargin(S)             "Planning margin to ensure adequate capacity during peak  [p.u.]"
    ;
*================================*
*     The Actual Equations       *
*================================*
* Important: we must be included into a larger model, so no objective function defined

*====== Planning Reserve Margin (peak period only)
ePlanMargin(S) ..  sum[(G), %cap_for_plan_margin%*pGen(G,'cap_credit',S)] 
$ifthen set plan_margin_penalty
                    + vUnderPlanReserve(S)
$endif
                     =g=
                     (1 + pPlanReserve)*pDemandMax(S);
