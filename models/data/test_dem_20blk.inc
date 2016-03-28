
$ontext
 -----------------------------------------------------
 Test system demand data for capacity planning for use with StaticCapPlan model

 The simple test system is meant to provide a consistant comparison for testing performance
 and checking against accepted "answers"

 20 Load blocks total
 
  Sample 20 level demand (including actual peak) data based on ERCOT 2009 loads
  This data was created using: ERCOT_2009_Hourly_Wind&Load_GAMS_formatter.xlsx ver.6

 originally coded in GAMS by Bryan Palmintier 2010-03-30

Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-11:07  11:40 bpalmintier    Adapted from demand.inc v5, data matches back to SVN r96
  2  2012-02-03  16:40  bpalmintier   SCALED units (GW, etc)
  3  2012-05-02  11:05  bpalmintier   Separate demand (D) into blocks (B) and time sub-periods (T)
 -----------------------------------------------------
$offtext

*---- ERCOT 2007 as 20 blocks explicitly including the actual peak -----
* Declare the actual set members (blocks, hours, etc)
set
    B           "Demand blocks (e.g. weeks), here a single set for entire load dur curve"
               /ldc/
	T			"Demand time sub-periods (e.g. hours), here the sub-blocks of the ldc"
               /d1*d20/
    ;

parameter
    pDemandData    (B, T, DEM_PARAMS)   "table of raw demand data"
    ;

* The actual demand data table:
table    pDemandData(B, T, DEM_PARAMS)   "Demand data"
         dur  power
*        [hr]  [GW]
ldc.d1    50  63.520
ldc.d2   459  56.248
ldc.d3   459  50.270
ldc.d4   459  45.749
ldc.d5   459  42.102
ldc.d6   459  39.529
ldc.d7   459  37.557
ldc.d8   459  36.017
ldc.d9   459  34.851
ldc.d10  459  33.762
ldc.d11  459  32.891
ldc.d12  459  32.046
ldc.d13  459  31.276
ldc.d14  459  30.554
ldc.d15  459  29.841
ldc.d16  459  28.919
ldc.d17  459  27.743
ldc.d18  459  26.412
ldc.d19  459  24.561
ldc.d20  448  22.671
;
