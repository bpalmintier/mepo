
$ontext
 -----------------------------------------------------
    Generator data for all new technologies with no existing system
 -----------------------------------------------------
 Generator data capacity expansion planning from scratch

  IMPORTANT: Only Capacities & Fuels defined here. Must specify a gen_params file, too.


 originally coded in GAMS by Bryan Palmintier 2011-10-14

 Ver   Date       Time   Who           What
 ---  ----------  -----  ------------- ---------------------------------
   1  2012-01-28  20:20  bpalmintier   Adapted from informs2011_gens.inc v2
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
                c_fix_om    "fixed O&M cost                              [$/MW-yr]"
                c_cap       "total capital cost                          [$/MW]"
                life        "economic lifetime for unit                  [yr]"
                heatrate    "heatrate for generator (inverse efficiency) [kBTU/MW]"
                p0_fuel     "fuel use at zero power out (heatrate intercept) [MMBTU]"
                fuel        "name of fuel used                           [name]"
                cap_cur     "Current installed capacity for generation   [MW]"
                cap_max     "Maximum installed capacity for generation   [MW]"
                co2_embed   "CO2_eq emissions from plant construction    [t per MW]"
                co2_ccs     "Fraction of carbon capture & sequestration  [p.u.]"
                p_min       "minimum power output (for baseload)         [p.u.]"
                lead_time   "Delay from construction to operation        [yr]"
                gen_size  "typical discrete plant size                 [MW]"
                ramp_max    "Maximum hourly ramp rate                    [fract/hr]"
                unit_min    "Minimum power output per committed unit     [MW]"
                c_start_fix "Fixed cost to start up a unit               [$/start/unit]"
                fuel_start  "Fuel usage to start up a unit               [MMBTU/start/unit]"
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
            u235_st
            wind
            coal_sub_st_ccs
            ng_cc_ccs;

*-- Generator Table Parameters
table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
                    type                cap_cur             cap_max             fuel                extended_type
*                   [code]              [GW]                [GW]                [name]              [code]
wind                wind                    5                 5                 wind                wind
new_coal_st         coal_sub_st             0                Inf                coal_sub            coal_sub_st
new_ng_cc           ng_cc                   0                Inf                ng                  ng_cc
new_ng_gt           ng_gt                   0                Inf                ng                  ng_gt
new_nuke_st         u235_st                 0                Inf                u235                u235_st
new_coal_st_ccs     coal_sub_st_ccs         0                Inf                coal_sub            coal_sub_st_ccs
new_ng_cc_ccs       ng_cc_ccs               0                Inf                ng                  ng_cc_ccs
;
