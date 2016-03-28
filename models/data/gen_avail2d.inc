$ontext
----------------------------------------------------
 Generic 2 Plant Thermal Availability Data for use with Advanced Power family of models
 
 20 Load blocks total, only 2 plants for debugging purposes
 
 Sources:
   Other: Rough estimates

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   July 2011

 Version History
###    Date      Time  Who            What
---  ---------- ----- -------------- ---------------------------------
  1  2011-07-24  08:15  bpalmintier   Adapted from gen_avail2d.csv
----------------------------------------------------- 
$offtext

parameter
    pGenAvailData(D, G)   "Complete long-term availability data"
    ;

$ondelim
* Note: assumes the set of demand time periods have already been established
table    pGenAvailData(D, G) "Generator availability Table"
time,  CCGT,   CT
 d1,  0.85,  0.85
 d2,  0.85,  0.85
 d3,  0.85,  0.85
 d4,  0.85,  0.85
 d5,  0.85,  0.85
 d6,  0.85,  0.85
 d7,  0.85,  0.85
 d8,  0.85,  0.85
 d9,  0.85,  0.85
 d10,  0.85,  0.85
 d11,  0.85,  0.85
 d12,  0.85,  0.85
 d13,  0.85,  0.85
 d14,  0.85,  0.85
 d15,  0.85,  0.85
 d16,  0.85,  0.85
 d17,  0.85,  0.85
 d18,  0.85,  0.85
 d19,  0.85,  0.85
 d20,  0.85,  0.85
 ;
* Return to normal GAMS space delimited data formats
$offdelim
