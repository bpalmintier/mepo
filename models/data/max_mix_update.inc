*Start Block Quote
$ontext
-------------------------------------------------
Fixed Capacities based on results of test run #56 (ng_only-startup_rps0.4)
To test performance of fixed mix operations costing

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   September 2010

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2010-10-25  21:30  bpalmintier   Original version
  2  2010-10-26  07:30  bpalmintier   Set both cap_max and cap_cur
  3  2010-10-26  17:30  bpalmintier   Back to only setting cap_max as equal to known optimum
  4  2010-11-07  02:38  bpalmintier   Using values from ercot8760_startup_dm1.2_fast with max 1 CCGT
  5  2011-10-11  14:15  bpalmintier   Renamed plant_size to gen_size (also related flags)
  6  2012-02-07  21:05  bpalmintier   Scaled from MW to GW
-------------------------------------------------
$offtext

table    pGenData(G, GEN_PARAMS)   "Existing Generation Updates"
             cap_cur   cap_max  co2_embed   co2_ccs    p_min  cap_credit      gen_size
*               [GW]     [GW]     [t/GW]   [fract]  [fract]     [fract]         [GW]
Nuke            8.200   16300          0         0        0        0.9          1.350
Coal           15.500   15500          0         0        0        0.85         0.600
CCGT           29.000   29400          0         0        0        0.85         0.400
CT             20.500   37060          0         0        0        0.85         0.230
Wind            8.962   34462          0         0        0        0.1          0.050
;
