
$ontext
 -----------------------------------------------------
 Generator data for operations & capacity planning with the Advanced Power Family of models

  ERCOT Cluster Data from 2010 edition of eGrid (2007 data)
  
  Clustered by: EFFICIENCY
  
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
                coal_lig_st_hiEff
                coal_lig_st_avgEff
                coal_lig_st_loEff
                coal_sub_st_hiEff
                coal_sub_st_avgEff
                coal_sub_st_loEff
                ng_cc_hiEff
                ng_cc_avgEff
                ng_cc_loEff
                ng_gt_hiEff
                ng_gt_avgEff
                ng_gt_loEff
                ng_st_hiEff
                ng_st_avgEff
                ng_st_loEff
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
            coal_lig_st_hiEff
            coal_lig_st_avgEff
            coal_lig_st_loEff
            coal_sub_st_hiEff
            coal_sub_st_avgEff
            coal_sub_st_loEff
            ng_cc_hiEff
            ng_cc_avgEff
            ng_cc_loEff
            ng_gt_hiEff
            ng_gt_avgEff
            ng_gt_loEff
            ng_st_hiEff
            ng_st_avgEff
            ng_st_loEff
            u235_st
            wind
            ;

*-- Generator Table Parameters
table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
                    type                cap_cur             cap_max             fuel                heatrate            gen_size            extended_type
*                   [code]              [GW]                [GW]                [name]              [MBTU/MWh]          [GW]                [code]
coal_lig_st_hiEff   coal_lig_st         1.84980             1.84980             coal_lig             9.612              0.92490             coal_lig_st_hiEff
coal_lig_st_avgEff  coal_lig_st         6.48615             6.48615             coal_lig             10.959             0.58965             coal_lig_st_avgEff
coal_lig_st_loEff   coal_lig_st         0.41000             0.41000             coal_lig             12.148             0.41000             coal_lig_st_loEff
coal_sub_st_hiEff   coal_sub_st         1.05390             1.05390             coal_sub            10.066              0.52695             coal_sub_st_hiEff
coal_sub_st_avgEff  coal_sub_st         6.49340             6.49340             coal_sub            10.575              0.64934             coal_sub_st_avgEff
coal_sub_st_loEff   coal_sub_st         0.93200             0.93200             coal_sub            14.073              0.46600             coal_sub_st_loEff
ng_cc_hiEff         ng_cc               14.97154            14.97154            ng                   7.331              0.51626             ng_cc_hiEff
ng_cc_avgEff        ng_cc               7.14636             7.14636             ng                   7.746              0.54972             ng_cc_avgEff
ng_cc_loEff         ng_cc               0.92300             0.92300             ng                   9.595              0.23075             ng_cc_loEff
ng_gt_hiEff         ng_gt               1.02360             1.02360             ng                   8.518              0.08530             ng_gt_hiEff
ng_gt_avgEff        ng_gt               1.41060             1.41060             ng                   12.069             0.07053             ng_gt_avgEff
ng_gt_loEff         ng_gt               1.67060             1.67060             ng                   13.998             0.08353             ng_gt_loEff
ng_st_hiEff         ng_st               7.00180             7.00180             ng                  10.976              0.35009             ng_st_hiEff
ng_st_avgEff        ng_st               8.10985             8.10985             ng                  12.028              0.27965             ng_st_avgEff
ng_st_loEff         ng_st               7.78000             7.78000             ng                  13.892              0.31120             ng_st_loEff
u235_st             u235_st             5.13860             5.13860             u235                 10.400             1.28465             u235_st
wind                wind                 3.71050             3.71050            wind                1.000               0.1                 wind
;