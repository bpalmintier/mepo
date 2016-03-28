$Title Demo Unit Commitment model

$ontext
----------------------------------------------------
  A very basic deterministic unit commitment model for electricity generation operations
  
  Supports:
    - arbitrary number of generation technologies/units with 
        + Minimum power output
        + Startup costs
        + maximum installed capacity by unit
    - arbitrary number of demand blocks
        + arbitrary duration
        + assumes repeating block sequence to capture startup/shutdown at end of model
    - linear variable costs (zero no load costs)

  Written by:
   Bryan Palmintier, MIT
   April 2010
   For ESD.934/6.974 HW4 Solutions

 Version History
   Date      Time  Who            What
 ---------- ----- -------------- ---------------------------------
 2010-04-02 10:15  bpalmintier    Original code
 
----------------------------------------------------- 
$offtext

*-------- GAMS Options --------
* Allow declaration of empty sets & variables
$onempty 
* Allow additions to set elements with multiple set definitions
$onmulti

*get exact MIP solution  (optcr is relative convergence). Default is 10%
option optcr=0

* ------ Problem Setup --------
* Declare all sets so can use in equations

sets
* Sets for table parameters
         DEM_PARAMS  demand block parameters
               /dur, power/
         GEN_PARAMS  generation parameters
               /p_min, p_max, c_var, c_startup/
               
* Sets for data
         D           demand levels
         G           generation

parameters
*Declare the data parameters. Actual data table can be found below
         pDemandData(D, DEM_PARAMS) table of demand data
         pGenData   (G, GEN_PARAMS) table of generator data

variables
   vTotalCost                total operating cost         [$]
   vStartUpCost              cost from startup            [$]
   vVarCost                  variable generation costs    [$]
   
binary variable
   vOnOff (D, G)   unit commitment state for generator                [0 or 1]

positive variables
   vPwrOut   (D, G)   production of the unit during the demand period [GW]
* Note that even though the startup&shutdown variables will only take integer values, we can treat
* them as positive because the unit commitment constraint (eState) will only return binary results
* since vOnOff is binary. This trick reduces the number binary variables and converts part of the 
* otherwise complex integer tree to a larger and fast to solve LP
   vStartUp  (D, G)   binary variable to start up.                    [0 or 1]
   vShutDown (D, G)   binary variable to shut down                    [0 or 1]
   ;

*-------- Model Formulation -------
equations
* objective function
   eTotalCost       total operating cost                      [$ per load cycle]
   eStartupCost     total startup costs                       [$ per load cycle]
   eVarCost         total economic dispatch costs for energy  [$ per load cycle]  

* Contraints   
   ePwrMax   (D, G)  output lower than installed max       [GW]
   ePwrMin   (D, G)  output greater than installed min     [GW]
   eDemand   (D   )  output must equal demand              [GW]
   
* Binary Variable Handing
   eState    (D, G)  compute the unit commitment states
   ;

* Equations to be solved
* Objective:
eTotalCost    .. vTotalCost =e=  vStartupCost + vVarCost;
eStartupCost	.. vStartUpCost =e= sum[(D, G), vStartup(D,G)*pGenData(G,'c_startup')];
eVarCost      .. vVarCost =e= sum[(G,D), pGenData(G,'c_var')*vPwrOut(D,G)*pDemandData(D, 'dur')];

* Constraints:
ePwrMax (D, G) .. vPwrOut(d, g) =l= vOnOff(d,g) * pGenData(g,'p_max');
ePwrMin (D, G) .. vPwrOut(d, g) =g= vOnOff(d,g) * pGenData(G,'p_min');
eDemand (D)    .. sum[(g), vPwrOut(d, g)] =e= pDemandData(D,'power');

*Handle on/off binary variables
* Formula: on/off state equals previous on/off state + 1 for startup or -1 for shutdown. 
* Note the use of the circular lead operator (--) which treats the demand levels as cyclical, such 
* that the unit commitment state during the final period is used as the initial unit commitment
* state before the first period
eState  (D,G)  .. vOnOff(d,g) =e= vOnOff(d--1,g) + vStartUp(d,g) - vShutDown(d,g)

* -------- Define Data --------
* -- Generator data
*
*  From MIT ESD.934/6.974 Homework 4 Spring 2010 (corrected)
*
* --
                                                                                                                             
* Define the list of generators
set
         G           generation
               /Papa, Mama, Baby/

* And the parameters for these generators
table    pGenData(G, GEN_PARAMS)   Generation Data Table
               p_min      p_max      c_var     c_startup
*               [GW]       [GW]    [$/MWh]     [$/start]
Papa            1200       1500         10         80000
Mama             500       1200         20         10000
Baby             100        600         30          3000
;

* -- Demand data
*
*  From MIT ESD.934/6.974 Homework 4 Spring 2010
*
* --

* Declare the actual set members (blocks, hours, etc)
set
  D   demand blocks
               /low, high/

* The actual demand data table:
table    pDemandData(D, DEM_PARAMS)   Demand data
                dur     power
*              [hr]      [GW]
low              20      1250
high              4      1800
;

* -------- Run the model --------
model DemoUnitCommit  /all/
solve DemoUnitCommit using MIP minimizing vTotalCost;

* -------- Display the Results --------
* Note: there is a bunch of stuff from here to the end of the file, but it is only to display the 
* results to the screen and does not affect the model execution or results themselves.

* -- Set up a file proxy so we will print the screen.
* From McCarl GAMS Users guide
$set console
$if %system.filesys% == UNIX $set console /dev/tty
$if %system.filesys% == DOS $set console con
$if %system.filesys% == MS95 $set console con
$if %system.filesys% == MSNT $set console con
$if "%console%." == "." abort "filesys not recognized";
file screen / '%console%' /;

*choose to use the file for subsequent outputs
put screen;

*setup text & numeric column width
screen.tw = 8;
screen.nw = 8;
screen.lw = 8;
* set show no decimal places
screen.nd = 0;

*and set the width of our header column
scalar head_col /28/;

* -- Print dispatch table
* first a title
put // '---------- Unit Commitment Constrained Dispatch ---------':0 //;

* Now print column headers
put @(head_col+1)
loop(D,
	put D.tl:>;
)
put /;

* And print the resulting power output table, one generator per line
loop(G,
	put G.tl:0 ' (W)' @(head_col+1);
	loop(D,
		put vPwrOut.l(D,G);
	)
	put /;
)

*print sum lines
put @(head_col+1);
loop(D,
	put '-----':>;
)
put /;

*print demand block totals
put 'Total Demand (W)':(head_col);
loop(D,
	put pDemandData(d, 'power');
)
put /

* Add marginal costs
* first compute them
parameter pMarginCost(D);
pMarginCost(D) = eDemand.m(D)/pDemandData(D,'dur');

put / 'Marginal Cost ($/MWh)':0 @head_col;
loop(D,
	put pMarginCost(d)::0;
)

put / 'Margin Gen VarCost ($/MWh)':0 @head_col;
loop(D,
	put smax(G, vOnOff.l(d, g) * pGenData(g, 'c_var'))::0;
)
put //

* -- show cost summary
* print header row
put / @(head_col+1);
loop(G,
	put g.tl:>;
)
put 'Total':>	/;

*print variable costs
put 'Variable Costs ($)':head_col;
loop(G,
	put sum(D, vPwrOut.l(d,g)*pGenData(g, 'c_var')*pDemandData(d,'dur'))::0;
)
put vVarCost.l::0;
put /;

*print startup costs
put 'Startup Costs ($)':head_col;
loop(G,
	put sum(D, vStartup.l(d,g)*pGenData(g, 'c_startup'))::0;
)
put vStartupCost.l::0;
put /;

*print sum lines
put @(head_col+1);
loop(G,
	put '-----':	>;
)
put '-----':>;
put /;

*print total costs
put 'Total Costs ($)':head_col;
loop(G,
	put sum(D, vPwrOut.l(d,g)*pGenData(g, 'c_var')*pDemandData(d,'dur') + vStartup.l(d,g)*pGenData(g, 'c_startup'))::0;
)
put vTotalCost.l::0;
put /;



* finish up the screen printing
putclose;

*-- and finally add a few pieces to the output file
display vPwrOut.l
display pMarginCost