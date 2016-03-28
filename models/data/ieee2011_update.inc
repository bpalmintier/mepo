
$ontext
-------------------------------------------------
Update file for IEEE PES General meeting 2011 (Detroit) presentation runs
Goal is to match assumptions from original paper, but use the new data formats

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   July 2011

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-07            bpalmintier   Original version
  2  2012-01-26  11:37  bpalmintier   Updated scenario dependent parameters with (S)
  3  2012-02-07  21:05  bpalmintier   Scaled from MW to GW
-------------------------------------------------
$offtext

*Base case for comparison
pRPS(S) = 0.2;
pCostCO2(S) = 75;
pDemandScale(S) = 1.2;


$ontext
*Old assumptions (used in paper) for existing capacity
table    pGenData(G, GEN_PARAMS)   "Existing Generation Updates"
             cap_cur
*               [GW]
Nuke            8.200
Coal           15.500
CCGT           29.000
CT             20.500
Wind            8.962
;
$offtext

$ontext
*"Optimal" mix based on 5% RPS and no demand scaling
table    pGenData(G, GEN_PARAMS)   "Existing Generation Updates"
             cap_cur
*               [GW]
Nuke               0
Coal           24.000
CCGT           16.800
CT             33.580
Wind            8.962
;
$offtext

*OR force our build from scratch to use only new generators
$ifthen set from_scratch
table    pGenData(G, GEN_PARAMS)   "Existing Generation Updates"
             cap_max
*             [GW]
Nuclear        0
Coal           0
NG_CCGT        0
NG_ST          0
NG_Peak        0
;
$endif