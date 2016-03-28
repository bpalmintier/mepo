
$ontext
----------------------------------------------------
  Helper include to write most standard output files for Advanced Power models
  
	
  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   January 2012

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2012-01-28  02:00 bpalmintier    Extracted from UnitCommit v26
  2  2012-01-28  22:00 bpalmintier    Added gen_simple table
  3  2012-03-07  15:45 bpalmintier    Remove any possible old output files before writting
  4  2012-05-02  10:45  bpalmintier   Separate demand (D) into blocks (B) and time sub-periods (T)
  5  2012-05-04  23:05  bpalmintier   Added maintenance support
  6  2012-08-22  00:15  bpalmintier   Shortened file names, including no more "out_" or "_table"
  7  2012-09-02  12:57  bpalmintier   Added off maintenance debug table
  8  2012-09-06  09:58  bpalmintier   No QuickStart processing with no_quick_st
  8  2012-09-14  15:30  bpalmintier   Added net load down reserves
-----------------------------------------------------
$offtext

*Don't display line number and memory use to the logfile/screen for subsequent includes
$offlog

* ======  Write Results to CSV files
* WARNING: the structure of these output files matters for us with the CapPlanDP code... take
* care when changing

mDelFile("%out_dir%%out_prefix%summary.csv")
mDelFile("%out_dir%%out_prefix%power.csv")
mDelFile("%out_dir%%out_prefix%uc.csv")
mDelFile("%out_dir%%out_prefix%spin.csv")
mDelFile("%out_dir%%out_prefix%reg_up.csv")
mDelFile("%out_dir%%out_prefix%reg_down.csv")
mDelFile("%out_dir%%out_prefix%quick_st.csv")
mDelFile("%out_dir%%out_prefix%flex_up.csv")
mDelFile("%out_dir%%out_prefix%flex_down.csv")
mDelFile("%out_dir%%out_prefix%gen_params.csv")
mDelFile("%out_dir%%out_prefix%gen_type.csv")
mDelFile("%out_dir%%out_prefix%gen_type_ext.csv")
mDelFile("%out_dir%%out_prefix%gen_avail.csv")
mDelFile("%out_dir%%out_prefix%gen_simple.csv")
mDelFile("%out_dir%%out_prefix%maint.csv")
mDelFile("%out_dir%%out_prefix%tot_cap.csv")
mDelFile("%out_dir%%out_prefix%new_plants.csv")
mDelFile("%out_dir%%out_prefix%new_cap.csv")
mDelFile("%out_dir%%out_prefix%off_maint.csv")
mDelFile("%out_dir%%out_prefix%net_lf_down.csv")

*-- [1] Output solution summary
* file setup
* file has 2 columns: name, data
file fListOut /"%out_dir%%out_prefix%summary.csv"/
put fListOut;

*Set output precision to have 5 places right of the decimal (except for large numbers in scientific format)
fListOut.nd=5;

*Allow maximum page width to prevent truncation
fListOut.pw=32767;


*Write out summary in standard form
$include %shared_dir%writeSummary.gms

*And include any additional model dependant variables
*  -- None --

*close our file
putclose

$if set summary_only $goto skip_non_summary
*-- [2] Output Power Out (dispatch) data as a 2-D table
*One scenario case
$ifthen.one_scen not set scen
    parameter
        pPwrOut(B, T,G)
        ;
*Use smax to extract single set element
        pPwrOut(B, T,G) = smax[S, vPwrOut.l(B, T,G,S)];
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%power.csv" "table" pPwrOut(B,T,G) B.T G
*Multiple scenario case
$else.one_scen
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%power.csv" "table" vPwrOut.l(B,T,G,S) S.B.T G
$endif.one_scen

$if set summary_and_power_only $goto skip_non_summary
*-- [4] Output Unit Commitment States data as a 2-D table
*One scenario case
$ifthen.one_scen not set scen
    parameter
        pUnitCommit(B, T,G)
        ;
*Use smax to extract single set element
        pUnitCommit(B, T,G) = smax[S, vUnitCommit.l(B, T,G,S)];
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%uc.csv" "table" pUnitCommit(B,T,G) B.T G
*Multiple scenario case
$else.one_scen
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%uc.csv" "table" vUnitCommit.l(B,T,G,S) S.B.T G
$endif.one_scen

*-- [5] If using operating reserves, output set of files with associated data
$ifthen.sep_r set separate_rsrv
*One scenario case
$ifthen.one_scen not set scen
    parameters
        pSpinReserve(B, T,G)
        pNetLoadFollowDown(B, T,G)
        pRegUp(B, T,G)
        pRegDown(B, T,G)
$ifthen.no_qs not set no_quick_st
        pQuickStart(B, T,G)
$endif.no_qs
        ;
*Use smax to extract single set element
        pSpinReserve(B, T,G) = smax[S, vSpinReserve.l(B, T,G,S)];
        pNetLoadFollowDown(B, T,G) = smax[S, vNetLoadFollowDown.l(B, T,G,S)];
        pRegUp(B, T,G) = smax[S, vRegUp.l(B, T,G,S)];
        pRegDown(B, T,G) = smax[S, vRegDown.l(B, T,G,S)];
$ifthen.no_qs not set no_quick_st
        pQuickStart(B, T,G) = smax[S, vQuickStart.l(B, T,G,S)];
$endif.no_qs
        
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%spin.csv" "table" pSpinReserve(B,T,G) B.T G
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%net_lf_down.csv" "table" pNetLoadFollowDown(B,T,G) B.T G
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%reg_up.csv" "table" pRegUp(B,T,G) B.T G
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%reg_down.csv" "table" pRegDown(B,T,G) B.T G

$ifthen.no_qs not set no_quick_st
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%quick_st.csv" "table" pQuickStart(B,T,G) B.T G
$endif.no_qs
*Multiple scenario case
$else.one_scen
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%spin.csv" "table" vSpinReserve.l(B,T,G,S) S.B.T G
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%net_lf_down.csv" "table" vNetLoadFollowDown.l(B,T,G,S) S.B.T G
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%reg_up.csv" "table" vRegUp.l(B,T,G,S) S.B.T G
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%reg_down.csv" "table" vRegDown.l(B,T,G,S) S.B.T G
$ifthen.no_qs not set no_quick_st
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%quick_st.csv" "table" vQuickStart.l(B,T,G,S) S.B.T G
$endif.no_qs
$endif.one_scen
$endif.sep_r

*-- [6] Output files with flexibility reserve data
$ifthen set flex_rsrv
*One scenario case
$ifthen.one_scen not set scen
    parameters
        pFlexUp(B, T,G)
        pFlexDown(B, T,G)
        ;
*Use smax to extract single set element
        pFlexUp(B, T,G) = smax[S, vFlexUp.l(B, T,G,S)];
        pFlexDown(B, T,G) = smax[S, vFlexDown.l(B, T,G,S)];

$batinclude %util_dir%put2csv "%out_dir%%out_prefix%flex_up.csv" "table" pFlexUp(B,T,G) B.T G
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%flex_down.csv" "table" pFlexDown(B,T,G) B.T G
*Multiple scenario case
$else.one_scen
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%flex_up.csv" "table" vFlexUp.l(B,T,G,S) S.B.T G
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%flex_down.csv" "table" vFlexDown.l(B,T,G,S) S.B.T G
$endif.one_scen
$endif

*-- [7] Output files with generator input parameters
*= Output Generator Parameter Table
$ifthen.gen_param set out_gen_params
file fGParamOut /"%out_dir%%out_prefix%gen_params.csv"/;
put fGParamOut;

*Set data field width long enough to avoid truncation for extended type information
fGParamOut.nw=32;

*Allow maximum page width to prevent truncation
fGParamOut.pw=32767;

* Output separate table for each scenario. Each with an identifying header
loop (S) do
    if card(S) > 1 then
        put "===== Scenario "  S.tl:0;
    endif;
$batinclude %util_dir%put2csv "" "table" pGen(G,GEN_PARAMS,S) G GEN_PARAMS
endloop;
*close our file
putclose

$ifthen.type_def set gen_type_data_defined

*= Output Generator Type Table
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%gen_type.csv" "list" pGenData(G,'type') G

*= Output Generator Extended Type Table
file fGTypeExt /"%out_dir%%out_prefix%gen_type_ext.csv"/
put fGTypeExt;

*Set data field width long enough to avoid truncation for extended type information
fGTypeExt.nw=64;

$batinclude %util_dir%put2csv "" "list" pGenData(G,'extended_type') G

*close our file
putclose

$endif.type_def
$endif.gen_param


*-- [8] Output files with generator input parameters
*= Output Generator Availability Table
$ifthen set out_gen_avail
file fGAvailOut /"%out_dir%%out_prefix%gen_avail.csv"/
put fGAvailOut;

*Allow maximum page width to prevent truncation
fGAvailOut.pw=32767;

loop (S) do
    if card(S) > 1 then
        put "===== Scenario "  S.tl:0;
    endif;
$batinclude %util_dir%put2csv "" "table" pGenAvail(B,T,G,S) S.B.T G
endloop;
*close our file
putclose

$endif

*-- [9] Output simplified generator parameter table
*= Output Generator Fix & Var Cost Table
$ifthen.g_simple set out_gen_simple
set
    GEN_SIMPLE      "Simple generator parameters"
       /
        'c_fix_Musd_GW'     "Fixed cost o&m + capital, if annualized"
        'c_var_usd_MWh'     "Variable cost (fuel + o&m + carbon)"
        'co2_t_MWh'   "Average CO2 emissions per MWh (average req'd for piecewise linear)"
        'heatrate_MMBTU_MWh'  "Average Fuel use per MWh"
        'max_out_MW'    "Maximum run output "
       /
parameter
    pGenSimple(G, GEN_SIMPLE, S)
    ;

*Compute maximum out once to filter results for gens that don't run
pGenSimple(G, 'max_out_MW', S) = smax[(B, T), vPwrOut.l(B, T,G,S)]; 
   
*- Fixed costs
* including annualized capital costs if defined
pGenSimple(G, 'c_fix_Musd_GW', S) = pGen(G, 'c_fix_om', S)
$ifthen declared pCRF
                                + pCRF(G)*pGen(G, 'c_cap', S)
$endif
                                ;

*- Heatrate
*Compute actual average for units that run (includes piecewise linear effects)
pGenSimple(G, 'heatrate_MMBTU_MWh',S)$(pGenSimple(G, 'max_out_MW', S) > 0)
                                   = sum[(B, T), 
                                            vInstantFuel.l(B, T, G, S)*pDemand(B, T, 'dur', S)
                                        ]
                                        / sum[(B, T), vPwrOut.l(B, T,G,S)*pDemand(B, T, 'dur', S)];

*Or simply return data table values for those that don't (ignores piecewise linear)
pGenSimple(G, 'heatrate_MMBTU_MWh',S)$(pGenSimple(G, 'max_out_MW', S) = 0)
                                = pGen(G, 'heatrate', S);

*- Carbon emission rate
pGenSimple(G, 'co2_t_MWh', S)= sum[(GEN_FUEL_MAP(G,F)), 
                                    pGenSimple(G, 'heatrate_MMBTU_MWh',S)
                                    * pFuel(F,'co2', S)*(1-pGen(G,'co2_ccs', S))
                                  ];
                                
*- Variable cost
* (based on other averages)
pGenSimple(G, 'c_var_usd_MWh', S) = pGen(G, 'c_var_om', S) 
                            + sum[(GEN_FUEL_MAP(G,F)), 
                                    pGenSimple(G, 'heatrate_MMBTU_MWh',S) * pFuel(F,'cost', S)
                                ]
                            + pCostCO2(S) * pGenSimple(G, 'co2_t_MWh', S);

file fGSimpleOut /"%out_dir%%out_prefix%gen_simple.csv"/;
put fGSimpleOut;

*Set data field width long enough to avoid truncation for extended type information
fGSimpleOut.nw=32;

*Allow maximum page width to prevent truncation
fGSimpleOut.pw=32767;

* Output separate table for each scenario. Each with an identifying header
loop (S) do
    if card(S) > 1 then
        put "===== Scenario "  S.tl:0;
    endif;
$batinclude %util_dir%put2csv "" "table" pGenSimple(G,GEN_SIMPLE,S) G GEN_SIMPLE
endloop;
*close our file
putclose

$endif.g_simple

*-- [10] Output Maintenance plan as a 2-D table
*One scenario case
$ifthen.maint set maint
$ifthen.one_scen not set scen
    parameter
        pMaint(B, G)
        ;
*Use smax to extract single set element
        pMaint(B, G) = smax[S, vOnMaint.l(B, G,S)];
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%maint.csv" "table" pMaint(B,G) B G
*Multiple scenario case
$else.one_scen
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%maint.csv" "table" vOnMaint.l(B,G,S) S.B G
$endif.one_scen

*-- [11] Capacity off maintenance debug
*One scenario case
$ifthen.off_maint set debug_off_maint
$ifthen.one_scen not set scen
    parameter
        pCapOffMaint(B, T,G)
        ;
*Use smax to extract single set element
        pCapOffMaint(B, T,G) = smax[S, vCapOffMaint.l(B, T,G,S)];
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%off_maint.csv" "table" pCapOffMaint(B,T,G) B.T G
*Multiple scenario case
$else.one_scen
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%off_maint.csv" "table" vCapOffMaint.l(B,T,G,S) S.B.T G
$endif.one_scen
$endif.off_maint

$endif.maint

$label skip_non_summary
