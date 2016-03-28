
$ontext
 -----------------------------------------------------
 Generator data for operations & capacity planning with the Advanced Power Family of models

  ERCOT Cluster Data from 2010 edition of eGrid (2007 data)
  
  Clustered by: AGE
  
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
                                    Age (year in service)
    Type            Use Clusters    old     midAge  new
    coal_lig_st     TRUE            0       1975    1985
    coal_sub_st     TRUE            0       1980    1985
    ng_cc           TRUE            0       2000    2005
    ng_gt           TRUE            0       1980    2000
    ng_st           TRUE            0       1960    1970
    u235_st         FALSE
    wind            FALSE
  
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
                coal_lig_st_old
                coal_lig_st_midAge
                coal_lig_st_new
                coal_sub_st_old
                coal_sub_st_midAge
                coal_sub_st_new
                ng_cc_old
                ng_cc_midAge
                ng_cc_new
                ng_gt_old
                ng_gt_midAge
                ng_gt_new
                ng_st_old
                ng_st_midAge
                ng_st_new
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
            coal_lig_st_old
            coal_lig_st_midAge
            coal_lig_st_new
            coal_sub_st_old
            coal_sub_st_midAge
            coal_sub_st_new
            ng_cc_old
            ng_cc_midAge
            ng_cc_new
            ng_gt_old
            ng_gt_midAge
            ng_gt_new
            ng_st_old
            ng_st_midAge
            ng_st_new
            u235_st
            wind
            ;

*-- Generator Table Parameters
table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
                    type                cap_cur             cap_max             fuel                heatrate            gen_size            extended_type
*                   [code]              [GW]                [GW]                [name]              [MBTU/MWh]          [GW]                [code]
coal_lig_st_old     coal_lig_st         1.78020             1.78020             coal_lig            10.770              0.59340             coal_lig_st_old
coal_lig_st_midAge  coal_lig_st         4.76679             4.76679             coal_lig            11.139              0.68097             coal_lig_st_midAge
coal_lig_st_new     coal_lig_st         2.19900             2.19900             coal_lig            9.810               0.54975             coal_lig_st_new
coal_sub_st_old     coal_sub_st         3.01520             3.01520             coal_sub             11.584             0.60304             coal_sub_st_old
coal_sub_st_midAge  coal_sub_st         2.89810             2.89810             coal_sub             10.330             0.57962             coal_sub_st_midAge
coal_sub_st_new     coal_sub_st         2.56600             2.56600             coal_sub             10.729             0.64150             coal_sub_st_new
ng_cc_old           ng_cc               0.73341             0.73341             ng                   9.711              0.24447             ng_cc_old
ng_cc_midAge        ng_cc               20.53824            20.53824            ng                   7.459              0.54048             ng_cc_midAge
ng_cc_new           ng_cc               1.76920             1.76920             ng                   7.723              0.35384             ng_cc_new
ng_gt_old           ng_gt               0.94200             0.94200             ng                  11.891              0.07850             ng_gt_old
ng_gt_midAge        ng_gt               2.03976             2.03976             ng                  13.071              0.08499             ng_gt_midAge
ng_gt_new           ng_gt               1.12288             1.12288             ng                  10.031              0.07018             ng_gt_new
ng_st_old           ng_st               2.61612             2.61612             ng                   12.347             0.14534             ng_st_old
ng_st_midAge        ng_st               8.19531             8.19531             ng                   12.624             0.30353             ng_st_midAge
ng_st_new           ng_st               12.07995            12.07995            ng                   12.146             0.41655             ng_st_new
u235_st             u235_st             5.13860             5.13860             u235                 10.400             1.28465             u235_st
wind                wind                 3.71050             3.71050            wind                1.000               0.1                 wind
;
