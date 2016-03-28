
$ontext
----------------------------------------------------
 Stochastic (Static) Capacity Planning model
----------------------------------------------------
  A stochastic static (aka single period) electricity generation capacity planning
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
   --separate_rsrv=(off)  Enable complete separate operating reserves constraints for every time
                          period. This includes Reg Up, Reg Down, Spin Up, & Quick Start
   --flex_rsrv=(off)      Enbable combined operating reserve constraints: Flex Up and Flex Down
   --no_nse=(off)         Don't allow non-served energy
   --force_renewables=(off) Force all renewable output to be used. This is only feasible until
                           the point where load and op_reserves dictate a max. (until we add storage).
                           When used with cap_fix, it is a bit more widely useful b/c we can limit
                           output to the level of demand. (this is NLP when capacity is a decision)
   --fix_cap=(off)        Fix capacity to cap_cur by not allowing additions or retirements
   --max_start=(off)      Enforce maximum number of startups   (default: ignore)
   --force_gen_size=(off) Force all plant sizes to equal the specified value (in MW)
   --min_gen_size=(off) Force small plant sizes to be larger than specified value (in MW)
   --derate=(off)         Use simple derating of power output, typically for non-reserves
   --from_scratch=(off)   Zero out existing capacity and build new system from scratch
   --basic_pmin=(off)     Enforce non-UC based minimum output levels for each generator type. 
                          This can be useful for baseload plants with simple (non-UC) operations.
   --no_capital=(off)     Ignore capital costs, used for operations models to only compute non
                           capital costs. Not recommended for planning models. [default: include 
                           capital costs]
   --plan_margin=(off)    Enforce the planning margin

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
    --mip_gap=0.0002        max MIP gap to treat as valid solution
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
        ** Separate out Availability into separate include file & clean up gen include files
    * Option for simpler reserves: group up & spin, remove down & put quick into planning
    * Decouple ops into blocks for faster UC?
    * Add hydro
    * Add stochasticity
    * include option settings in summary
    - quadratic or affine (linear+offset) heat rate curves for different plants in group
    - replace put2csv with rutherford's equivalent?
    - cleanup output file names
    - add min up/down times
    - compute fixed and var cost by gen
    - compute required market based incentives to achieve same results
    - expand in-line comments for equations
    - automatic scaling of demand blocks based on year, baseline, & growth rate
    - setup solution in a loop with initial start to allow saving of intermediate solutions?
    ? initial guess for some integer constraints

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   March 2010

 Version History
 Ver   Date       Time  Who           What
 --- ----------  -----  ------------- ---------------------------------
   1 2012-01-28  02:45  bpalmintier   Original version adapted from StaticCapPlan v70
   2 2012-02-03  15:55  bpalmintier   Updated solver options and units (scaling) notes
   3 2012-09-02  17:08  bpalmintier   Replace all $set with $setglobal (to prevent scope errors)
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
$Title "Stochastic Capacity Planning model"

*If so set it
$setglobal model_name StocCapPlan

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
$if NOT set out_prefix $setglobal out_prefix StocCP_

* ======  Handle some initial command line parameters

*================================*
*         Declarations           *
*================================*

* ====== Bypass Declarations & Model if doing a restart
$if defined StocCapPlan $goto skip_redef


* ======  Declare all sets so can use in equations
* Note: be sure to quote descriptions otherwise "/" can not be used in a description.

sets
* Sets for data, actual definitions can be found in include files
    G           "generation types (or generator list)"
    S           "scenarios for multi-period and stochastic problems"
    
* Allow use of S set in two different capacities within the same equation
    alias(S, SS)

* ======  Declare the data parameters. Actual data imported from include files
parameters
    pScenWeight(S)     "Scenario weighting for cost calcs. Use for probability or time discounting"

* ======  Declare Variables
variables
   vObjective  "Objective: scenario weighted average (EV or discounted ops cost)  [M$]"
   vTotalCost      (S)          "total system cost for scenario               [M$]"
   vOpsCost        (S)          "system operations cost in target year        [M$]"
   vCapitalCost    (S)          "annualized capital costs of new capacity     [M$]"

positive variables
   vNewCapacity(G, S)   "new capacity constructed              [GW]"

* ======  Declare Equations
equations
$ifthen %model_name% == StocCapPlan
   eObjective  "Objective function: scenario weighted average (EV or discounted ops cost)  [M$]"
   eTotalCost  (S)     "total cost = ops + capital cos            [M$]"
$endif

    eSameCapAcrossScen(G, S)   "Force the same capacity across all scenarios"

*================================*
*  Additional Model Formulation  *
*================================*
* Note: this must be included between declarations & equations so that the included file 
* has access to our declarations, and any objective function additions can be used.

* Enable $ variables from included model(s) to propagate back to this master file
$onglobal

* Include the basic StaticCapPlan model, which greatly expands the parameter, variable, and equation set
$include StaticCapPlan

* Disable influence of $ settings from sub-models
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
$ifthen.we_are_main   %model_name% == StocCapPlan
$if not set obj_var $setglobal obj_var vTotalCost

eObjective  ..  vObjective =e= sum[(S), pScenWeight(S) * %obj_var%(S)];

* Allows uniform use of total cost for both operations and planning models
eTotalCost (S)  ..  vTotalCost (S) =e= vOpsCost (S) + vCapitalCost (S);

$endif.we_are_main

*======  Additional Constraints
*Note have to skip the first scenario or all new capacity will be forced to zero
    eSameCapAcrossScen(G,S)$(ord(S)>1)   .. vNewCapacity( G, S) =e= vNewCapacity( G, S-1);

*Skip ahead to here on restart
$label skip_redef
*================================*
*        Handle The Data         *
*================================*

* Data read in handled by StaticCapPlan

*================================*
*       Solve & Related          *
*================================*
*Only run the rest of this file if we are the main function.
$ifthen.we_are_main %model_name% == StocCapPlan

* ======  Setup the model
* Skip this definition if we are doing a restart
$ifthen not defined StocCapPlan
    model StocCapPlan  /all/;

* ======  Adjust Solver parameters
* Enable/Disable Parallel processing
*By default, use only one thread, since this is often faster for small problems
$if not set par_threads $setglobal par_threads 1
$if not set lp_method $setglobal lp_method 4

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
subalg %lp_method%

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

*enable relative epsilon optimal (cheat) parameter
*This value is not used if cheat is defined
relobjdif %rel_cheat%

$offecho

*Tell GAMS to use this option file
StocCapPlan.optfile = 1;

* ======  Tune performance with some initial guesses and settings to speed up the solution

*Setup branching priorities to prioritize capacity decisions
    StocCapPlan.prioropt = 1 ;
$if not set fix_cap    vNumNewPlants.prior(G,S) = 1 ;
$if set maint          vOnMaint.prior(B, G, S) = 2 ;
*Note: the following endif is for the $ifthen not the $if
$endif

* ====== Check command line options
* Check spelling of command line -- options
* Notes:
*  - all command line options have to have either been used already or be listed
* here to avoid an error. We place it here right before the solve statment such that
* if there is an error, we don't wait till post solution to report the problem
$setddlist ignore_integer summary_only summary_and_power_only memo gdx out_gen_params out_gen_avail out_gen_simple

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
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%out_installed_cap.csv" "table" pCapTotal(G,S) G S

*-- [4] Output List of New plants by type
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%out_new_plants.csv" "table" vNumNewPlants.l(G,S) G S

*-- [5] Output List of New capacity by type
$batinclude %util_dir%put2csv "%out_dir%%out_prefix%out_new_cap.csv" "table" vNewCapacity.l(G,S) G S


$label skip_non_summary
*-- end of output suppression when no_csv flag is set
$if "no_csv = 1" $offtext

$if set gdx execute_unload '%out_dir%%out_prefix%solve.gdx'

* Write value of all control variables to the list file (search for Environment Report)
$show

$endif.we_are_main
