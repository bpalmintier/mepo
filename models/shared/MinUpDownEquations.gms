
$ontext
----------------------------------------------------
  Abstracts out the rather convoluted minimum up and down time computations for Advanced Power 
  Family of Models.
  
LIMITATIONS:
   -- Currently limited to up/down times of 50hrs
   -- Hourly demand. (Or more generally: equal demand periods and that the min_up & min_down
       parameters are specified in units of demand periods)
  

Command Line Parameters Implemented Here:
    --min_up_down=(off)  Enforce minimum up and down time constraints (default: ignore)

Additional control variables:

IMPORTANT: Currently assumes that the demand dataset is hourly. This could change with more sums

IMPORTANT: time looping (ie first period follows the last) controlled by the no_loop command
 line parameter through mDemShift

IMPORTANT: unlike most equation $include files, this file must be loaded AFTER reading in
the generator datafile. That way our $macros expand properly

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   September 2011

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-09-27  23:05  bpalmintier   Original Code
  2  2011-10-11  14:15  bpalmintier   Renamed plant_size to gen_size (also related flags)
  3  2012-01-25  23:55  bpalmintier   Added scenario support for stochastic UC, multi-period planning, etc.
  4  2012-03-07  12:55  bpalmintier   Added support for partial period simulation through D_SIM
  5  2012-03-09  12:45  bpalmintier   Replace -- with mDemandShift for optional loop startup
  6  2012-05-02  10:45  bpalmintier   Separate demand (D) into blocks (B) and time sub-periods (T)
-----------------------------------------------------
$offtext

*================================*
*         Declarations           *
*================================*
set
GEN_PARAMS
   /
    min_up
    min_down
   / 
;

* ======  Declare Variables

* ======  Declare Equations
equations
    eMinUpTime(B, T, G, S)
    eMinDownTime(B, T, G, S)
    ;

*================================*
*     The Actual Equations       *
*================================*
* Important: we must be included into a larger model, so no objective function defined

* == Once on, a generator must remain on for specified number of periods (eMinUpTime)
eMinUpTime(B, T, G, S)$( B_SIM(B)
                      and G_UC(G) 
                      and pGen(G, 'min_up', S) > 1 
                      and pGen(G,'gen_size', S) <> 0 ) ..
    vUnitCommit(B, T, G, S)
    =g=
    vStartup(B, T, G, S) 
    + vStartup(B, mDemShift(T,1), G, S)$(pGen(G, 'min_up', S) > 1)
    + vStartup(B, mDemShift(T,2), G, S)$(pGen(G, 'min_up', S) > 2)
    + vStartup(B, mDemShift(T,3), G, S)$(pGen(G, 'min_up', S) > 3)
    + vStartup(B, mDemShift(T,4), G, S)$(pGen(G, 'min_up', S) > 4)
    + vStartup(B, mDemShift(T,5), G, S)$(pGen(G, 'min_up', S) > 5)
    + vStartup(B, mDemShift(T,6), G, S)$(pGen(G, 'min_up', S) > 6)
    + vStartup(B, mDemShift(T,7), G, S)$(pGen(G, 'min_up', S) > 7)
    + vStartup(B, mDemShift(T,8), G, S)$(pGen(G, 'min_up', S) > 8)
    + vStartup(B, mDemShift(T,9), G, S)$(pGen(G, 'min_up', S) > 9)
    + vStartup(B, mDemShift(T,10), G, S)$(pGen(G, 'min_up', S) > 10)
    + vStartup(B, mDemShift(T,11), G, S)$(pGen(G, 'min_up', S) > 11)
    + vStartup(B, mDemShift(T,12), G, S)$(pGen(G, 'min_up', S) > 12)
    + vStartup(B, mDemShift(T,13), G, S)$(pGen(G, 'min_up', S) > 13)
    + vStartup(B, mDemShift(T,14), G, S)$(pGen(G, 'min_up', S) > 14)
    + vStartup(B, mDemShift(T,15), G, S)$(pGen(G, 'min_up', S) > 15)
    + vStartup(B, mDemShift(T,16), G, S)$(pGen(G, 'min_up', S) > 16)
    + vStartup(B, mDemShift(T,17), G, S)$(pGen(G, 'min_up', S) > 17)
    + vStartup(B, mDemShift(T,18), G, S)$(pGen(G, 'min_up', S) > 18)
    + vStartup(B, mDemShift(T,19), G, S)$(pGen(G, 'min_up', S) > 19)
    + vStartup(B, mDemShift(T,20), G, S)$(pGen(G, 'min_up', S) > 20)
    + vStartup(B, mDemShift(T,21), G, S)$(pGen(G, 'min_up', S) > 21)
    + vStartup(B, mDemShift(T,22), G, S)$(pGen(G, 'min_up', S) > 22)
    + vStartup(B, mDemShift(T,23), G, S)$(pGen(G, 'min_up', S) > 23)
    + vStartup(B, mDemShift(T,24), G, S)$(pGen(G, 'min_up', S) > 24)
    + vStartup(B, mDemShift(T,25), G, S)$(pGen(G, 'min_up', S) > 25)
    + vStartup(B, mDemShift(T,26), G, S)$(pGen(G, 'min_up', S) > 26)
    + vStartup(B, mDemShift(T,27), G, S)$(pGen(G, 'min_up', S) > 27)
    + vStartup(B, mDemShift(T,28), G, S)$(pGen(G, 'min_up', S) > 28)
    + vStartup(B, mDemShift(T,29), G, S)$(pGen(G, 'min_up', S) > 29)
    + vStartup(B, mDemShift(T,30), G, S)$(pGen(G, 'min_up', S) > 30)    
    + vStartup(B, mDemShift(T,31), G, S)$(pGen(G, 'min_up', S) > 31)
    + vStartup(B, mDemShift(T,32), G, S)$(pGen(G, 'min_up', S) > 32)
    + vStartup(B, mDemShift(T,33), G, S)$(pGen(G, 'min_up', S) > 33)
    + vStartup(B, mDemShift(T,34), G, S)$(pGen(G, 'min_up', S) > 34)
    + vStartup(B, mDemShift(T,35), G, S)$(pGen(G, 'min_up', S) > 35)
    + vStartup(B, mDemShift(T,36), G, S)$(pGen(G, 'min_up', S) > 36)
    + vStartup(B, mDemShift(T,37), G, S)$(pGen(G, 'min_up', S) > 37)
    + vStartup(B, mDemShift(T,38), G, S)$(pGen(G, 'min_up', S) > 38)
    + vStartup(B, mDemShift(T,39), G, S)$(pGen(G, 'min_up', S) > 39)
    + vStartup(B, mDemShift(T,40), G, S)$(pGen(G, 'min_up', S) > 40)    
    + vStartup(B, mDemShift(T,41), G, S)$(pGen(G, 'min_up', S) > 41)
    + vStartup(B, mDemShift(T,42), G, S)$(pGen(G, 'min_up', S) > 42)
    + vStartup(B, mDemShift(T,43), G, S)$(pGen(G, 'min_up', S) > 43)
    + vStartup(B, mDemShift(T,44), G, S)$(pGen(G, 'min_up', S) > 44)
    + vStartup(B, mDemShift(T,45), G, S)$(pGen(G, 'min_up', S) > 45)
    + vStartup(B, mDemShift(T,46), G, S)$(pGen(G, 'min_up', S) > 46)
    + vStartup(B, mDemShift(T,47), G, S)$(pGen(G, 'min_up', S) > 47)
    + vStartup(B, mDemShift(T,48), G, S)$(pGen(G, 'min_up', S) > 48)
    + vStartup(B, mDemShift(T,49), G, S)$(pGen(G, 'min_up', S) > 49)
    ;
    
eMinDownTime(B, T, G, S)$( B_SIM(B)
                        and G_UC(G)
                        and pGen(G, 'min_down', S) > 1 
                        and pGen(G,'gen_size', S) <> 0 ) ..
    (%capacity_G% / pGen(G,'gen_size', S) - vUnitCommit(B, T, G, S))
    =g=
    vShutdown(B, T, G, S) 
    + vShutDown(B, mDemShift(T,1), G, S)$(pGen(G, 'min_down', S) > 1)
    + vShutDown(B, mDemShift(T,2), G, S)$(pGen(G, 'min_down', S) > 2)
    + vShutDown(B, mDemShift(T,3), G, S)$(pGen(G, 'min_down', S) > 3)
    + vShutDown(B, mDemShift(T,4), G, S)$(pGen(G, 'min_down', S) > 4)
    + vShutDown(B, mDemShift(T,5), G, S)$(pGen(G, 'min_down', S) > 5)
    + vShutDown(B, mDemShift(T,6), G, S)$(pGen(G, 'min_down', S) > 6)
    + vShutDown(B, mDemShift(T,7), G, S)$(pGen(G, 'min_down', S) > 7)
    + vShutDown(B, mDemShift(T,8), G, S)$(pGen(G, 'min_down', S) > 8)
    + vShutDown(B, mDemShift(T,9), G, S)$(pGen(G, 'min_down', S) > 9)
    + vShutDown(B, mDemShift(T,10), G, S)$(pGen(G, 'min_down', S) > 10)
    + vShutDown(B, mDemShift(T,11), G, S)$(pGen(G, 'min_down', S) > 11)
    + vShutDown(B, mDemShift(T,12), G, S)$(pGen(G, 'min_down', S) > 12)
    + vShutDown(B, mDemShift(T,13), G, S)$(pGen(G, 'min_down', S) > 13)
    + vShutDown(B, mDemShift(T,14), G, S)$(pGen(G, 'min_down', S) > 14)
    + vShutDown(B, mDemShift(T,15), G, S)$(pGen(G, 'min_down', S) > 15)
    + vShutDown(B, mDemShift(T,16), G, S)$(pGen(G, 'min_down', S) > 16)
    + vShutDown(B, mDemShift(T,17), G, S)$(pGen(G, 'min_down', S) > 17)
    + vShutDown(B, mDemShift(T,18), G, S)$(pGen(G, 'min_down', S) > 18)
    + vShutDown(B, mDemShift(T,19), G, S)$(pGen(G, 'min_down', S) > 19)
    + vShutDown(B, mDemShift(T,20), G, S)$(pGen(G, 'min_down', S) > 20)
    + vShutDown(B, mDemShift(T,21), G, S)$(pGen(G, 'min_down', S) > 21)
    + vShutDown(B, mDemShift(T,22), G, S)$(pGen(G, 'min_down', S) > 22)
    + vShutDown(B, mDemShift(T,23), G, S)$(pGen(G, 'min_down', S) > 23)
    + vShutDown(B, mDemShift(T,24), G, S)$(pGen(G, 'min_down', S) > 24)
    + vShutDown(B, mDemShift(T,25), G, S)$(pGen(G, 'min_down', S) > 25)
    + vShutDown(B, mDemShift(T,26), G, S)$(pGen(G, 'min_down', S) > 26)
    + vShutDown(B, mDemShift(T,27), G, S)$(pGen(G, 'min_down', S) > 27)
    + vShutDown(B, mDemShift(T,28), G, S)$(pGen(G, 'min_down', S) > 28)
    + vShutDown(B, mDemShift(T,29), G, S)$(pGen(G, 'min_down', S) > 29)
    + vShutDown(B, mDemShift(T,30), G, S)$(pGen(G, 'min_down', S) > 30)    
    + vShutDown(B, mDemShift(T,31), G, S)$(pGen(G, 'min_down', S) > 31)
    + vShutDown(B, mDemShift(T,32), G, S)$(pGen(G, 'min_down', S) > 32)
    + vShutDown(B, mDemShift(T,33), G, S)$(pGen(G, 'min_down', S) > 33)
    + vShutDown(B, mDemShift(T,34), G, S)$(pGen(G, 'min_down', S) > 34)
    + vShutDown(B, mDemShift(T,35), G, S)$(pGen(G, 'min_down', S) > 35)
    + vShutDown(B, mDemShift(T,36), G, S)$(pGen(G, 'min_down', S) > 36)
    + vShutDown(B, mDemShift(T,37), G, S)$(pGen(G, 'min_down', S) > 37)
    + vShutDown(B, mDemShift(T,38), G, S)$(pGen(G, 'min_down', S) > 38)
    + vShutDown(B, mDemShift(T,39), G, S)$(pGen(G, 'min_down', S) > 39)
    + vShutDown(B, mDemShift(T,40), G, S)$(pGen(G, 'min_down', S) > 40)    
    + vShutDown(B, mDemShift(T,41), G, S)$(pGen(G, 'min_down', S) > 41)
    + vShutDown(B, mDemShift(T,42), G, S)$(pGen(G, 'min_down', S) > 42)
    + vShutDown(B, mDemShift(T,43), G, S)$(pGen(G, 'min_down', S) > 43)
    + vShutDown(B, mDemShift(T,44), G, S)$(pGen(G, 'min_down', S) > 44)
    + vShutDown(B, mDemShift(T,45), G, S)$(pGen(G, 'min_down', S) > 45)
    + vShutDown(B, mDemShift(T,46), G, S)$(pGen(G, 'min_down', S) > 46)
    + vShutDown(B, mDemShift(T,47), G, S)$(pGen(G, 'min_down', S) > 47)
    + vShutDown(B, mDemShift(T,48), G, S)$(pGen(G, 'min_down', S) > 48)
    + vShutDown(B, mDemShift(T,49), G, S)$(pGen(G, 'min_down', S) > 49)
    ;
    