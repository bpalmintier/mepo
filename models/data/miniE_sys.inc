
$ontext
-----------------------------------------------------
 miniaturized ERCOT 2007: Reduced to only 7 each of Coal, NG-CC, NG-GT + wind.
 The total resulting capacity is only 11% of the thesis ERCOT so demand scaled
 to 11% by default
 
 see thesis_sys.inc (v4) for other notes

 Ver   Date       Time  Who            What
 ---  ----------  ----- -------------- ---------------------------------
   1  2015-08-01  23:50  bpalmintier   Adapted from thesis_sys.inc v4
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
   pDemandScale(S)=0.095;
   
*Allow more simultaneous maintenance b/c of smaller number of test weeks
$if not set max_maint $setglobal max_maint 0.25


*===== System Assumptions =====
*weighted average cost of capital (utility investment discount rate) [fract]
* 9% "Interest rate" listed in: [2] Electric Reliability Council of Texas [ERCOT], "Long-Term System Assessment for the ERCOT Region," Dec. 2010.
 pWACC = 0.09;       
   
*cost of non-served energy		[$/MWh = M$/TWh]
pPriceNonServed = 5e4;

*===== Reserves =====
*Planning reserve (unused capacity) during peak period (includes op reserve)
*ERCOT now uses a 13.75% planning reserve 
* [3] B. Jones, “Agenda Item 7: 2010 Loss of Load Events (LOLEV)/Target Reserve Margin (TRM) Study,” 09-Nov-2010.
$if declared pPlanReserve
   pPlanReserve = 0.1375;

*Percentage of Contingency Reserve that can be meet by off-line (quick start) units
* Based on WECC requirements of 50% provided gens can reach required output level in
* 10minutes as reported in [1] Ela 2011 (p45)
$if declared pQuickStSpinSubFract
    pQuickStSpinSubFract = 0.5;

*Contingency reserve as a fraction of load
$if declared pSpinReserveLoadFract
   pSpinReserveLoadFract = 0.033;

*Contingency reserve minimum (typically set to max plant/unit size)
* Max plant in miniE is 728MW (Ballstrop) but this is too much so use 500MW

$if declared pSpinReserveMinGW
   pSpinReserveMinGW = 0.5;

*Off-line Replacement reserves to cover deployed spinning reserves
* Set to size of largest (single) generator
$if declared pReplaceReserveGW
   pReplaceReserveGW = 0.5;

*Frequency regulation as a fraction of load
* Based on a 1% of load target used in PJM as reported in Ela 2011 (p
$if declared pRegUpLoadFract
   pRegUpLoadFract = 0.01;

$if declared pRegDownLoadFract
   pRegDownLoadFract = 0.01;
   
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
* Imbalance/Forecast component
* See discussion in Thesis for values

$if declared pWindFlexUpForecast
	pWindFlexUpForecast = 0.139;
	
$if declared pWindFlexUpCapacity
	pWindFlexUpCapacity = 0.0795;
	
$if declared pWindFlexDownForecast
	pWindFlexDownForecast = 0;
	
$if declared pWindFlexDownCapacity
	pWindFlexDownCapacity = 0.02;

*------- Setup default references to data sub-include files
$if not set fuel $setglobal fuel thesis_fuel.inc

$if not set demand $setglobal demand ercot2007_dem_yr_as_5wk.inc

$if not set gens $setglobal gens miniE_units_clust.inc
$if not set gparams $setglobal gparams eia_aeo2011_gen_params.inc

$if NOT set avail $setglobal avail ercot2007_avail.inc
