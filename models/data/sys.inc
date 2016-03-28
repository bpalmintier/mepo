
$ontext
 -----------------------------------------------------
 System data for capacity planning for use with StaticCapPlan and ToyCapPlan models

  Sample financial & carbon data

 originally coded in GAMS by Bryan Palmintier 2010-04-08

Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2010-04-08         bpalmintier   Original data
  2  2010-05-20  23:45  bpalmintier   Added RPS, PlanReserve, & CarbonCap (optional for bwd compat)
  3  2010-09-07  18:30  bpalmintier   Converted to single sys.inc with subincludes. Updated comments
  4  2010-11-14  00:46  bpalmintier   Added Operating Reserves
  5  2010-11-14  19:40  bpalmintier   renamed scalars (s*) to parameters (p*)
  6  2011-05-20  02:40  bpalmintier   Added additional reserves for wind
  7  2011-06-15  01:15  bpalmintier   Do not include default includes if set in caller
  8  2011-07-07  01:15  bpalmintier   Made remaining defaults optional
  9  2011-07-24  08:30  bpalmintier   Replace availability CSV with GAMS table format
 10  2012-01-26  11:37  bpalmintier   Updated scenario dependent parameters with (S)
 11  2012-03-07  12:35  bpalmintier   Added pReplaceReserveGW for compatibility with separate reserves
 12  2012-09-02  17:08  bpalmintier   Replace all $set with $setglobal (to prevent scope errors)
 -----------------------------------------------------
$offtext

*===== Scenario Dependent Parameters =====
*cost of carbon (in terms of CO2)        [$/t-CO2eq]   
$if declared pCostCO2
   pCostCO2(S) = 0;         

*Carbon Cap in metric tons CO2(eq)
$if declared pCarbonCap
   pCarbonCap(S) = Inf;

*Scaling parameter for demand
$if declared pDemandScale
   pDemandScale(S)=1;

*renewable portfolio standard (% energy) Note: value overridden by --rps=#.# command-line option
$if declared pRPS
   pRPS(S) = 0.0;

*===== System Assumptions =====
*weighted average cost of capital (utility investment discount rate) [fract]
$if declared pWACC
   pWACC = 0.08;       
   
*cost of non-served energy		[$/MW]
$if declared pPriceNonServed
   pPriceNonServed = 1e5;
   
*===== Reserves =====
*Planning reserve (unused capacity) during peak period (includes op reserve)
$if declared pPlanReserve
   pPlanReserve = 0.10;

* Response time for Spinning Reserves [minutes]
$if declared pSpinResponseTime      
	pSpinResponseTime = 10.0;

*Off-line Operating reserve up (non-spin) as a fraction of load
$if declared pQuickStartLoadFract
   pQuickStartLoadFract = 0.03;

*On-line Spinning reserve as a fraction of load
$if declared pSpinReserveLoadFract
   pSpinReserveLoadFract = 0.03;

*On-line spinning reserve minimum (typically set to max plant size)
$if declared pSpinReserveMinMW
   pSpinReserveMinMW = 1350;

*Off-line Replacement reserves to cover deployed spinning reserves
$if declared pReplaceReserveGW
   pReplaceReserveGW = 0;

*Frequency regulation up as a fraction of load
$if declared pRegUpLoadFract
   pRegUpLoadFract = 0.01;

*Frequency regulation down as a fraction of load
$if declared pRegDownLoadFract
   pRegDownLoadFract = 0.01;

*Wind Forecast Error
$if declared pWindForecastError
   pWindForecastError=0.2;
   
*Additional reserves for Wind
* Data from (De Jonghe, et al 2011) Table III
$if declared pWindFlexUpForecast
	pWindFlexUpForecast = 0.125;
	
$if declared pWindFlexUpCapacity
	pWindFlexUpCapacity = 0.065;
	
$if declared pWindFlexDownForecast
	pWindFlexDownForecast = 0.0875;
	
$if declared pWindFlexDownCapacity
	pWindFlexDownCapacity = 0.0625;

   
*------- Reference data sub-include files
* -- Setup default (empty) path to csv include file. Typically this will be overridden within the model
$if NOT set data_dir    $setglobal data_dir   

$ifthen not set fuel
$include %data_dir%fuel.inc
$endif

$ifthen not set demand
$include %data_dir%demand.inc
$endif

$ifthen not set gens
$include %data_dir%gens.inc
$endif

* Read availability tables if needed
$ifthen NOT set avail
$include %data_dir%gen_avail.inc
$endif