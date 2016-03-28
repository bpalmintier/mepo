
$ontext
----------------------------------------------------
 Generic Wind & Thermal Availability Data for use with Advanced Power family of models
 
 168 Load blocks total
 
 Important:
  -- Not Compatible with CapPlanDp MATLAB model, because, time indexed availability is only 
      provided for Wind, all others set in bulk.
  -- All non-wind blocks set to a constant availability of 1.0, so we can handle any mix of
     non wind resources for our binary vs integer runtime comparisons
 
 Sources:
   Wind: Historic power production from 2009 for ERCOT, normalized to percentage of installed
    capacity using ERCOT_2009_Hourly_Wind&Load_GAMS_formatter.xlsx
   Other: Set to 1 for eas of comparison

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   July 2011

 Version History
###    Date      Time  Who            What
---  ---------- ----- -------------- ---------------------------------
  1  2011-07-24  10:45  bpalmintier   Adapted from gens_sepunit_ercot2009_week.inc v2 & gen_avail.inc v1
----------------------------------------------------- 
$offtext

parameter
    pGenAvailData(D, G)   "Complete long-term availability data"
    ;

* Note: assumes the set of demand time periods have already been established
* -- Fixed availability (traditional generators, when maintenance not included)
* Note: first set all to 1, then change the values as needed.
pGenAvailData(D, G)$(pGenData(G,'fuel') ne wind) = 1;

* -- Read hourly availability tables for wind
table    pGenAvailData(D, G) "Generator availability Table"
        Wind
wt1     0.316
wt2     0.322
wt3     0.322
wt4     0.305
wt5     0.329
wt6     0.309
wt7     0.328
wt8     0.301
wt9     0.263
wt10    0.255
wt11    0.222
wt12    0.173
wt13    0.096
wt14    0.088
wt15    0.092
wt16    0.121
wt17    0.138
wt18    0.147
wt19    0.162
wt20    0.171
wt21    0.188
wt22    0.198
wt23    0.266
wt24    0.339
wt25    0.356
wt26    0.379
wt27    0.397
wt28    0.338
wt29    0.363
wt30    0.386
wt31    0.338
wt32    0.320
wt33    0.269
wt34    0.290
wt35    0.276
wt36    0.220
wt37    0.146
wt38    0.105
wt39    0.109
wt40    0.136
wt41    0.162
wt42    0.184
wt43    0.210
wt44    0.238
wt45    0.250
wt46    0.267
wt47    0.373
wt48    0.416
wt49    0.415
wt50    0.439
wt51    0.361
wt52    0.371
wt53    0.359
wt54    0.371
wt55    0.366
wt56    0.362
wt57    0.360
wt58    0.391
wt59    0.323
wt60    0.312
wt61    0.307
wt62    0.266
wt63    0.245
wt64    0.241
wt65    0.257
wt66    0.276
wt67    0.271
wt68    0.278
wt69    0.298
wt70    0.307
wt71    0.326
wt72    0.366
wt73    0.373
wt74    0.418
wt75    0.391
wt76    0.405
wt77    0.376
wt78    0.363
wt79    0.358
wt80    0.412
wt81    0.333
wt82    0.365
wt83    0.301
wt84    0.237
wt85    0.202
wt86    0.186
wt87    0.229
wt88    0.229
wt89    0.217
wt90    0.238
wt91    0.272
wt92    0.308
wt93    0.337
wt94    0.296
wt95    0.306
wt96    0.345
wt97    0.360
wt98    0.366
wt99    0.378
wt100   0.361
wt101   0.370
wt102   0.369
wt103   0.317
wt104   0.276
wt105   0.220
wt106   0.216
wt107   0.183
wt108   0.164
wt109   0.103
wt110   0.079
wt111   0.094
wt112   0.089
wt113   0.093
wt114   0.089
wt115   0.108
wt116   0.113
wt117   0.114
wt118   0.145
wt119   0.197
wt120   0.241
wt121   0.263
wt122   0.341
wt123   0.351
wt124   0.380
wt125   0.245
wt126   0.187
wt127   0.141
wt128   0.111
wt129   0.062
wt130   0.035
wt131   0.044
wt132   0.034
wt133   0.026
wt134   0.024
wt135   0.034
wt136   0.035
wt137   0.047
wt138   0.062
wt139   0.094
wt140   0.113
wt141   0.107
wt142   0.136
wt143   0.183
wt144   0.207
wt145   0.217
wt146   0.214
wt147   0.141
wt148   0.174
wt149   0.133
wt150   0.097
wt151   0.064
wt152   0.067
wt153   0.047
wt154   0.047
wt155   0.038
wt156   0.037
wt157   0.037
wt158   0.038
wt159   0.037
wt160   0.038
wt161   0.037
wt162   0.037
wt163   0.038
wt164   0.038
wt165   0.038
wt166   0.038
wt167   0.041
wt168   0.046
;