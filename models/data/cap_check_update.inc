*Start Block Quote
$ontext
-------------------------------------------------
Parameter updates to check capacity computed using heuristics such at unit_min or ignoring 
max_start, etc. The idea is to to bound the number of each type of units to a range of 1 or a few
plants above and below the mix to provide a psuedo gradient search.


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
  1  2010-11-24  11:30  bpalmintier   Original version based on carbon_cap_update v1
  2  2010-11-25  11:30  bpalmintier   Updated to allow enough CCGT adjustments to replace a full nuke
  3  2011-10-11  14:15  bpalmintier   Renamed plant_size to gen_size (also related flags)
  4  2012-01-26  11:37  bpalmintier   Updated scenario dependent parameters with (S)
  5  2012-02-03  16:51  bpalmintier   SCALED units: GW, Mt CO2
-------------------------------------------------
$offtext

*Force cost of carbon (in terms of CO2) to zero      [$/t-CO2eq]   
   pCostCO2(S) = 0;         

*And set a Carbon Cap in metric tons CO2(eq) [Mt]
$if declared pCarbonCap
   pCarbonCap(S) = 44.46;


*ERCOT has a 12.5% planning reserve
   pPlanReserve = 0.125;
*Let our operating reserves drive the design
*   pPlanReserve = 0;

table    pGenData(G, GEN_PARAMS)   "Existing Generation Updates"
             cap_cur   cap_max  cap_credit   gen_size
*               [GW]      [GW]   [fract]      [GW]
Nuke           20.350     23.050   0.9        1.350
Coal           15.500     16.100   0.85       0.600
CCGT           31.000     35.000   0.85       0.400
CT             22.570     27.170   0.85       0.230
Wind           35.212     45.212   0.1        0.050
;
