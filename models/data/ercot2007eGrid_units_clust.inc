
$ontext
 -----------------------------------------------------
 Generator data for operations & capacity planning with the Advanced Power Family of models

  ERCOT Cluster Data from 2010 edition of eGrid (2007 data)
  
  Clustered by: ALL (fuel and prime-mover type)
  
  IMPORTANT: Only Capacities & Heatrates defined here. Must specify a gen_params file, too.

 Created using ERCOT2007 Unit Summary.xlsx SVN v221 with the following filters:
    Allow Combinations (all types)                          TRUE
    Combine CCGTs                                           TRUE
    Combine Wind                                            TRUE
    Minor Fuel System Capacity Threshold  (MW)              250
    Nameplate Minimum (MW)                                  50
    Oldest First year of operation (enter year)             0
    Status Code (ALL or comma separated list)               OP,V,OS,SB,TS
    Include Combined Heat & Power                           FALSE
    Include Hydro (Fuel = water)                            FALSE
    Include Bad Data                                        FALSE
    
  When pasting from Excel, convert tabs to spaces using a tabstop of 20

  Sources: eGrid 2010 v1.1

 originally coded in GAMS by Bryan Palmintier 2011-10-14

 Ver   Date       Time   Who           What
 ---  ----------  -----  ------------- ---------------------------------
   1  2011-10-14  02:00  bpalmintier   Adapted from ercot2007eGrid_units_all.inc v1
   2  2011-10-17  15:20  bpalmintier   Added control flag gen_type_data_defined
   3  2012-02-07  21:05  bpalmintier   Scaled from MW to GW
   4  2012-06-21  10:15  bpalmintier   Wind bin size to 100MW (existing average for 39 plants = 95MW)
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
                coal_lig_st
                coal_sub_st
                ng_cc
                ng_gt
                ng_st
                u235_st
                wind
               /

*Establish the generator cluster type and extended cluster type names so that we can use them 
*in the data table
acronyms    coal_lig_st
            coal_sub_st
            ng_cc
            ng_gt
            ng_st
            u235_st
            wind
            ;

*-- Generator Table Parameters
table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
                    type                cap_cur             cap_max             fuel                heatrate            gen_size            extended_type
*                   [code]              [GW]                [GW]                [name]              [MBTU/MWh]          [GW]                [code]
coal_lig_st         coal_lig_st          8.74594             8.74594            coal_lig            10.730              0.62471             coal_lig_st
coal_sub_st         coal_sub_st          8.47924             8.47924            coal_sub            10.897              0.60566             coal_sub_st
ng_cc               ng_cc               23.04094            23.04094            ng                  7.551               0.50089             ng_cc
ng_gt               ng_gt                4.10436             4.10436            ng                  11.969              0.07893             ng_gt
ng_st               ng_st               22.89116            22.89116            ng                  12.340              0.30934             ng_st
u235_st             u235_st              5.13860             5.13860            u235                10.400              1.28465             u235_st
wind                wind                 3.71050             3.71050            wind                1.000               0.1                 wind
;
