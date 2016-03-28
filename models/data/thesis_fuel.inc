
$ontext
 -----------------------------------------------------
 Region Specific Fuel data for capacity planning for use with ToyCapPlan model

  Sources:
    costs: EIA AOE2010 Table 3, Electricity Sector fuel prices for 2007 (in 2008 dollars)
           For South Central West (which includes Texas)
             http://www.eia.gov/oiaf/aeo/tablebrowser/#release=AEO2010&subject=3-AEO2010&table=3-AEO2010&region=1-7&cases=aeo2010r-d111809a
           except u235 based on:
              Royal Academy of Engineering. (2004). The cost of generating electricity. 
              London: Royal Academy of Engineering.
           for fuel prices and heatrate from:
              EIA Annual Energy Outlook, 2010 Table 8.2 Generator Cost Assumptions
           only one coal price reported (steam coal) so used for all types
   
    co2:   EIA Voluntary Reporting of Greenhouse Gases Program: 
               http://www.eia.doe.gov/oiaf/1605/coefficients.html
           ng: pipeline natural gas
           coal: subbituminos

 originally coded in GAMS by Bryan Palmintier 2010-03-30

Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2012-08-21  15:09 bpalmintier    Adapted from ercot2007_fuels.inc v1
----------------------------------------------------- 
$offtext

* ---- Define the list of fuel types
sets
         F           fuel types
               /u235     "uranium fuel for nuclear fission reactor"
                coal     "Generic coal (based on subbituminous"
                coal_bit "Bituminos Coal"
                coal_sub "Subbituminos Coal"
                coal_lig "Lignite Coal"
                ng       "natural gas"
                wind     "wind"
                water    "water"
               /
* ----- establish "acronyms" so can use names as parameters in the fuels & gens tables
acronyms u235, coal, coal_bit, coal_sub, coal_lig, ng, wind, water;
               
* ----- And the parameters for these fuel types
table    pFuelData(F, FUEL_PARAMS)   "Fuels Data Table"
           name       cost         co2
*        [name]   [$/MMBTU]   [t/MMBTU]
u235       u235       0.766          0
coal       coal       1.956     0.0965
coal_bit   coal_bit   1.956     0.0933
coal_sub   coal_sub   1.956     0.0965
coal_lig   coal_lig   1.956     0.0977
ng           ng       6.840     0.0531
wind       wind          0          0
water      water         0          0
;
