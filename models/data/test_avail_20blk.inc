
$ontext
----------------------------------------------------
 Test Generic Wind & Thermal Availability Data for use with Advanced Power family of models
 
 The simple test system is meant to provide a consistant comparison for testing performance
 and checking against accepted "answers"

 20 Load blocks total
 
 Sources:
   Wind: Historic power production from 2009 for ERCOT, normalized to percentage of installed
    capacity using ERCOT_2009_Hourly_Wind&Load_GAMS_formatter.xlsx
   Other: Rough estimates

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   July 2011

 Version History
###    Date      Time  Who            What
---  ---------- ----- -------------- ---------------------------------
  1  2011-11-07  11:25  bpalmintier   Adapted from gen_avail.inc v1  data matches back to SVN r96
  2  2012-05-02  11:05  bpalmintier   Separate demand (D) into blocks (B) and time sub-periods (T)
  3  2012-06-06  23:15  bpalmintier   Converted to fixed width (non-delimited) for MATLAB compatability
----------------------------------------------------- 
$offtext
parameter
    pGenAvailData(B, T, G)   "Complete long-term availability data"
    ;

* Note: assumes the set of demand time periods have already been established
table    pGenAvailData(B, T, G) "Generator availability Table"
          Wind     Nuke   Coal   CCGT   CT
 ldc.d1   0.1424   0.9    0.85   0.85   0.85
 ldc.d2   0.1650   0.9    0.85   0.85   0.85
 ldc.d3   0.1792   0.9    0.85   0.85   0.85
 ldc.d4   0.1988   0.9    0.85   0.85   0.85
 ldc.d5   0.2052   0.9    0.85   0.85   0.85
 ldc.d6   0.2183   0.9    0.85   0.85   0.85
 ldc.d7   0.2342   0.9    0.85   0.85   0.85
 ldc.d8   0.2309   0.9    0.85   0.85   0.85
 ldc.d9   0.2379   0.9    0.85   0.85   0.85
 ldc.d10  0.2382   0.9    0.85   0.85   0.85
 ldc.d11  0.2408   0.9    0.85   0.85   0.85
 ldc.d12  0.2495   0.9    0.85   0.85   0.85
 ldc.d13  0.2539   0.9    0.85   0.85   0.85
 ldc.d14  0.2639   0.9    0.85   0.85   0.85
 ldc.d15  0.2722   0.9    0.85   0.85   0.85
 ldc.d16  0.2717   0.9    0.85   0.85   0.85
 ldc.d17  0.2716   0.9    0.85   0.85   0.85
 ldc.d18  0.2842   0.9    0.85   0.85   0.85
 ldc.d19  0.3116   0.9    0.85   0.85   0.85
 ldc.d20  0.3320   0.9    0.85   0.85   0.85
 ;
