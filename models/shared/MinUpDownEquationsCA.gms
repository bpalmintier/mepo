
$ontext
----------------------------------------------------
 Carrion & Arroyo formulation for min up & down time that does not use separate startup or
 shutdown variables. for Advanced Power Family of Models.

WARNING: DOES NOT WORK WITH CLUSTERING
  
LIMITATIONS:
   -- Currently limited to up/down times of 50hrs
   -- Hourly demand. (Or more generally: equal demand periods and that the min_up & min_down
       parameters are specified in units of demand periods)
  

Command Line Parameters Implemented Here:
    --min_up_down=(off)  Enforce minimum up and down time constraints (default: ignore)

Additional control variables:

IMPORTANT: unlike most equation $include files, this file must be loaded AFTER reading in
the generator datafile. That way our $macros expand properly

IMPORTANT: Currently assumes that the demand dataset is hourly. This could change with more sums

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   September 2011

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2012-02-07  19:25  bpalmintier   Adapted from MinUpDownEquations v3
  2  2012-03-09  12:45  bpalmintier   Replace -- with mDemandShift for optional loop startup
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
    pGen(G, 'min_up', S)*(vUnitCommit(B, T, G, S) - vUnitCommit(B, mDemShift(T,1), G, S))
    =l=
    vUnitCommit(B, T, G, S)
    + vUnitCommit(B, mDemShift(T,1), G, S)$(pGen(G, 'min_up', S) > 1)
    + vUnitCommit(B, mDemShift(T,2), G, S)$(pGen(G, 'min_up', S) > 2)
    + vUnitCommit(B, mDemShift(T,3), G, S)$(pGen(G, 'min_up', S) > 3)
    + vUnitCommit(B, mDemShift(T,4), G, S)$(pGen(G, 'min_up', S) > 4)
    + vUnitCommit(B, mDemShift(T,5), G, S)$(pGen(G, 'min_up', S) > 5)
    + vUnitCommit(B, mDemShift(T,6), G, S)$(pGen(G, 'min_up', S) > 6)
    + vUnitCommit(B, mDemShift(T,7), G, S)$(pGen(G, 'min_up', S) > 7)
    + vUnitCommit(B, mDemShift(T,8), G, S)$(pGen(G, 'min_up', S) > 8)
    + vUnitCommit(B, mDemShift(T,9), G, S)$(pGen(G, 'min_up', S) > 9)
    + vUnitCommit(B, mDemShift(T,10), G, S)$(pGen(G, 'min_up', S) > 10)
    + vUnitCommit(B, mDemShift(T,11), G, S)$(pGen(G, 'min_up', S) > 11)
    + vUnitCommit(B, mDemShift(T,12), G, S)$(pGen(G, 'min_up', S) > 12)
    + vUnitCommit(B, mDemShift(T,13), G, S)$(pGen(G, 'min_up', S) > 13)
    + vUnitCommit(B, mDemShift(T,14), G, S)$(pGen(G, 'min_up', S) > 14)
    + vUnitCommit(B, mDemShift(T,15), G, S)$(pGen(G, 'min_up', S) > 15)
    + vUnitCommit(B, mDemShift(T,16), G, S)$(pGen(G, 'min_up', S) > 16)
    + vUnitCommit(B, mDemShift(T,17), G, S)$(pGen(G, 'min_up', S) > 17)
    + vUnitCommit(B, mDemShift(T,18), G, S)$(pGen(G, 'min_up', S) > 18)
    + vUnitCommit(B, mDemShift(T,19), G, S)$(pGen(G, 'min_up', S) > 19)
    + vUnitCommit(B, mDemShift(T,20), G, S)$(pGen(G, 'min_up', S) > 20)
    + vUnitCommit(B, mDemShift(T,21), G, S)$(pGen(G, 'min_up', S) > 21)
    + vUnitCommit(B, mDemShift(T,22), G, S)$(pGen(G, 'min_up', S) > 22)
    + vUnitCommit(B, mDemShift(T,23), G, S)$(pGen(G, 'min_up', S) > 23)
    + vUnitCommit(B, mDemShift(T,24), G, S)$(pGen(G, 'min_up', S) > 24)
    + vUnitCommit(B, mDemShift(T,25), G, S)$(pGen(G, 'min_up', S) > 25)
    + vUnitCommit(B, mDemShift(T,26), G, S)$(pGen(G, 'min_up', S) > 26)
    + vUnitCommit(B, mDemShift(T,27), G, S)$(pGen(G, 'min_up', S) > 27)
    + vUnitCommit(B, mDemShift(T,28), G, S)$(pGen(G, 'min_up', S) > 28)
    + vUnitCommit(B, mDemShift(T,29), G, S)$(pGen(G, 'min_up', S) > 29)
    + vUnitCommit(B, mDemShift(T,30), G, S)$(pGen(G, 'min_up', S) > 30)    
    + vUnitCommit(B, mDemShift(T,31), G, S)$(pGen(G, 'min_up', S) > 31)
    + vUnitCommit(B, mDemShift(T,32), G, S)$(pGen(G, 'min_up', S) > 32)
    + vUnitCommit(B, mDemShift(T,33), G, S)$(pGen(G, 'min_up', S) > 33)
    + vUnitCommit(B, mDemShift(T,34), G, S)$(pGen(G, 'min_up', S) > 34)
    + vUnitCommit(B, mDemShift(T,35), G, S)$(pGen(G, 'min_up', S) > 35)
    + vUnitCommit(B, mDemShift(T,36), G, S)$(pGen(G, 'min_up', S) > 36)
    + vUnitCommit(B, mDemShift(T,37), G, S)$(pGen(G, 'min_up', S) > 37)
    + vUnitCommit(B, mDemShift(T,38), G, S)$(pGen(G, 'min_up', S) > 38)
    + vUnitCommit(B, mDemShift(T,39), G, S)$(pGen(G, 'min_up', S) > 39)
    + vUnitCommit(B, mDemShift(T,40), G, S)$(pGen(G, 'min_up', S) > 40)    
    + vUnitCommit(B, mDemShift(T,41), G, S)$(pGen(G, 'min_up', S) > 41)
    + vUnitCommit(B, mDemShift(T,42), G, S)$(pGen(G, 'min_up', S) > 42)
    + vUnitCommit(B, mDemShift(T,43), G, S)$(pGen(G, 'min_up', S) > 43)
    + vUnitCommit(B, mDemShift(T,44), G, S)$(pGen(G, 'min_up', S) > 44)
    + vUnitCommit(B, mDemShift(T,45), G, S)$(pGen(G, 'min_up', S) > 45)
    + vUnitCommit(B, mDemShift(T,46), G, S)$(pGen(G, 'min_up', S) > 46)
    + vUnitCommit(B, mDemShift(T,47), G, S)$(pGen(G, 'min_up', S) > 47)
    + vUnitCommit(B, mDemShift(T,48), G, S)$(pGen(G, 'min_up', S) > 48)
    + vUnitCommit(B, mDemShift(T,49), G, S)$(pGen(G, 'min_up', S) > 49)
    ;
    
eMinDownTime(B, T, G, S)$( B_SIM(B)
                        and G_UC(G)
                        and pGen(G, 'min_down', S) > 1 
                        and pGen(G,'gen_size', S) <> 0 ) ..
    pGen(G, 'min_down', S)*(vUnitCommit(B, mDemShift(T,1), G, S) - vUnitCommit(B, T, G, S))
    =l=
    pGen(G, 'min_down', S) - 1
    + vUnitCommit(B, T, G, S) 
    + vUnitCommit(B, mDemShift(T,1), G, S)$(pGen(G, 'min_down', S) > 1)
    + vUnitCommit(B, mDemShift(T,2), G, S)$(pGen(G, 'min_down', S) > 2)
    + vUnitCommit(B, mDemShift(T,3), G, S)$(pGen(G, 'min_down', S) > 3)
    + vUnitCommit(B, mDemShift(T,4), G, S)$(pGen(G, 'min_down', S) > 4)
    + vUnitCommit(B, mDemShift(T,5), G, S)$(pGen(G, 'min_down', S) > 5)
    + vUnitCommit(B, mDemShift(T,6), G, S)$(pGen(G, 'min_down', S) > 6)
    + vUnitCommit(B, mDemShift(T,7), G, S)$(pGen(G, 'min_down', S) > 7)
    + vUnitCommit(B, mDemShift(T,8), G, S)$(pGen(G, 'min_down', S) > 8)
    + vUnitCommit(B, mDemShift(T,9), G, S)$(pGen(G, 'min_down', S) > 9)
    + vUnitCommit(B, mDemShift(T,10), G, S)$(pGen(G, 'min_down', S) > 10)
    + vUnitCommit(B, mDemShift(T,11), G, S)$(pGen(G, 'min_down', S) > 11)
    + vUnitCommit(B, mDemShift(T,12), G, S)$(pGen(G, 'min_down', S) > 12)
    + vUnitCommit(B, mDemShift(T,13), G, S)$(pGen(G, 'min_down', S) > 13)
    + vUnitCommit(B, mDemShift(T,14), G, S)$(pGen(G, 'min_down', S) > 14)
    + vUnitCommit(B, mDemShift(T,15), G, S)$(pGen(G, 'min_down', S) > 15)
    + vUnitCommit(B, mDemShift(T,16), G, S)$(pGen(G, 'min_down', S) > 16)
    + vUnitCommit(B, mDemShift(T,17), G, S)$(pGen(G, 'min_down', S) > 17)
    + vUnitCommit(B, mDemShift(T,18), G, S)$(pGen(G, 'min_down', S) > 18)
    + vUnitCommit(B, mDemShift(T,19), G, S)$(pGen(G, 'min_down', S) > 19)
    + vUnitCommit(B, mDemShift(T,20), G, S)$(pGen(G, 'min_down', S) > 20)
    + vUnitCommit(B, mDemShift(T,21), G, S)$(pGen(G, 'min_down', S) > 21)
    + vUnitCommit(B, mDemShift(T,22), G, S)$(pGen(G, 'min_down', S) > 22)
    + vUnitCommit(B, mDemShift(T,23), G, S)$(pGen(G, 'min_down', S) > 23)
    + vUnitCommit(B, mDemShift(T,24), G, S)$(pGen(G, 'min_down', S) > 24)
    + vUnitCommit(B, mDemShift(T,25), G, S)$(pGen(G, 'min_down', S) > 25)
    + vUnitCommit(B, mDemShift(T,26), G, S)$(pGen(G, 'min_down', S) > 26)
    + vUnitCommit(B, mDemShift(T,27), G, S)$(pGen(G, 'min_down', S) > 27)
    + vUnitCommit(B, mDemShift(T,28), G, S)$(pGen(G, 'min_down', S) > 28)
    + vUnitCommit(B, mDemShift(T,29), G, S)$(pGen(G, 'min_down', S) > 29)
    + vUnitCommit(B, mDemShift(T,30), G, S)$(pGen(G, 'min_down', S) > 30)    
    + vUnitCommit(B, mDemShift(T,31), G, S)$(pGen(G, 'min_down', S) > 31)
    + vUnitCommit(B, mDemShift(T,32), G, S)$(pGen(G, 'min_down', S) > 32)
    + vUnitCommit(B, mDemShift(T,33), G, S)$(pGen(G, 'min_down', S) > 33)
    + vUnitCommit(B, mDemShift(T,34), G, S)$(pGen(G, 'min_down', S) > 34)
    + vUnitCommit(B, mDemShift(T,35), G, S)$(pGen(G, 'min_down', S) > 35)
    + vUnitCommit(B, mDemShift(T,36), G, S)$(pGen(G, 'min_down', S) > 36)
    + vUnitCommit(B, mDemShift(T,37), G, S)$(pGen(G, 'min_down', S) > 37)
    + vUnitCommit(B, mDemShift(T,38), G, S)$(pGen(G, 'min_down', S) > 38)
    + vUnitCommit(B, mDemShift(T,39), G, S)$(pGen(G, 'min_down', S) > 39)
    + vUnitCommit(B, mDemShift(T,40), G, S)$(pGen(G, 'min_down', S) > 40)    
    + vUnitCommit(B, mDemShift(T,41), G, S)$(pGen(G, 'min_down', S) > 41)
    + vUnitCommit(B, mDemShift(T,42), G, S)$(pGen(G, 'min_down', S) > 42)
    + vUnitCommit(B, mDemShift(T,43), G, S)$(pGen(G, 'min_down', S) > 43)
    + vUnitCommit(B, mDemShift(T,44), G, S)$(pGen(G, 'min_down', S) > 44)
    + vUnitCommit(B, mDemShift(T,45), G, S)$(pGen(G, 'min_down', S) > 45)
    + vUnitCommit(B, mDemShift(T,46), G, S)$(pGen(G, 'min_down', S) > 46)
    + vUnitCommit(B, mDemShift(T,47), G, S)$(pGen(G, 'min_down', S) > 47)
    + vUnitCommit(B, mDemShift(T,48), G, S)$(pGen(G, 'min_down', S) > 48)
    + vUnitCommit(B, mDemShift(T,49), G, S)$(pGen(G, 'min_down', S) > 49)
    ;
    