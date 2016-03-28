
$ontext
 -----------------------------------------------------
 Generator data capacity expansion planning based on ERCOT in 2007:

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
   1  2011-11-08  21:20  bpalmintier   Adapted from ercot2007eGrid_units_clust.inc v2
   2  2011-11-10  20:35  bpalmintier   Corrected cap_max for combined coal
   3  2012-02-01  21:54  bpalmintier   Scale units for GW demand
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
                cap_credit  "Capacity Credit during peak block           [p.u.]"
                c_var_om    "variable O&M cost                           [$/MWh]"
                c_fix_om    "fixed O&M cost                              [M$/GW-yr]"
                c_cap       "total capital cost                          [M$/GW]"
                life        "economic lifetime for unit                  [yr]"
                heatrate    "heatrate for generator (inverse efficiency) [MMBTU/MWh = BTUe9/GWh]"
                p0_fuel     "fuel use at zero power out (heatrate intercept) [BTUe9]"
                fuel        "name of fuel used                           [name]"
                cap_cur     "Current installed capacity for generation   [GW]"
                cap_max     "Maximum installed capacity for generation   [GW]"
                co2_embed   "CO2_eq emissions from plant construction    [Mt/GW]"
                co2_ccs     "Fraction of carbon capture & sequestration  [p.u.]"
                p_min       "minimum power output (for baseload)         [p.u.]"
                lead_time   "Delay from construction to operation        [yr]"
                gen_size    "typical discrete plant size                 [GW]"
                ramp_max    "Maximum hourly ramp rate                    [fract/hr]"
                unit_min    "Minimum power output per committed unit     [GW]"
                c_start_fix "Fixed cost to start up a unit               [K$/start]"
                fuel_start  "Fuel usage to start up a unit               [BTUe9/start]"
                quick_start "Fraction of capacity avail for non-spin reserves [p.u.]" 
                reg_up      "Fraction of capacity avail for regulation up reserves [p.u.]" 
                reg_down    "Fraction of capacity avail for regulation down reserves [p.u.]" 
                spin_rsv    "Fraction of capacity avail for spinning reserves [p.u.]" 
                max_start   "Maximum number of startups per plant per year [starts/yr]"
                max_cap_fact "Maximum capacity factor, use for maintanence [p.u.]"
                min_up       "Minimum up (operating) time                [hr]"
                min_down     "Minimum down (off) time                    [hr]"
               /

         G           "generation: Separate Unit Level data"
               /
                old_coal_st
                old_ng_cc
                old_ng_gt
                old_ng_st
                old_nuke_st
                wind
                new_coal_st
                new_ng_cc
                new_ng_gt
                new_nuke_st
                new_coal_st_ccs
                new_ng_cc_ccs
               /

*Establish the generator cluster type and extended cluster type names so that we can use them 
*in the data table
acronyms    coal_sub_st
            ng_cc
            ng_gt
            ng_st
            u235_st
            wind
            coal_sub_st_ccs
            ng_cc_ccs;

*-- Generator Table Parameters
table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
                    type                cap_cur             cap_max             fuel                heatrate            gen_size            extended_type
*                   [code]              [GW]                [GW]                [name]              [MBTU/MWh]          [GW]                [code]
old_coal_st         coal_sub_st         17.22518            17.22518            coal_sub            10.897              0.60566              coal_sub_st
old_ng_cc           ng_cc               23.04094            23.04094            ng                  7.551               0.50089              ng_cc
old_ng_gt           ng_gt                4.10436             4.10436            ng                  11.969              0.07893               ng_gt
old_ng_st           ng_st               22.89116            22.89116            ng                  12.340              0.30934              ng_st
old_nuke_st         u235_st              5.13860             5.13860            u235                10.400              1.28465             u235_st
wind                wind                 3.71050              Inf               wind                1.000               3.71050             wind
* New gen's heatrate set to zero to use default from gen_param.inc
new_coal_st         coal_sub_st             0                Inf                coal_sub               0                   0                coal_sub_st
new_ng_cc           ng_cc                   0                Inf                ng                     0                   0                ng_cc
new_ng_gt           ng_gt                   0                Inf                ng                     0                   0                ng_gt
new_nuke_st         u235_st                 0                Inf                u235                   0                   0                u235_st
new_coal_st_ccs     coal_sub_st_ccs         0                Inf                coal_sub               0                   0                coal_sub_st_ccs
new_ng_cc_ccs       ng_cc_ccs               0                Inf                ng                     0                   0                ng_cc_ccs
;
