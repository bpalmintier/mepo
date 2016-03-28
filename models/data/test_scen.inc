
$ontext
 -----------------------------------------------------
 Test scenario for Advanced Power family of models
 -----------------------------------------------------

 This simple setup introduces 3 different scenarios and their weights. Use with 
  test_scen_update.inc to vary parameters between scenarios. When used with
  UnitCommit or StaticCapPlan they effectively solve 3 separate identical problems for 
  a sort of (inefficient) sensitivity analysis. Use with StocCapPlan, StocUC, or DynCapPlan
  to introduce additional constraints to test more interesting problems
  
 originally coded in GAMS by Bryan Palmintier 2012-01-28

 Ver   Date       Time   Who            What
 ---  ----------  -----  -------------- ---------------------------------
   1  2012-01-28  21:17  bpalmintier    Initial version
   
 -----------------------------------------------------
$offtext

  set
    S   "three test scenarios"
       /
* No commas in explanatory text or CSV output will be messed up
        Scen1   "first scenario"
        Scen2   "second scenario"
* Use a non-sequence to verify that handling does not rely on having sequential names
        ScenC   "third scenario"
       /
    ;

  parameter
    pScenWeight(S)     "Scenario weighting for cost calcs. Use for probability or time discounting"
    ;

* Note: weights need not add up to 1, since they are not necessarily probabilities
pScenWeight('Scen1') = 0.5;
pScenWeight('Scen2') = 0.3;
pScenWeight('ScenC') = 0.2;

$if not set scen_val $setglobal scen_val test_scen_val.inc

