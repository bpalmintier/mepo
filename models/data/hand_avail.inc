
$ontext
----------------------------------------------------
GENERIC (Lookup) HAND/Human readalbe Sequential WIND production data
----------------------------------------------------
For use with The Advanced Power family of models

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   June 2012

 Version History
###    Date      Time  Who            What
---  ---------- ----- -------------- ---------------------------------
  1  2012-06-28  15:32  bpalmintier   Adapted from ercot2007_avail.inc v3
----------------------------------------------------- 
$offtext

set
    D_AVAIL   "time blocks for wind data... assumed to be a superset of the demand timeseries"
               /av1*av24/
;

parameter
    pGenAvailData(D_AVAIL, G)   "Complete long-term availability data"
    ;

* Init all non-wind gens to always available
* ARGHHH... we have to explicitly exclude wind otherwise our table statement will NOT overwrite
* the default value assigned here... Why does GAMS have to behave this way.
pGenAvailData(D_AVAIL, G)$(not(sameas('wind',G))) = 1;

table    pGenAvailData(D_AVAIL, G) "Generator availability Table"
        Wind
av1      0.5
av2      0.4
av3      0.3
av4      0.2
av5      0.1
av6      0.1
av7      0.2
av8      0.3
av9      0.4
av10     0.5
av11     0.5
av12     0.3
av13     0.1
av14     0.3
av15     0.1
av16     0.5
av17     0.1
av18     0.5
av19     0.4
av20     0.2
av21     0.3
av22     0.5
av23     0.1
av24     0.3
;
