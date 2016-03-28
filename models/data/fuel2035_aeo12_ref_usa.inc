
$ontext
 -----------------------------------------------------
 ERCOT Specific Fuel data for 2035 - EIA AEO2012 Reference Scenario
  for operations and capacity planning for use with Advanced Power Family of models

  Sources:
    costs: EIA AOE2012 Table 3, Electricity Sector fuel prices for 2035 (in 2010 dollars)
           for the entire USA region
             Energy Information Administration [EIA]. (2012). Annual Energy Outlook 2012, Table 3: Energy Prices by Sector and Source. Retrieved March 27, 2013, from http://www.eia.gov/oiaf/aeo/tablebrowser/#release=AEO2012&subject=3-AEO2012&table=3-AEO2012&region=1-0&cases=hccst12-d031312a,lccst12-d031312a,lm2012-d022412a,hm2012-d022412a,ref2012-d020112c
           only one coal price reported (steam coal) so used for all types

           except u235 based on:
              Assuming 33% thermal efficiency with 2010 fuel costs from: 
              Energy Information Administration (EIA). (2013). Electric Power Annual 2011. Retrieved from http://www.eia.gov/electricity/annual/
   
    co2:   EIA Voluntary Reporting of Greenhouse Gases Program: 
               http://www.eia.doe.gov/oiaf/1605/coefficients.html
           ng: pipeline natural gas (weighted national average energy content, 1029 BTU/scf)
           coal: electric power sector coal (average, see also individual coal types)

Use tab spacing of 12 for pasting

 originally coded in GAMS by Bryan Palmintier 2013-03-27

Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2013-03-26  21:41 bpalmintier    Adapted from thesis_fuel2030.inc v1
----------------------------------------------------- 
$offtext

* ---- Define the list of fuel types
sets
         F     "fuel types"
               /
                u235      "uranium fuel for nuclear fission reactor"
                coal      "Generic coal (based on national average co2)"
                coal_anth "Anthracite Coal"
                coal_bit  "Bituminos Coal"
                coal_sub  "Subbituminos Coal"
                coal_lig  "Lignite Coal"
                ng        "natural gas"
                wind      "wind"
                water     "water"
                oil_dist  "Distilled petroleum product -- diesel"
                oil_resid "Residual Fuel Oil -- bunker oil"
               /
* ----- establish "acronyms" so can use names as parameters in the fuels & gens tables
acronyms u235, oil_dist, oil_resid, coal, coal_anth, coal_bit, coal_sub, coal_lig, ng, wind, water;
               
* ----- And the parameters for these fuel types
table    pFuelData(F, FUEL_PARAMS)   "Fuels Data Table"
            name        co2         cost
*           [name]      [t/MMBTU]   [2010$/MMBTU]
u235        u235        0           0.646
oil_dist    oil_dist    0.07315     27.80
oil_resid   oil_resid   0.07880     25.72
ng          ng          0.0531      7.21
coal        coal        0.0965      2.80
coal_anth   coal_anth   0.10369     2.80
coal_bit    coal_bit    0.0933      2.80
coal_sub    coal_sub    0.0965      2.80
coal_lig    coal_lig    0.0977      2.80
wind        wind        0           0
water       water       0           0
;
