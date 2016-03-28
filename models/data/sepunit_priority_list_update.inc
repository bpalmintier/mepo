*Start Block Quote
$ontext
-------------------------------------------------
Update file that assigns a priority list order for generator start up in hopes
of speeding-up the MIP branch and bound for unit commitment

 Timing test results for 1 week IEEE RTS96 (SVN repo v216)
       Variable to limit       ignore_min_down   min_up_down  Equations   Time (MacBook)   Objective
            Do not use Priority List                 yes          N/A      0:00:27.857      3.996831 
  +   vStartup(D, G_NEXT)           no               yes       >ord(G)     0:02:36.793      3.998519
      vUnitCommit(D, G_NEXT)        no               yes       >ord(G)     0:13:32.501      4.005414
  ?   vStartup(D, G_NEXT)           no               yes  notOK: =ord(G)+1 0:00:52.866      3.998109
      vUnitCommit(D, G_NEXT)        no               yes  notOK: =ord(G)+1 0:16:59.793      4.005801
      vStartup(D, G_NEXT)           yes              yes       >ord(G)     0:07:18.553      4.002901
  +   vUnitCommit(D, G_NEXT)        yes              yes       >ord(G)     0:00:35.438      4.011305
      vStartup(D, G_NEXT)           yes              yes       =ord(G)+1   0:10:38.979      4.003255
  *   vUnitCommit(D, G_NEXT)        yes              yes       =ord(G)+1   0:00:34.684      4.010708      
            Do not use Priority List                 no           N/A      0:00:07.491      3.994055 
  *   vUnitCommit(D, G_NEXT)        N/A              no        =ord(G)+1   0:00:03.265      3.995865      
      vStartup(D, G_NEXT)           N/A              no        =ord(G)+1   0:00:12.669      3.993523      
      vUnitCommit(D, G_NEXT)        N/A              no        >ord(G)     0:00:05.991      3.994649      
      vStartup(D, G_NEXT)           N/A              no        >ord(G)     0:00:05.602      3.994452      

Common options: --par_threads=1 --sys=ieee_rts96_sys.inc --no_nse=1 --demscale=0.92 
  --demand=ieee_rts96_dem_wk.inc --gens=ieee_rts96_gens_sepunit.inc 
  --startup=1 --debug=1

LIMITATIONS if min up & down used:
   -- Currently limited to up/down times of 50hrs
   -- Hourly demand. (Or more generally: equal demand periods and that the min_up & min_down
       parameters are specified in units of demand periods)


Command Line Parameters Implemented Here:
  --priority_list_ignore_min_down=off  If enabled, enforce only a strict priority order such 
                                        that a lower priority unit only runs if its previous
                                        unit is also running. This does not consider the
                                        possibility that a different unit might turn on
                                        if a unit recently turned off. But run times are greatly
                                        improved.

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   October 2011

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-10-09  15:30  bpalmintier   Original version
  2  2011-10-09  16:00  bpalmintier   Only include min down time checks if min_up_down enabled
  3  2011-10-09  16:30  bpalmintier   Added priority_list_ignore_min_down for simpler constraints
  4  2011-10-09  23:15  bpalmintier   Adjusted formulation based on testing
  5  2012-03-09  12:45  bpalmintier   Replace -- with mDemandShift for optional loop startup
-------------------------------------------------
$offtext

*Start by defining an alias for the generator set so we can use it twice in one equation
alias(G, G_NEXT);

*Declare equation
equation
    eUcStartPriority(D, G, G_NEXT)    "Enforce a priority order for unit startup"
;

*---- Equation -----

* Here we require that the any higher priority ordered unit be either running (vUnitCommit) or
* to have recently shutdown and still be within the minimum down time window

* When min down constraints are not active, the formulation is fairly easy and testing showed
* UnitCommit and a limited number of equations to be fastest.
$ifthen.no_min_down not set min_up_down
    eUcStartPriority(D, G, G_NEXT)$(  (pGenData(G, 'type') = pGenData(G_NEXT, 'type'))
                                        and (ord(G_NEXT) = ord(G) + 1)
                                   )
        .. vUnitCommit(D, G_NEXT) =l= vUnitCommit(D, G);

* When min down constraints are on, but we choose to ignore them when enforcing our priority
* list we use the same formulation as no min down constraints. 
*
* Note: we have to duplicate it here b/c GAMS $ifs don't seem to allow and
$else.no_min_down 
$ifthen.ignore_min_down set priority_list_ignore_min_down
    eUcStartPriority(D, G, G_NEXT)$(  (pGenData(G, 'type') = pGenData(G_NEXT, 'type'))
                                        and (ord(G_NEXT) = ord(G) + 1)
                                   )
        .. vUnitCommit(D, G_NEXT) =l= vUnitCommit(D, G);

$else.ignore_min_down
    eUcStartPriority(D, G, G_NEXT)$(  (pGenData(G, 'type') = pGenData(G_NEXT, 'type'))
                                    and (ord(G_NEXT) > ord(G))                      )
        .. vStartup(D, G_NEXT) =l= vUnitCommit(D, G)
                                    + vShutDown(mDemShift(D,1), G)$(pGenData(G, 'min_down') > 1)
                                    + vShutDown(mDemShift(D,2), G)$(pGenData(G, 'min_down') > 2)
                                    + vShutDown(mDemShift(D,3), G)$(pGenData(G, 'min_down') > 3)
                                    + vShutDown(mDemShift(D,4), G)$(pGenData(G, 'min_down') > 4)
                                    + vShutDown(mDemShift(D,5), G)$(pGenData(G, 'min_down') > 5)
                                    + vShutDown(mDemShift(D,6), G)$(pGenData(G, 'min_down') > 6)
                                    + vShutDown(mDemShift(D,7), G)$(pGenData(G, 'min_down') > 7)
                                    + vShutDown(mDemShift(D,8), G)$(pGenData(G, 'min_down') > 8)
                                    + vShutDown(mDemShift(D,9), G)$(pGenData(G, 'min_down') > 9)
                                    + vShutDown(mDemShift(D,10), G)$(pGenData(G, 'min_down') > 10)
                                    + vShutDown(mDemShift(D,11), G)$(pGenData(G, 'min_down') > 11)
                                    + vShutDown(mDemShift(D,12), G)$(pGenData(G, 'min_down') > 12)
                                    + vShutDown(mDemShift(D,13), G)$(pGenData(G, 'min_down') > 13)
                                    + vShutDown(mDemShift(D,14), G)$(pGenData(G, 'min_down') > 14)
                                    + vShutDown(mDemShift(D,15), G)$(pGenData(G, 'min_down') > 15)
                                    + vShutDown(mDemShift(D,16), G)$(pGenData(G, 'min_down') > 16)
                                    + vShutDown(mDemShift(D,17), G)$(pGenData(G, 'min_down') > 17)
                                    + vShutDown(mDemShift(D,18), G)$(pGenData(G, 'min_down') > 18)
                                    + vShutDown(mDemShift(D,19), G)$(pGenData(G, 'min_down') > 19)
                                    + vShutDown(mDemShift(D,20), G)$(pGenData(G, 'min_down') > 20)
                                    + vShutDown(mDemShift(D,21), G)$(pGenData(G, 'min_down') > 21)
                                    + vShutDown(mDemShift(D,22), G)$(pGenData(G, 'min_down') > 22)
                                    + vShutDown(mDemShift(D,23), G)$(pGenData(G, 'min_down') > 23)
                                    + vShutDown(mDemShift(D,24), G)$(pGenData(G, 'min_down') > 24)
                                    + vShutDown(mDemShift(D,25), G)$(pGenData(G, 'min_down') > 25)
                                    + vShutDown(mDemShift(D,26), G)$(pGenData(G, 'min_down') > 26)
                                    + vShutDown(mDemShift(D,27), G)$(pGenData(G, 'min_down') > 27)
                                    + vShutDown(mDemShift(D,28), G)$(pGenData(G, 'min_down') > 28)
                                    + vShutDown(mDemShift(D,29), G)$(pGenData(G, 'min_down') > 29)
                                    + vShutDown(mDemShift(D,30), G)$(pGenData(G, 'min_down') > 30)    
                                    + vShutDown(mDemShift(D,31), G)$(pGenData(G, 'min_down') > 31)
                                    + vShutDown(mDemShift(D,32), G)$(pGenData(G, 'min_down') > 32)
                                    + vShutDown(mDemShift(D,33), G)$(pGenData(G, 'min_down') > 33)
                                    + vShutDown(mDemShift(D,34), G)$(pGenData(G, 'min_down') > 34)
                                    + vShutDown(mDemShift(D,35), G)$(pGenData(G, 'min_down') > 35)
                                    + vShutDown(mDemShift(D,36), G)$(pGenData(G, 'min_down') > 36)
                                    + vShutDown(mDemShift(D,37), G)$(pGenData(G, 'min_down') > 37)
                                    + vShutDown(mDemShift(D,38), G)$(pGenData(G, 'min_down') > 38)
                                    + vShutDown(mDemShift(D,39), G)$(pGenData(G, 'min_down') > 39)
                                    + vShutDown(mDemShift(D,40), G)$(pGenData(G, 'min_down') > 40)    
                                    + vShutDown(mDemShift(D,41), G)$(pGenData(G, 'min_down') > 41)
                                    + vShutDown(mDemShift(D,42), G)$(pGenData(G, 'min_down') > 42)
                                    + vShutDown(mDemShift(D,43), G)$(pGenData(G, 'min_down') > 43)
                                    + vShutDown(mDemShift(D,44), G)$(pGenData(G, 'min_down') > 44)
                                    + vShutDown(mDemShift(D,45), G)$(pGenData(G, 'min_down') > 45)
                                    + vShutDown(mDemShift(D,46), G)$(pGenData(G, 'min_down') > 46)
                                    + vShutDown(mDemShift(D,47), G)$(pGenData(G, 'min_down') > 47)
                                    + vShutDown(mDemShift(D,48), G)$(pGenData(G, 'min_down') > 48)
                                    + vShutDown(mDemShift(D,49), G)$(pGenData(G, 'min_down') > 49)
                                    + vShutDown(mDemShift(D,50), G)$(pGenData(G, 'min_down') > 50)
                ;
$endif.ignore_min_down
$endif.no_min_down
