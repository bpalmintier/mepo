$Title Demo Static Capacity Planning model

$ontext
----------------------------------------------------
  A very basic deterministic static electricity generation capacity planning model with continuous build decisions.

  Supports:
    - arbitrary number of generation technologies/units with
        + maximum installed capacity by unit
    - arbitrary number of demand blocks of varying duration

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   March 2010

Ver   Date      Time  Who            What
---  ---------- ----- -------------- ---------------------------------
  1  2010-03-25 22:00  bpalmintier    Original Version with 4 blocks & no Hydro
  2  2010-03-30 21:25  bpalmintier     - Moved data to include files
                                       - Expanded comments & renamed variables
  3  2010-03-30 22:30  bpalmintier    Corrected error in ePwrMin
  4  2010-04-09 14:00  bpalmintier    Merged into single file for Demo
  5  2010-04-09 16:15  bpalmintier    Removed min & CF
-----------------------------------------------------
$offtext

* ----- GAMS Options
* Allow declaration of empty sets & variables
$onempty
* Allow additions to set elements with multiple set definitions
$onmulti


* ----- Declare all sets so can use in equations
sets
* Sets for table parameters
         DEM_PARAMS  demand block parameters from load duration curve
               /dur, power/
         GEN_PARAMS  generation parameters
               /c_var, c_fix, max_cap/

* Sets for data, actual definitions can be found in include files
         D           demand levels
         G           generation

* ----- Declare the data parameters. Actual data defined below
parameters
         pDemandData(D, DEM_PARAMS) table of demand data
         pGenData   (G, GEN_PARAMS) table of generator data

* ----- Declare Variables
variables
   vTotalCost                total system cost in target year   [M$]
   vAnnualizedFixedCost      annualized fixed [cap + fixed O&M] [M$]
   vVariableOpCost           variable O&M [fuel etc]            [M$]

positive variables
   vPwrOut   (D, G)   production of the unit                [GW]
   vCapacity (   G)   total installed capacity that is used [GW]
   ;

* ----- Declare Equations
equations
   eTotalCost       total system cost                  [M$]

   eFixedCost       system fixed costs [annualized]    [M$]
   eVarCost         system variable costs for one year [M$]

   eInstCap  (   G)  installed capacity                    [GW]
   ePwrMax   (D, G)  output lower than installed max       [GW]
   eDemand   (D)     output must equal demand              [GW]
   ;

* ----- The actual Model
eTotalCost    .. vTotalCost =e=  vAnnualizedFixedCost + vVariableOpCost;
eFixedCost    .. vAnnualizedFixedCost =e= sum[(G  ), pGenData(G,'c_fix')*vCapacity(G)];
eVarCost      .. vVariableOpCost*1e3 =e= sum[(G,D),
                    pGenData(G,'c_var')*vPwrOut(D,G)*pDemandData(D, 'dur')];

eInstCap(G)    .. vCapacity(G) =l= pGenData(G,'max_cap');
ePwrMax (D, G) .. vPwrOut(D, G) =l= vCapacity(G);
eDemand (D)    .. sum[(G), vPwrOut(D, G)] =e= pDemandData(D,'power');

* ----- Define Data
* -- Generator data
*
*  Sample generation data, loosely based on:
*
*  Royal Academy of Engineering. (2004). The cost of generating electricity.
*  London: Royal Academy of Engineering.
*
*  with some adjustments based on:
*    DoE Annual Energy Outlook, 2010
* --

* Define the list of generators
set
         G           generation
               /Nuke, CCGT, CT/

* And the parameters for these generators
table    pGenData(G, GEN_PARAMS)   Generation Data Table
               c_var      c_fix    max_cap
*            [$/MWh]   [M$/GW-yr]     [GW]
Nuke              17       92         Inf
CCGT              33       36         Inf
CT                48       32.5       Inf
;

* -- Demand data
*
*  Sample 3 level demand data based on ERCOT 2009 loads
* --

* Declare the actual set members (blocks, hours, etc)
set
  D   demand blocks
               /peak, shoulder, low/

* The actual demand data table:
* Note durations for non-peak shifted by 1 hour to ensure
* intermediate generation actually gets built
table    pDemandData(D, DEM_PARAMS)   Demand data
                dur     power
*              [hr]      [GW]
peak            233     63.491
shoulder       3266     54.135
low            5261     36.028
;


* ----- Run the model
model DemoCapPlan  /all/
solve DemoCapPlan using LP minimizing vTotalCost;

* ----- Display the results
* display command writes to the end of the *.lst file
display vPwrOut.l
display vCapacity.l
