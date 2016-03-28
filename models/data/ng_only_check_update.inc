*Start Block Quote
$ontext
-------------------------------------------------
Generator Parameter Limits to look at high RPS mixes, where Nat'l Gas is the clear winner over Coal and Nuke. New construction is limited to one plant each for coal and nukes as a check. If this one plant is not built, then the assumption of only NG was correct. This limits the search in the investment decision space for faster MIP convergence.


Note: 5GW of internal combustion superpeakers were added to the CT bin as a quick short cut.

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   September 2010

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2010-10-24  03:30  bpalmintier   Original version
  2  2011-10-11  14:15  bpalmintier   Renamed plant_size to gen_size (also related flags)
  3  2012-02-07  21:05  bpalmintier   Scaled from MW to GW
-------------------------------------------------
$offtext

table    pGenData(G, GEN_PARAMS)   "Existing Generation Updates"
             cap_cur   cap_max  co2_embed   co2_ccs    p_min  cap_credit      gen_size
*               [GW]      [GW]     [t/GW]   [fract]  [fract]     [fract]        [GW]
Nuke               0    1.350          0         0        0        0.9          1.350
Coal               0    0.600          0         0        0        0.85         0.600
CCGT               0      Inf          0         0        0        0.85         0.400
CT                 0      Inf          0         0        0        0.85         0.230
Wind               0      Inf          0         0        0        0.1          0.050
;
