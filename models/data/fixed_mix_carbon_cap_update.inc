*Start Block Quote
$ontext
-------------------------------------------------
To test performance of fixed mix operations costing

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   September 2010

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2010-11-30  12:40  bpalmintier   Combined fixed_mix_update v5 with carbon_cap_update v1
  2  2010-11-30  13:30  bpalmintier   Rounded up to next integer plant multiple (+1 for wind)
  3  2011-10-11  14:15  bpalmintier   Renamed plant_size to gen_size (also related flags)
  4  2012-01-26  11:37  bpalmintier   Updated scenario dependent parameters with (S)
  5  2012-02-07  21:05  bpalmintier   Scaled from MW to GW & co2 tons to Mt
-------------------------------------------------
$offtext

*Force cost of carbon (in terms of CO2) to zero      [$/t-CO2eq]   
   pCostCO2(S) = 0;         

*And set a Carbon Cap in million metric tons CO2(eq)
pCarbonCap(S) = 44.46;


*ERCOT has a 12.5% planning reserve
   pPlanReserve = 0.125;

table    pGenData(G, GEN_PARAMS)   "Existing Generation Updates"
             cap_cur   cap_max  co2_embed   co2_ccs    p_min  cap_credit      gen_size
*               [GW]      [GW]     [t/GW]   [fract]  [fract]     [fract]         [GW]
Nuke          22.950    22.950          0         0        0        0.9          1.350
Coal          15.600    15.600          0         0        0        0.85         0.600
CCGT          29.200    29.200          0         0        0        0.85         0.400
CT            29.670    29.670          0         0        0        0.85         0.230
Wind          34.500    34.500          0         0        0        0.1          0.050
;
