$Title Toy Static Capacity Planning model

$ontext
----------------------------------------------------
  A basic deterministic static electricity generation capacity planning
  model with continuous build decisions.
  
 Command Line Options (defaults shown):
 ======================================
 Data 
  Primary data setup file:
   --sys=test_sys.inc          System parameters include file. This file references all data for a model
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

  Specific Value Overrides (take precedence over all values defined in data files. Use for 
  sensitivity analysis, etc.)
   --co2cost=#            Cost of CO2 in $/m.t. (default: use value from sys)

  Command Line Flags (by default these are not set. Set to any number, including zero, to enable)
   --avg_avail=off        Flag to use the average rather than time dependent availabilities

  Supports:
    - arbitrary number of generation technologies/units with 
        + minimum power for baseload units
        + existing installed capacity, with ability to not fully use
        + maximum installed capacity by unit
    - arbitrary number of demand blocks of varying duration
    - loading of data from include files to allow an unchanging core model. These files can 
       optionally be specified at the command line.
    - heat rates + separate fuel costs for easy scenario analysis
    - carbon intensity
       + imbedded carbon from construction
       + carbon content of fuels
    - internal annualizing of capital costs (requires definition of WACC)

Notes:
    - Use StaticCapPlan for a more complete static model that also supports variable renewables
    
ToDo:
    - rework to make fixed and var cost by gen easier to see
    - planning reserves

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   March 2010

 Version History
###    Date      Time  Who            What
---  ---------- ----- -------------- ---------------------------------
  1  2010-03-25 22:00  bpalmintier    Original Version with 4 blocks & no Hydro
  2  2010-03-30 21:25  bpalmintier     - Moved data to include files
                                      - Expanded comments & renamed variables
  3  2010-03-30 22:30  bpalmintier    Corrected error in ePwrMin
  4  2010-04-08 14:00  bpalmintier    Added Command line definition of include files
  5  2010-04-08 22:00  bpalmintier    Added Heat Rate and Fuels
  6  2010-04-09 01:30  bpalmintier    Added CO2 Costs, annualized capital, command line co2cost
  7  2010-05-19 19:15  bpalmintier    Quoted comments to allow use of / in  units
  8  2010-09-06 23:45  bpalmintier    - Made include paths platform independent
                                      - Moved data includes to ../data directory
  9  2010-09-07  20:23 bpalmintier    Separated pGenAvail for time varying availability
                                      Converted to more traditional availability/cap factor derating
 10  2010-09-07  23:00  bpalmintier   Added flag to use averages for availability
 11  2010-09-07  22:30  bpalmintier   Converted to single sys.inc with subincludes. Updated comments
 12  2011-07-07  21:45  bpalmintier   Updated for separate avail file to match StaticCapPlan
 13  2011-11-07  15:25  bpalmintier   Updated to use test_sys.inc
 14  2012-09-02  17:08  bpalmintier   Replace all $set with $setglobal (to prevent scope errors)
----------------------------------------------------- 
$offtext

* ----- GAMS Options
* Allow declaration of empty sets & variables
$onempty 
* Allow additions to set elements with multiple set definitions
$onmulti
* Support end of line comments using #
$oneolcom
$eolcom #
*display $dollar commands in lst file (for easier pre-compiler debugging)
$ondollar 

* ----- Platform Specific Adjustments
* Setup the file separator to use for relative pathnames 
$iftheni %system.filesys% == DOS $setglobal filesep "\"
$elseifi %system.filesys% == MS95 $setglobal filesep "\"
$elseifi %system.filesys% == MSNT $setglobal filesep "\"
$else $setglobal filesep "/"
$endif

* ----- Set data and output directories
* By default look for data in the sibling directory "data"
$if NOT set data_dir    $setglobal data_dir ..%filesep%data%filesep%   

* By default store output in the sub-directory "out"
$if NOT set out_dir    $setglobal out_dir out%filesep%   

* ----- Declare all sets so can use in equations
* Note: be sure to quote descriptions with "/" can not be used in a sets description.

sets
* Sets for table parameters
         DEM_PARAMS  demand block table parameters from load duration curve
               /dur         "duration of block                 [hrs]"
                power       "average power demand during block [GW]"
               /
               
         GEN_PARAMS  generation table parameters
               /c_var_om    "variable O&M cost                           [$/MWh]"
                c_fix_om    "fixed O&M cost                              [M$/GW-yr]"
                c_cap       "total capital cost                          [$/GW]"
                life        "economic lifetime for unit                  [yr]"
                heatrate    "heatrate for generator (inverse efficiency) [kBTU/MW]"
                fuel        "name of fuel used                           [name]"
                cap_cur     "Current installed capacity for generation   [GW]"
                cap_max     "Maximum installed capacity for generation   [GW]"
                co2_embed   "CO2_eq emissions from plant construction    [t per MW]"
                co2_ccs     "Fraction of carbon capture & sequestration  [fraction]"
                p_min       "minimum power output (for baseload)         [fraction]"
               /
               
         FUEL_PARAMS fuel table parameters
               /name        "The name as a string (acronym) for comparison  [name]"
                cost        "Unit fuel cost                                 [$/kBTU]"
                co2         "Carbon Dioxide (eq) emitted                    [t/kBTU]"
               /
               
* Sets for data, actual definitions can be found in include files
         D           "demand levels"
         G           "generation types (or generator list)"
         F           "fuel types"

* Sets for mapping between other sets
         GEN_FUEL_MAP(G, F)     "map for generator fuel types"

* ----- Declare the data parameters. Actual data imported from include files
parameters
* Data Tables
         pDemandData(D, DEM_PARAMS)   "table of demand data"
         pGenData   (G, GEN_PARAMS)   "table of generator data"
         pGenAvail  (D, G)            "table of time dependent generator availability"
         pFuelData  (F, FUEL_PARAMS)  "table of fuel data"
* Additional Parameters
		 pGenAvgAvail (G)               "average availability (max capacity factor)"
         pCRF         (G)               "capital recovery factors     [/yr]"

scalars
   pWACC             "weighted average cost of capital (utility investment discount rate) [fract]"
   pCostCO2          "cost of carbon (in terms of CO2)        [$/t-CO2eq]"
         
* ----- Declare Variables
variables
   vTotalCost                "total system cost in target year             [M$]"
   vFixedOMCost              "fixed O&M costs in target year               [M$]"
   vVariableOMCost           "variable O&M costs in target year            [M$]"
   vFuelCost                 "total fuel costs in target year              [M$]"
   vCapitalCost              "annualized capital costs of new capacity     [M$]"
   vCarbonCost               "carbon from operations + fraction embedded   [M$]"

positive variables
   vFuelUse  (F)      "fuel usage by type                  [MBTU]"
   vPwrOut   (D, G)   "production of the unit                [GW]"
   vCapacity (   G)   "total installed capacity that is used [GW]"
   vNewCapacity( G)   "new capacity cnostructed              [GW]"
   vCapSlack (   G)   "slack variable to prevent neg net new generation"
   ;

* ----- Declare Equations
equations
   eTotalCost       "total system cost for one year of operation  [M$]"
   eFixedOMCost     "system fixed O&Mcosts for one year           [M$]"
   eVarOMCost       "system variable O&M costs for one year       [M$]"
   eFuelCost        "system fuel costs for one year               [M$]"
   eCapitalCost     "annualized capital cost of new capacity      [M$]"
   eCarbonCost      "cost of carbon: ops + embedded               [M$]"

   eFuelUse         "fuel usage by type                         [MBTU]"
   eNewCapacity     "prevent negative net new capacities w slack variable."

   eInstCap  (   G)  "installed capacity                    [GW]"
   ePwrMax   (D, G)  "output lower than installed max       [GW]"
   ePwrMin   (D, G)  "output greater than installed min     [GW]"
   eDemand   (D   )  "output must equal demand              [GW]"
   eCapFactor(D, G)  "power generation less than cap factor [GW]"
   ;

* ----- The actual Model
*--objective function and components
eTotalCost    .. vTotalCost =e=  vFixedOMCost + vVariableOMCost + vFuelCost + vCapitalCost + vCarbonCost;

eFixedOMCost  .. vFixedOMCost*1e6 =e= sum[(  G), pGenData(G,'c_fix_om')*vCapacity(G)];

eVarOMCost    .. vVariableOMCost*1e6 =e= sum[(D, G), pGenData(G,'c_var_om')*vPwrOut(D,G)*pDemandData(D, 'dur')];

eFuelCost     .. vFuelCost*1e6 =e= sum[(F), pFuelData(F,'cost')*vFuelUse(F)];

*capital cost = new capacity*annualized cost of capital using capital recovery factor
eCapitalCost  .. vCapitalCost*1e6 =e= sum[(G), pCRF(G)*vNewCapacity(G)*pGenData(G,'c_cap')];

*carbon cost =  carbon price * (fuel use - ccs * carbon intensity + embedded carbon * new capacity) 
eCarbonCost   .. vCarbonCost*1e6 =e= pCostCO2 * (sum[(G), vNewCapacity(G)*pGenData(G,'co2_embed')]
                                                  + sum[(D,GEN_FUEL_MAP(G,F)), pGenData(G,'heatrate')*vPwrOut(D,G)*pDemandData(D, 'dur')
                                                          *pFuelData(F,'co2')*(1-pGenData(G,'co2_ccs'))]);

*--intermediate calculations
eFuelUse(F)      .. vFuelUse(F) =e= sum[(D,GEN_FUEL_MAP(G,F)), pGenData(G,'heatrate')*vPwrOut(D,G)*pDemandData(D, 'dur')];

*introduce a slack variable so we don't pay for negative net capacities when vCapacity < current capacity
eNewCapacity(G)  .. vNewCapacity(G) =e= vCapacity(G)-pGenData(G,'cap_cur') + vCapSlack(G);

*--basic contraints
eInstCap(G)    .. vCapacity(G) =l= pGenData(G,'cap_max');
ePwrMax (D, G) .. vPwrOut(D, G) =l= vCapacity(G);
eDemand (D)    .. sum[(G), vPwrOut(D, G)] =e= pDemandData(D,'power');

*--additional constraints
* minimum output: typically only used for baseload plants
*    ignore by using p_min=0 or not defining p_min (unspecified parameters default to zero)
ePwrMin (D, G) .. vPwrOut(D, G) =g= pGenData(G,'p_min')*vCapacity(G);

* capacity factor: ensure that we are operating the plants within availability limits. 
eCapFactor(D, G)  .. vPwrOut(D, G) =l= pGenAvail(D, G)*vCapacity(G);

* ====== Include Data files
* By default use test_sys.inc if not not passed at the command line
$if NOT set sys    $setglobal sys    test_sys.inc
*Setup default generator availability filename

* Actually do include the system data definition file
$include %data_dir%%sys%

$if set fuel   $include %data_dir%%fuel%
$if set demand $include %data_dir%%demand%
* Note: include demand before gens, so can use the demand levels for time varying availabiilty
$if set gens   $include %data_dir%%gens%
$if set avail  $include %data_dir%%avail%

* Read availability tables
$ondelim
* Note: assumes the set of demand time periods have already been established
table    pGenAvail(D, G) "Generator availability Table"
$include %data_dir%%avail%
;
* Return to normal GAMS space delimited data formats
$offdelim

* ----- Calculate parameters & subsets
*Compute average availability for each generator
pGenAvgAvail(G) = sum[(D), pGenAvail(D, G)*pDemandData(D, 'dur')] / sum[(D), pDemandData(D, 'dur')];

*Convert to average availabilities if desired
$ifthen set avg_avail
    pGenAvail(D,G) = pGenAvgAvail(G);
$endif

*override CO2 price with command line setting if provided
$if set co2cost pCostCO2=%co2cost%;

*only include elements where the generator fuel name parameter matches the fuel name parameter
GEN_FUEL_MAP(G, F)$(pGenData(g,'fuel') = pFuelData(f,'name')) = yes;

pCRF(G) = pWACC/(1-1/( (1 + pWACC)**pGenData(G,'life') ));

* ----- Run the model
model ToyCapPlan  /all/
solve ToyCapPlan using LP minimizing vTotalCost;

* ----- Display the results
* display command writes to the end of the *.lst file
display vPwrOut.l
display vCapacity.l
