
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
                Arthur_Von_Rosenberg_Combined
                Bastrop_Combined
                Bosque_County_Peaking_GT_1
                Bosque_County_Peaking_GT_2
                Bosque_County_Peaking_Units3to5_Combo
                Brazoz_Valley_Generating_Facility_Combo
                Coleto_Creek_1
                Colorado_Bend_Energy_Center_Combined_1
                Colorado_Bend_Energy_Center_Combined_2
                DeCordova_Steam_Electric_Station_CT4
                Ennis_Power_Company_Combined
                Fayette_Power_Project_1
                Fayette_Power_Project_2
                Fayette_Power_Project_3
                Permian_Basin_CT2
                Permian_Basin_CT3
                R_W_Miller_4
                R_W_Miller_5
                San_Jacinto_Steam_Electric_Station_1
                San_Jacinto_Steam_Electric_Station_2
                wind
                new_coal_st_1
                new_coal_st_2
                new_ng_cc_1
                new_ng_cc_2
                new_ng_cc_3
                new_ng_cc_4
                new_ng_gt_aero_1
                new_ng_gt_aero_2
                new_ng_gt_aero_3
                new_ng_gt_aero_4
                new_ng_gt_aero_5
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
*                                       [code]              [GW]                [GW]                [name]              [MBTU/MWh]          [GW]                [code]       
Arthur_Von_Rosenberg_Combined           ng_cc               0.55                0.55                ng                  7.499               0.55                ng_cc
Bastrop_Combined                        ng_cc               0.7278              0.7278              ng                  7.845               0.7278              ng_cc
Bosque_County_Peaking_GT_1              ng_gt               0.154               0.154               ng                  7.639               0.154               ng_gt
Bosque_County_Peaking_GT_2              ng_gt               0.154               0.154               ng                  7.639               0.154               ng_gt
Bosque_County_Peaking_Units3to5_Combo   ng_cc               0.499               0.499               ng                  7.639               0.499               ng_cc
Brazoz_Valley_Generating_Facility_Combo ng_cc               0.6756              0.6756              ng                  7.462               0.6756              ng_cc
Coleto_Creek_1                          coal_sub_st         0.6004              0.6004              coal_sub            10.133              0.6004              coal_sub_st
Colorado_Bend_Energy_Center_Combined_1  ng_cc               0.2781              0.2781              ng                  7.386               0.2781              ng_cc
Colorado_Bend_Energy_Center_Combined_2  ng_cc               0.2781              0.2781              ng                  7.386               0.2781              ng_cc
DeCordova_Steam_Electric_Station_CT4    ng_gt               0.0894              0.0894              ng                  12.147              0.0894              ng_gt
Ennis_Power_Company_Combined            ng_cc               0.418               0.418               ng                  7.361               0.418               ng_cc
Fayette_Power_Project_1                 coal_sub_st         0.615               0.615               coal_sub            10.679              0.615               coal_sub_st
Fayette_Power_Project_2                 coal_sub_st         0.615               0.615               coal_sub            10.679              0.615               coal_sub_st
Fayette_Power_Project_3                 coal_sub_st         0.46                0.46                coal_sub            10.679              0.46                coal_sub_st
Permian_Basin_CT2                       ng_gt               0.0894              0.0894              ng                  13.750              0.0894              ng_gt
Permian_Basin_CT3                       ng_gt               0.0894              0.0894              ng                  13.750              0.0894              ng_gt
R_W_Miller_4                            ng_gt               0.1188              0.1188              ng                  12.666              0.1188              ng_gt
R_W_Miller_5                            ng_gt               0.1188              0.1188              ng                  12.666              0.1188              ng_gt
San_Jacinto_Steam_Electric_Station_1    ng_gt               0.0882              0.0882              ng                  13.516              0.0882              ng_gt
San_Jacinto_Steam_Electric_Station_2    ng_gt               0.0882              0.0882              ng                  13.516              0.0882              ng_gt
* Installed wind Set to 0.5GW
wind                                    wind                  0.4                5.0                wind                1.000               0.200               wind         
* New gen's heatrate & gen_size set to zero to use default from gen_param.inc
new_coal_st_1                           coal_sub_st             0                0.65               coal_sub               0                0.650               coal_sub_st  
new_coal_st_2                           coal_sub_st             0                0.65               coal_sub               0                0.650               coal_sub_st  
new_ng_cc_1                             ng_cc                   0                0.40               ng                     0                0.400               ng_cc        
new_ng_cc_2                             ng_cc                   0                0.40               ng                     0                0.400               ng_cc        
new_ng_cc_3                             ng_cc                   0                0.40               ng                     0                0.400               ng_cc        
new_ng_cc_4                             ng_cc                   0                0.40               ng                     0                0.400               ng_cc        
new_ng_gt_aero_1                        ng_gt_aero              0                0.210              ng                     0                0.210               ng_gt_aero   
new_ng_gt_aero_2                        ng_gt_aero              0                0.210              ng                     0                0.210               ng_gt_aero   
new_ng_gt_aero_3                        ng_gt_aero              0                0.210              ng                     0                0.210               ng_gt_aero   
new_ng_gt_aero_4                        ng_gt_aero              0                0.210              ng                     0                0.210               ng_gt_aero   
new_ng_gt_aero_5                        ng_gt_aero              0                0.210              ng                     0                0.210               ng_gt_aero   
new_nuke_st                             u235_st                 0                1.118              u235                   0                1.118               u235_st      
;
