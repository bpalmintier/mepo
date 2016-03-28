
$ontext
-----------------------------------------------------
Test Generator data for capacity planning for use with Advanced Power Family of Models

 Data included for only 4 generators:
   - Natural Gas Combined Cycle
   - Coal
   - Nuclear
   - Wind

 The simple test system is designed to allow for enough non-renewable capacity that the
 optimal mix will often involve zero capacity in one generator type. This should help testing
 of value functions ability to estimate/extrapolate to corner solutions.
  
  Existing capacity based on "optimal" mix to meet ercot2007 load using StaticCapPlan GAMS 
  model (r414) with simple operations & planning margin. This allows
  consistant use with operations only models and CapPlanDp MATLAB code using "from data" for
  baseline system sizing.

 originally coded in GAMS by Bryan Palmintier 2012

Ver   Date       Time   Who           What
---  ----------  -----  ------------- ---------------------------------
  1  2012-06-26  11:00  bpalmintier   Adapted from ngcc_coal_wind_gens.inc v1
----------------------------------------------------- 
$offtext
               
* Indicate that we define type data in our table
$setglobal gen_type_data_defined

* ---- Define the list of generation technologies
sets
         GEN_PARAMS  "generation table parameters"
*Note by including this list again here, we can add attributes in this document without breaking
*Old models such as ToyCapPlan
               /
                type        "Generator Prime Mover & Fuel code"
                extended_type "Generator type with additional clustering information"
                heatrate    "heatrate for generator (inverse efficiency) [kBTU/MW]"
                fuel        "name of fuel used                           [name]"
                cap_cur     "Current installed capacity for generation   [GW]"
                cap_max     "Maximum installed capacity for generation   [GW]"
                gen_size  "typical discrete plant size                 [GW]"
               /

         G           "generation: Separate Unit Level data"
               /
                coal_sub_st
                ng_cc
                nuke_st
                wind
               /

*Establish the generator cluster type and extended cluster type names so that we can use them 
*in the data table
acronyms    
            coal_sub_st
            ng_cc
            u235_st
            wind
            ;

*-- Generator Table Parameters
table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
                    type                cap_cur             cap_max             fuel        extended_type
*                   [code]               [GW]                [GW]               [name]          [code]
coal_sub_st         coal_sub_st          28.6                Inf                coal_sub        coal_sub_st
ng_cc               ng_cc                41.6                Inf                ng              ng_cc
nuke_st             u235_st               0                  Inf                u235            u235_st
wind                wind                  0                  Inf                wind            wind
;
