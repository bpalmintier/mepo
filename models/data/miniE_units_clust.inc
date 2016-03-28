
$ontext
 -----------------------------------------------------
 miniaturized ERCOT 2007: Reduced to only 5xCoal, 7xNG-CC, 11xNG-GT + wind.

  Clustered by: ALL (fuel and prime-mover type)
  
  IMPORTANT: Only Capacities & Heatrates defined here. Must specify a gen_params file, too.

 Created using miniE Unit Summary.xlsx SVN v572 adapted from thesis gen set
 with lots of manual removals
    
  When pasting from Excel, convert tabs to spaces using a tabstop of 20

  Sources: eGrid 2010 v1.1

 originally coded in GAMS by Bryan Palmintier 2015-08-01

 Ver   Date       Time   Who           What
 ---  ----------  -----  ------------- ---------------------------------
   1  2015-08-01  23:50  bpalmintier   Adapted from thesis_gens.inc v4
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
                old_coal_sub_st
                old_ng_cc
                old_ng_gt
                wind
                new_coal_st
                new_ng_cc
                new_ng_gt_aero
                new_nuke_st
               /

*Establish the generator cluster type and extended cluster type names so that we can use them 
*in the data table
acronyms    coal_sub_st
            ng_cc
            ng_gt
            wind
            u235_st
            ng_gt_aero;

*-- Generator Table Parameters
table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
                    type                cap_cur             cap_max             fuel                heatrate            gen_size            extended_type
*                   [code]              [GW]                [GW]                [name]              [MBTU/MWh]          [GW]                [code]       
old_coal_sub_st     coal_sub_st         2.29040             2.29040             coal_sub            10.536              0.57260             coal_sub_st
old_ng_cc           ng_cc               3.42657             3.42657             ng                  7.550               0.48951             ng_cc
old_ng_gt           ng_gt               0.99018             0.99018             ng                  11.403              0.11002             ng_gt
* Installed wind Set to 0.5GW
wind                wind                  0.4                5.0                wind                1.000               0.200               wind         
* New gen's heatrate & gen_size set to zero to use default from gen_param.inc
new_coal_st         coal_sub_st             0                1.3                coal_sub               0                0.650               coal_sub_st  
new_ng_cc           ng_cc                   0                1.6                ng                     0                0.400               ng_cc        
new_ng_gt_aero      ng_gt_aero              0                1.05               ng                     0                0.210               ng_gt_aero   
new_nuke_st         u235_st                 0                1.118              u235                   0                1.118               u235_st      
;
