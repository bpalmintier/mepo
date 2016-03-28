$Title Reserve & Ramp Constrained Dispatch model

$ontext
----------------------------------------------------
  Simplified lectric power system operations model that includes inter-period ramping and reserve
  requirements in a simplified way.
  
Model formulation based primarily on the non unit-commitment operations described in:
 Palmintier, B., & Webster, M. (2011). Impact of Unit Commitment Constraints on Generation 
 Expansion Planning with Renewables. Proceedings of 2011 IEEE Power and Energy Society General 
 Meeting. Presented at the 2011 IEEE Power and Energy Society General Meeting, Detroit, MI: IEEE. 
 On-line at http://web.mit.edu/b_p/pdf/UC_CapPlan_IEEE_PES_2011.pdf

 But using simplified reserves (and curtailment costs & storage) from:
 De Jonghe, C., Delarue, E., Belmans, R., & D’haeseleer, W. (2011). Determining optimal electricity
 technology mix with high level of wind power penetration. Applied Energy, 88(6), 2231-2238. 
 doi:10.1016/j.apenergy.2010.12.046


 Command Line Options (defaults shown):
 ======================================
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
   --fuel=(from sys)    Fuel prices and emissions
   --gens=(from sys)    Generation set & tables of parameters & availability/renewable output.
   --avail=(from sys)  Generation availability/renewable output
   --demand=(from sys)  Demand include file that defines demand blocks, levels, and duration
   --update=NONE            An optional final include file to override selected settings from other
                             include files. Does not override any explicit command-line values. The
                             path for update file is relative to the model (not data_dir)

  Specific Value Overrides (take precedence over all values defined in data files. Use for
  sensitivity analysis, etc.)
   --co2cost=#            Cost of CO2 in $/m.t. (default: use sys or update value)
   --demscale=#           Factor to uniformly scale demand (default: use sys or update value)
   --rps=#                Renewable Portfolio Standard     (default: use sys or update value)
   --co2cap=#             Carbon Emission Cap (Kt)         (default: use sys or update value)

  Model Setup Flags (by default these are not set. Set to any number, including zero, to enable)
   --no_nse=(off)         Don't allow non-served energy
   --force_renewables=(off) Force all renewable output to be used. This is only feasible until
                             the point where load and op_reserves dicate a max.
   --force_gen_size=(off) Force all plant sizes to equal the specified value (in MW)
   --min_gen_size=(off) Force small plant sizes to be larger than specified value (in MW)
   --basic_pmin=(off)     Enforce non-UC based minimum output levels for each generator type. 
                          This can be useful for baseload plants with simple (non-UC) operations.
  True on/off flags (set to off to disable, on to enable)  
   --ramp=(on)           Flag to limit inter period ramp rates  (default: on)
   --flex_rsrv=(on)      Enbable combined operating reserve constraints: Flex Up and Flex Down
   Note: the StaticCapPlan equivalent options of --flex_rsrv and --ramp are always enabled
   --no_loop=(off)       Do not loop around demand periods for inter-period constraints
                          such as ramping, min_up_down. (default= assume looping)

  Solver Options
   --debug=(off)          Print out extra material in the *.lst file (timing, variables, equations, etc)
   --obj_var=vTotalCost   Variable to minimize in solution. Common options:
                             vTotalCost  (default) Least cost operations
                             vCarbonEmissions  Use with no_nse=1 to find minimum possible co2

  File Locations (Note, on Windows & DOS, \'s are used for defaults)
   --data_dir=../data/  Relative path to data file includes
   --out_dir=out/       Relative path to output csv files
   --util_dir=../util/  Relative path to csv printing and other utilities
   --out_prefix=OpLp_    Prefix for all our our output data files

  Output Control Flags (by default these are not set. Set to any number, including zero, to enable)
   --no_csv=(off)         Flag to suppress creation of csv output files (default: create csv output)
   --summary_only=(off)   Only create output summary data (default: create additional tables)
   --summary_and_power_only=(off)   Create only summary & power table outputs (Default: all files)
   --memo=(none)          Free-form text field added to the summary table NO COMMAS (Default: none)

  Supports:

Outputs
    - Summary, Power, emissions, wind shedding, cost breakdown.


Additional Features:
    - loading of data from include files to allow an unchanging core model.
        - These file names can be optionally specified at the command line.
    - A final, optional "update" file to allow for adjusting parameters for easy sensitivity
      analysis or to change the values for a model run without changing the default values
    - internal annualizing of capital costs (requires definition of WACC)
    - ability to scale demand
    - Force wind mode to require using all wind production with no shedding (only valid for small %wind)

Performance enhancements:

Assumptions:
    - Ramping and Startup "loop" such that the state at the endo of the year must match the
      beginning of year. This prevents turning off baseload in anticipation of the "end of the world"


ToDo:
    -- Add preventative maintence (reintroduce CapFactor by a different name)
    -- Rename p_min to must_run?
    -- Add wind curtailment penalty
    -- Add storage (requires reworking the force renewables equation)
    -- Consider rewritting flex up and down capabilities based on ramp rates rather than reserves.
    -- Update Wind reserve requirements to reflect ramp rates & forecast errors on different time periods
    
  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   May 2011

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-05-20  01:00  bpalmintier   Original version adapted from StaticCapPlan v36
  2  2011-06-15  01:15  bpalmintier   Added --avail option to fix bug with inconsitant gen availability files
  3  2011-06-20  12:15  bpalmintier   change update file path to relative to the model (not data_dir)
  4  2011-07-14  23:15  bpalmintier   overhauled and expanded output summary
  5  2011-07-15  10:15  bpalmintier   move output summary to shared include file
  6  2011-08-02  17:15  bpalmintier   Updates for compatability with StaticCapPlan
                                        - Remove down req't for wind when shedding OK (ie force_renewables=off)
                                        - Replace availability CSV with GAMS table format
  7  2011-08-02  17:35  bpalmintier   further StaticCapPlan synchronization
                                        - Converted line endings to Windows CRLF format
                                        - refined ramping limits
                                        - added co2cap command line parameter
                                        - set ramp and flex_rsrv control variables for output file
                                        - user configurable out_prefix
  8  2011-08-05  03:11  bpalmintier   switched to CPLEX barrier solver (added cplex.opt file)
  9  2011-08-05  10:45  bpalmintier   Added force_gen_size and min_gen_size for consistancy
 10  2011-08-05  11:30  bpalmintier   Increased output precision to 5 after decimal
 11  2011-08-06  16:15  bpalmintier   Further refinement of solver to use concurrent optimization
 12  2011-08-06         bpalmintier   Further refinement of solver start barrier & only use dual if no converge
 13  2011-08-07  16:10  bpalmintier   Added option to minimize arbitrary variable, rather than only cost (obj_var)
 14  2011-08-08  01:30  bpalmintier   Real on/off flags for ramp & flex_rsrv (default to on). Scaled vCarbonEmissions
 15  2011-10-11  14:15  bpalmintier   Renamed plant_size to gen_size (also related flags)
 16  2011-11-07  15:25  bpalmintier   Updated to use test_sys.inc
 17  2012-03-09  12:45  bpalmintier   Replace -- with mDemandShift for optional loop startup
 18  2012-03-09  12:45  bpalmintier   Use shared AdvPwrSetup
 19  2012-09-02  17:08  bpalmintier   Replace all $setglobal with $setglobal (to prevent scope errors)
-----------------------------------------------------
$offtext

*================================*
*             Setup              *
*================================*

* ======  Platform Specific Adjustments
* Setup the file separator to use for relative pathnames
$iftheni %system.filesys% == DOS $setglobal filesep "\"
$elseifi %system.filesys% == MS95 $setglobal filesep "\"
$elseifi %system.filesys% == MSNT $setglobal filesep "\"
$else $setglobal filesep "/"
$endif

* Command line options that affect setup
$if not set shared_dir $setglobal shared_dir ..%filesep%shared%filesep%

* Enable $ variables from include file to propagate back to this master file
$onglobal

* Include common setup definitions including:
*  -- Platform specific path adjustments
*  -- GAMS options
*  -- debug settings
*  -- standardized AdvPower directories
$include %shared_dir%AdvPwrSetup

* Disable influence of $ settings from include files
$offglobal

* ======  Setup command line flag defaults
*Enable reserves by default
$if not set flex_rsrv $setglobal flex_rsrv on
*Enable ramp constraints by default
$if not set ramp $setglobal ramp on

*================================*
*         Declarations           *
*================================*

* ======  Declare all sets so can use in equations
* Note: be sure to quote descriptions otherwise "/" can not be used in a description.

sets
* Sets for table parameters

    DEM_PARAMS  demand block table parameters from load duration curve
        /dur         "duration of block                 [hrs]"
         power       "average power demand during block [GW]"
        /

    GEN_PARAMS  generation table parameters
       /cap_credit  "Capacity Credit during peak block           [p.u.]"
        c_var_om    "variable O&M cost                           [$/MWh]"
        c_fix_om    "fixed O&M cost                              [M$/GW-yr]"
        c_cap       "total capital cost                          [$/GW]"
        life        "economic lifetime for unit                  [yr]"
        heatrate    "heatrate for generator (inverse efficiency) [kBTU/MW]"
        fuel        "name of fuel used                           [name]"
        cap_cur     "Current installed capacity for generation   [GW]"
        cap_max     "Maximum installed capacity for generation   [GW]"
        co2_embed   "CO2_eq emissions from plant construction    [t per MW]"
        co2_ccs     "Fraction of carbon capture & sequestration  [p.u.]"
        p_min       "minimum power output (for baseload)         [p.u.]"
        lead_time   "Delay from construction to operation        [yr]"
        gen_size  "typical discrete plant size                 [GW]"
        ramp_max    "Maximum hourly ramp rate                    [fract/hr]"
        unit_min    "Minimum power output per committed unit     [GW]"
        c_start_fix "Fixed cost to start up a unit               [$/start/unit]"
        fuel_start  "Fuel usage to start up a unit               [MMBTU/start/unit]"
        quick_start "Fraction of capacity avail for non-spin reserves [p.u.]"
        reg_up      "Fraction of capacity avail for regulation up reserves [p.u.]"
        reg_down    "Fraction of capacity avail for regulation down reserves [p.u.]"
        spin_rsv    "Fraction of capacity avail for spinning reserves [p.u.]"
        max_start   "Maximum number of startups per plant per year [starts/yr]"
       /

    FUEL_PARAMS fuel table parameters
        /name        "The name as a string (acronym) for comparison  [name]"
         cost        "Unit fuel cost                                 [$/kBTU]"
         co2         "Carbon Dioxide (eq) emitted                    [t/kBTU]"
        /

* Sets for data, actual definitions can be found in include files
    G           "generation types (or generator list)"
        /wind
        /
    D           "demand levels"
    F           "fuel types"

* Sets for mapping between other sets
    GEN_FUEL_MAP(G, F)     "map for generator fuel types"

* Subsets for special purposes
    G_RPS(G)     "Generators included in the Renewable Portfolio Standard"
    G_RAMP(G)    "Generators for which to enforce ramping limits"
    G_WIND(G)    "Wind generators (for reserve requirements)"

* ======  Declare the data parameters. Actual data imported from include files
parameters
* Data Tables
    pDemandData(D, DEM_PARAMS)   "table of demand data"
    pGenData   (G, GEN_PARAMS)   "table of generator data"
    pGenAvail  (D, G)            "table of time dependent generator availability"
    pFuelData  (F, FUEL_PARAMS)  "table of fuel data"
* Post Processing Results Parameters
    pGenAvgAvail (G)             "average availability (max capacity factor)"
* Additional Parameters
    pCRF       (G)               "capital recovery factors     [/yr]"

scalars
    pWACC             "weighted average cost of capital (utility investment discount rate) [p.u.]"
    pCostCO2          "cost of carbon (in terms of CO2 equivalent)                         [$/t-CO2eq]"
    
    pPriceNonServed     "Cost of non-served energy                                           [$/MWh]"
    
    pRPS              "fraction of energy from wind                                        [p.u.]"
    pCarbonCap        "max annual CO2 emissions                                            [Kt CO2e]"
    pDemandScale      "factor by which to scale demand"
    pWindForecastError "forecast error as a fraction of wind capacity for quick start reserves [p.u.]"

    pSpinResponseTime           "Response time for Spinning Reserves                        [minutes]"
    pQuickStartLoadFract        "addition Fraction of load for non-spin reserves            [p.u.]"
    pSpinReserveLoadFract       "addition Fraction of load for spin reserves                [p.u.]"
    pSpinReserveMinGW         "minimum spining reserve                                      [GW]"
    pRegUpLoadFract             "additional Fraction of load for regulation up              [p.u.]"
    pRegDownLoadFract           "Fraction of load over unit minimums for regulation down    [p.u.]"

*Additional Reserves for Wind see (De Jonghe, et al 2011)
* pWindFlexUpForecast=A_POS, pWindFlexUpCapacity=B_POS, pWindFlexDownForecast=A_NEG, pWindFlexDownCapacity=B_NEG
    pWindFlexUpForecast     "Additional up reserves based on wind power output (forecast)  [fraction of PwrOur]"
    pWindFlexUpCapacity     "Additional up reserves based on installed wind capacity [fraction of Wind capacity]"
    pWindFlexDownForecast   "Additional down reserves based on wind power output (forecast)  [fraction of PwrOur]"
    pWindFlexDownCapacity   "Additional down reserves based on installed wind capacity [fraction of Wind capacity]"
    
* ======  Declare Variables
variables
   vTotalCost                "total system cost in target year             [M$]"
   vFixedOMCost              "fixed O&M costs in target year               [M$]"
   vVariableOMCost           "variable O&M costs in target year            [M$]"
   vFuelCost                 "total fuel costs in target year              [M$]"
   vCapitalCost              "annualized capital costs                     [M$]"
   vCarbonCost               "cost of all carbon emissions                 [M$]"

   vCarbonEmissions          "carbon from operations + fraction embedded   [Kt-CO2e]"

positive variables
   vFuelUse  (F)      "fuel usage by type                  [MMBTU]"
   vPwrOut   (D, G)   "production of the unit                [GW]"

   vNonServed(D   )   "non-served demand                     [GW]"

* Reserves
   vFlexUp    (D,G)  "Flexibility up   (Spinning + QuickStart + RegUp + Renewable Up) reserves [GW]"
   vFlexDown  (D,G)  "Flexibility down (RegDown + Renewable Down) reserves [GW]"
   ;

* ======  Declare Equations
equations
   eTotalCost       "total system cost for one year of operation  [M$]"
   eFixedOMCost     "system fixed O&Mcosts for one year           [M$]"
   eVarOMCost       "system variable O&M costs for one year       [M$]"
   eFuelCost        "system fuel costs for one year               [M$]"
   eCapitalCost     "annualized capital cost of new capacity      [M$]"
   eCarbonCost      "cost of all carbon emissions                 [M$]"

   eCarbonEmissions "carbon from operations + fraction embedded   [Kt-CO2e]"
   eFuelUse         "fuel usage by type                           [MMBTU]"

   ePwrMax   (D, G)  "output w/ reserves lower than available max       [GW]"
   ePwrMin   (D, G)  "output w/ reserves greater than installed min     [GW]"
   eDemand   (D   )  "output must equal demand [GW]"

   eRPS              "RPS Standard: minimum energy percent from renewables     [p.u.]"
   eCarbonCap        "Limit total emissions                                    [Kt-CO2e]"

$ifthen set force_renewables
   eForceRenewables (D, G) "force the use of all renewable output (up to 100% of load) [GW]"
$endif

$ifthen.flex %flex_rsrv%==on
    eFlexUp    (D)     "Provide required flexibility up reserves (aka Positive Balance) [GW]"
    eFlexDown  (D)     "Provide required flexibility down reserves (aka Negative Balance) [GW]"
    
    eFlexUpMax    (D,G)     "Stay below max spinning reserves on-line generators of each class can supply [GW]"
    eFlexDownMax  (D,G)     "Stay below max regulation up reserves on-line generators of each class can supply [GW]"
$endif.flex

$ifthen.ramp %ramp%==on
    eRampUpLimit(D,G)       "Limit period to period ramp up rates"
    eRampDownLimit(D,G)     "Limit period to period ramp down rates"
$endif.ramp
   ;

*================================*
*       The Actual Model         *
*================================*
*====== objective function and components
eTotalCost    .. vTotalCost =e=  vFixedOMCost + vVariableOMCost + vFuelCost + vCapitalCost + vCarbonCost
$ifthen not set no_nse
                 + sum[(D), vNonServed(D)*pPriceNonServed*pDemandData(D, 'dur')]/1e6
$endif
                 ;

eFixedOMCost  .. vFixedOMCost*1e6 =e= sum[(  G), pGenData(G,'c_fix_om')*pGenData(G,'cap_cur')];

eVarOMCost    .. vVariableOMCost*1e6 =e= sum[(D, G), pGenData(G,'c_var_om')*vPwrOut(D,G)*pDemandData(D, 'dur')];

eFuelCost     .. vFuelCost*1e6 =e= sum[(F), pFuelData(F,'cost')*vFuelUse(F)];

*capital cost = existing+new capacity*annualized cost of capital using capital recovery factor
*Note: this formulation ensures we still pay the capital costs on old capacity even if it is not
* used and will not effect the solution, b/c it simply adds a constant cost to the problem
eCapitalCost  .. vCapitalCost*1e6 =e= sum[(G), pCRF(G)*(
                                            pGenData(G,'cap_cur'))*pGenData(G,'c_cap')];

*carbon cost =  carbon price * carbon emissions
eCarbonCost   .. vCarbonCost*1e6 =e= pCostCO2 * vCarbonEmissions*1e3;

*====== Intermediate Calculations
*carbon emissions = fuel use - ccs * carbon intensity + embedded carbon * new capacity
eCarbonEmissions   .. vCarbonEmissions*1e3 =e= sum[(D,GEN_FUEL_MAP(G,F)), pGenData(G,'heatrate')*vPwrOut(D,G)*pDemandData(D, 'dur')
                                                          *pFuelData(F,'co2')*(1-pGenData(G,'co2_ccs'))];


eFuelUse(F)      .. vFuelUse(F) =e= sum[(D,GEN_FUEL_MAP(G,F)), pGenData(G,'heatrate')*vPwrOut(D,G)*pDemandData(D, 'dur')];

*======  Basic Contraints
* Supply equals demand at all times. Note: reserves are enforced in separate equations below
eDemand (D)    .. sum[(G), vPwrOut(D, G)]
$ifthen not set no_nse
                    + vNonServed(D)
$endif
                    =e= pDemandData(D,'power');


*Equivalent to (De Jonghe, et al 2011) eq 11 with BP addition of Availability
ePwrMax (D, G) .. pGenData(G,'cap_cur') * pGenAvail(D, G) =g= vPwrOut(D, G) + vFlexUp(D, G);

*======  Additional Constraints
* technology minimum output: typically only used for baseload plants. Applies to entire generator
* category
*    ignore by using p_min=0 or not defining p_min (unspecified parameters default to zero)

*Equivalent to (De Jonghe, et al 2011) eq 9 with BP addition of FlexDown considideration
ePwrMin (D, G) ..   vPwrOut(D, G) =g= pGenData(G,'p_min')*pGenData(G,'cap_cur') + vFlexDown(D,G);


* renewable energy / total energy > RPS
eRPS        ..  sum[(D, G_RPS), vPwrOut(D, G_RPS)*pDemandData(D, 'dur')] =g=
                    pRPS*sum[(G, D), vPwrOut(D,G)*pDemandData(D, 'dur')];
eCarbonCap  ..  vCarbonEmissions =l= pCarbonCap;

*force the use of all renewable output (up to 100% of load) [GW]
$ifthen set force_renewables
* In contrast to (De Jonghe, et al 2011) eq 6, 7, 20, & 21, Wind is treated as any other generator
* and assumed to be curtailable unless the following equation is used to force using all of the wind

   eForceRenewables(D, G)$(G_RPS(G)) .. vPwrOut(D, G) =e= 
                   min(  pGenData(G,'cap_cur')*pGenAvail(D,G), pDemandData(D, 'power') );
$endif

*======  Reserve Constraints
*Ensure we have enough reserves

$ifthen.flex %flex_rsrv%==on
*Equivalent to (De Jonghe, et al 2011) eq 16 & 18 with BP addition of baseline (non-wind)
*requirement to meet Spin Reserve + Reg Up
    eFlexUp    (D) .. sum[(G), vFlexUp(D, G)] =g=
                            max(pDemandData(D,'power') * pSpinReserveLoadFract,
                                pSpinReserveMinGW)
                            + pDemandData(D,'power') * pRegUpLoadFract
                            + pWindFlexUpForecast * sum[(G)$G_WIND(G), vPwrOut(D, G)]
                            + pWindFlexUpCapacity * sum[(G)$G_WIND(G), pGenData(G,'cap_cur')];

    eFlexDown  (D) .. sum[(G), vFlexDown(D, G)] =g=
                            max(pDemandData(D,'power') * pSpinReserveLoadFract,
                                pSpinReserveMinGW)
                            + pDemandData(D,'power') * pRegDownLoadFract
                            + pWindFlexDownForecast * sum[(G)$G_WIND(G), vPwrOut(D, G)]
                            + pWindFlexDownCapacity * sum[(G)$G_WIND(G), pGenData(G,'cap_cur')];

* Compute the maximum reserves per generator as a function of capabilities.
* Note: ePwrMax and ePwrMin ensure that we do not double count capacity

*Equivalent to (De Jonghe, et al 2011) eq 10 using BP field names and assuming the spin_rsv and 
*reg_up limits are additive
    eFlexUpMax    (D,G) .. vFlexUp(D,G) =l=
                                (pGenData(G, 'spin_rsv') + pGenData(G, 'reg_up')) * vPwrOut(D, G)
                                + pGenData(G, 'quick_start') * (pGenData(G, 'cap_cur') - vPwrOut(D, G));
*Equivalent to (De Jonghe, et al 2011) eq 12 with the BP correction that off-line generators can't
*be used to provide downward flexibility, using BP field names and assuming the spin_rsv and 
*reg_up limits are additive
    eFlexDownMax    (D,G) .. vFlexDown(D,G) =l=
                                (pGenData(G, 'spin_rsv') + pGenData(G, 'reg_down')) * vPwrOut(D, G);
$endif.flex

*======  Ramping Constraints
$ifthen.ramp %ramp%==on
* Use total capacity based ramping limits
* Rather than using the De Jonghe, et al 2011 ramping formulation based on FlexUp and FlexDown
* we use explicit ramping limit relations. We do this b/c FlexUp and FlexDown try to capture
* flexibility _within_ the hour, rather than between hours as in ramping

* This equation replaces eq 14 in De Jonghe, et al 2011, Here we assume that "on-line" capacity
* does not contribute to ramping (its already on) and "off-line" capacity is limited either by
* its ramp limit (as is appropriate for any committed units not at their max, and any new starts)
* or by its quick start ability (as is appropriate for new starts of some plants)
    eRampUpLimit(D,G)$(G_RAMP(G)) ..
                    vPwrOut(D++1, G) - vPwrOut(D, G) 
                    =l=
                    max(pGenData(G, 'ramp_max'), pGenData(G, 'quick_start'))
                      * (pGenData(G,'cap_cur')*pGenAvail(D, G) - vPwrOut(D, G));

* Likewise, this equation replaces eq 15 in De Jonghe, et al 2011. Here we assume "on-line" 
* capacity can be the only contributor to downward ramping, since you have to be running to 
* ramp down. This may need to change with storage
    eRampDownLimit(D,G)$(G_RAMP(G)) ..
                    vPwrOut(mDemShift(D,1), G) - vPwrOut(D, G)
                    =l=
                    pGenData(G, 'ramp_max') * (pGenData(G, 'cap_cur')*pGenAvail(mDemShift(D,1), G) - vPwrOut(mDemShift(D,1), G));
$endif.ramp

*================================*
*        Handle The Data         *
*================================*

*Skip ahead to here on restart
$label skip_redef

*Supress listfile output for includes
$if not set debug $offlisting

* ====== Include Data files
* By default use test_sys.inc if not not passed at the command line
$if NOT set sys    $setglobal sys    test_sys.inc

* Actually do include the system data definition file
$include %data_dir%%sys%

$if set fuel   $include %data_dir%%fuel%
$if set demand $include %data_dir%%demand%
* Note: include demand before gens, so can use the demand levels for time varying availabiilty
$if set gens   $include %data_dir%%gens%

* Read availability tables
$if set avail $include %data_dir%%avail%

* Now allow for updates to any of the parameters for easier interfacing to external programs
* by loading this file after all of the core data, we can update the actual values used in the
* optimization. (Note: only possible b/c $onmulti used)
$if set update $include %update%

*Return to listing in the output file
$if not set debug $onlisting

* ===== Additional Command Line Parameters
*override CO2 price with command line setting if provided
$if set co2cost pCostCO2=%co2cost%;

*override Demand scaling with command line setting if provided
$if set demscale pDemandScale=%demscale%;

*override RPS level with command line setting if provided
$if set rps pRPS=%rps%;

*override Carbon Cap (Mt) with command line setting if provided
$if set co2cap pCarbonCap=%co2cap%;

*allow user to specify a uniform gen_size
$if set force_gen_size pGenData(G,'gen_size') = %force_gen_size%;
*and minimum plant size
$if set min_gen_size pGenData(G,'gen_size') = max(pGenData(G,'gen_size'), %min_gen_size%);

*remove p_min value if not used
$if not set basic_pmin pGenData(G, 'p_min') = 0;

* ====== Calculate subsets
*only include elements where the generator fuel name parameter matches the fuel name parameter
GEN_FUEL_MAP(G, F)$(pGenData(G,'fuel') = pFuelData(f,'name')) = yes;

*include all wind, solar, and geotherm plants in the RPS standard
acronyms wind, solar, geotherm;
G_RPS(G)$(pGenData(G,'fuel') = wind) = yes;
G_RPS(G)$(pGenData(G,'fuel') = solar) = yes;
G_RPS(G)$(pGenData(G,'fuel') = geotherm) = yes;

*create set for wind generators (for increased reserve requirements)
G_WIND(G)$(pGenData(G,'fuel') = wind) = yes;

*Only worry about ramping for plants with ramp limits < 1
G_RAMP(G)$(pGenData(G,'ramp_max') < 1) = yes;


* ====== Calculate parameters
*Compute average availability for each generator
pGenAvgAvail(G) = sum[(D), pGenAvail(D, G)*pDemandData(D, 'dur')] / sum[(D), pDemandData(D, 'dur')];

*Convert time varying to average availabilities if desired
$ifthen set avg_avail
    pGenAvail(D,G) = pGenAvgAvail(G);
$endif

*Scale demand
pDemandData(D,'power') = pDemandScale * pDemandData(D,'power');

*compute capital recovery factor (annualized payment for capital investment)
pCRF(G)$(pGenData(G, 'cap_max')) = pWACC/(1-1/( (1 + pWACC)**pGenData(G,'life') ));

*Remove Wind driven Flex Down constraints if we allow wind shedding. b/c rather than
*ramping thermal down, we could simply shed wind
$ifthen not set force_renewables
    pWindFlexDownForecast = 0;
    pWindFlexDownCapacity = 0;
$endif

*================================*
*       Solve & Related          *
*================================*

* ======  Setup the model
* Skip this definition if we are doing a restart
model OpsLp  /all/;

* ======  Adjust Solver parameters
* Enable/Disable Parallel processing
*By default, use only one thread
$if not set par_threads $setglobal par_threads 2

*Create a solver option file
file fSolveOpt /"%gams.optdir%cplex.opt"/
put fSolveOpt;

* Note: the number of threads can either be specified explicitly or using "0" for use all cores
* In some cases barrier solves faster with only 1 thread (at least compared to 2)
put 'threads %par_threads%' /

* Conserve memory when possible... hopefully avoid crashes b/c of memory
* put 'memoryemphasis 1' /

* First try barrier algorithm (#4) for pure LP, RMIP, and final MIP solve. 
*   Options: 0=automatic (typically dual simplex), 2=Dual Simplex, 4=barrier,  or
*            6=concurrent (race between dual simplex and barrier in parallel.
* Typically Barrier tends to be much faster for this problem class but may not converge    
put 'LPmethod 4' /

putclose fSolveOpt;

*Tell GAMS to use this option file
OpsLp.optfile = 1;

* ====== Check command line options
* Check spelling of command line -- options
* Notes:
*  - all command line options have to have either been used already or be listed
* here to avoid an error. We place it here right before the solve statment such that
* if there is an error, we don't wait till post solution to report the problem
$setddlist summary_only summary_and_power_only memo obj_var

* ======  Actually solve the model
* Set objective, default = min total costs
$if not set obj_var $setglobal obj_var vTotalCost

solve OpsLp using LP minimizing %obj_var%;

$ontext
* If barrier only found an intermediate solution, try again using one of the more robust barrier
* algorithms
if OpsLp.modelstat eq 7 then

*Create a new solver option file
    put fSolveOpt;

*See option descriptions above
    put 'threads %par_threads%' /
*    put 'memoryemphasis 1' /
    put 'LPmethod 4' /
    put 'barcrossalg -1' /

*Specify the barrier algorithm to use. Selected options are
*   1  Infeasibility estimate start (more robust, MIP default)
*   3  Standard barrier (fastest, LP default)
    put 'baralg 1' /
    putclose fSolveOpt;

*And try again
    solve OpsLp using LP minimizing %obj_var%;
endif;

* If this still doesn't work, try using concurrent optimization where dual simplex competes
* against an even more robust barrier model that uses simplex at the end
* Now we want to use parallel threads unless the user specifically stated only 1 thread
if OpsLp.modelstat eq 7 then

*Create a new solver option file
    put fSolveOpt;

*See option descriptions above
    put 'threads %par_threads%' /
*    put 'memoryemphasis 1' /
    put 'LPmethod 6' /

    putclose fSolveOpt;

*And try one more time
    solve OpsLp using LP minimizing %obj_var%;
endif;
$offtext

*================================*
*         Postprocessing         *
*================================*

* ======  Post processing computations 
* Most of these calculations are standardized in ../shared/calcSummary.gms
$include %shared_dir%calcSummary.gms

* ======  Write Results to CSV files
* WARNING: the structure of these output files matters for us with the CapPlanDP code... take
* care when changing
*-- Suppress CSV output if no_csv flag is set
$if "no_csv = 1" $ontext

*-- [1] Output solution summary
* summary file setup
* file has 2 columns: name, data
file fListOut /"%out_dir%%out_prefix%out_summary.csv"/
put fListOut;

*Set output precision to have 5 places right of the decimal (except for large numbers in scientific format)
fListOut.nd=5;

*- Model Run and Objective Function Information -
* Note: this section is model specific so not included in the shared writeSummary include file
put  "run_modstat," OpsLp.Tmodstat /
put  "run_solstat," OpsLp.Tsolstat /

*Write out additional summary in standard form
$include %shared_dir%writeSummary.gms

*And include any additional model dependant variables
*  -- None --

*close our file
putclose

$if set summary_only $goto skip_non_summary
*-- [2] Output Power Out (dispatch) data as a 2-D table
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%out_power_table.csv" "table" vPwrOut.l(D,G) D G

$if set summary_and_power_only $goto skip_non_summary
*-- [3] Output files with flexibility reserve data
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%out_flex_up_table.csv" "table" vFlexUp.l(D,G) D G
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%out_flex_down_table.csv" "table" vFlexDown.l(D,G) D G

$label skip_non_summary
*-- end of output suppression when no_csv flag is set
$if "no_csv = 1" $offtext

