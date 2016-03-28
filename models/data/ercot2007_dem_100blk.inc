
$ontext
-----------------------------------------------------
Non-Sequential Full Year Demand Load Duration Curve with 100 BLOCKS 
For ERCOT for use with The Advanced Power family of models

100 Blocks:
  Sorted by:   decreasing total load
  Peak block:  15hr, with power equal to peak
  Other blocks: 89hr (except final 23hr), load scaled to match annual total


  This data was created using: ERCOT_2007_Hourly_Wind&Load_GAMS_formatter.xlsx (SVN v379M)
  Actual recorded data from ERCOT POI page: 
    http://planning.ercot.com/data/hourly-windoutput/2007/
  
   When pasting from Excel, convert tabs to spaces using a tabstop of 12

 originally coded in GAMS by Bryan Palmintier 2010-03-30

History:
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-11-07  16:15  bpalmintier   Adapted from ercot2007_dem_day v1
  2  2012-01-30  03:04  bpalmintier   Convert demand to GW
  3  2012-05-04  12:35  bpalmintier   Separate demand (D) into blocks (B) and time sub-periods (T)
-----------------------------------------------------
$offtext

*---- ERCOT2007 demand as 100 block load duration curve -----
* Declare the actual set members (blocks, hours, etc)
set
    B           "Demand blocks (e.g. weeks), here a single set for entire load dur curve"
        /ldc/
    T           "Demand time sub-periods (e.g. hours), here the sub-blocks of the ldc"
        /d1*d100/
    ;

parameter
    pDemandData    (B, T, DEM_PARAMS)   "table of raw demand data"
    ;

* The actual demand data table:
table    pDemandData(B, T, DEM_PARAMS)   "Demand data"
            dur         power
*           [hr]        [GW]
ldc.d1      15          61.990
ldc.d2      89          56.764
ldc.d3      89          53.980
ldc.d4      89          52.428
ldc.d5      89          51.271
ldc.d6      89          50.321
ldc.d7      89          49.323
ldc.d8      89          48.595
ldc.d9      89          47.923
ldc.d10     89          47.231
ldc.d11     89          46.571
ldc.d12     89          45.972
ldc.d13     89          45.378
ldc.d14     89          44.894
ldc.d15     89          44.358
ldc.d16     89          43.794
ldc.d17     89          43.217
ldc.d18     89          42.683
ldc.d19     89          42.185
ldc.d20     89          41.690
ldc.d21     89          41.250
ldc.d22     89          40.817
ldc.d23     89          40.379
ldc.d24     89          40.048
ldc.d25     89          39.662
ldc.d26     89          39.279
ldc.d27     89          38.929
ldc.d28     89          38.577
ldc.d29     89          38.239
ldc.d30     89          37.942
ldc.d31     89          37.633
ldc.d32     89          37.355
ldc.d33     89          37.091
ldc.d34     89          36.847
ldc.d35     89          36.580
ldc.d36     89          36.294
ldc.d37     89          36.031
ldc.d38     89          35.791
ldc.d39     89          35.526
ldc.d40     89          35.328
ldc.d41     89          35.136
ldc.d42     89          34.934
ldc.d43     89          34.730
ldc.d44     89          34.539
ldc.d45     89          34.346
ldc.d46     89          34.177
ldc.d47     89          34.021
ldc.d48     89          33.857
ldc.d49     89          33.674
ldc.d50     89          33.504
ldc.d51     89          33.320
ldc.d52     89          33.179
ldc.d53     89          33.034
ldc.d54     89          32.883
ldc.d55     89          32.752
ldc.d56     89          32.609
ldc.d57     89          32.466
ldc.d58     89          32.320
ldc.d59     89          32.157
ldc.d60     89          32.029
ldc.d61     89          31.906
ldc.d62     89          31.770
ldc.d63     89          31.640
ldc.d64     89          31.503
ldc.d65     89          31.396
ldc.d66     89          31.275
ldc.d67     89          31.159
ldc.d68     89          31.044
ldc.d69     89          30.919
ldc.d70     89          30.816
ldc.d71     89          30.709
ldc.d72     89          30.598
ldc.d73     89          30.471
ldc.d74     89          30.303
ldc.d75     89          30.153
ldc.d76     89          29.992
ldc.d77     89          29.803
ldc.d78     89          29.617
ldc.d79     89          29.420
ldc.d80     89          29.205
ldc.d81     89          28.974
ldc.d82     89          28.747
ldc.d83     89          28.516
ldc.d84     89          28.263
ldc.d85     89          27.985
ldc.d86     89          27.697
ldc.d87     89          27.373
ldc.d88     89          27.039
ldc.d89     89          26.701
ldc.d90     89          26.333
ldc.d91     89          25.919
ldc.d92     89          25.499
ldc.d93     89          25.136
ldc.d94     89          24.756
ldc.d95     89          24.386
ldc.d96     89          23.999
ldc.d97     89          23.616
ldc.d98     89          23.294
ldc.d99     89          22.835
ldc.d100    23          22.209
;
