
$ontext
-----------------------------------------------------
HAND/human readable Test Generator data for use with Advanced Power Family of Models

 Data included for only 4 generators:
   - Natural Gas Combined Cycle
   - Coal
   - Nuclear
   - Wind

  Existing capacity set to a bit over the firm (10%) capacity requirements

 originally coded in GAMS by Bryan Palmintier 2012

Ver   Date       Time   Who           What
---  ----------  -----  ------------- ---------------------------------
  1  2012-06-28  15:05  bpalmintier   Adapted from gcnw_gens.inc v1
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
coal_sub_st         coal_sub_st          50                  Inf                coal_sub        coal_sub_st
ng_cc               ng_cc                60                  Inf                ng              ng_cc
nuke_st             u235_st               0                  Inf                u235            u235_st
wind                wind                  0                  Inf                wind            wind
;
