
$ontext
-----------------------------------------------------
 System data for IEEE reliability test system

  originally coded in GAMS by Bryan Palmintier 2010-04-08

 Ver   Date       Time  Who            What
 ---  ----------  ----- -------------- ---------------------------------
   1  2011-09-26  01:50  bpalmintier   Adapted from ercot_water_sys.inc ver 2
   2  2011-09-28  04:00  bpalmintier   Switch to 1 week load by default
   3  2011-10-17  17:00  bpalmintier   Replace local set and include for data to setglobal (for inclusion by caller)
   4  2011-10-17  17:10  bpalmintier   Added pQuickStSpinSubFract for proper reserve handling
   5  2012-01-26  11:37  bpalmintier   Updated scenario dependent parameters with (S)
-----------------------------------------------------
$offtext

*===== Scenario Dependent Parameters =====
*cost of carbon (in terms of CO2)        [$/t-CO2eq]   
*Note: value overridden by --co2cost=#.# command-line option
 pCostCO2(S) = 0;         

*Carbon Cap in metric tons CO2(eq)
$if declared pCarbonCap
   pCarbonCap(S) = Inf;

*Scaling parameter for demand
$if declared pDemandScale
   pDemandScale(S)=1;

*renewable portfolio standard (% energy) 
*Note: value overridden by --rps=#.# command-line option
$if declared pRPS
 pRPS(S) = 0;
   
*===== System Assumptions =====
*weighted average cost of capital (utility investment discount rate) [fract]
 pWACC = 0.08;       
   
*cost of non-served energy		[$/MW]
pPriceNonServed = 5e4;

*===== Reserves =====
*Planning reserve (unused capacity) during peak period (includes op reserve)
*ERCOT uses a 12.5% planning reserve
$if declared pPlanReserve
   pPlanReserve = 0.125;

* Response time for Spinning Reserves [minutes]
$if declared pSpinResponseTime      
	pSpinResponseTime = 10.0;

$if declared pQuickStSpinSubFract
    pQuickStSpinSubFract = 0.5;

*Off-line Operating reserve up (non-spin) as a fraction of load
$if declared pQuickStartLoadFract
   pQuickStartLoadFract = 0.00;

*On-line Spinning reserve as a fraction of load
$if declared pSpinReserveLoadFract
   pSpinReserveLoadFract = 0.00;

*On-line spinning reserve minimum (typically set to max plant size)
$if declared pSpinReserveMinMW
   pSpinReserveMinMW = 400;

*Off-line Replacement reserves to cover deployed spinning reserves
*Set to zero for consistency between runs for LongTermUnitCommitPaper. Should be closer to 1350MW
*TODO: use non-zero value
$if declared pReplaceReserveMW
   pReplaceReserveMW = 0;

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

*------- Setup default references to data sub-include files
$if not set fuel $setglobal fuel ieee_rts96_fuel.inc
$if not set demand $setglobal demand ieee_rts96_dem_wk.inc
$if not set gens $setglobal gens ieee_rts96_gens.inc
$if NOT set avail $setglobal avail ieee_rts96_avail.inc
