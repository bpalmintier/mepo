
$ontext
----------------------------------------------------
  Helper include to write the standardized output summary put file for Advanced Power models
  
	
  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   July 2011

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-07-15  00:45  bpalmintier   Extracted from OpsLp v4
  2  2011-07-15  10:15  bpalmintier   moved solution result (run_*) to caller
  3  2011-08-02  16:05  bpalmintier   Added complete command line option results using writeFlagState
  4  2011-08-07  16:05  bpalmintier   Always write non-served energy
  5  2011-08-17  15:55  bpalmintier   Added water cost
  6  2011-09-22  16:26  bpalmintier   Added Generic solution timing and status information
  7  2011-09-28  04:15  bpalmintier   Corrected $if for pMipGap
  8  2011-10-06  21:55  bpalmintier   Output total duration in hours
  9  2011-10-08  13:55  bpalmintier   New flags: p0_recover, rel_cheat, pwl2afine
 10  2011-10-09  12:15  bpalmintier   Added pUcIntEnabled
 11  2011-10-09  16:15  bpalmintier   Added model size statistics
 12  2011-10-11  14:15  bpalmintier   Renamed plant_size to gen_size (also related flags)
 13  2011-10-14  03:15  bpalmintier   Added gparams include file output
 14  2011-11-10  13:45  bpalmintier   Added no_capital
 15  2012-01-26  15:35  bpalmintier   Updated for scenario (S) support used with stochastic UC, multi-period planning, etc.
 16  2012-01-28  23:05  bpalmintier   Added model_name, scenario weights, and scen_val file information
 17  2012-02-03  00:15  bpalmintier   Adjusted for carbon emissions by generator
 18  2012-02-03  13:35  bpalmintier   Added skip_cap_limit and overbuild
 19  2012-05-02  10:45  bpalmintier   Separate demand (D) into blocks (B) and time sub-periods (T)
 20  2012-05-04  23:05  bpalmintier   Added maintenance support
 21  2012-06-14  15:05  bpalmintier   Added rps & planning margin penalties
 22  2012-08-21  17:15  bpalmintier   Convert plan_margin to value flag
 23  2012-08-21  23:05  bpalmintier   Added maintenance cost
 24  2012-08-21  23:55  bpalmintier   Added retirement
  25 2012-08-22  15:05  bpalmintier   Added priority (B&B tree) option
  26 2012-08-23  13:05  bpalmintier   Added maint_lp to ignore maintenance integers
  27 2012-08-23  14:05  bpalmintier   Added uc_lp
  28 2012-08-24  14:25  bpalmintier   BUGFIX: summary scaling of non-served cost
  29 2012-08-24  15:25  bpalmintier   Rearrange to move energy non-served up
  30 2012-08-31  01:05  bpalmintier   Add rsrv_use_tot_demand
  31 2012-08-31  07:25  bpalmintier   Use adj_rsrv_for_nse instead of rsrv_use_tot_demand
  32 2012-09-02  17:08  bpalmintier   Replace all $set with $setglobal (to prevent scope errors)
  33 2012-09-03  07:08  bpalmintier   Add derate_to_maint
  34 2012-09-06  09:58  bpalmintier   Add no_quick_st, non_uc_rsrv_down_offline and non_uc_rsrv_up_offline
-----------------------------------------------------
$offtext

* file has 2 columns: name, data
* name should include units and be in a MATLAB & MySQL identifier friendly format. That is 
* beginning with a letter and only containing alphanumeric characters and underscores (MATLAB)
* format is:
*     name_with_underscore_unit, value

*========== Model run Summary Data ==========
*- Model Run and Objective Function Information -
$if set model_name
    put  "run_model_name,%model_name%" /
$if set obj_var
    put  "run_obj_var,%obj_var%" /
$if declared vObjective    
    put  "run_obj_value," vObjective.l /

$ifthen set model_name
* Note: this section is only able to be included if we have defined the model_name as a
* control variable, since otherwise we don't know what model was used in the solve statement
    put  "run_modstat,"    %model_name%.Tmodstat /
    put  "run_solstat,"    %model_name%.Tsolstat /
$if set use_mip $if %use_mip% == yes    put  "run_mip_gap,"         pMipGap:0:6 /

* Solver only time (does not include GAMS generation time, reading solution, and reporting)
* Use this for algorithmic/formulation time comparisons
    put  "run_solver_time_sec,"    %model_name%.ETSolver /
    put  "run_mip_nodes,"          %model_name%.nodusd /

$endif

* print total solution time
put  "run_time_sec," system.elapsed /

*========== Scenario Dependent Data ==========
* -- Setup our scenario prefix for each scenario dependent output line
$ifthen set scen
* When we have a set of scenarios defined, prefix output with the scenario element name _
$setglobal scen_prefix S.tl:0"_"
*Work around for the fact that GAMS doesn't strip quotes if the entire string is not quoted
$setglobal quote ''
$else
* Otherwise leave it blank
$setglobal scen_prefix ''
*Work around for the fact that GAMS does strip outer quotes if the entire string is quoted
$setglobal quote '"'
$endif

* -- Loop over all scenarios
loop (S) do
* When we have more than one scenario, print it along with explanatory text
    if card(S) > 1 then
        put "SCENARIO_":0 ord(S):0:0 "," S.te(S):0 " (" S.tl:0 ": weight=" pScenWeight(S):0 ")"/
    endif;

* ---- Cost Data ----    
* total cost
    put %scen_prefix% "cost_total_Musd,"         vTotalCost.l(S)/
    
* write cost breakdown
$ifthen declared vCapitalCost
        put %scen_prefix% "cost_capital_Musd,"     vCapitalCost.l(S)/
$endif
    put %scen_prefix% "cost_ops_Musd,"         vOpsCost.l(S)/
    put %scen_prefix% "cost_fixedOM_Musd,"     vFixedOMCost.l(S)/
    put %scen_prefix% "cost_varOM_Musd,"       vVariableOMCost.l(S)/
    put %scen_prefix% "cost_fuel_Musd,"        vFuelCost.l(S)/
    put %scen_prefix% "cost_carbon_Musd,"      vCarbonCost.l(S)/
$ifthen not set no_nse
*Scale cost of non-served from $/MWh to M$/GWh
    put %scen_prefix% "cost_non_served_Musd,"  sum[(B, T), vNonServed.l(B, T, S)*pPriceNonServed*pDemand(B, T, 'dur', S)/1000]/
$endif
    put %scen_prefix% "cost_penalty_Musd,"     vPenaltyCost.l(S)/
$ifthen set startup
    put %scen_prefix% "cost_startup_Musd,"     vStartupCost.l(S)/
$endif
$ifthen set maint
    put %scen_prefix% "cost_maint_Musd,"       vMaintCost.l(S)/
$endif
$ifthen set calc_water
* Note scaling from Mgal (vH2oWithdrawPerGen) to kgal (pH2oCost), and usd (pH20Cost) to Musd (totals)
    put %scen_prefix% "cost_water_Musd,"        sum[ (G_H2O_LIMIT), vH2oWithdrawPerGen.l(G_H2O_LIMIT, S)* pH2oCost(S) /1e3 ]  /
$endif

* ---- Energy/Emissions data ----
* total emissions
    put %scen_prefix% "CO2e_total_Mt," pTotalCarbonEmissions(S) /

* carbon_price (use either the value set or the carbon cap constraint dual variable)
    put %scen_prefix% "CO2e_price_usd_t," (max(-eCarbonCap.m(S), pCostCO2(S)))/

* total energy
    put %scen_prefix% "energy_total_TWh,"  pEnergyTotal(S) /

* average electricity price
    put %scen_prefix% "avg_price_usd_MWh,"  (vTotalCost.l(S)/pEnergyTotal(S)) /

* non-served Energy
$ifthen not set no_nse
    put %scen_prefix% "energy_non_served_GWh," sum[(B, T), vNonServed.l(B, T, S)*pDemand(B, T, 'dur', S)]/
$else
    put %scen_prefix% "energy_non_served_GWh, 0"/
$endif

* energy by plant type
$batinclude %util_dir%put2csv "" "list" pEnergyGen(G,S) G %scen_prefix%%quote%'energy_TWh_'%quote%

$ifthen set plan_margin_penalty
    put %scen_prefix% "cap_under_plan_margin_GW," vUnderPlanReserve.l(S) /
$endif
$ifthen set rps_penalty
    put %scen_prefix% "energy_under_rps_GWh," vUnderRPS.l(S) /
$endif
    put %scen_prefix% "RPS_target_fraction," pRPS(S) /
    put %scen_prefix% "renew_fraction," pRenewPercent(S) /

* report renewable shedding
$batinclude %util_dir%put2csv "" "list" pTotalRenewableShedByGen(G_RPS,S) G_RPS %scen_prefix%%quote%'shed_GWh_'%quote%

* report avg number of starts per plant
$ifthen declared pPerUnitStartupCount
$if set startup $batinclude %util_dir%put2csv "" "list" pPerUnitStartupCount(G,S) G %scen_prefix%%quote%'avg_starts_'%quote%
$endif

* ---- Additional data ----
* peak demand
    put %scen_prefix% "demand_max_GW," pDemandMax(S)/
    put %scen_prefix% "data_dur_hr," pTotalDurationHr(S) /

$ifthen defined vNewCapacity 
$batinclude %util_dir%put2csv "" "list" vNewCapacity.l(G,S) G %scen_prefix%%quote%'cap_new_GW_'%quote%
$endif

* capacity by type
$batinclude %util_dir%put2csv "" "list" pCapTotal(G,S) G %scen_prefix%%quote%'cap_total_GW_'%quote%

* input data
    put %scen_prefix% "in_CO2e_cost_usd_ton, " pCostCO2(S) /
    put %scen_prefix% "in_CO2e_cap_Kt, " pCarbonCap(S) /
    put %scen_prefix% "demand_scale," pDemandScale(S) /
	
*End loop over scenarios
endloop;

*========== Scenario Independent Data ==========
* -- System wide data
put "WACC," pWACC /
put "in_non_served_price_usd_MWh, " pPriceNonServed /
$if declared pPlanReserve
	put "planning_reserve," pPlanReserve /

* -- Data files
put "data_dir, " "%data_dir%" /
put "data_sys, "  "%sys%" /
$if set demand put "data_demand, " "%demand%" /
$if set fuel   put "data_fuel, "   "%fuel%" /
$if set gens   put "data_gens, "   "%gens%" /
$if set gparams   put "data_gparams, "   "%gparams%" /
$if set avail  put "data_avail, "  "%avail%" /
$if set scen   put "data_scen, "  "%scen%" /
$if set scen_val   put "data_scen_val, "  "%scen_val%" /
$if set update put "data_update, " "%update%" /

* -- Additional Generator Data
* ID unit commitment integer state (integer=1, continuous=0, no_uc=na)
$ifthen set unit_commit
$batinclude %util_dir%put2csv "" "list" pUcIntEnabled(G) G "'uc_integer_'"
$endif

* -- Model Flags
$batinclude %shared_dir%writeFlagState startup
$batinclude %shared_dir%writeFlagState unit_commit "onoff" %unit_commit%
$batinclude %shared_dir%writeFlagState ramp "onoff" %ramp%
$batinclude %shared_dir%writeFlagState ignore_integer
$batinclude %shared_dir%writeFlagState uc_lp
$batinclude %shared_dir%writeFlagState avg_avail
$batinclude %shared_dir%writeFlagState ignore_cap_credit
$batinclude %shared_dir%writeFlagState no_capital "onoff" %no_capital%

$batinclude %shared_dir%writeFlagState uc_ignore_unit_min "value" %uc_ignore_unit_min%
$batinclude %shared_dir%writeFlagState uc_int_unit_min "value" %uc_int_unit_min%
$batinclude %shared_dir%writeFlagState uc_lp

$batinclude %shared_dir%writeFlagState rsrv "value" %rsrv%
$batinclude %shared_dir%writeFlagState separate_rsrv
$batinclude %shared_dir%writeFlagState flex_rsrv "onoff" %flex_rsrv%
$batinclude %shared_dir%writeFlagState no_quick_st
$batinclude %shared_dir%writeFlagState non_uc_rsrv_up_offline "value" %non_uc_rsrv_up_offline%
$batinclude %shared_dir%writeFlagState non_uc_rsrv_down_offline "value" %non_uc_rsrv_down_offline%
$batinclude %shared_dir%writeFlagState adj_rsrv_for_nse "onoff" %adj_rsrv_for_nse%
$batinclude %shared_dir%writeFlagState rps_penalty "value" %rps_penalty%
$batinclude %shared_dir%writeFlagState force_renewables
$batinclude %shared_dir%writeFlagState fix_cap

$batinclude %shared_dir%writeFlagState max_start
$batinclude %shared_dir%writeFlagState min_up_down

$batinclude %shared_dir%writeFlagState pwl_cost
$batinclude %shared_dir%writeFlagState p0_recover "value" %p0_recover%
$batinclude %shared_dir%writeFlagState pwl2afine

$batinclude %shared_dir%writeFlagState force_gen_size "value" %force_gen_size%
$batinclude %shared_dir%writeFlagState min_gen_size "value" %min_gen_size%

$batinclude %shared_dir%writeFlagState derate
$batinclude %shared_dir%writeFlagState derate_to_maint
$batinclude %shared_dir%writeFlagState from_scratch
$batinclude %shared_dir%writeFlagState basic_pmin

$batinclude %shared_dir%writeFlagState plan_margin "value" %plan_margin%
$batinclude %shared_dir%writeFlagState plan_margin_penalty "value" %plan_margin_penalty%
$batinclude %shared_dir%writeFlagState overbuild
$batinclude %shared_dir%writeFlagState skip_cap_limit

$batinclude %shared_dir%writeFlagState maint
$batinclude %shared_dir%writeFlagState max_maint "value" %max_maint%
$batinclude %shared_dir%writeFlagState retire "value" %retire%
$batinclude %shared_dir%writeFlagState maint_lp

$batinclude %shared_dir%writeFlagState max_solve_time "value" %max_solve_time%
$batinclude %shared_dir%writeFlagState mip_gap "value" %mip_gap%
$batinclude %shared_dir%writeFlagState par_threads "value" %par_threads%
$batinclude %shared_dir%writeFlagState priority "onoff" %priority%

$batinclude %shared_dir%writeFlagState cheat "value" %cheat%
$batinclude %shared_dir%writeFlagState rel_cheat "value" %rel_cheat%

*========== Model Extras ==========
$if set calc_water $include %shared_dir%writeWaterSummary

*========== Final Notes ==========
* -- Model statistics
$ifthen set model_name
    put  "model_num_eq,"    %model_name%.numequ:0:0 /
    put  "model_num_var,"   %model_name%.numvar:0:0 /
    put  "model_num_discrete_var,"   %model_name%.numdvar:0:0 /
    put  "model_num_nonzero,"   %model_name%.numnz:0:0 /
$endif

* -- Memo field if provided
$if set memo put "memo, "  "%memo%" /
