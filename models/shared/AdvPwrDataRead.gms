
*skip if data is already read (for sequential simulations)
$if set data_has_been_read $goto label_skip_data_read

*Supress listfile output for includes
$if not set debug $offlisting

$ontext
----------------------------------------------------
Unified data file reading & initial processing for Advanced Power Family of Models.
  
  Reads in standard data file set & handle command-line overrides. Including
   -- sys, gens, demand, fuel, & avail data
   -- update file
   -- command-line overrides including: demscale, rps, co2cost, co2cap
   -- additional options including: force_gen_size, min_gen_size, basic_pmin, 
       uc_ignore_unit_min, avg_avail
  Also computes sub-sets for G_UC, G_RPS, G_WIND, G_RAMP


Command Line Parameters Implemented Here:
 Data
  Primary data setup file:
   --sys=test_sys.inc     System parameters include file. This file references all data for a model
                          run. Typically single value data such as: cost of carbon, WACC, etc. are
                          included directly, while larger tables are in separate sub-include files.
                          The standard sub-include files are:
                              fuel.inc      Fuel names, prices, and emissions
                              gens.inc      Generator set, operating parameters, and availability
                              demand.inc    Demand block set, duration, and power levels

  Files used to override values set or referenced in sys and sub-includes (assumed to to be
  located in data_dir, except as noted):
   --fuel=(from sys)     Fuel prices and emissions
   --gens=(from sys)     Generation set & tables of parameters & availability/renewable output.
   --gparams=(OPTIONAL from sys)    Default generator parameters to use for any missing values.
   --avail=(from sys)    Generation availability/renewable output
   --demand=(from sys)   Demand include file that defines demand blocks, levels, and duration
   --update=NONE         An optional final include file to override selected settings from other
                          include files. Does not override any explicit command-line values. The
                          path for update file is relative to the model (not data_dir). 
                          IMPORTANT: the update file works in S space, so most parameters must 
                          be indexed by S and you must use the scenario dependent 
                          parameters: pFuel, pDemand, pGen, and pGenAvail. Changes to the 
                          p*Data parameters (pGen, pDemand, etc) will NOT be used.
   --scen=NONE           For multiple scenario problems (multi-period or stochastic) specifies
                          the list of scenarios (populates the S set) and their associated
                          weight/probability table, pScenWeight(S).
   --scen_val=(from scen) For multiple scenario problems (multi-period or stochastic) specifies
                          problem the value variations across scenarios. This file works
                          similarly to the update file in that it is imported after all other 
                          date files (except update which is only superseded by command line 
                          parameters) in that it allows updating only selected parameters.


  Specific Value Overrides (take precedence over all values defined in data files. Use for
  sensitivity analysis, etc.) IMPORTANT, these values are used for ALL scenarios, use an update
  for changing these on a by scenario basis.
   --co2cost=#            Cost of CO2 in $/t-co2e          (default: use sys or update value)
   --demscale=#           Factor to uniformly scale demand (default: use sys or update value)
   --rps=#                Renewable Portfolio Standard     (default: use sys or update value)
   --co2cap=#             Carbon Emission Cap (Mt-co2e)    (default: use sys or update value)
   --plan_margin=(off)    Enforce/override the planning margin. Set to 1 to enable and use the
                           defined pPlanReserve (typically in sys.inc). Alternatively can set
                           to a value < 1 that then is used for pPlanReserve overriding other 
                           definitions.
   --maint_om_fract=0.5   If maintenance planning enabled, the default fraction of total fixed 
                           O&M costs to divide among the required weeks of maintenance.
  --no_quick_st=(off)     Flag to zero out quickstart reserve contribution to spinning/flex up 
                           reserves. Useful when non_uc_rsrv... > 0

  Model Setup Flags (by default these are not set. Set to any number, including zero, to enable)
   --avg_avail=(off)      Flag to use the average rather than time dependent availabilities. Using
                           averages is OK for thermal units, but highly simplifies time varying
                           renewables. This simplification is made in the analytic version of the
                           model, but not generally a good idea for numeric estimates. (default: use
                           complete time varying information.)
   --uc_ignore_unit_min=(0)   Threshold for unit_min to ignore All (even continuos) commitment 
                            decisions & constraints. Gens with unit_min less than or equal to 
                            this value will not have commitment variables and use LP 
                            formulations for equations from dispatch. Use uc_int_unit_min for
                            a better approach.
   --uc_int_unit_min=(0)   Threshold for unit_min to ignore INTEGER commitment 
                            decisions & constraints. Gens with unit_min less than or equal to 
                            this value will still have commitment variables, but their valid
                            range is relaxed to be continous. The same equations are used
                            as for those units with integer constraints.
   --basic_pmin=(off)     Enforce non-UC based minimum output levels for each generator type. 
                           this can be useful for baseload plants with simple (non-UC) operations.
   --no_capital=(off)     Ignore capital costs, used for operations models to only compute non
                           capital costs. Not recommended for planning models. [default: include 
                           capital costs]
   --force_gen_size=(off) Force all plant sizes to equal the specified value (in MW)
   --min_gen_size=(off)   Force small plant sizes to be larger than specified value (in MW)
   --retire=(0)           Fraction of current capacity to retire. Max capacity is also adjusted
                           down accordingly (value 0 to 1)
    --derate_to_maint=(off) Override gen datafile derating value and derate based on 
                            the maintenance value only.

Additional control variables:
   --debug_avail=(off)    Display full availability table in *.lst file for debugging
   --debug_block_dur=(off)    Display block durations in *.lst file for debugging

	
  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   September 2011

 Version History
 Ver  Date       Time  Who            What
 --- ----------  ----- -------------- ---------------------------------
  1  2011-09-21  17:05  bpalmintier   Extracted from UnitCommit v5
  2  2011-09-23  16:05  bpalmintier   Converted to $setglobal so our changes propagate to caller
  3  2011-10-06  13:30  bpalmintier   Added scaling of max_starts based on simulation duration
  4  2011-10-08  20:30  bpalmintier   Set cost of non-served energy to INF if no_nse flag set
  5  2011-10-08  22:40  bpalmintier   Implement uc_int_unit_min for better linearization
  6  2011-10-11  14:15  bpalmintier   Renamed plant_size to gen_size (also related flags)
  7  2011-10-13  15:55  bpalmintier   Added support for default generator parameters
  8  2011-10-14  09:55  bpalmintier   BUGFIX: corrected scaling for co2_cap passed from command line
  9  2011-10-14  11:40  bpalmintier   Added pGenAvail data extraction from subsets of pGenAvailData
 10  2011-11-07  15:25  bpalmintier   Updated comments about sys.inc
 11  2011-11-10  12:15  bpalmintier   Added no_capital option
 12  2012-01-19  14:51  bpalmintier   Added debug_avail option
  13 2012-01-26  13:05  bpalmintier   Major expansion:
                                        -- Scenario support for stochastic UC, multi-period planning, etc.
                                        -- Separate pGen, pDemand, pFuel (used in model) from p*Data read from file
  14 2012-01-28  22:45  bpalmintier   Added scenario value file (scen_val)
  15 2012-01-30  20:15  bpalmintier   Added centralized max demand calculation: pDemandMax(S)
  16 2012-02-21  22:15  bpalmintier   Added centralized average demand calculation: pDemandAvg(S)
  17 2012-03-07  20:15  bpalmintier   Added flags to skip if data already read
  18 2012-05-02  10:45  bpalmintier   Separate demand (D) into blocks (B) and time sub-periods (T)
  19 2012-06-14  14:35  bpalmintier   Enable plan_margin to override pPlanReserve
  20 2012-08-21  14:25  bpalmintier   Divide maint_om_fract of fixed O&M costs among maintenance weeks
  21 2012-08-21  15:21  bpalmintier   BUGFIX: adjust remaining c_fix_om, syntax errors
  22 2012-08-21  17:21  bpalmintier   BUGFIX: command line plan_margin value setting
  22 2012-08-21  23:27  bpalmintier   NEW: simple retirement
  23 2012-09-02  17:08  bpalmintier   Replace all $set with $setglobal (to prevent scope errors)
  24 2012-09-03  07:08  bpalmintier   Add derate_to_maint
-----------------------------------------------------
$offtext

*================================*
*        Handle The Data         *
*================================*

* ====== Include Data files
* ---- Big picture problem setup
* Read in the scenario list first, if defined, so that we can properly populate the S set
* during subsequent data file reads
$ifthen set scen  
$include %data_dir%%scen%
* If no scenario list is defined, establish a baseline default with only one scenario
$else
  set
    S   "scenario for multi-period and stochastic problems"
        /onlyS/
    ;
    
    pScenWeight('onlyS') = 1;
$endif

* By default use test_sys.inc if not not passed at the command line
$if NOT set sys    $setglobal sys    test_sys.inc

* Actually do include the system data definition file
* Note: often includes defaults for fuel, demand, gens, gparams, and/or avail
$include %data_dir%%sys%

* ---- Read-in scenario independent data tables
* Initially read in complete, baseline data from data files (not scenario differentiated)
* using the p*Data set of parameters that are not indexed by S
$if set fuel   $include %data_dir%%fuel%
$if set demand $include %data_dir%%demand%
* Note: include demand before gens, so can use the demand levels for time varying availabiilty
$if set gens   $include %data_dir%%gens%

* Use default generator parameters when needed
$ifthen set gparams 
* First read in the data
$include %data_dir%%gparams%
* Then for any generator parameter that has a zero value, fill in the missing data
* from the corresponding default value.
*
* We do this before reading in availability data since the availability data might rely on
* information provided by the Gparams table
*
* Note: in this case the smax function is used to pull out a single matching data item. It 
* is expected that there is only one match in the pGenDefaults table.
    pGenData(G,GEN_PARAMS)$(not pGenData(G,GEN_PARAMS)) 
        = smax[(GEN_TYPE)$( pGenData(G,'type')=pGenDefaults(GEN_TYPE,'type') ),
                    pGenDefaults(GEN_TYPE, GEN_PARAMS)];

* Summary data expresses minimum output in per unit. So here we convert to a power output level.
    pGenData(G,'unit_min')$(not pGenData(G,'unit_min'))
        = pGenData(G,'unit_min_pu') * pGenData(G,'gen_size');
$endif

* Divide out maintenance cost per week from O&M for any entries with maint req'd & no
* specific maintenance cost set (a zero value for c_maint_wk implies no specific cost set)
$ifthen set maint
$if not set maint_om_fract $setglobal maint_om_fract 0.5
    set
        G_OM_Maint(G)   "Subset of gens to divide fixed O&M costs among maint_wks" 
        ;
        
    G_OM_Maint(G)$(pGenData(G, 'maint_wks') > 0 and  pGenData(G, 'c_maint_wk') = 0) = yes;
    
    pGenData(G, 'c_maint_wk')$G_OM_Maint(G)
        = %maint_om_fract% * pGenData(G, 'c_fix_om') / (pGenData(G, 'maint_wks'));
    pGenData(G, 'c_fix_om')$G_OM_Maint(G)
        = (1-%maint_om_fract%) * pGenData(G, 'c_fix_om');
$endif

*Handle retirements
$ifthen set retire
*Setup a parameter so we can subtract from both cap_cur and cap_max
    parameter
        pCapToRetire(G) "Current capacity to retire GW"
    ;
    pCapToRetire(G) = %retire% * pGenData(G, 'cap_cur');
    pGenData(G, 'cap_cur') = pGenData(G, 'cap_cur') - pCapToRetire(G);
    pGenData(G, 'cap_max') = pGenData(G, 'cap_max') - pCapToRetire(G);
$endif

*Read in availability data. If not specified, assume 100% availability for all
$ifthen set avail 
$include %data_dir%%avail%
$else
    pGenAvail(B, T,G,S) = 1;
$endif

* ---- Match our scenario independent p*Data with the corresponding scenario indexed parameter
pFuel(F, FUEL_PARAMS, S) = pFuelData(F, FUEL_PARAMS);
pDemand(B, T, DEM_PARAMS, S) = pDemandData(B, T, DEM_PARAMS);
pGen(G, GEN_PARAMS, S)  = pGenData(G, GEN_PARAMS);

*If we have an availability matching demand set (D_AVAIL)
$ifthen.d_avail defined D_AVAIL
*Pull out the subset of availability data that matches our in-use demand periods
* Note: the mapping takes a few seconds for large data sets, consider a dedicated pGenAvail
*  for commonly used large data sets
* The mapping set was ~4x faster than attempting to put the conditional directly in the smax[]
    set
        AVAIL_MAP(B, T, D_AVAIL)
    ;
    AVAIL_MAP(B,T,D_AVAIL)$(pDemandData(B,T,'avail_idx') = ord(D_AVAIL)) = yes;
$ifthen defined pGenAvailDataByScen
    pGenAvail(B, T, G, S) = smax[(D_AVAIL)$AVAIL_MAP(B, T, D_AVAIL), pGenAvailDataByScen(D_AVAIL, G, S)];
$elseif defined pGenAvailData
    pGenAvail(B, T, G, S) = smax[(D_AVAIL)$AVAIL_MAP(B, T, D_AVAIL), pGenAvailData(D_AVAIL, G)];

$endif
$else.d_avail
*Otherwise, assume matching B, T set membership and copy to all scenarios
$ifthen defined pGenAvailDataByScen
    pGenAvail(B, T, G, S) = pGenAvailDataByScen(B, T, G, S);
$elseif defined pGenAvailData
    pGenAvail(B, T, G, S) = pGenAvailData(B, T, G);
$endif
$endif.d_avail


* ---- Process Scenario Value file
*
* Note this file works in S space, so most parameters must be indexed by S and the
* scenario dependent parameters: pFuel, pDemand, pGen, and pGenAvail should be used. Changes
* to the p*Data parameters (pGen, pDemand, etc) will NOT be used
$if set scen_val $include %data_dir%%scen_val%

* ---- Process update file. 
* Now allow for updates to any of the parameters for easier interfacing to external programs
* by loading this file after all of the core data, we can update the actual values used in the
* optimization. (Note: only possible b/c $onmulti used)
*
* Note the update file works in S space, so most parameters must be indexed by S and the
* scenario dependent parameters: pFuel, pDemand, pGen, and pGenAvail should be used. Changes
* to the p*Data parameters (pGenData, pDemandData, etc) will NOT be used
$if set update $include %update%

*Return to listing in the output file
$if not set debug $onlisting

* ===== Additional Command Line Parameters
*override CO2 price with command line setting if provided
$if set co2cost pCostCO2(S)=%co2cost%;

*override Demand scaling with command line setting if provided
$if set demscale pDemandScale(S)=%demscale%;

*override RPS level with command line setting if provided
$if set rps pRPS(S)=%rps%;

*override Carbon Cap (Kt) with command line setting if provided
$if set co2cap pCarbonCap(S)=%co2cap%;

*override planning margin value if provided a fraction < 100% (no spaces allowed)
$if set plan_margin $if not "%plan_margin%"=="on" $if not "%plan_margin%"=="off" $ife %plan_margin%<1   pPlanReserve=%plan_margin%;

*allow user to specify a uniform gen_size
$if set force_gen_size pGen(G,'gen_size', S) = %force_gen_size%;
*and minimum plant size
$if set min_gen_size pGen(G,'gen_size', S) = max(pGen(G,'gen_size', S), %min_gen_size%);

*remove p_min value if not used
$if not set basic_pmin pGen(G, 'p_min', S) = 0;

*Zero out capital costs if not used
$if set no_capital pGen(G, 'c_cap', S) = 0;

*Set derating for maintenance only if requested
$if set derate_to_maint pGen(G, 'derate', S) = 1-pGen(G, 'maint_wks', S)/52;

*Zero out quickstart fraction of spin/flex reserves when disabled
$if set no_quick_st pQuickStSpinSubFract = 0;


*================================*
*    Additional Calculations     *
*================================*
* ====== Calculate subsets
*only include elements where the generator fuel name parameter matches the fuel name parameter
GEN_FUEL_MAP(G, F)$(pGenData(G,'fuel') = pFuelData(F,'name')) = yes;

*only solve unit commitment for plants with non-zero minimum outputs
$if NOT set uc_ignore_unit_min    $setglobal uc_ignore_unit_min 0
$if NOT set uc_int_unit_min    $setglobal uc_int_unit_min 0

** Assign gens to unit commitment sets
*start by setting all to not included
G_UC(G) = no;
G_UC_INT(G) = no;

*then add in if needed, note duplicate code b/c $ifthen doesn't like or
$if set unit_commit $setglobal unit_commit %unit_commit%
$ifthen.uc_set set unit_commit
$ifthen.uc_on   "%unit_commit% test" == "on test"
    G_UC(G)$(pGenData(G,'unit_min') > %uc_ignore_unit_min%) = yes;
    G_UC_INT(G)$(G_UC(G) and (pGenData(G,'unit_min') > %uc_int_unit_min%)) = yes;
$elseif.uc_on     %unit_commit% == 1
    G_UC(G)$(pGenData(G,'unit_min') > %uc_ignore_unit_min%) = yes;
    G_UC_INT(G)$(G_UC(G) and (pGenData(G,'unit_min') > %uc_int_unit_min%)) = yes;
$endif.uc_on
$endif.uc_set

*include all wind, solar, and geotherm plants in the RPS standard
acronyms wind, solar, geotherm;
G_RPS(G)$(pGenData(G,'fuel') = wind) = yes;
G_RPS(G)$(pGenData(G,'fuel') = solar) = yes;
G_RPS(G)$(pGenData(G,'fuel') = geotherm) = yes;

*create set for wind generators (for increased reserve requirements)
G_WIND(G)$(pGenData(G,'fuel') = wind) = yes;

*Only worry about ramping for plants with ramp limits < 1
G_RAMP(G)$(pGenData(G,'ramp_max') < 1) = yes;

*Handle time/demand subsets
* Note: for simple demand subsets to work, three control variables must be defined:
*          d_subset: flag to use subsets, rather than all demand periods
*          d_start:  first demand block to include (an integer)
*          d_end:    last demand block to include (an integer)
$ifthen.d_subset set d_subset
$ifthen.d_start set d_start
$ifthen.d_end set d_end
    B_SIM(B)$( ord(B) >= %d_start% and ord(B) <= %d_end% ) = yes;
$endif.d_end
$endif.d_start
$else.d_subset
    B_SIM(B) = yes;
$endif.d_subset


* ====== Calculate parameters
*Scale demand
pDemand(B, T,'power', S) = pDemandScale(S) * pDemand(B, T,'power', S);

*compute capital recovery factor (annualized payment for capital investment)
$if declared pCRF
pCRF(G)$(pGenData(G, 'cap_max')) = pWACC/(1-1/( (1 + pWACC)**pGenData(G,'life') ));

*Remove Wind driven Flex Down constraints if we allow wind shedding. b/c rather than
*ramping thermal down, we could simply shed wind
$ifthen.rsrv set rsrv 
$ifthen not set force_renewables
    pWindFlexDownForecast = 0;
    pWindFlexDownCapacity = 0;
$endif
$endif.rsrv

* -- Use piecewise linear data for affine parameters if requested
$ifthen set pwl2afine
* If the generator has a defined first segment, extract & use the segment with the highest 
* slope which b/c we assume concave, will be the last segment
    pGen(G,'heatrate', S)$(pGenHrSegments(G,'seg1','slope'))
        = smax[(HR_SEG), pGenHrSegments(G,HR_SEG, 'slope')];

* If the generator has a defined first segment, extract & use the segment with the lowest 
* intercept that also has a positive slope which b/c we assume concave, will be the last segment
    pGen(G,'p0_fuel', S)$(pGenHrSegments(G,'seg1','slope'))
        = smin[(HR_SEG)$(pGenHrSegments(G,HR_SEG, 'slope') > 0), 
                pGenHrSegments(G,HR_SEG, 'intercept')];
$endif

*Assign +INF to the cost of non served energy if it is not allowed
$if set no_nse pPriceNonServed = +inf;

display "Generator Data Table after AdvPwrDataRead...";
display pGen;

$ifthen.debug_avail set debug_avail
$ifthen defined pGenAvailData
    display "Raw Availability Data";
    display pGenAvailData;
$endif
$ifthen defined pGenAvailDataByScen
    display "Raw Availability Data by Scenario";
    display pGenAvailDataByScen;
$endif
    display "Availability Table after demand period matching";
    display pGenAvail;
$endif.debug_avail

* ====== Demand period based parameters
parameters
* Additional Parameters that may not have been defined
    pGenAvgAvail (G, S)            "average availability (max capacity factor)"

    pTotalDurationHr(S)            "the total time for the demand data in hrs"
    pFractionOfYear (S)            "fraction of year covered by the simulation"
    pDemandMax(S)                  "maximum demand for scenario [GW]"
    pDemandAvg(S)                  "average demand for scenario [GW]"
    pBlockDurWk(B, S)              "duration for each block in weeks"
;

pTotalDurationHr(S) = sum[(B, T), pDemand(B, T, 'dur', S)];
pFractionOfYear(S) = pTotalDurationHr(S)/8760;
pBlockDurWk(B, S) = sum[(T), pDemand(B, T, 'dur', S)] / 168;

$ifthen set debug_block_dur
    display "Block durations in weeks";
    display pBlockDurWk;
$endif


*Find resulting max demand
pDemandMax(S) = smax[(B, T), pDemand(B, T, 'power', S)];
*And resulting average demand
pDemandAvg(S) = sum[(B, T), pDemand(B, T, 'power', S)*pDemand(B, T, 'dur', S)] / pTotalDurationHr(S);

*Compute average availability for each generator
pGenAvgAvail(G, S) = sum[(B, T), pGenAvail(B, T, G, S)*pDemand(B, T, 'dur', S)] / pTotalDurationHr(S);


*Convert time varying to average availabilities if desired
$ifthen set avg_avail
    pGenAvail(B, T,G,S) = pGenAvgAvail(G,S);
$endif

* -- Scale annual values based on total simulation time
* max_num of startups 
$ifthen set max_start
    pGen(G, 'max_start', S) = round(pGen(G, 'max_start', S) * pFractionOfYear(S));
$endif

$setglobal data_has_been_read
$label label_skip_data_read