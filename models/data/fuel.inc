
$ontext
 -----------------------------------------------------
 Fuel data for capacity planning for use with ToyCapPlan model

  Sources:
    costs: EIA AOE2010 Table 3, Electricity Sector fuel prices for 2030
           except u235 based on:
              Royal Academy of Engineering. (2004). The cost of generating electricity. 
              London: Royal Academy of Engineering.
           for fuel prices and heatrate from:
              EIA Annual Energy Outlook, 2010 Table 8.2 Generator Cost Assumptions
   
    co2:   EIA Voluntary Reporting of Greenhouse Gases Program: 
               http://www.eia.doe.gov/oiaf/1605/coefficients.html
           ng: pipeline natural gas
           coal: subbituminos

 originally coded in GAMS by Bryan Palmintier 2010-03-30

Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2010-04-08        bpalmintier    Original data
  2  2010-05-20  23:45 bpalmintier    Added Wind
  3  2010-09-12  01:00 bpalmintier    Added Water
  4  2011-09-26  02:00 bpalmintier    Upgraded comment styles
----------------------------------------------------- 
$offtext

* ---- Define the list of fuel types
sets
         F           fuel types
               /u235     "uranium fuel for nuclear fission reactor"
                coal     "Generic coal"
                ng       "natural gas"
                wind     "wind"
                water    "water"
               /
* ----- establish "acronyms" so can use names as parameters in the fuels & gens tables
acronyms u235, coal, ng, wind, water;
               
* ----- And the parameters for these fuel types
table    pFuelData(F, FUEL_PARAMS)   "Fuels Data Table"
           name       cost        co2
*        [name]   [$/MMBTU]   [t/MMBTU]
u235       u235      0.766          0
coal       coal       1.98     0.0965
ng           ng       6.42     0.0531
wind       wind          0          0
water      water         0          0
;
