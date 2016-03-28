
$ontext
 -----------------------------------------------------
 Test scenario values for Advanced Power family of models
 -----------------------------------------------------

 This simple setup introduces a 3 way difference between demand scaling
 
 originally coded in GAMS by Bryan Palmintier 2012-01-28

 Ver  Date       Time   Who            What
 --- ----------  -----  -------------- ---------------------------------
   1 2012-01-28  22:47  bpalmintier   Initial version
   2 2012-05-02  11:10  bpalmintier   Separate demand (D) into blocks (B) and time sub-periods (T)
 -----------------------------------------------------
$offtext

  sets
    S   "three test scenarios"
       /
* No commas in explanatory text or CSV output will be messed up
        Scen1   "High growth case"
        Scen2   "Moderate growth case"
* Use a non-sequence to verify that handling does not rely on having sequential names
        ScenC   "Zero growth case"
       /
    B           "Demand blocks (e.g. weeks or ldc)"
	T			"Demand time sub-periods (e.g. hours or ldc sub-blocks)"
    
    DEM_PARAMS  "demand block table parameters from load duration curve"
        /
         dur         "duration of block                 [hrs]"
         power       "average power demand during block [GW]"
        /
    ;

parameter
    pDemand    (B, T, DEM_PARAMS, S)   "table of demand data by scenario"
    ;

* Scale demand... Note expected value equals one
pDemand(B, T, 'power', 'Scen1') = pDemand(B, T, 'power', 'Scen1') * 1.5;
pDemand(B, T, 'power', 'Scen2') = pDemand(B, T, 'power', 'Scen2') * 1.2;
pDemand(B, T, 'power', 'ScenC') = pDemand(B, T, 'power', 'ScenC') * 1;

