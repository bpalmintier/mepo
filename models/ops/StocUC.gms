
$ontext
----------------------------------------------------
 Stochastic Unit Commitment model
----------------------------------------------------
  Highly Configurable STOCHASTIC Electric power system operations model


  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   March 2012

 Version History
 Ver   Date       Time  Who           What
 --- ----------  -----  ------------- ---------------------------------
   1 2012-03-12  11:15  bpalmintier   Adapted from StocCapPlan v2
   2 2012-05-02  12:40  bpalmintier   Separate demand (D) into blocks (B) and time sub-periods (T)
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
$Title "Stochastic Flexible Unit Commitment model"

*If so set it
$setglobal model_name StocUC

* == And we want to idenfify whether or not we are using a mixed integer solution
$ifthen.mip set ignore_integer
$setglobal use_mip no
$else.mip
$setglobal use_mip yes
$endif.mip

*In this case, we also know the capacity is fixed so skip all of the capacity expansion terms
$setglobal fix_cap
*And we want to default to using unit-commitment
$if not set unit_commit $setglobal unit_commit on

$endif.we_are_main

* == Default to main UnitCommit operations sub model
$if not set ops_model $setglobal ops_model UnitCommit

* == Setup short hand alias for total capacity to use as a control variable
$ifthen set fix_cap
$setglobal capacity_G pGen(G,'cap_cur', S) 
$else
$setglobal capacity_G vCapInUse(G, S) 
$endif

* Setup output prefix
$if NOT set out_prefix $setglobal out_prefix StocUC_

* ======  Handle some initial command line parameters

*================================*
*         Declarations           *
*================================*

* ====== Bypass Declarations & Model if doing a restart
$if defined StocUC $goto skip_redef


* ======  Declare all sets so can use in equations
* Note: be sure to quote descriptions otherwise "/" can not be used in a description.

sets
* Sets for data, actual definitions can be found in include files
    G           "DUPLICATE generation types (or generator list)"
    B           "Demand blocks (e.g. weeks or ldc)"
	T			"Demand time sub-periods (e.g. hours or ldc sub-blocks)"
    B_SIM(B)    "demand blocks used in simulation"
    S           "DUPLICATE scenarios for multi-period and stochastic problems"
    
* ======  Declare the data parameters. Actual data imported from include files
parameters
    pScenWeight(S)     "Scenario weighting for cost calcs. Use for probability or time discounting"

* ======  Declare Variables
variables
   vObjective  "Objective: scenario weighted average (EV or discounted ops cost)  [M$]"
   vTotalCost      (S)          "total system cost for scenario               [M$]"
   vOpsCost        (S)          "DUPLICATE system operations cost in target year        [M$]"

positive variables
   vUnitCommit(B,T, G, S)  "DUPLICATE number of units of each gen type on-line during period     [continuous]"

* ======  Declare Equations
equations
$ifthen %model_name% == StocUC
   eObjective  "Objective function: scenario weighted average (EV or discounted ops cost)  [M$]"
   eTotalCost  (S)     "total cost = ops                             [M$]"
$endif
    eSameCommitAcrossScen(B,T, G, S)   "Force the same unit commitment across all scenarios"
    ;

*================================*
*  Additional Model Formulation  *
*================================*
* Note: this must be included between declarations & equations so that the included file 
* has access to our declarations, and any objective function additions can be used.

* Enable $ variables from included model(s) to propagate back to this master file
$onglobal

* Include the core UnitCommitment operations model, which greatly expands the parameter, variable, and equation set
$include %ops_model%

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
$ifthen.we_are_main   %model_name% == StocUC
$if not set obj_var $setglobal obj_var vOpsCost

eObjective  ..  vObjective =e= sum[(S), pScenWeight(S) * %obj_var%(S)];

* Allows uniform use of total cost for both operations and planning models
eTotalCost (S)  ..  vTotalCost (S) =e= vOpsCost (S);

$endif.we_are_main

*======  Additional Constraints
*Note have to skip the first scenario or all new capacity will be forced to zero
    eSameCommitAcrossScen(B,T,G,S)$( ord(S)>1
                                   and B_SIM(B) )   
                .. vUnitCommit(B,T, G, S) =e= vUnitCommit(B,T, G, S-1);

*Skip ahead to here on restart
$label skip_redef
*================================*
*        Handle The Data         *
*================================*

* Data read in handled by StaticCapPlan

* == Compute max integers for unit_commitment states
*Note: by default GAMS restricts to the range 0 to 100 so this provides two features:
*  1) allowing for higher integer numbers for small plant types as required for a valid solution
*  2) Restricting the integer search space for larger plants
*Important: For capacity expansion problems, this parameter MUST be changed to account for new plants

$ifthen.max_plants %model_name% == StocUC

*Here we simply use the current capacity divided by the plant size.
  pMaxNumPlants(G, S)$pGen(G, 'gen_size', S) = ceil(pGen(G, 'cap_cur', S)/pGen(G, 'gen_size', S));

$ifthen set unit_commit
    vUcInt.up(B_SIM, T, G_UC, S) = pMaxNumPlants(G_UC, S);
$endif

$endif.max_plants

*================================*
*       Solve & Related          *
*================================*
*Only run the rest of this file if we are the main function.
$ifthen.we_are_main %model_name% == StocUC

* ======  Setup the model
* Skip this definition if we are doing a restart
    model %model_name%  /all/;

* ======  Adjust Solver parameters
* Enable/Disable Parallel processing
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
* subalg %lp_method%

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
%model_name%.optfile = 1;

* ======  Tune performance with some initial guesses and settings to speed up the solution
$if set cheat %model_name%.cheat = %cheat%;


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

* ======  Post processing computations
* Most of these calculations are standardized in ../shared/calcSummary.gms
$include %shared_dir%calcSummary.gms

* ======  Write Standard Results to CSV files
*-- Suppress CSV output if no_csv flag is set
$if "no_csv = 1" $ontext
$include %shared_dir%writeResults.gms

*-- end of output suppression when no_csv flag is set
$if "no_csv = 1" $offtext


$if set gdx execute_unload '%out_dir%%out_prefix%solve.gdx'

* Write value of all control variables to the list file (search for Environment Report)
$show

$endif.we_are_main
