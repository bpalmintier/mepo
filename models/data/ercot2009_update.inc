*Start Block Quote
$ontext
-------------------------------------------------
Parameter updates for ERCOT 2009


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
  1  2010-09-12  03:30  bpalmintier   Original version
  2  2011-10-11  14:15  bpalmintier   Renamed plant_size to gen_size (also related flags)
  3  2012-02-07  21:05  bpalmintier   Scaled from MW to GW
-------------------------------------------------
$offtext

*ERCOT has a 12.5% planning reserve
   pPlanReserve = 0.125;
*Let our operating reserves drive the design
*   pPlanReserve = 0;

table    pGenData(G, GEN_PARAMS)   "Existing Generation Updates"
             cap_cur   cap_max  co2_embed   co2_ccs    p_min  cap_credit     gen_size
*               [GW]      [GW]     [t/GW]   [fract]  [fract]     [fract]        [GW]
Nuke            8.200     Inf          0         0        0        0.9          1.350
Coal           15.500     Inf          0         0        0        0.85         0.600
CCGT           29.000     Inf          0         0        0        0.85         0.400
CT             20.500     Inf          0         0        0        0.85         0.230
Wind            8.962     Inf          0         0        0        0.1          0.050
;
