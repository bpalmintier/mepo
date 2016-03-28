
$ontext
 -----------------------------------------------------
 Generator data for operations & capacity planning with the Advanced Power Family of models

  ERCOT Cluster Data from 2010 edition of eGrid (2007 data)
  
  Clustered by: SIZE
  
  IMPORTANT: Only Capacities & Heatrates defined here. Must specify a gen_params file, too.

 Created using ERCOT2007 Unit Summary.xlsx SVN v343 with the following filters:
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
  
  And the following Clustering Parameters:
                                              Size (Cap >= X MW)              
Type            Fuel        Use Clusters     small   med     large
coal_lig_st     coal_lig        TRUE          0       500     650
coal_sub_st     coal_sub        TRUE          0       500     650
ng_cc           ng              TRUE          0       300     600
ng_gt           ng              TRUE          0       75      100
ng_st           ng              TRUE          0       150     300
u235_st         u235            FALSE                                           
wind            wind            FALSE                                             
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
                coal_lig_st_small
                coal_lig_st_med
                coal_lig_st_large
                coal_sub_st_small
                coal_sub_st_med
                coal_sub_st_large
                ng_cc_small
                ng_cc_med
                ng_cc_large
                ng_gt_small
                ng_gt_med
                ng_gt_large
                ng_st_small
                ng_st_med
                ng_st_large
                u235_st
                wind
               /

*Establish the generator cluster type and extended cluster type names so that we can use them 
*in the data table
acronyms    
            coal_lig_st
            coal_sub_st
            ng_cc
            ng_gt
            ng_st
            coal_lig_st_small
            coal_lig_st_med
            coal_lig_st_large
            coal_sub_st_small
            coal_sub_st_med
            coal_sub_st_large
            ng_cc_small
            ng_cc_med
            ng_cc_large
            ng_gt_small
            ng_gt_med
            ng_gt_large
            ng_st_small
            ng_st_med
            ng_st_large
            u235_st
            wind
            ;

*-- Generator Table Parameters
table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
                    type                cap_cur             cap_max             fuel                heatrate            gen_size            extended_type
*                   [code]              [GW]                [GW]                [name]              [MBTU/MWh]          [GW]                [code]
coal_lig_st_small   coal_lig_st         0.75921             0.75921             coal_lig             11.556             0.25307             coal_lig_st_small
coal_lig_st_med     coal_lig_st         2.96420             2.96420             coal_lig             10.878             0.59284             coal_lig_st_med
coal_lig_st_large   coal_lig_st         5.02260             5.02260             coal_lig             10.518             0.83710             coal_lig_st_large
coal_sub_st_small   coal_sub_st         1.84552             1.84552             coal_sub             12.221             0.46138             coal_sub_st_small
coal_sub_st_med     coal_sub_st         3.62562             3.62562             coal_sub            10.510              0.60427             coal_sub_st_med
coal_sub_st_large   coal_sub_st         3.00820             3.00820             coal_sub             10.550             0.75205             coal_sub_st_large
ng_cc_small         ng_cc               4.12784             4.12784             ng                   7.681              0.25799             ng_cc_small
ng_cc_med           ng_cc               8.58194             8.58194             ng                  7.651               0.50482             ng_cc_med
ng_cc_large         ng_cc               10.33136            10.33136            ng                   7.415              0.79472             ng_cc_large
ng_gt_small         ng_gt               1.37011             1.37011             ng                   12.042             0.05957             ng_gt_small
ng_gt_med           ng_gt               2.18875             2.18875             ng                  12.456              0.08755             ng_gt_med
ng_gt_large         ng_gt               0.54560             0.54560             ng                  9.828               0.13640             ng_gt_large
ng_st_small         ng_st               2.03637             2.03637             ng                  13.323              0.09697             ng_st_small
ng_st_med           ng_st               4.14260             4.14260             ng                  12.171              0.20713             ng_st_med
ng_st_large         ng_st               16.71252            16.71252            ng                  12.262              0.50644             ng_st_large
u235_st             u235_st             5.13860             5.13860             u235                10.400              1.28465             u235_st
wind                wind                 3.71050             3.71050            wind                1.000               0.1                 wind
;
