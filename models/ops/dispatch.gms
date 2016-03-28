$Title Simple Economic Dispatch Model for Electric Power Systems

$ontext
----------------------------------------------------
  A very basic economic dispatch model
  
  command line options:
   --method==STRING  choose solution method either "loop" or "big_lp" (default="big_lp")
   
  Supports:
    - separate include files for data

Ver   Date      Time  Who            What
---  ---------- ----- -------------- ---------------------------------
  1  200?              mwebster      Original Version with full path includes
  2  2010-08-19 16:30  bpalmintier   Added comments & switch to relative paths
  3  2010-08-19 16:30  bpalmintier   Test with 8760 demand levels (result: loop=SLOW)
  4  2010-08-23 22:00  bpalmintier   command-line option to switch between big-lp and loop
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

* ----- Handle Command line parameters
$if not set method $set method "big_lp"

* ----- Declare all sets so can use in equations
* Note: be sure to quote descriptions otherwise "/" can not be used in a description.
Sets
i plants / 1*391 /
dl demand level /1*8760/
;

$include costparams.gms
$include demand.gms

Parameter genresults(i, dl);
Parameter costresults(i,dl);

Parameter c(i) cost in $ per MWh of each plant ;
c(i) =  FCost(i)*IOB(i) + VOM(i);


$ifthen %method% == "big_lp"
Variables
x(i,dl) generation of each plant in MW
s(dl) total supply of electricity in MW
z total cost ;

Positive variable x;

Equations
cost define objective function
supply(i,dl) observe supply limit at plant i
demand(dl) satisfy total demand ;

cost..           z =e= sum[(i,dl), c(i)*x(i,dl)] ;
supply(i,dl)..      x(i,dl) =l= MaxGen(i) ;
demand(dl)..         sum(i, x(i,dl)) =e= DEM(dl) ;
Model dispatch /all/ ;
solve dispatch using lp minimizing z ;

genresults(i,dl) = x.l(i,dl);
costresults(i,dl) = x.l(i,dl) * c(i);
$endif

$ifthen %method% == "loop"
Variables
x(i) generation of each plant in MW
s total supply of electricity in MW
z total cost ;

Positive variable x;

Equations
cost define objective function
supply(i) observe supply limit at plant i
demand satisfy total demand ;

Parameter d;


cost..           z =e= sum(i, c(i)*x(i)) ;
supply(i)..      x(i) =l= MaxGen(i) ;
demand..         sum(i, x(i)) =e= d ;
Model dispatch /all/ ;

loop(dl,

         d = DEM(dl);
         solve dispatch using lp minimizing z ;
         display d, x.l, x.m ;

         genresults(i,dl) = x.l(i);
         costresults(i,dl) = x.l(i) * c(i);

);
$endif


$ontext
*Results Array is not used
Parameter results array for holding results;

loop(i,
         results(i,"id") = PlantID(i);
         results(i,"gen") = x.l(i);
         results(i,"cost") = x.l(i) * c(i);
);
$offtext

*file dispatch_out;
*put dispatch_out;

*$libinclude gams2tbl results
*$libinclude gams2tbl genresults
*$libinclude gams2tbl costresults

*putclose dispatch_out;

*Commented out for non Windows use -BP
*execute_unload "ercot.gdx" genresults
*execute 'gdxxrw.exe ercot.gdx o=ercot.xls par=genresults rng=1Generation!a1'

*execute_unload "ercot.gdx" costresults
*execute 'gdxxrw.exe ercot.gdx o=ercot.xls par=costresults rng=2Costs!a1'


