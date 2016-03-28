
$ontext
-----------------------------------------------------
Human-debugging friendly Sequential Hourly Demand data for ONE DAY ONLY.
For use with The Advanced Power family of models

 originally coded in GAMS by Bryan Palmintier 2012
 
History:
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2012-06-28  14:26  bpalmintier   Adapted from ercot2007_dem_day.inc
-----------------------------------------------------
$offtext

* Declare the actual set members (blocks, hours, etc) and add hr_of_yr cross reference
sets
    DEM_PARAMS  "demand block table parameters from load duration curve"
       /
        avail_idx   "corresponding hour of the year index for avail lookup"
        dur         "duration of block                 [hrs]"
        power       "average power demand during block [GW]"
       /

    B           "Demand blocks (e.g. weeks or ldc)"
        /day/
    T           "Demand time sub-periods (e.g. hours or ldc sub-blocks)"
        /t01*t24/
;

* The actual demand data table:
table    pDemandData(B, T, DEM_PARAMS)   "Demand data"
            avail_idx   dur         power
*           [#]         [hr]        [GW]
day.t01        1        1           50
day.t02        2        1           60
day.t03        3        1           70
day.t04        4        1           80
day.t05        5        1           90
day.t06        6        1           100
day.t07        7        1           80
day.t08        8        1           60
day.t09        9        1           40
day.t10       10        1           60
day.t11       11        1           80
day.t12       12        1           100
day.t13       13        1           75
day.t14       14        1           50
day.t15       15        1           25
day.t16       16        1           50
day.t17       17        1           50
day.t18       18        1           50
day.t19       19        1           75
day.t20       20        1           100
day.t21       21        1           100
day.t22       22        1           100
day.t23       23        1           75
day.t24       24        1           50
;
