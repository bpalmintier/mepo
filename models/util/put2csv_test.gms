$Title put2csv Test file (based on demo capacity plannning)

$ontext
----------------------------------------------------
  The main goal here is to check out the features of put2csv, but to do so in a realistic context
  and to extract data from variables requires actually running an optimization. So this file builds
  on current efforts to develop a very simple Electricity Capacity Planning model simply as a way 
  to get moderately interesting numbers to display.
  
  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   May 2010

Ver   Date      Time  Who            What
---  ---------- ----- -------------- ---------------------------------
  1  2010-05-20 22:15  bpalmintier   Original code, modified from DemoCapPlan v 5
  2  2012-01-28 18:13  bpalmintier   Expanded to test multiple dimensions
----------------------------------------------------- 
$offtext

* ----- GAMS Options
* Allow declaration of empty sets & variables
$onempty 
* Allow additions to set elements with multiple set definitions
$onmulti
* Include $ commands in output
$ondollar


* ----- Declare all sets so can use in equations
sets
* Sets for table parameters
         DEM_PARAMS  demand block parameters from load duration curve
               /dur, power/
         GEN_PARAMS  generation parameters
               /c_var, c_fix, max_cap/
               
* Sets for data, actual definitions can be found in include files
         DEM           demand levels
         G           generation

* ----- Declare the data parameters. Actual data defined below
parameters
         pDemandData(DEM, DEM_PARAMS) table of demand data
         pGenData   (G, GEN_PARAMS) table of generator data

* ----- Declare Variables
variables
   vTotalCost                total system cost in target year   [M$]
   vAnnualizedFixedCost      annualized fixed [cap + fixed O&M] [M$]
   vVariableOpCost           variable O&M [fuel etc]            [M$]

positive variables
   vPwrOut   (DEM, G)   production of the unit                [MW]
   vCapacity (   G)   total installed capacity that is used [MW]
   ;

* ----- Declare Equations
equations
   eTotalCost       total system cost                  [M$]
   
   eFixedCost       system fixed costs [annualized]    [M$]
   eVarCost         system variable costs for one year [M$]

   eInstCap  (   G)  installed capacity                    [GW]
   ePwrMax   (DEM, G)  output lower than installed max       [GW]
   eDemand   (DEM)     output must equal demand              [GW]
   ;

* ----- The actual Model
eTotalCost    .. vTotalCost =e=  vAnnualizedFixedCost + vVariableOpCost;
eFixedCost		.. vAnnualizedFixedCost =e= sum[(G  ), pGenData(G,'c_fix')*vCapacity(G)];
eVarCost      .. vVariableOpCost =e= sum[(G,DEM), pGenData(G,'c_var')*vPwrOut(DEM,G)*pDemandData(DEM, 'dur')];

eInstCap(G)    .. vCapacity(G) =l= pGenData(G,'max_cap');
ePwrMax (DEM, G) .. vPwrOut(DEM, G) =l= vCapacity(G);
eDemand (DEM)    .. sum[(G), vPwrOut(DEM, G)] =e= pDemandData(DEM,'power');

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
*            [$/MWh]   [$/MW-yr]     [MW]
Nuke              17       92000      Inf
CCGT              33       36000      Inf
CT                48       32500      Inf
;

* -- Demand data
*
*  Sample 3 level demand data based on ERCOT 2009 loads
* --

* Declare the actual set members (blocks, hours, etc)
set
  DEM   demand blocks
               /peak, shoulder, low/

* The actual demand data table:
* Note durations for non-peak shifted by 1 hour to ensure 
* intermediate generation actually gets built
table    pDemandData(DEM, DEM_PARAMS)   Demand data
                dur     power
*              [hr]      [MW]
peak            233     63491
shoulder       3266     54135
low            5261     36028
;


* ----- Run the model
model ToyCapPlan  /all/
solve ToyCapPlan using LP minimizing vTotalCost;

* ----- Display the results
* display command writes to the end of the *.lst file (for comparison)
display vPwrOut.l
display vCapacity.l

*============================================
* And finally here are some put2csv tests
*============================================
* Test directly writing output variables as 1-D and 2-D arrays
*Output Power Out (dispatch) data as a 2-D table
$batinclude put2csv.gms "put2csv_test_table.csv" "table" vPwrOut.l(DEM,G) G DEM "'prefix_'"

*Output Cacacity as a list
$batinclude put2csv.gms "put2csv_test_list.csv" "list" vCapacity.l(G) G "'prefix_'"


*Build up a multi-D array
    sets
        A  "first dimension"
            /a1   "Element-A1-"
             a2   "Element-A2-"
             a3   "Element-A3-"
            /
        B  "second dimension"
            /b1*b3/
        C  "third dimension"
            /c1*c3/
        D  "fourth dimension"
            /d1*d3/
        E  "fifth dimension"
            /e1*e3/
        F  "sixth dimension"
            /f1*f3/
    ;
    parameters
        pData5(A, B, C, D, E)  "5 dimensional data"
        pData6(A, B, C, D, E, F)  "6 dimensional data"
        ;
        
        pData5(A,B,C,D,E) = uniform(0,10);
        pData6(A,B,C,D,E,F) = uniform(0,10);

* ----- Write Results to CSV file

*Now test various shapes of output in the same file
    FILE multi_d    /"put2csv_test_multiD.csv"/;
    PUT multi_d;
*Allow maximum page width to prevent truncation
    multi_d.pw=32767;
    
$batinclude put2csv.gms "" "list"  pData5(A,B,C,D,E) A.B.C.D.E   A.te(A)
$batinclude put2csv.gms "" "table" pData5(A,B,C,D,E) A.B.C.D   E "A.te(A)"
$batinclude put2csv.gms "" "table" pData5(A,B,C,D,E) A.B.C   D.E "'3x2_'"
$batinclude put2csv.gms "" "table" pData5(A,B,C,D,E) A.B   C.D.E "'2x3_'"
$batinclude put2csv.gms "" "table" pData5(A,B,C,D,E) A   B.C.D.E "'1x4_'"

    put "Full 6-D data set as 1x5" /
$batinclude put2csv.gms "" "table" pData6(A,B,C,D,E,F) A   B.C.D.E.F

*Close our put file
    putclose