
$ontext
----------------------------------------------------
 Static Capacity Planning model
----------------------------------------------------
  A deterministic static (aka single period) electricity generation capacity planning
  model with discrete or continuous build decisions.

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
                          p*Data parameters (pGenData, pDemandData, etc) will NOT be used.
   --scen=NONE           For multiple scenario problems (multi-period or stochastic) specifies
                          the list of scenarios (populates the S set) and their associated
                          weight/probability table, pScenWeight(S).


  Specific Value Overrides (take precedence over all values defined in data files. Use for
  sensitivity analysis, etc.) IMPORTANT, these values are used for ALL scenarios, use an update
  for changing these on a by scenario basis.
   --co2cost=#            Cost of CO2 in $/t-co2e (default: use sys or update value)
   --demscale=#           Factor to uniformly scale demand (default: use sys or update value)
   --rps=#                Renewable Portfolio Standard     (default: use sys or update value)
   --co2cap=#             Carbon Emission Cap (Mt-co2e)         (default: use sys or update value)

  Model Setup Flags (by default these are not set. Set to any number, including zero, to enable)
   --obj_var=vTotalCost   Variable to minimize in solution. In scenario mode (stochastic UC, 
                            multi-period planning, etc.) The weighted sum across scenarios of
                            this value is used Common options:
                             vTotalCost  (default) Least cost operations
                             vCarbonEmissions  Use with no_nse=1 to find minimum possible co2
                            Technical Note: Any variable indexed by S can be used
   --startup=(off)        Compute startup costs (also enables unit_commit)   (default: ignore)
   --unit_commit=(off)    Compute unit commitment constraints   (default: ignore)
   --ramp=(off)           Flag to limit inter period ramp rates  (default: ignore)
   --ignore_integer=(off) Flag to ignore integer constraints in new capacity investments,
                           (eg allow 1MW nuclear plants) and in Unit Commitment if enabled (unit is
                           either committed or not) (default: use integer constraints)
   --avg_avail=(off)      Flag to use the average rather than time dependent availabilities. Using
                           averages is OK for thermal units, but highly simplifies time varying
                           renewables. This simplification is made in the analytic version of the
                           model, but not generally a good idea for numeric estimates. (default: use
                           complete time varying information.)
   --ignore_cap_credit=(off) Flag to ignore the distinction between capacity credit and availability
                           When set, the capacity credit parameter is set equal to the time weighted
                           average of availability. (default: use cap_credit value from GenParams)
   --uc_ignore_unit_min=(0)   Threshold for unit_min to ignore integer commitment decisions in unit
                           commitment. Gens with unit_min less than or equal to this value will be
                           treated as continuous to speed performance
   --uc_int_unit_min=(0)   Threshold for unit_min to ignore INTEGER commitment 
                            decisions & constraints. Gens with unit_min less than or equal to 
                            this value will still have commitment variables, but their valid
                            range is relaxed to be continous. The same equations are used
                            as for those units with integer constraints.
    --uc_lp=(0)            Ignore integer constraints on all UC variables (& startup/shutdown)
   --adj_rsrv_for_nse=(off)  Adjust reserves for non-served energy. This uses actual power
                  production rather than total desired demand for setting reserve requirements.
                  This distinction is only significant if there is non-served energy. When
                  enabled (old default for SVN=479-480), then non-served energy provides a way
                  to reduce reserve requirements. [Default= use total non-adjusted demand]
   --rsrv=(none)  Specify Type of reserve calculation. Options are:
        =separate  Enforce separate reserve requirements based on "classic" ancillary
                    services plus additions for renewable uncertainty. This includes Reg Up, 
                    Reg Down, Spin Up, & Quick Start
        =flex      Use combined "flexibility" reserves grouped simply into flex up and flex down
        =both      Compute both separate and flexibility reserves
        =(none)    If not set, no reserve limits are computed
  --non_uc_rsrv_up_offline=0   For non-unit commitment generators, the fraction of non-running 
                    generation capacity to use toward UP reserves. This parameter has no
                    effect on UC generators. deJonge assumes 0.6, NETPLAN assumes 1.0, 
                    (default=0). 
  --non_uc_rsrv_down_offline=0 For non-unit commitment generators, the fraction of non-running 
                    generation capacity to use toward DOWN reserves. This parameter has no
                    effect on UC generators. deJonge assumes 0.6, NETPLAN assumes 1.0, 
                    (default=0).
  --no_quick_st=(off)     Flag to zero out quickstart reserve contribution to spinning/flex up 
                           reserves. Useful when non_uc_rsrv... > 0
   --no_nse=(off)         Don't allow non-served energy
   --force_renewables=(off) Force all renewable output to be used. This is only feasible until
                           the point where load and op_reserves dictate a max. (until we add storage).
                           When used with cap_fix, it is a bit more widely useful b/c we can limit
                           output to the level of demand. (this is NLP when capacity is a decision)
   --fix_cap=(off)        Fix capacity to cap_cur by not allowing additions or retirements
   --max_start=(off)      Enforce maximum number of startups   (default: ignore)
   --force_gen_size=(off) Force all plant sizes to equal the specified value (in GW)
   --min_gen_size=(off)   Force small plant sizes to be larger than specified value (in GW)
   --derate=(off)         Use simple derating of power output, typically for non-reserves
   --from_scratch=(off)   Zero out existing capacity and build new system from scratch
   --no_cap_limit=(off)   Allow unlimited expansion of all generators (useful with from_scratch)
   --basic_pmin=(off)     Enforce non-UC based minimum output levels for each generator type. 
                          This can be useful for baseload plants with simple (non-UC) operations.
   --no_capital=(off)     Ignore capital costs, used for operations models to only compute non
                           capital costs. Not recommended for planning models. [default: include 
                           capital costs]
   --renew_lim=(avg)     Technique for limiting renewable expansion:
         =avg   Limit Avg to demand peak: 
                 average power < peak*(1+renew_overbuild) [default]
         =firm  Limit base on firm capacity (typically way to high):
                 cap_credit < peak*(1+plan_margin)*(1+renew_overbuild)
         =rps   Limit expansion to that required to meet the RPS (maybe too low for high rps):
                 rps*(1+renew_overbuild)
         =norm  Treat As Normal Gen (uses general overbuild, not renew_specific): 
                 (1+overbuild)*max(avg < peak*(1+plan), cap_credit < peak(1+plan))
   --overbuild=0.2        Amount (a fraction) over the planning margin to limit the maximum
                           number of plants for each type. Also used with the heuristic capacity
                           limit described below.
   --renew_overbuild=0.2  Amount (a fraction) over the peak/rps energy requirements for 
                           renewables.
   --skip_cap_limit=(off) Do not enforce the heuristic capacity limit equation that can greatly
                           speed MIP tree searches by ignoring capacity combinations, such as 
                           maxing out all gens, that exceed the tougher of the planning margin
                           or operating reserve requirements by more than the overbuild factor.
                           In rare cases, with few generator types, strange availability patterns,
                           etc. this heuristic may be overly restrictive.
   --no_loop=(off)       Do not loop around demand periods for inter-period constraints
                          such as ramping, min_up_down. (default= assume looping)
   --maint=(off)         Compute Maintenance schedule (default = use avail data, typically 
                          assumes full availability for thermal plants)
   --maint_lp=(off)      Relax integer constraints on maintenance decisions (default: use integers) 
   --maint_om_fract=0.5   If maintenance planning enabled, the default fraction of total fixed 
                           O&M costs to divide among the required weeks of maintenance.
   --plan_margin=(off)    Enforce the planning margin. Set to 1 to enable and use the problem
                           defined pPlanReserve (typically in sys.inc). Alternatively can set
                           to a value < 1 that then is used for pPlanReserve overriding other 
                           definitions.
   --plan_margin_penalty=(off) Allow planning margin to be not met and define associated penalty
                           [$/MW-firm] (default= must meet planning margin)
   --rps_penalty=(off)    Allow planning margin to be not met and define associated penalty
                           [$/MWh] (default= must meet rps)
   --retire=(0)           Fraction of current capacity to retire. Max capacity is also adjusted
                           down accordingly (value 0 to 1)
    --derate_to_maint=(off) Override gen datafile derating value and derate based on 
                            the maintenance value only.

  Additional Model Components & Related
   --calc_water=(off)     Compute water use and limits
         Related options (see shared_dir/WaterEquations for complete details)
           --h2o_limit=(Inf)     System wide maximum water use [Tgal]. Only computed for gens
                                  with specified water usage (h2o_withdraw_var)
           --h2o_cost=(0)        System wide water cost [$/kgal]. Only computed for gens
                                  with specified water usage (h2o_withdraw_var)


  Solver Options
    --debug=(off)           Print out extra material in the *.lst file (timing, variables, equations, etc)
    --max_solve_time=10800  Maximum number of seconds to let the solver run. (Default = 3hrs)
    --mip_gap=0.001        max MIP gap to treat as valid solution
    --par_threads=1         Number of parallel threads to use. Specify 0 to use one thread per core 
                             (Default = use only 1 thread)
    --par_mode=1            CPLEX parallel mode 1=deterministic & repeatable, 0=automatic,
                             -1=Opportunistic, but not repeatable (Default = determinstic)
    --lp_method=4           CPLEX code for lp_method to use for pure root node, LP, RMIP, and 
                             final MIP solve.  Options: 0=automatic, 2=Dual Simplex, 4=barrier,
                             6=concurrent (a race between dual simplex and barrier in parallel)
                             (Default = 4, barrier) Use 6 if running in parallel
    --cheat=(off)           use epsilon-optimal branch & bound by removing solutions that are
                             not "cheat" better than the current best. This can speed up the 
                             MIP search, but may miss the true optimal solution. Note that this
                             value is specified in absolute terms of the objective function.
    --rel_cheat=(off)       Similar to cheat, but specified in relative percentage of objective
                             this works in CPLEX only
    --probe=0               CPLEX code for probing, a technique to more fully examine a MIP 
                             problem before starting branch-and-cut. Can sometimes dramatically
                             reduce run times. Options: 0=automatic, 1=limited, 2=more, 3=full,
                             -1=off. (default = 0, automatic). Probe time also limited to 5min.
    --priority=off          Use branching priorities for Branch & Bound tree, set to anything
                             other than off to enable.    

  File Locations (Note, on Windows & DOS, \'s are used for defaults)
   --data_dir=../data/     Relative path to data file includes
   --out_dir=out/          Relative path to output csv files
   --util_dir=../util/     Relative path to csv printing and other utilities
   --shared_dir=../shared/ Relative path to shared model components
   --out_prefix=SCP_       Prefix for all our our output data files
   
  Output Control Flags (by default these are not set. Set to any number, including zero, to enable)
   --debug=(off)           Print out extra material in the *.lst file (timing, variables, 
                            equations, etc)
   --debug_avail=(off)    Display full availability table in *.lst file for debugging
   --no_csv=(off)         Flag to suppress creation of csv output files (default: create csv output)
   --summary_only=(off)   Only create output summary data (default: create additional tables)
   --summary_and_power_only=(off)   Create only summary & power table outputs (Default: all files)
   --out_gen_params=(off) Create output file listing generator parameter input data (Default: skip)
   --out_gen_avail=(off)  Create output file listing generator availability input data (Default: skip)
   --memo=(none)          Free-form text field added to the summary table NO COMMAS (Default: none)
   --gdx=(off)            Export the entire solved model to a gdx file in the out_dir (Default: no gdx file)
   --debug_off_maint=(off) Create table of capacity off maintenance


  Supports:
    - multiple operations model modes:
        + simple economic dispatch
        + ramp (up & down) constrained economic dispatch
        + integer unit commitment:
           - minimum output for committed generators
           - startup costs (optional)
           - ramp (up & down) constraints (optional)
    - arbitrary number of generation technologies/units with
        + availability factors (separate from capacity credit, see below)
        + maximum installed capacity by unit
        + minimum power for baseload units
        + existing installed capacity, with ability to not fully use
        + discrete plant sizes (can ignore)
        + technology specific operating reserve capabilities
    - features designed explicitly for proper wind support:
        + RPS (minimum wind energy penetration %)
        + Non-unity capacity credits (how much does each generator help the peak?)
        + time varying wind availability/output
    - (optional) endogenous operating reserves during each time block (hourly for 8760) including:
        + Spinning Reserves
        + Quick Start Reserves (effectively non-spin)
        + Regulation Up & Down
    - planning reserves (during peak block only)
    - arbitrary number of demand blocks of varying duration
    - heat rates + separate fuel costs for easy scenario analysis
    - carbon intensity
       + imbedded carbon from construction
       + carbon content of fuels
    - carbon constraint (carbon cap)
    - carbon tax
    - non-served energy
    - ability to mothball plants to save fixed O&M costs (still pay capital costs)

Outputs
    - Summary, Power, Commitment, New capacity, #startups, emissions, wind shedding, cost breakdown.


Additional Features:
    - loading of data from include files to allow an unchanging core model.
        - These file names can be optionally specified at the command line.
    - A final, optional "update" file to allow for adjusting parameters for easy sensitivity
      analysis or to change the values for a model run without changing the default values
    - internal annualizing of capital costs (requires definition of WACC)
    - ability to scale demand
    - ability to ignore integer constraints
    - automatically estimates max integer # of plants based on gen_size
    - Force wind mode to require using all wind production with no shedding (only valid for small %wind)

Performance enhancements:
    - ignores unit commitment for plants with no/low unit minimum output such as renewables and
      peakers. This threshold is tunable with --unit_min

Assumptions:
    - Ramping and Startup "loop" such that the state at the endo of the year must match the
      beginning of year. This prevents turning off baseload in anticipation of the "end of the world"


ToDo:
    * Decouple ops into blocks for faster UC?
    * Add hydro
    ? compute fixed and var cost by gen
    - compute required market based incentives to achieve same results
    - automatic scaling of demand blocks based on year, baseline, & growth rate

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   March 2010

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2010-05-20  23:30  bpalmintier   Original version merged: ToyCapPlan v7 + DemoCapPlanWind v4
  2  2010-05-21  04:00  bpalmintier   Expanded & Improved features for MATLAB integration
  3  2010-05-21  10:30  bpalmintier   Added support for lumpy (integer plant) investments
  4  2010-05-21  10:50  bpalmintier   Made existing capacity also pay capital costs (no change to
                                      solution by "grandma's theorem")
  5  2010-07-31  08:40  bpalmintier   Added flag (no_csv) to suppress output of csv files.
  6  2010-08-02  00:40  bpalmintier   Fixed MAJOR bug: derate power output by availability
  7  2010-09-06  22:00  bpalmintier   Added total energy to summary output
  8  2010-09-06  23:45  bpalmintier   - Made include paths platform independent
                                      - Moved data includes to ../data directory
                                      - Fix no_csv default
                                      - explicitly compute total capacity
  9  2010-09-07  20:23  bpalmintier   Separated pGenAvail for time varying availability
 10  2010-09-07  23:00  bpalmintier   Added flag to use averages for availability
 11  2010-09-07  18:30  bpalmintier   Converted to single sys.inc with subincludes. Updated comments
 12  2010-09-08  23:55  bpalmintier   Added ramp_limits (optional) for ramp constrained dispatch
 13  2010-09-09  17:35  bpalmintier   Adjusted solve parameters for more realistic runtimes
 14  2010-09-09  19:35  bpalmintier   Made key solution parameters available on the command line
 15  2010-09-11  20:00  bpalmintier   Minor tweaks and bug fixes:
                                       - loop around for ramp constraints to prevent start from 0
                                       - use RMIP for ignore_integer (also fix related $if bugs)
                                       - renamed --limit_ramps to --ramp
                                       - renamed --mip_tol to --mip_gap
 16  2010-09-17  12:15  bpalmintier   Added option to use avg avail for cap_credit (traditional approach)
 17  2010-10-24  01:00  bpalmintier   Added calculation of energy production mix
 18  2010-10-26  13:00  bpalmintier   Major rework to ignore integer unit commitment for unit_min=0
                                      Result is 10-300x speed up for MIP (startup) solutions!!!
                                      Also:
                                        - improved comments
                                        - Expanded RPS to include a subset based on fuel type (not name)
 19  2010-11-xx         bpalmintier   made unit_min a tunable parameter (default = 0)
 20  2010-11-13  23:00  bpalmintier   Key Update to include both up & down ramping
 21  2010-11-14  10:30  bpalmintier   Additional features:
                                        - debug mode to print more complete *.lst file
                                        - More realistic ramping for unit commitment that considers
                                          the on-line generator fleet rather than the total fleet
 22  2010-11-14  18:30  bpalmintier   Added hourly reserves (finally!) including Spin, QuickStart,
                                       RegUp, and RegDown.
 23  2010-11-14  22:30  bpalmintier   Added non-served energy & some solution helpers
 24  2010-11-15  02:30  bpalmintier   New features:
                                        - Ability to restart from a saved solution (should help initial LP only)
                                        - Command line switches for non-served, op_reserves, etc.
                                        - Reworked equations so unit_commit dictated by $G_UC(G)
 25  2010-11-16  09:00  bpalmintier   BUG FIX: corrected ramp limits for UC
 26  2010-11-16  09:00  bpalmintier   Tweaks:
                                        - Only compute ramp for units with ramp_max < 1
                                        - Consider availability in ramp for non-UC
                                        - Shortened command line options to no_nse & no_op_rsrv
 27  2010-11-16  23:59  bpalmintier   Report Startup Data
 30  2010-11-18  03:00  bpalmintier   Added max_start
 31  2010-11-19         bpalmintier   FIXED major bug in op reserve: loophole for spin_rsv, etc = 0
 32  2010-11-20  11:00  bpalmintier   FIXED major bug where startup did not actually turn on UC
 33  2010-11-22  10:30  bpalmintier   Added fix_cap mode
 34  2010-11-23  20:50  bpalmintier   Added & renamed output for use with StaticCapPlanScripter.m
 35  2010-11-24  11:15  bpalmintier   Added carbon price and marginal emissions
 36  2011-01-11  20:00  bpalmintier   Added command-line parameter checks
 37  2011-05-26  20:00  bpalmintier   Added startup cost to summary
 38  2011-06-18  03:15  bpalmintier   Added --avail option to fix bug with inconsitant gen availability files
 39  2011-06-20  12:15  bpalmintier   change update file path to relative to the model (not data_dir)
 40  2011-07-08  02:15  bpalmintier   Added ability to force plant (bin) sizes to a specified value
 41  2011-07-15  10:15  bpalmintier   move output summary to shared include file
 42  2011-07-20  03:00  bpalmintier   re-arrange data includes for sys definition of avail file
 43  2011-07-20  15:00  bpalmintier   Added support for parallel processing with par_threads
 44  2011-07-21  03:00  bpalmintier   Added --memo, set cap_max=0 integer limit to zero
 45  2011-07-21  03:30  bpalmintier   Added --co2cap
 46  2011-07-22  14:55  bpalmintier   Added combined Flexibility reserves (from OpsLp v5)
 47  2011-07-24  01:00  bpalmintier   Added max_cap_factor and derate, cleaned up flex vs separate reserves
 48  2011-07-24  01:15  bpalmintier   Remove down req't for wind when shedding OK, Added --from_scratch
 49  2011-07-24  08:30  bpalmintier   Replace availability CSV with GAMS table format
 50  2011-07-24  11:30  bpalmintier   Corrected (again) double counting for separate & flex reserves
 51  2011-07-24  19:30  bpalmintier   User configurable --out_prefix
 52  2011-07-26  16:30  bpalmintier   Made support of p_min optional with --basic_pmin
 53  2011-08-02  17:00  bpalmintier   Made planning margin optional with --plan_margin
 54  2011-08-02  17:30  bpalmintier   More flexible force_renewables with min of demand and renew output (borrow from OpsLp)
 55  2011-08-02  21:30  bpalmintier   Corrections based on OpsLp:
                                        - only G_WIND used for reserves since req't are tech specific
                                        - cleaned up ramping limit equations
 56  2011-08-03  00:10  bpalmintier   BUG FIX: pPlanRserve use for non fix_cap settings
 57  2011-08-03  00:40  bpalmintier   Added support for water limits via include file
 58  2011-08-05  01:40  bpalmintier   TWEAKED solver option file to use barrier algorithm
 59  2011-08-05  11:30  bpalmintier   Increased output precision to 5 after decimal
 60  2011-08-06  16:15  bpalmintier   Further refinement of solver to use concurrent optimization
 61  2011-08-17  15:55  bpalmintier   Added water cost
 62  2011-08-19  10:35  bpalmintier   Force renewables on system-wide, rather than per gen, basis
 63  2011-09-21  17:00  bpalmintier   Comments & other updates from UnitCommit extraction
 64  2011-10-11  14:15  bpalmintier   Renamed plant_size to gen_size (also related flags)
 65  2011-10-14  09:55  bpalmintier   BUGFIX: corrected scaling for co2_cap passed from command line
 66  2011-11-06  13:15  bpalmintier   Updated to use AdvPwrSetup and AdvPwrDataRead
 67  2011-11-07  15:25  bpalmintier   Corrected comments re: sys.inc
 68  2011-11-10  12:15  bpalmintier   Added no_capital option
  69 2012-01-26  11:05  bpalmintier   Search and replace to partially match UnitCommit scenario overhaul (v26)
  70 2012-01-28  02:45  bpalmintier   Modularize to call UnitCommit for operations
  71 2012-01-29  00:10  bpalmintier   Removed "helper" lower bound on new cap b/c causing errors
  72 2012-02-03  15:15  bpalmintier   MAJOR
                                        -- scaling: MW to GW, Capital costs to M$/GW
                                        -- Default to using barrier for LP solver (typically faster, especially for LPs)
                                        -- Cleaned-up Capacity limit equations
  73 2012-02-21  15:15  bpalmintier   Stricter capacity limits for renewables. Added renew_overbuild and renew_to_rps
  74 2012-03-07  11:35  bpalmintier   Added support for partial period simulation through B_SIM
  75 2012-05-02  12:40  bpalmintier   Separate demand (D) into blocks (B) and time sub-periods (T)
  76 2012-06-14  05:10  bpalmintier   Added no_cap_limit option
  77 2012-06-14  15:05  bpalmintier   Added rps & planning margin penalties (via UnitCommit)
  78 2012-08-21  16:05  bpalmintier   Updated comments, prevent negative max for rps gens with low rps & renew_to_rps
  79 2012-08-22  00:15  bpalmintier   Shortened file names, no more "out_"
  80 2012-08-22  15:05  bpalmintier   Added priority (B&B tree) option
  81 2012-08-23  14:05  bpalmintier   BUGFIX: ignore integers for startup/shutdown when ignoring uc integers, publish uc_lp option
  82 2012-08-25  09:05  bpalmintier   BUGFIX: correct renew_to_rps logic (previously reversed).
  83 2012-08-25  11:10  bpalmintier   Replace renew_to_rps with more flexible renew_lim
  84 2012-08-29  17:45  bpalmintier   Update to set integer bounds for all except uclp
  85 2012-08-31  00:35  bpalmintier   Allow non-served energy to reduce reserve needs (old behavior with --rsrv_use_tot_demand=1)
  86 2012-08-31  07:15  bpalmintier   UPDATE: default to rsrv to demand (without nse). Flag renamed to adj_rsrv_for_nse
  87 2012-09-02  17:05  bpalmintier   BUGFIX: Correct maintenance by preventing mismatch between local & global values of capacity_G, Ergh!
  88 2012-09-02  17:08  bpalmintier   Replace all $set with $setglobal (to prevent other possible troubles)
  89 2012-09-03  07:08  bpalmintier   Add derate_to_maint & debug_off_maint
-----------------------------------------------------
$offtext

*================================*
*             Setup              *
*================================*

* First define the shared directory

* ======  Platform Specific Adjustments
* Setup the file separator to use for relative pathnames
$iftheni %system.filesys% == DOS $setglobal filesep "\"
$elseifi %system.filesys% == MS95 $setglobal filesep "\"
$elseifi %system.filesys% == MSNT $setglobal filesep "\"
$else $setglobal filesep "/"
$endif

* By default look for shared components in sibling directory "shared"
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


* ======  Additional setup

* == Identify if we are the master calling model
$ifthen.we_are_main NOT set model_name 
*Establish the title
$Title "Static Capacity Planning model"

*If so set it
$setglobal model_name StaticCapPlan

* == And we want to idenfify whether or not we are using a mixed integer solution
$ifthen.mip set ignore_integer
$setglobal use_mip no
$else.mip
$setglobal use_mip yes
$endif.mip

$endif.we_are_main

* == Default to UnitCommit based operations
$if not set ops_model $setglobal ops_model UnitCommit

* Setup output prefix
$if NOT set out_prefix $setglobal out_prefix SCP_

* ======  Handle some initial command line parameters
*Additional factor for capacity/unit commitment upper limits 
$if not set overbuild $setglobal overbuild .2
$if not set renew_overbuild $setglobal renew_overbuild .2
$if not set renew_lim $setglobal renew_lim avg

*================================*
*         Declarations           *
*================================*

* ====== Bypass Declarations & Model if doing a restart
$if defined StaticCapPlan $goto skip_redef


* ======  Declare all sets so can use in equations
* Note: be sure to quote descriptions otherwise "/" can not be used in a description.

sets
* Sets for table parameters

    DEM_PARAMS  "demand block table parameters from load duration curve"
        /dur         "duration of block                 [hrs]"
         power       "average power demand during block [GW]"
        /

    GEN_PARAMS  "generation table parameters"
       /
        cap_credit  "Capacity Credit during peak block           [p.u.]"
        c_cap       "total capital cost                          [$/GW]"
        life        "economic lifetime for unit                  [yr]"
        cap_cur     "Current installed capacity for generation   [GW]"
        cap_max     "Maximum installed capacity for generation   [GW]"
        lead_time   "Delay from construction to operation        [yr]"
        gen_size    "typical discrete plant size                 [GW]"
        derate       "Derating factor for simple (non-reserves) cap planning [p.u.]"
       /

* Sets for data, actual definitions can be found in include files
    G           "generation types (or generator list)"
    S           "scenarios for multi-period and stochastic problems"
    B           "Demand blocks (e.g. weeks or ldc)"
	T			"Demand time sub-periods (e.g. hours or ldc sub-blocks)"
    B_SIM(B)    "demand blocks used in simulation"

* Subsets for special purposes

* ======  Declare the data parameters. Actual data imported from include files
parameters
* Data Tables
    pGen   (G, GEN_PARAMS, S)       "table of generator data"
* Post Processing Results Parameters
    pGenAvgAvail (G, S)             "average availability (max capacity factor)"
* Additional Parameters
    pScenWeight(S)     "Scenario weighting for cost calcs. Use for probability or time discounting"
    pCRF       (G)               "capital recovery factors      [/yr]"
    pDemandMax (S)               "Maximum demand level          [GW]"

scalars
    pWACC             "weighted average cost of capital (utility investment discount rate) [p.u.]"

*Include operating reserves in total capacity limits only if they are used
$ifthen.skip_lim not set skip_cap_limit
$ifthen.fix_cap not set fix_cap
$ifthen.plan_marg set plan_margin 
$ifthen.rsrv set rsrv
    pSpinReserveLoadFract       "addition Fraction of load for spin reserves                [p.u.]"
    pRegUpLoadFract             "additional Fraction of load for regulation up              [p.u.]"
    pRegDownLoadFract           "Fraction of load over unit minimums for regulation down    [p.u.]"
    pSpinReserveMinGW           "Additional spinning reserve for max contingency            [GW]"
    pReplaceReserveGW           "Offline replacement reserve to replace deployed spinning   [GW]"
$endif.rsrv                    
$endif.plan_marg
$endif.fix_cap
$endif.skip_lim

$ifthen set plan_margin
    pPlanReserve                "planning reserve                                           [p.u.]"
$endif

* ======  Declare Variables
variables
   vObjective  "Objective: scenario weighted average (EV or discounted ops cost)  [M$]"
   vTotalCost      (S)          "total system cost for scenario               [M$]"
   vOpsCost        (S)          "system operations cost in target year        [M$]"
   vCapitalCost    (S)          "annualized capital costs of new capacity     [M$]"

* Specify integer variables. If ignore_integer flag is specified these are treated as continous by
* GAMS by using the RMIP solution type.
integer variables
    vNumNewPlants(G, S)   "number of discrete new plants to construct         [integer]"


positive variables
   vCapInUse (   G, S)   "total installed capacity that is used [GW]"

   vNewCapacity( G, S)   "new capacity constructed              [GW]"
* ======  Declare Equations
equations
$ifthen %model_name% == StaticCapPlan
   eObjective  "Objective function: scenario weighted average (EV or discounted ops cost)  [M$]"
   eTotalCost  (S)     "total cost = ops + capital cos            [M$]"
$endif
   eCapitalCost (S)    "annualized capital cost of new capacity      [M$]"

$ifthen not set fix_cap
   ePositiveNew(G, S)   "prevent negative net new capacities w slack variable."
   eInstCap  (   G, S)  "installed capacity                    [GW]"
$endif

$ifthen.skip_lim not set skip_cap_limit
$ifthen.fix_cap not set fix_cap
$ifthen set plan_margin 
   eLimitTotalCap (S)     "Set a rough upper bound on total capacity to aid MIP solver"
$endif
$endif.fix_cap
$endif.skip_lim

$ifthen not set fix_cap
   eNewPlants (G, S)      "integer constraints on new capacity investment"
$endif
   ;

*================================*
*  Additional Model Formulation  *
*================================*
* Note: this must be included between declarations & equations so that the included file 
* has access to our declarations, and any objective function additions can be used.

* Enable $ variables from included model(s) to propagate back to this master file
$onglobal

* Include operations model, which greatly expands the parameter, variable, and equation set
$include ../ops/%ops_model%

* Include Planning Margin if required
$if set plan_margin $include %shared_dir%PlanMarginEquations

* Water equations included in operations model

* Disable influence of $ settings from include files
$offglobal

*================================*
*       The Actual Model         *
*================================*
*====== objective function and components
* == Objective (eObjective)
*
* The standard objective is total cost (see below for alternative objective options). We use
* our definition of this equation whenever we are the main model. Otherwise we expect our caller
* to define a similar objective function.
* 
$ifthen.we_are_main   %model_name% == StaticCapPlan
$if not set obj_var $setglobal obj_var vTotalCost

eObjective  ..  vObjective =e= sum[(S), pScenWeight(S) * %obj_var%(S)];

* Allows uniform use of total cost for both operations and planning models
eTotalCost (S)  ..  vTotalCost (S) =e= vOpsCost (S) + vCapitalCost (S);

$endif.we_are_main

* == Total Capital Costs (eCapitalCost)
*capital cost = existing+new capacity*annualized cost of capital using capital recovery factor
*
*Note: We can't use %capacity_G% here because we still want to pay the capital costs on old 
* capacity even if it is not used.
* Scaling:
*  1x       pGen(c_cap)     M$/GW
*  1x       vCapCost        M$
eCapitalCost(S)  .. vCapitalCost(S) =e= sum[(G), pCRF(G)*(
$ifthen not set fix_cap
                                            vNewCapacity(G, S)+
$endif
                                            pGen(G,'cap_cur', S))*pGen(G,'c_cap', S)]
                                        * pFractionOfYear(S);

*====== Intermediate Calculations
$ifthen not set fix_cap
*introduce a slack variable so we don't get a credit for unused plants which will have negative net
*capacities because vCapInUse < current capacity
    ePositiveNew(G, S)  .. vNewCapacity(G, S) =e= vCapInUse(G, S)-pGen(G,'cap_cur',S)
*    + vCapSlack(G,S)
    ;

*Constrain new capacity to integer numbers of plants
    eNewPlants(G,S) .. vNewCapacity(G,S) =e= vNumNewPlants(G,S) * pGen(G, 'gen_size',S);
$endif

$ifthen not set fix_cap
    eInstCap(G,S)    .. vCapInUse(G,S) =l= pGen(G,'cap_max',S);
$endif

*======  Additional Constraints

*======  Integer Solution helpers (to speed up MIP searching)
$ifthen.skip_lim not set skip_cap_limit
$ifthen.fix_cap not set fix_cap
$ifthen.plan_marg set plan_margin 
    eLimitTotalCap (S)  .. sum[(G), vCapInUse(G,S)*pGen(G,'cap_credit',S)] =l=
                         (1+%overbuild%)*
$ifthen.rsrv set rsrv
                         max(   
* Existing capacity if overbuilt                         
                                sum[(G), pGen(G,'cap_cur',S)*pGen(G,'cap_credit',S)]
                                ,
* Operating reserve based limits                            
                                (1+ pSpinReserveLoadFract + pRegUpLoadFract)* pDemandMax(S)
                                    + pSpinReserveMinGW + pReplaceReserveGW
                                ,
$else.rsrv                    
                            (
$endif.rsrv                    
* Traditional Planning Reserve limits
                                (1 + pPlanReserve) * pDemandMax(S)
                            );
$endif.plan_marg
$endif.fix_cap
$endif.skip_lim

*Skip ahead to here on restart
$label skip_redef
*================================*
*        Handle The Data         *
*================================*

* Data read in by operations model

* ====== Additional Calculations...

*Clear out existing capacity when building from scratch
$ifthen set from_scratch
    pGen(G, 'cap_cur', S) = 0;
$endif
$ifthen set no_cap_limit
    pGen(G, 'cap_max', S) = Inf;
$endif

* ====== Compute max integer number of plants & unit_commitment states
*Note: by default GAMS restricts to the range 0 to 100 so this provides two features:
*  1) allowing for higher integer numbers for small plant types as required for a valid solution
*  2) Restricting the integer search space for larger plants
parameter
  pMaxNumPlants(G,S)
  ;

* Only compute pMax for non-zero cap_max.
  pMaxNumPlants(G,S)$(pGen(G, 'cap_max', S)) = 
        round((1+%overbuild%)
            *min(
*bound by max capacity 
                floor( pGen(G, 'cap_max',S)/pGen(G, 'gen_size',S) ),
*and use looser of
                max(    
*peak period cap credit
                    ceil(   (pDemandMax(S)
$ifthen set plan_margin
                             * (1 + pPlanReserve) 
$endif
                                )/ (pGen(G, 'gen_size',S) * pGen(G, 'cap_credit',S) )
                        ),
*and average availability vs peak demand
                    ceil(   pDemandMax(S)/ (pGen(G, 'gen_size',S) * min(pGenAvgAvail(G,S), pGen(G, 'derate',S) ) )
                        )
                    )
                )
            );

* Adjust max number of plants for variable renewables (assumed to apply to all renewables)
* By default, assume renewables may compete on their own and supply power for economic reasons
$ifthen.re_lim set renew_lim
$ifthen.lim_type %renew_lim%==avg
* In this case, we limit new capacity to that capable of supplying the peak demand based on the greater of
* capacity factor and average availability
    pMaxNumPlants(G,S)$G_RPS(G) = 
                round((1+%renew_overbuild%)
                    * ceil(   pDemandMax(S)
                                / ( pGen(G, 'gen_size',S) * max(pGen(G, 'cap_credit',S), pGenAvgAvail(G,S)) )
                          )
                );
$elseif.lim_type %renew_lim%==rps
* But if indicated, instead limit renewable expansion to the RPS level (plus renew_overbuild)
    pMaxNumPlants(G,S)$G_RPS(G) = 
        max[0,
                round((1+%renew_overbuild%)
                    * ceil(   pDemandAvg(S)*pRPS(S)
                                / ( pGen(G, 'gen_size',S) * pGenAvgAvail(G,S) )
                          )
                 )
            ];
$elseif.lim_type %renew_lim%==firm
* But if indicated, instead limit renewable expansion to the RPS level (plus renew_overbuild)
    pMaxNumPlants(G,S)$G_RPS(G) = 
        max[0,
                round((1+%renew_overbuild%)
                    * ceil(   (pDemandMax(S)
$ifthen set plan_margin
                             * (1 + pPlanReserve) 
$endif
                                )/ (pGen(G, 'gen_size',S) * pGen(G, 'cap_credit',S) )
                          )
                 )
            ];
$endif.lim_type
$endif.re_lim

*list max plant numbers in *.lst file
display pMaxNumPlants;

*Compute Max new plants by subtracting off existing capacity
 vNumNewPlants.up(G,S)$(pGen(G, 'cap_max',S)) = max[0, pMaxNumPlants(G,S) - floor(pGen(G, 'cap_cur',S)/pGen(G, 'gen_size',S))];
*For units that the current capacity is greater than max, no new plants (prevent negatives)
 vNumNewPlants.fx(G,S)$(pGen(G, 'cap_cur',S)-pGen(G, 'cap_max',S)>=0) = 0;

$ifthen set unit_commit
    vUcInt.up(B_SIM, T, G_UC, S) = pMaxNumPlants(G_UC, S);
$endif

$ifthen not set uc_lp
    vStartInt.up(B_SIM, T, G_UC, S) = pMaxNumPlants(G_UC, S);
    vShutInt.up(B_SIM, T, G_UC, S) = pMaxNumPlants(G_UC, S);
$endif

$ifthen set maint
    vOnMaint.up(B, G, S)$(pGen(G, 'maint_wks', S) > 0) = ceil(%max_maint% * pMaxNumPlants(G, S));
    vMaintBegin.up(B, G, S)$(pGen(G, 'maint_wks', S) > 0) = ceil(%max_maint% * pMaxNumPlants(G, S));
    vMaintEnd.up(B, G, S)$(pGen(G, 'maint_wks', S) > 0) = ceil(%max_maint% * pMaxNumPlants(G, S));
*Fix maintenance at zero if maintenance not required
	vOnMaint.fx(B, G, S)$(pGen(G, 'maint_wks', S) = 0) = 0;
    vMaintBegin.fx(B, G, S)$(pGen(G, 'maint_wks', S) = 0) = 0;
    vMaintEnd.fx(B, G, S)$(pGen(G, 'maint_wks', S) = 0) = 0;
$endif

* ===== Take some initial guesses =====
if (sum(G_RPS,1) > 0) then
    vNewCapacity.l('wind',S) = sum[(B_SIM, T), pDemand(B_SIM, T, 'power',S)*pDemand(B_SIM, T, 'dur',S)]*pRPS(S) - pGen('wind','cap_cur',S);
endif;
* ===== Fix any values we can
$ifthen set fix_cap
    vCapInUse.fx(G,S) = pGen(G,'cap_cur',S);
    vNumNewPlants.fx(G,S) = 0;
    vNewCapacity.fx(G,S) = 0;
$endif

*================================*
*   Additional Data Processing   *
*================================*

* Enable $ variables from included model(s) to propagate back to this master file
$onglobal

* Include water limiting equations and associated parameters and variables
$if set calc_water $include %shared_dir%WaterDataSetup

* Disable influence of $ settings from sub-models
$offglobal

*================================*
*       Solve & Related          *
*================================*
*Only run the rest of this file if we are the main function.
$ifthen.we_are_main %model_name% == StaticCapPlan

* ======  Setup the model
* Skip this definition if we are doing a restart
$ifthen.scp_model not defined StaticCapPlan
    model StaticCapPlan  /all/;

* ======  Adjust Solver parameters
* Enable/Disable Parallel processing
*By default, use only one thread, since this is often faster for small problems
$if not set par_threads $setglobal par_threads 1
*Default to barrier b/c typically faster
$if not set lp_method $setglobal lp_method 4
*Use default probing
$if not set probe $setglobal probe 0

*Create a solver option file
$onecho > cplex.opt
* Note: the number of threads can either be specified explicitly or using "0" for use all cores
threads %par_threads%

*Parallel mode. Options:
* 1=deterministic & repeatable, 0=automatic, -1=opportunistic & non-repeatable 
parallelmode %par_mode%

* Conserve memory when possible... hopefully avoid crashes b/c of memory
memoryemphasis 1

* Declare solution method for pure LP, RMIP, and final MIP solve. 
*   Options: 0=automatic, 2=Dual Simplex, 4=barrier, 6=concurrent (a race between
* dual simplex and barrier in parallel)
*
* Sometimes barrier is notably faster for operations problems, but more often dual simplex wins
* Barrier is often better for planning problems
LPmethod %lp_method%
* Solution method for solving the root MIP node. See description and options for LPmethod above
startalg %lp_method%
* Solution method for solving sub MIP nodes. See description and options for LPmethod above
* For some reason, the default (usually dual simplex) is typically better here. 
*subalg %lp_method%

* Tighten LP tolerance (default 1e-6). For problems with objective values close to 1, this 
* may be necessary to find the true optimal. In particular, with MILP, using the default can 
* cause the final LP solve to stop short of finding the best node from the MILP branch-and-cut
* Surprisingly, a tighter tolerance can also achieve FASTER run times for MILP, presumably
* because the nodes can be compared more carefully.
epopt 1e-9

* Stay with barrier until the optimal solution is found rather than crossing over to simplex
* This can run much faster for these problems, because the final simplex iterations can be 
* slow and b/c the cross-over itself takes a good bit of time. However, the approach is not
* robust and can fail or be slower than the default behavior. Not recommended with barrier 
* alone (LPmethod = 4) b/c may not converge. Consider for concurrent optimization.
*barcrossalg -1

* Ignore small (dual) infeasibilities in the final LP solve. Without this setting, occasionally
* CPLEX will get unhappy with an infeasibility on the order of 1e-6
relaxfixedinfeas 1

* Probing: a technique to more fully examine a MIP problem before starting branch-and-cut. Can
* sometimes dramatically reduce run times. Options: 0=automatic, 1=limited, 2=more, 3=full,
* -1=off.
probe %probe%
* Limit the probe time to 5min, experience shows the default is typically <=1 sec, so this
* Will seldom be a big driver
probetime 300

*enable relative epsilon optimal (cheat) parameter
*This value is not used if cheat is defined
relobjdif %rel_cheat%

$offecho

*Tell GAMS to use this option file
StaticCapPlan.optfile = 1;

* ======  Tune performance with some initial guesses and settings to speed up the solution
$ifthen.prior_set set priority
$ifthen.prior_on not %priority%==off
*Setup branching priorities to prioritize capacity decisions
    StaticCapPlan.prioropt = 1 ;

    vNumNewPlants.prior(G,S) = 1 ;

* And then maintenance decisions
$if set maint          vOnMaint.prior(B, G, S) = 2 ;
$if set maint          vMaintBegin.prior(B, G, S) = 2 ;
$if set maint          vMaintEnd.prior(B, G, S) = 2 ;

$endif.prior_on
$endif.prior_set

*Note: the following endif is for the $ifthen not the $if
$endif.scp_model

* ====== Check command line options
* Check spelling of command line -- options
* Notes:
*  - all command line options have to have either been used already or be listed
* here to avoid an error. We place it here right before the solve statment such that
* if there is an error, we don't wait till post solution to report the problem
$setddlist ignore_integer summary_only summary_and_power_only memo gdx out_gen_params out_gen_avail out_gen_simple debug_off_maint

* ======  Actually solve the model
$ifthen set ignore_integer
     solve %model_name% using RMIP minimizing vObjective;
$else
     solve %model_name% using MIP minimizing vObjective;
$endif

*================================*
*         Postprocessing         *
*================================*

*-- Suppress CSV output if no_csv flag is set
$if "no_csv = 1" $ontext

* ======  Post processing computations
* Most of these calculations are standardized in ../shared/calcSummary.gms
$include %shared_dir%calcSummary.gms

* ======  Write Standard Results to CSV files
$include %shared_dir%writeResults.gms

$if set summary_and_power_only $goto skip_non_summary
*-- [3] Output List of Total installed generation by type
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%tot_cap.csv" "table" pCapTotal(G,S) G S

*-- [4] Output List of New plants by type
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%new_plants.csv" "table" vNumNewPlants.l(G,S) G S

*-- [5] Output List of New capacity by type
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%new_cap.csv" "table" vNewCapacity.l(G,S) G S


$label skip_non_summary
*-- end of output suppression when no_csv flag is set
$if "no_csv = 1" $offtext

$if set gdx execute_unload '%out_dir%%out_prefix%solve.gdx'

* Write value of all control variables to the list file (search for Environment Report)
$show

$endif.we_are_main
