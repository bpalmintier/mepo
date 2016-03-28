$Title "Max Affine (Convex LP Piecewise-Linear) Fitting Problem"

$ontext
----------------------------------------------------
Find the best piecewise linear fit to a given set of D
  
  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   December 2011

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-12-07  09:45  bpalmintier   Original version
  2  2011-12-08  00:45  bpalmintier   Added Monte Carlo global optimal search
-----------------------------------------------------
$offtext


*=========================*
*         Setup           *
*=========================*

* Reduce the size of the LST file
* Turn off equation listing, (unless debug on) see below
* Note: limrow specifies the number of cases for each equation type that are included in the output
option limrow = 0;

* Turn off variable listing, (unless debug on) see below
* Note: limrow specifies the number of cases for each equation type that are included in the output
option limcol = 0;

* Force a full restart with each iteration (rather than using previous solutions results)
option bratio = 1;

* Tighten convergence tolerance (Default is only 1%)
option optcr = 0.0001;

* Turn off detailed solution printing
option Solprint = off ;


* Number of iterations for random start points to global solution search
$set n_iter 10

*================================*
*         Declarations           *
*================================*

* ======  Declare all sets so can use in equations
* Note: be sure to quote descriptions otherwise "/" can not be used in a description.

sets

    L     "Piecewise Linear Segments"
    D     "Data points"
    
    COORD "Components of coordinate pairs"
       / 
        x   "independent variable"
        y   "dependent variable"
       /
;

* ======  Optimal Search related parameters
scalars 
    pCount
    pGlobalMin
    ;

pCount = 1; 
pGlobalMin = inf;

* ======  Declare the Data parameters. Actual Data defined below
parameters
* Data Table
    pData(D, COORD)   "list of sample (x, y) pair data values"

* Optimal Search related
    pBestKnownSlope(L)

* ======  Declare Variables
positive variables
   vSlope(L)      "Piecewise Linear segment slope"

variables
   vFit(D)        "Convex Piecewise Linear Values"
   vIntercept(L)  "Piecewise Linear intercept"

   vSquareError        "Squared error term"

* ======  Declare Equations
equations
   eSquareError        "Objective function. Minimize square error to minimize RMS"
   eFit(D)             "Find function approximation for each D"

   eOrderSegsIntercept(L)       "Order piecewise linear segments to simply optimization and provide cleaner results"
*   eOrderSegsSlope(L)  "Order piecewise linear segments to simply optimization and provide cleaner results"
   ;


*================================*
*       The Actual Model         *
*================================*
*====== objective function and components

eSquareError    .. vSquareError =e=  sum[ (D), sqr(vFit(D) - pData(D, 'y'))];

*smax is max over a set
eFit(D)       .. vFit(D) =e= smax[(L), vSlope(L)*pData(D, 'x') + vIntercept(L)];

eOrderSegsIntercept(L) .. vIntercept(L) =g= vIntercept(L+1);
*eOrderSegsSlope(L) .. vSlope(L) =l= vSlope(L+1);

*================================*
*        Handle The Data         *
*================================*

sets
L /l1*l2/

* Fake Data combining IEEE RTS 1996 197MW Oil Plant and 350MW Coal plant
D /d1*d8/

table pData(D, COORD)
      x       y
*    MW     MMBTU
d1   68.95   741.2
d2  118.2   1164.3
d3  157.6   1519.9
d4  197     1891.2
d5  140     1428.0
d6  227.5   2184.0
d7  280     2660.0
d8  350     3325.0
;

*Initial guess for slope to match maximum data point slope. We then perturb this later if
* during our Monte Carlo global search
parameter
    pMaxLinSlope  "Simple Linear Slope to maximum fuel use point"
    ;

pMaxLinSlope = smax[D, pData(D,'y')/pData(D,'x')];
    

*================================*
*       Solve & Related          *
*================================*

* ======  Setup the model
model max_affine  /all/;

* ======  Actually solve the model
* DNLP = Non-linear Program with Discontinuous Derivatives (because we use smax)
*  These are generally hard problems, with possible numeric challenges for standard non-linear
*  solvers that are optimized for continuous derivatives. We may need to use global solvers 
*  such as BARON, CBC, or DICOPT
while[ (pCount le %n_iter%),
    vSlope.l(L) = pMaxLinSlope + uniform(-pMaxLinSlope,pMaxLinSlope);
    vIntercept.l(L) = uniform(-1000,1000);
    display "Iteration #", pCount, "Initial Guess", vSlope.l;
    solve max_affine using DNLP minimizing vSquareError;
    display "Solve this Iteration", vSlope.l;
    if [ (vSquareError.l le pGlobalMin),
        display "New Optimal Found!";
        pGlobalMin = vSquareError.l;
        pBestKnownSlope(L) = vSlope.l(L);
    ]; 
    pCount = pCount+1;
];

* Do a final solve using the best know results
* Note: fix the slopes, since in some cases the optimizer actually otherwise returns a worse
* solution using this best result as a starting point. 
vSlope.fx(L) = pBestKnownSlope(L);
solve max_affine using DNLP minimizing vSquareError;


display vSlope.l, vIntercept.l, vFit.l, pGlobalMin, pBestKnownSlope