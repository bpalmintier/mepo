
$ontext
-----------------------------------------------------
Sequential Hourly Demand data for ONE DAY ONLY.
For ERCOT for use with The Advanced Power family of models

  This data was created using: ERCOT_2007_Hourly_Wind&Load_GAMS_formatter.xlsx (SVN v221)
  Actual recorded data from ERCOT POI page: 
    http://planning.ercot.com/data/hourly-windoutput/2007/
  
  Data from: Monday 2007-Aug-13
  Which contains the PEAK DEMAND (4pm)

  When pasting from Excel, convert tabs to spaces using a tabstop of 12

 originally coded in GAMS by Bryan Palmintier 2010-03-30

History:
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-10-14  01:15  bpalmintier   Adapted from ercot2007_dem_wk_pk v2
  2  2012-05-04  11:45  bpalmintier   Adapted for separate blocks (B) and time sub-periods (T)
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
day.t01     5376        1           41.167
day.t02     5377        1           38.359
day.t03     5378        1           36.423
day.t04     5379        1           35.280
day.t05     5380        1           34.715
day.t06     5381        1           34.955
day.t07     5382        1           36.792
day.t08     5383        1           38.234
day.t09     5384        1           39.539
day.t10     5385        1           42.929
day.t11     5386        1           46.996
day.t12     5387        1           51.759
day.t13     5388        1           55.542
day.t14     5389        1           58.710
day.t15     5390        1           60.851
day.t16     5391        1           61.919
day.t17     5392        1           61.990
day.t18     5393        1           61.355
day.t19     5394        1           60.349
day.t20     5395        1           58.313
day.t21     5396        1           55.839
day.t22     5397        1           54.667
day.t23     5398        1           50.845
day.t24     5399        1           46.603
;
