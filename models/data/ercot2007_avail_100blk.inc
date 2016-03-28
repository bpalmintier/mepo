
$ontext
----------------------------------------------------
Non-Sequential Full Year Wind data corresponding to 100 BLOCKS load duration curve
For ERCOT for use with The Advanced Power family of models

100 Blocks:
  Sorted by:   decreasing total load
  Peak block:  15hr, with power equal to peak
  Other blocks: 89hr (except final 23hr), load scaled to match annual total
  Average wind for each block recorded

NOTE: this file indexes over demand blocks (B) & sub-periods(T) and therefore requires B, T,
anand S sets to already be defined. See ercot2007_avail.inc for a more generic mapping
table. The advantage of this file is that it is faster to read into GAMS. However it is
limited to data withe identical B & T implementations

  This data was created using: ERCOT_2007_Hourly_Wind&Load_GAMS_formatter.xlsx (SVN v221)
  Actual recorded data from ERCOT POI page: 
    http://planning.ercot.com/data/hourly-windoutput/2007/
  
  When pasting from Excel, convert tabs to spaces using a tabstop of 8

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   Sept 2011

 Version History
###    Date      Time  Who            What
---  ---------- ----- -------------- ---------------------------------
  1  2011-11-07  16:20  bpalmintier   Adapted from ercot2007_avail.inc v2
  2  2012-05-04  12:35  bpalmintier   Separate demand (D) into blocks (B) and time sub-periods (T)
----------------------------------------------------- 
$offtext

parameter
    pGenAvailData(B, T, G)   "Complete long-term availability data"
    ;

* Init all non-wind gens to always available
* ARGHHH... we have to explicitly exclude wind otherwise our table statement will NOT overwrite
* the default value assigned here... Why does GAMS have to behave this way.
pGenAvailData(B, T, G)$(not(sameas('wind',G))) = 1;

table    pGenAvailData(B, T, G) "Generator availability Table"
             wind
 ldc.d1     0.1019
 ldc.d2     0.2453
 ldc.d3     0.1855
 ldc.d4     0.1773
 ldc.d5     0.1979
 ldc.d6     0.2021
 ldc.d7     0.1748
 ldc.d8     0.1925
 ldc.d9     0.1755
 ldc.d10    0.1873
 ldc.d11    0.1873
 ldc.d12    0.1710
 ldc.d13    0.1865
 ldc.d14    0.1731
 ldc.d15    0.2524
 ldc.d16    0.1969
 ldc.d17    0.1939
 ldc.d18    0.2032
 ldc.d19    0.2033
 ldc.d20    0.2037
 ldc.d21    0.2055
 ldc.d22    0.2053
 ldc.d23    0.2285
 ldc.d24    0.2402
 ldc.d25    0.1958
 ldc.d26    0.2077
 ldc.d27    0.2363
 ldc.d28    0.2900
 ldc.d29    0.1895
 ldc.d30    0.2275
 ldc.d31    0.2366
 ldc.d32    0.2286
 ldc.d33    0.1824
 ldc.d34    0.2514
 ldc.d35    0.2256
 ldc.d36    0.2525
 ldc.d37    0.2245
 ldc.d38    0.2567
 ldc.d39    0.2676
 ldc.d40    0.2666
 ldc.d41    0.2379
 ldc.d42    0.2674
 ldc.d43    0.2474
 ldc.d44    0.2750
 ldc.d45    0.3035
 ldc.d46    0.2650
 ldc.d47    0.2553
 ldc.d48    0.2701
 ldc.d49    0.2853
 ldc.d50    0.3136
 ldc.d51    0.2736
 ldc.d52    0.2867
 ldc.d53    0.2462
 ldc.d54    0.2661
 ldc.d55    0.2748
 ldc.d56    0.2857
 ldc.d57    0.2698
 ldc.d58    0.2970
 ldc.d59    0.2679
 ldc.d60    0.2354
 ldc.d61    0.2921
 ldc.d62    0.2964
 ldc.d63    0.2750
 ldc.d64    0.2405
 ldc.d65    0.2501
 ldc.d66    0.2982
 ldc.d67    0.2441
 ldc.d68    0.2599
 ldc.d69    0.2680
 ldc.d70    0.3050
 ldc.d71    0.2838
 ldc.d72    0.2694
 ldc.d73    0.2916
 ldc.d74    0.2901
 ldc.d75    0.2577
 ldc.d76    0.2455
 ldc.d77    0.2855
 ldc.d78    0.2686
 ldc.d79    0.3107
 ldc.d80    0.2817
 ldc.d81    0.2750
 ldc.d82    0.2768
 ldc.d83    0.3181
 ldc.d84    0.2495
 ldc.d85    0.3257
 ldc.d86    0.2955
 ldc.d87    0.3242
 ldc.d88    0.3426
 ldc.d89    0.3595
 ldc.d90    0.3335
 ldc.d91    0.3847
 ldc.d92    0.4117
 ldc.d93    0.3479
 ldc.d94    0.3476
 ldc.d95    0.3564
 ldc.d96    0.3930
 ldc.d97    0.4114
 ldc.d98    0.3794
 ldc.d99    0.3661
 ldc.d100   0.3903
 ;
