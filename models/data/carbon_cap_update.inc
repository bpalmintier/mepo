*Start Block Quote
$ontext
-------------------------------------------------
Parameter updates for ERCOT 2009 with Carbon Cap


Estimated from: 
  Campbell, D. (2010, August 2). Cycling Coal and Gas: Challenges and Implications. Presented at 
  the EPRI Summer Seminar 2010. Retrieved from 
  http://mydocs.epri.com/docs/SummerSeminar10/Presentations/3.3_Campbell_Luminant.pdf
  
  Using: ERCOT Total capacity estimates.xlsx

Note: 5GW of internal combustion superpeakers were added to the CT bin as a quick short cut.

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   September 2010

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2010-11-24  11:30  bpalmintier   Original version based on ercot2009_update v1
  2  2011-10-11  14:15  bpalmintier   Renamed plant_size to gen_size (also related flags)
  3  2012-01-26  11:37  bpalmintier   Updated scenario dependent parameters with (S)
  5  2012-02-03  16:51  bpalmintier   SCALED units: GW, Mt CO2
-------------------------------------------------
$offtext

*Force cost of carbon (in terms of CO2) to zero      [$/t-CO2eq]   
   pCostCO2(S) = 0;         

*And set a Carbon Cap in metric tons CO2(eq) [Mt]
pCarbonCap(S) = 44.46;


*ERCOT has a 12.5% planning reserve
   pPlanReserve = 0.125;
*Let our operating reserves drive the design
*   pPlanReserve = 0;

table    pGenData(G, GEN_PARAMS)   "Existing Generation Updates"
             cap_cur   cap_max  cap_credit   gen_size
*               [GW]      [GW]   [fract]      [GW]
Nuke            8.200     Inf      0.9        1.350
Coal           15.500     Inf      0.85       0.600
CCGT           29.000     Inf      0.85       0.400
CT             20.500     Inf      0.85       0.230
Wind            8.962     Inf      0.1        0.050
;
