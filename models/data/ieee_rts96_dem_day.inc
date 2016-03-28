
$ontext
-----------------------------------------------------
Sequential Hourly Demand data for ONE DAY ONLY.
For IEEE Reliability Test system for use with StaticCapPlan model

  This data was created using: IEEE Reliability Test System 1996 Data.xlsx

  When pasting from Excel, convert tabs to spaces using a tabstop of 8

 originally coded in GAMS by Bryan Palmintier 2010-03-30

History:
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-09-26  02:00  bpalmintier   Adapted from ieee_rts96_dem_wk v1
  2  2012-02-07  21:05  bpalmintier   Scaled from MW to GW
-----------------------------------------------------
$offtext

*---- IEEE Reliability Test System demand as full sequential hourly -----
* Declare the actual set members (blocks, hours, etc)
set
  D   demand blocks
               /t0*t23/

* The actual demand data table:
table    pDemandData(D, DEM_PARAMS)   Demand data
        dur     power
*       [hr]    [GW]
t0      1       1.8240
t1      1       1.7100
t2      1       1.6530
t3      1       1.5960
t4      1       1.5960
t5      1       1.6530
t6      1       1.8240
t7      1       2.1660
t8      1       2.4795
t9      1       2.7075
t10     1       2.8215
t11     1       2.8500
t12     1       2.8215
t13     1       2.8500
t14     1       2.8500
t15     1       2.7645
t16     1       2.7360
t17     1       2.7360
t18     1       2.6505
t19     1       2.6220
t20     1       2.6220
t21     1       2.6505
t22     1       2.4795
t23     1       2.0520
;
