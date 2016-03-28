
$ontext
-----------------------------------------------------
 System data for ERCOT using 2007 eGrid data (typically Unit level)
	WITH Zero Secondary Reserves as a function of wind Capacity (only Reg Up/Down)

 As noted, many reserve numbers are based on:
   [1] E. Ela, M. Milligan, and B. Kirby, "Operating Reserves and Variable Generation," 
     National Renewable Energy Laboratory (NREL), Golden, CO, NREL/TP-5500-51978, Aug. 2011.

  originally coded in GAMS by Bryan Palmintier 2010-04-08

 Ver   Date       Time  Who            What
 ---  ----------  ----- -------------- ---------------------------------
   1  2013-10-14  15:50  bpalmintier   Adapted from ercot2007eGrid_sys ver 5
 -----------------------------------------------------
$offtext

*===== Scenario Dependent Parameters =====

*cost of carbon (in terms of CO2)        [$/t-CO2eq]   
*Note: value overridden by --co2cost=#.# command-line option
 pCostCO2(S) = 0;         

*renewable portfolio standard (% energy) 
*Note: value overridden by --rps=#.# command-line option
$if declared pRPS
 pRPS(S) = 0;
   
*Carbon Cap in million metric tons CO2(eq)
$if declared pCarbonCap
   pCarbonCap(S) = Inf;

*Scaling parameter for demand
$if declared pDemandScale
   pDemandScale(S)=1;

*===== System Assumptions =====
*weighted average cost of capital (utility investment discount rate) [fract]
 pWACC = 0.08;       
   
*cost of non-served energy		[$/MWh = M$/TWh]
pPriceNonServed = 5e4;

*===== Reserves =====
*Planning reserve (unused capacity) during peak period (includes op reserve)
*ERCOT now uses a 13.75% planning reserve 
* [1] B. Jones, “Agenda Item 7: 2010 Loss of Load Events (LOLEV)/Target Reserve Margin (TRM) Study,” 09-Nov-2010.
$if declared pPlanReserve
   pPlanReserve = 0.1375;

* Response time for Spinning Reserves [minutes]
*$if declared pSpinResponseTime  (currently not used)
*	pSpinResponseTime = 10.0;

*Percentage of Contingency Reserve that can be meet by off-line (quick start) units
* Based on WECC requirements of 50% provided gens can reach required output level in
* 10minutes as reported in [1] Ela 2011 (p45)
$if declared pQuickStSpinSubFract
    pQuickStSpinSubFract = 0.5;

*Off-line Operating reserve up (non-spin) as a fraction of load
*$if declared pQuickStartLoadFract
*   pQuickStartLoadFract = 0.03;

*Contingency reserve as a fraction of load
* Based on proposed WECC rule or 3% of load as reported in Ela 2011 (p45)
$if declared pSpinReserveLoadFract
   pSpinReserveLoadFract = 0.03;

*Contingency reserve minimum (typically set to max plant/unit size)
* Max plant in ERCOT is a 1354.3 MW Nuke (eGrid) this plant actually has 2 units, not sure if
* it is a credible contingency to lose both simultaneously. 
* But according to * [2] GE Energy, "Analysis of Wind Generation Impact on ERCOT Ancillary 
* Services Requirements," Mar. 2008. The current level is 2300MW

$if declared pSpinReserveMinGW
   pSpinReserveMinGW = 2.3;

*Off-line Replacement reserves to cover deployed spinning reserves
*Set to zero for consistency between runs for LongTermUnitCommitPaper. Should be closer to 1350MW
*TODO: use non-zero value
$if declared pReplaceReserveGW
   pReplaceReserveGW = 0;

*Frequency regulation as a fraction of load
* Based on a 1% of load target used in PJM as reported in Ela 2011 (p
$if declared pRegUpLoadFract
   pRegUpLoadFract = 0.01;

$if declared pRegDownLoadFract
   pRegDownLoadFract = 0.01;
   
*Wind Forecast Error (currently not used)
*$if declared pWindForecastError
*   pWindForecastError=0.2;
   
*---Additional reserves for Wind
* Regulation (GWreg/GWwind)
* Average up/down value from ERCOT adjustments to reg reserve per 1000MW wind as reported in 
* table V (p41) of [1] Ela 2011 which duplicates a table from Appendix F of...
* [2] GE Energy, "Analysis of Wind Generation Impact on ERCOT Ancillary Services Requirements,"
* Mar. 2008.
$if declared pWindRegUpCapacity
	pWindRegUp = 0.003584;
$if declared pWindRegDownCapacity
	pWindRegDown = 0.003208;

* Load Following
* Variability component
* Based on 3sigma of reported ERCOT wind variation at 10GW capacity reported in:
*  [3] Y. Wan, “Analysis of Wind Power Ramping Behavior in ERCOT,” National Renewable Energy Laboratory (NREL), Golden, CO, NREL/TP-5500-49218, Mar. 2011.

$if declared pWind10minRsrv
	pWindFlexUpForecast = 0.02;

* Imbalance/Forecast component
* Data from (De Jonghe, et al 2011) Table III
$if declared pWindFlexUpForecast
	pWindFlexUpForecast = 0.125;
	
$if declared pWindFlexUpCapacity
	pWindFlexUpCapacity = 0;
	
$if declared pWindFlexDownForecast
	pWindFlexDownForecast = 0.0875;
	
$if declared pWindFlexDownCapacity
	pWindFlexDownCapacity = 0;

*------- Setup default references to data sub-include files
$if not set fuel $setglobal fuel ercot2007_fuel.inc

$if not set demand $setglobal demand ercot2007_dem_wk.inc

$if not set gens $setglobal gens ercot2007eGrid_units_clust.inc
$if not set gparams $setglobal gparams nw_power_plan6_gen_params.inc

$if NOT set avail $setglobal avail ercot2007_avail.inc
