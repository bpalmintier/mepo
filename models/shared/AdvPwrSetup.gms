
*skip if already setup (to allow including one model from another)
$if set setup_complete $goto label_skip_setup

$ontext
----------------------------------------------------
  Unified setup file for Advanced Power Family of Models.
  
Includes common setup definitions for:
  -- Platform specific path adjustments
  -- GAMS options including support for set redefinition and limits to list output display
  -- Debug settings for expanded list file information
  -- Standardized AdvPower directories
  

Command Line Parameters Implemented Here:
  Model Setup Flags (by default these are not set. Set to any number, including zero, to enable)
   --no_loop=(off)       Do not loop around demand periods for inter-period constraints
                          such as ramping, min_up_down. (default= assume looping)
  Solver Options
   --debug=(off)           Print out extra material in the *.lst file (timing, variables, 
                            equations, etc)
   --max_solve_time=10800  Maximum number of seconds to let the solver run. (Default = 3hrs)
   --mip_gap=0.001         Max MIP gap to treat as valid solution (Default = 0.1%)
   --par_threads=2         Number of parallel threads to use. Specify 0 to use one thread per
                             core (Default = use 2 cores)

  File Locations (Note, on Windows & DOS, \'s are used for defaults)
   --data_dir=../data/     Relative path to data file includes
   --out_dir=out/          Relative path to output csv files
   --util_dir=../util/     Relative path to csv printing and other utilities

  Output Control Flags (by default these are not set. Set to any number, including zero, to enable)
   --no_csv=(off)         Flag to suppress creation of csv output files (default: create csv output)


Additional control variables:

Note: Many of these settings and compile variables need to propagate up
to the caller. Be sure to set $onglobal before $including this file 
(optionally you can use $offglobal afterwards)
	
  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   September 2011

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-09-21  17:05  bpalmintier   Extracted from StaticCapPlan v62
  2  2011-09-23  15:55  bpalmintier   Moved platform specific filesep & shared_dir definition (required by caller)
  3  2011-09-23  16:05  bpalmintier   Converted to $setglobal so our changes propagate to caller
  4  2011-09-23  19:55  bpalmintier   Relaxed default MIP gap to 0.1%
  5  2012-01-26  15:45  bpalmintier   Use alternate loop/control structure syntax
  6  2012-01-30  12:25  bpalmintier   Added par_mode and rel_cheat
-----------------------------------------------------
$offtext

*================================*
*             Setup              *
*================================*

* ======  GAMS Options
*display $dollar commands in lst file (for easier pre-compiler debugging)
$ondollar
* Allow declaration of empty sets & variables
$onempty
* Allow additions to set elements with multiple set definitions
$onmulti
* Include symbol list in LST file
$onsymlist
*Enable alternate loop syntax using end* rather than ()'s
$onend


*get a more precise MIP solution  (optcr is relative convergence). GAMS default is only 10%
$if not set mip_gap $setglobal mip_gap 0.001
option optcr=%mip_gap%

*Allow for extra execution time. units are seconds of execution (needed to extend the GAMS default
* of only 1000 to successfully solve larger problems)
$if not set max_solve_time $setglobal max_solve_time 10800
option reslim = %max_solve_time%;

*Default to not using a relative cheat parameter
$if NOT set rel_cheat $setglobal rel_cheat 0

*Default to deterministic parallel mode
$if NOT set par_mode $setglobal par_mode 1

* Reduce the size of the LST file
* Turn off equation listing, (unless debug on) see below
* Note: limrow specifies the number of cases for each equation type that are included in the output
option limrow = 0;

* Turn off variable listing, (unless debug on) see below
* Note: limrow specifies the number of cases for each equation type that are included in the output
option limcol = 0;

*=== Solution Output options
* Enable csv output by default
$if NOT set no_csv $setglobal no_csv 0

* Turn off solution printing unless csv output is disabled
$ifthen %no_csv% == 1
    option solprint = on ;
$else
    option Solprint = off ;
$endif

*=== Debug options
*enable additional debugging information
$ifthen set debug
* include 10 example equation of each type
    option limrow = 10;
* inlude 10 example variables of each type
    option limcol = 10;
* Include solver output information
    option sysout = on;
* Print the solution (seems to happen even if turned off 11/2010 -BSP)
    option solprint = on;
* Include symbol cross-reference in LST file
$onsymxref
* Include summary execution times to identify slow assignments, etc.
    option profile = 1;
* Limit profile statements to those that take longer than 10msec
    option profiletol = 0.01;
$endif

* ======  Setup directories
* By default look for data in the sibling directory "data"
$if NOT set data_dir    $setglobal data_dir ..%filesep%data%filesep%

* By default store output in the sub-directory "out"
$if NOT set out_dir    $setglobal out_dir out%filesep%

* By default look for utilities in sibling directory "util"
$if NOT set util_dir   $setglobal util_dir ..%filesep%util%filesep%

* ======  Define Macros
* mDemShift, this is a general replacement for the set - and -- operators that allows
* the user to control whether or inter-demand period constraints loop"
$ifthen not set no_loop
$macro mDemShift(d_set, shift) d_set -- shift
$else
$macro mDemShift(d_set, shift) d_set - shift
$endif

* mDelFile, Delete an operating system file (quietly)
* Choose appropriate system delete function using filesep as a proxy for Unix-like vs Windows
* Note that both forms, quietly ignore any missing files
$ifthen %filesep% == "/"
$macro mDelFile(fname) execute "=rm -f &&fname"
$else
$macro mDelFile(fname) execute "=if exist &&fname del &&fname"
$endif

$setglobal setup_complete
$label label_skip_setup