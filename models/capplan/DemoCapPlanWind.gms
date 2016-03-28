$Title "Demo Static Capacity Planning model with Wind in a single file"

$ontext
----------------------------------------------------
  A very basic deterministic static electricity generation capacity planning model with continuous build decisions & added support for wind.
  
  This model is contained in a single standalone file and can run in the free trial version of GAMS.
  
  Based on theoretic work by Ignacio Perez-Arriaga, Bryan Palmintier, Yuan Yao, and James Merrick
  
  Supports:
    - arbitrary number of generation technologies/units with 
        + maximum installed capacity by unit
        + availability factors (separate from capacity credit, see below)
    - features designed explicitly for proper wind support:
        + RPS (minimum wind energy penetration %)
        + Non-unity capacity credits (how much does each generator help the peak?)
    - arbitrary number of demand blocks of varying duration
    - carbon constraint (carbon cap)
    - carbon tax
  ToDo:
    - compute required market based incentives to achieve same results
    - display results to screen
    
  Wind Notes:
    - In this very simple model, wind production is modelled as a uniform expected value, using
      availability as the average % of nameplate wind power production for all time periods

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   April 2010

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2010-04-14  18:00  bpalmintier    Adapted from DemoCapPlan v5 to add Wind by:
                                        - adding availability factors
                                        - adding RPS & constraint
                                        - adding reserve margin & constraint
  2  2010-04-15  21:30  bpalmintier    Added CO2 as constraint & updated capital costs using CRF
  3  2010-04-16   7:03  bpalmintier    Converted to 21 level LDC
  4  2010-05-20  23:25  bpalmintier    Added carbon cost & csv output, cleaned up comments
  5  2012-02-01  23:45  bpalmintier    Adjusted scaling to match other models
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


* ----- Declare all sets so can use in equations
sets
* Sets for table parameters
         DEM_PARAMS  demand block parameters from load duration curve
               /dur, power/
         GEN_PARAMS  generation parameters
               /c_var, c_fix, max_cap, avail, cap_credit, co2/
               
* Sets for data, actual definitions can be found in include files.
*  Note: must define Wind here for formulas, but can extend set in future calls
         D           demand levels
         G           generation
               /Wind/

* ----- Declare the data parameters. Actual data defined below
parameters
         pDemandData(D, DEM_PARAMS) "table of demand data"
         pGenData   (G, GEN_PARAMS) "table of generator data"
         
         pRPS                       "fraction of energy from wind [fract]"
         pPlanReserve               "planning reserve             [fract]"
         pCarbonCap                 "max annual CO2 emissions     [mt CO2e]"
         pCarbonCost                "carbon cost/tax              [$/mt CO2e]"

* ----- Declare Variables
variables
   vTotalCost                "total system cost in target year   [M$]"
   vAnnualizedFixedCost      "annualized fixed [cap + fixed O&M] [M$]"
   vVariableOpCost           "variable O&M [fuel etc]            [M$]"
   vCarbonCost               "total system wide carbon cost      [M$]"

positive variables
   vPwrOut   (D, G)   "actual production of the generator    [GW]"
   vCapacity (   G)   "total installed capacity that is used [GW]"
   ;

* ----- Declare Equations
equations
   eTotalCost       "total system cost                  [M$]"
   eFixedCost       "system fixed costs [annualized]    [M$]"
   eVarCost         "system non-carbon variable costs for one year [M$]"
   eCarbonCost      "system carbon costs for one year [M$]"

   eRPS             "energy percent from wind"
   ePlanMargin      "ensure adequate capacity"
   eCarbonCap       "limit total emissions"
   
   eInstCap  (   G)  "installed capacity below limits                [GW]"
   ePwrMax   (D, G)  "output lower than derated installed max        [GW]"
   eDemand   (D)     "derated output must equal demand in each block [GW]"
   ;

* ----- The actual Model
eTotalCost    .. vTotalCost =e=  vAnnualizedFixedCost + vVariableOpCost + vCarbonCost;
eFixedCost    .. vAnnualizedFixedCost =e= sum[(G  ), pGenData(G,'c_fix')*vCapacity(G)];
eVarCost      .. vVariableOpCost*1e3 =e= sum[(G,D),
                    pGenData(G,'c_var')*vPwrOut(D,G)*pDemandData(D, 'dur')];
eCarbonCost   .. vCarbonCost*1e3 =e= sum[(G,D), 
                    pGenData(G,'co2')*vPwrOut(D,G)*pDemandData(D, 'dur')*pCarbonCost];

* wind energy / total energy > RPS
eRPS        ..  sum[(D), vPwrOut(D, 'Wind')*pDemandData(D, 'dur')] =g=
                    pRPS*sum[(G, D), vPwrOut(D,G)*pDemandData(D, 'dur')];
ePlanMargin ..  sum[(G), vCapacity(G)*pGenData(G,'cap_credit')] =g= 
                     (1 + pPlanReserve)*pDemandMax(S);
eCarbonCap  ..  sum[(G,D), pGenData(G,'co2')*vPwrOut(D,G)*pDemandData(D, 'dur')]/1000 =l=
                    pCarbonCap;

eInstCap(G)    .. vCapacity(G) =l= pGenData(G,'max_cap');
ePwrMax (D, G) .. vPwrOut(D, G) =l= pGenData(G,'avail')*vCapacity(G);
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
*    DoE Annual Energy Outlook (AEO), 2010
*
*  CO2 based on DoE AEO Heatrates with
*   EIA Voluntary Reporting of Greenhouse Gases Program: http://www.eia.doe.gov/oiaf/1605/coefficients.html
* --
                                                                                                                             
* Define the list of generators
set
         G           generation
               /Nuke, Coal, CCGT, CT, Wind/

* And the parameters for these generators
table    pGenData(G, GEN_PARAMS)   Generation Data Table
               c_var      c_fix   max_cap   avail    cap_credit      co2
*            [$/MWh]   [M$/GW-yr]   [GW]    [p.u.]      [p.u.]    [t/MWh]
Nuke              17       193      Inf      0.90        0.90          0
Coal              23       146      Inf      0.85        0.85       0.89
CCGT              33        84      Inf      0.85        0.85       0.36
CT                48        66      Inf      0.85        0.85       0.49
Wind               0       173      Inf      0.33        0.10          0
;

* -- Demand data
*
*  Sample 20 level + peak demand data based on ERCOT 2009 loads
* --

* Declare the actual set members (blocks, hours, etc)
set
  D   demand blocks
               /d1*d21/

* The actual demand data table:
* Note durations for non-peak shifted by 1 hour to ensure 
* intermediate generation actually gets built
table    pDemandData(D, DEM_PARAMS)   Demand data
     dur  power
*   [hr]  [GW]
d1   59   63.491
d2   435  57.838
d3   435  50.913
d4   435  46.651
d5   435  43.197
d6   435  40.686
d7   435  38.812
d8   435  37.448
d9   435  36.385
d10  435  35.482
d11  435  34.690
d12  435  33.920
d13  435  33.223
d14  435  32.531
d15  435  31.955
d16  435  31.250
d17  435  30.615
d18  435  29.823
d19  435  28.746
d20  435  27.389
d21  435  25.873
;

* -- System Parameters
pRPS = 0.20;
pPlanReserve = 0.10;

*Carbon Cap in 1000 metric tons CO2(eq) (usd/kT)
pCarbonCap = 20e3;

*Carbon Cost in $/mt CO2e
pCarbonCost = 0;


* ----- Run the model
model DemoCapPlanWind  /all/
solve DemoCapPlanWind using LP minimizing vTotalCost;

* ----- Display the results
* display command writes to the end of the *.lst file
display vPwrOut.l
display vCapacity.l
