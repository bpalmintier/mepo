*Start Block Quote
$ontext
-------------------------------------------------
Similar to Fixed Mix, except that GAMS gets to optimize the capacity for peakers (only)

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   September 2010

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2010-11-12  22:54  bpalmintier   Adapted from fixed_mix_update v3 (using ercot8760_startup_dm1.2_c45_pmin_fast capacities)
  2  2010-11-22  07:54  bpalmintier   Set to 1 more CCGT than ercot8760_dm1.2_c0_startup_ramp_rsrv_maxstart_v60 
  3  2011-10-11  14:15  bpalmintier   Renamed plant_size to gen_size (also related flags)
  4  2012-02-07  21:05  bpalmintier   Scaled from MW to GW
-------------------------------------------------
$offtext

*ERCOT has a 12.5% planning reserve
   pPlanReserve = 0.125;

table    pGenData(G, GEN_PARAMS)   "Existing Generation Updates"
             cap_cur   cap_max  co2_embed   co2_ccs    p_min  cap_credit      gen_size
*               [GW]      [GW]     [t/GW]   [fract]  [fract]     [fract]         [GW]
Nuke            8.200    8.200          0         0        0        0.9          1.350
Coal           15.500   15.500          0         0        0        0.85         0.600
CCGT           29.400   29.400          0         0        0        0.85         0.400
CT             20.500      Inf          0         0        0        0.85         0.230
Wind           34.462   34.462          0         0        0        0.1          0.050
;
