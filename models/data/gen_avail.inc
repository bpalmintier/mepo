$ontext
----------------------------------------------------
 Generic Wind & Thermal Availability Data for use with Advanced Power family of models
 
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
  1  2011-07-24  08:15  bpalmintier   Adapted from gen_avail.csv
----------------------------------------------------- 
$offtext

parameter
    pGenAvailData(D, G)   "Complete long-term availability data"
    ;

$ondelim
* Note: assumes the set of demand time periods have already been established
table    pGenAvailData(D, G) "Generator availability Table"
time, Wind,    Nuke,  Coal,  CCGT,   CT
 d1,  0.1424,  0.9,   0.85,  0.85,  0.85
 d2,  0.1650,  0.9,   0.85,  0.85,  0.85
 d3,  0.1792,  0.9,   0.85,  0.85,  0.85
 d4,  0.1988,  0.9,   0.85,  0.85,  0.85
 d5,  0.2052,  0.9,   0.85,  0.85,  0.85
 d6,  0.2183,  0.9,   0.85,  0.85,  0.85
 d7,  0.2342,  0.9,   0.85,  0.85,  0.85
 d8,  0.2309,  0.9,   0.85,  0.85,  0.85
 d9,  0.2379,  0.9,   0.85,  0.85,  0.85
 d10, 0.2382,  0.9,   0.85,  0.85,  0.85
 d11, 0.2408,  0.9,   0.85,  0.85,  0.85
 d12, 0.2495,  0.9,   0.85,  0.85,  0.85
 d13, 0.2539,  0.9,   0.85,  0.85,  0.85
 d14, 0.2639,  0.9,   0.85,  0.85,  0.85
 d15, 0.2722,  0.9,   0.85,  0.85,  0.85
 d16, 0.2717,  0.9,   0.85,  0.85,  0.85
 d17, 0.2716,  0.9,   0.85,  0.85,  0.85
 d18, 0.2842,  0.9,   0.85,  0.85,  0.85
 d19, 0.3116,  0.9,   0.85,  0.85,  0.85
 d20, 0.3320,  0.9,   0.85,  0.85,  0.85
 ;
* Return to normal GAMS space delimited data formats
$offdelim
