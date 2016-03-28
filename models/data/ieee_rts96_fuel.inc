
$ontext
-----------------------------------------------------
Fuel data for capacity planning for use with ToyCapPlan model

  Sources:
    Cost Data:
[1] Reliability Test System Task Force, “IEEE Reliability Test System,” IEEE Transactions on 
Power Apparatus and Systems, vol. 98, pp. 2047-2054, Nov. 1979.

    CO2 data:
[2] C. Grigg et al., “The IEEE Reliability Test System-1996. A report prepared by the
Reliability Test System Task Force of the Application of Probability
Methods Subcommittee,” IEEE Transactions on Power Systems, vol. 14, no. 3, pp. 1010-1020, Aug. 1999.

originally coded in GAMS by Bryan Palmintier 2010-03-30
 
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-09-26        bpalmintier    Adapted from fuel.inc v3
----------------------------------------------------- 
$offtext

* ---- Define the list of fuel types
sets
         F           fuel types
               /u235     "uranium fuel for nuclear fission reactor"
                coal     "Bituminous coal"
                oil_2    "Fuel Oil #2"
                oil_6    "Fuel Oil #6"
               /
* ----- establish "acronyms" so can use names as parameters in the fuels & gens tables
acronyms u235, coal, oil_2, oil_6;
               
* ----- And the parameters for these fuel types
table    pFuelData(F, FUEL_PARAMS)   "Fuels Data Table"
           name       cost        co2
*        [name]   [$/MMBTU]   [t/MMBTU]
oil_2     oil_2       3.00       0.080
oil_6     oil_6       2.30       0.085
coal      coal        1.20       0.105
u235      u235        0.60       0
;
