
$ontext
 -----------------------------------------------------
 System data for capacity planning for use with StaticCapPlan and ToyCapPlan models

  Simple 2 generator type example

 originally coded in GAMS by Bryan Palmintier 2010-04-08

 Ver   Date       Time  Who            What
 ---  ----------  ----- -------------- ---------------------------------
   1  2011-03-25  23:00  bpalmintier   Adapted from sys.inc v5
   2  2011-07-24  08:30  bpalmintier   Replace availability CSV with GAMS table format
   3  2012-01-26  11:37  bpalmintier   Updated scenario dependent parameters with (S)
   4  2012-03-14  14:10  bpalmintier   Moderized:
                                        -- SCALED units (GW, etc)
                                        -- added pReplaceReserveGW 
                                        -- added wind reserves as a function of wind
                                        -- set additional includes rather than including
 -----------------------------------------------------
$offtext

*===== Scenario Dependent Parameters =====
*cost of carbon (in terms of CO2)        [$/t-CO2eq]   
$if declared pCostCO2
   pCostCO2(S) = 0;         

*Carbon Cap in 1e6 metric tons CO2(eq)
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
* Changed from 0.10 in SVN r370, but for time/testCapPlanDp this was overridden as 0.08 at
* least as far back as r115
$if declared pWACC
   pWACC = 0.08;       
   
*cost of non-served energy		[$/MWh]
$if declared pPriceNonServed
    pPriceNonServed = 1e5;
   
*===== Reserves =====
*Planning reserve (unused capacity) during peak period (includes op reserve)
$if declared pPlanReserve
   pPlanReserve = 0.10;

* Response time for Spinning Reserves [minutes]
$if declared pSpinResponseTime      
	pSpinResponseTime = 10.0;

* Amount of spinning reserve that can be supplied by quick start units
$if declared pQuickStSpinSubFract
    pQuickStSpinSubFract = 0.5;

*Off-line Operating reserve up (non-spin) as a fraction of load
$if declared pQuickStartLoadFract
   pQuickStartLoadFract = 0.03;

*On-line Spinning reserve as a fraction of load
$if declared pSpinReserveLoadFract
   pSpinReserveLoadFract = 0.03;

*On-line spinning reserve minimum (typically set to max plant size)
$if declared pSpinReserveMinGW
   pSpinReserveMinGW = 1.350;

*Off-line Replacement reserves to cover deployed spinning reserves
$if declared pReplaceReserveGW
   pReplaceReserveGW = 0;

*Frequency regulation up as a fraction of load
$if declared pRegUpLoadFract
   pRegUpLoadFract = 0.01;

*Frequency regulation down as a fraction of load
$if declared pRegDownLoadFract
   pRegDownLoadFract = 0.01;

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
*------- Setup default references to data sub-include files
$if not set fuel $setglobal fuel test_fuel.inc

$if not set demand $setglobal demand test_dem_20blk.inc

$if not set gens $setglobal gens gens2d.inc

$if NOT set avail $setglobal avail gen_avail2d.inc

