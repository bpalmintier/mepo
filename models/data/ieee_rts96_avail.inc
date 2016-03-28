
$ontext
----------------------------------------------------
 IEEE Reliability Test System Availability Data
 
 Sources:
[1] R. N. Allan, R. Billinton, and N. M. K. Abdel-Gawad, “The IEEE Reliability Test System - 
Extensions to and Evaluation of the Generating System,” IEEE Transactions on Power Systems, 
vol. 1, no. 4, pp. 1-7, Nov. 1986.

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   Sept 2011

 Version History
###    Date      Time  Who            What
---  ---------- ----- -------------- ---------------------------------
  1  2011-09-26  02:15  bpalmintier   Adapted from ERCOT_water_avail.inc v3
----------------------------------------------------- 
$offtext
parameter
    pGenAvailData(D, G)   "Complete long-term availability data"
    ;

*For now assume constant, full availability
pGenAvailData(D, G) = 1;
