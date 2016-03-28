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
  1  2010-10-25  21:30  bpalmintier   Original version
  2  2010-10-26  07:30  bpalmintier   Set both cap_max and cap_cur
  3  2010-11-12  22:54  bpalmintier   Updated to match ercot8760_startup_dm1.2_c45_pmin_fast (#71)
  4  2010-11-22  08:40  bpalmintier   Updated to match ercot8760_dm1.2_c45_startup_ramp_rsrv_maxstart_v59 (#116)
  5  2010-11-24  20:40  bpalmintier   Updated to match #124: ercot8760_dm1.2_c45_basic_lp_v61
  6  2011-07-20  05:30  bpalmintier   Updated with ieee2011.inc and to match #147: ercot8760_dm1.2_c100_basic_mip_v140
  7  2011-07-20  05:30  bpalmintier   Updated with ieee2011.inc and to match #152: greenfield_dm1.2_c75_basic_mip_v142
  8  2011-07-21  02:30  bpalmintier   Updated to match #155: ercot2009_dm1.2_c75_basic_mip_v143
  9  2012-01-26  11:37  bpalmintier   Updated scenario dependent parameters with (S)
 10  2012-02-07  21:05  bpalmintier   Scaled from MW to GW
-------------------------------------------------
$offtext

*ERCOT has a 12.5% planning reserve
   pPlanReserve = 0.125;

*Base case for comparison
pRPS(S) = 0.2;
pCostCO2(S) = 75;
pDemandScale(S) = 1.2;

*And use fixed generation mixes from previous runs for comparison
table    pGenData(G, GEN_PARAMS)   "Existing Generation Updates"
                cap_cur  cap_max
*               [GW]     [GW]
wind            34.462   34.462
coal            16.405   16.405
New_Nuclear      6.750    6.750
New_Coal         0        0
New_NG_CCGT     15.600   15.600
New_NG_CT        0        0
Nuclear          5.139    5.139
NG_CCGT         23.690   23.690
NG_ST           20.372   20.372
NG_Peak          4.056    4.056
;
