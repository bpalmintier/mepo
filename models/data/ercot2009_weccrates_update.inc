*Start Block Quote
$ontext
-------------------------------------------------
Parameter updates for ERCOT 2009
And unit commitment & startup parameters from WECC study 2009

Generator Parameters (except minimum output) estimated from:
  http://www.wecc.biz/committees/BOD/TEPPC/TAS/SWG/10222009/default.aspx?InstanceID=1

Capacity Estimated from: 
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
-------------------------------------------------
$offtext

*ERCOT has a 12.5% planning reserve
   pPlanReserve = 0.125;
*Let our operating reserves drive the design
*   pPlanReserve = 0;

table    pGenData(G, GEN_PARAMS)   "Existing Generation Updates"
             cap_cur   cap_max  cap_credit   gen_size
*               [MW]      [MW]     [fract]         [MW]
Nuke            8200       Inf        0.9          1350
Coal           15500       Inf        0.85          600
CCGT           29000       Inf        0.85          400
CT             20500       Inf        0.85          230
Wind            8962       Inf        0.1            50
;

table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
            c_var_om    heatrate
*            [$/MWh]   [MBTU/MWh]
Nuke            6.00      11     
Coal            2.00      10.1   
CCGT            5.70       7.5
CT              5.00      10.2
Wind               0       1
;

*-- Part 3: Unit Commitment
table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
             ramp_max     unit_min    c_start_fix       fuel_start   max_start
*           [p.u./hr]         [MW]      [$/start]     [MBTU/start]   [start/yr]
Nuke             0.2          1250         810000                0           2
Coal             0.6           300           3600             2602          50
CCGT             0.55          150           7500              600         300
CT               6              10           4300              104         Inf
Wind             1               0              0                0         Inf
;

*-- Part 4: Reserve Details
table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
           quick_start      reg_up  reg_down    spin_rsv
*               [p.u.]      [p.u.]    [p.u.]      [p.u.]
Nuke                 0        0         0              0
Coal                 0        0.01      0.01         0.1
CCGT                 0        0.01      0.01         0.1
CT                   1        0.05      0.05         0.5
Wind                 0        0         0              0
;
