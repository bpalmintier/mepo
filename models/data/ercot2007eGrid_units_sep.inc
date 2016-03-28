
$ontext
 -----------------------------------------------------
 Generator data for operations & capacity planning with the Advanced Power Family of models

  ERCOT Unit-Level Data from 2010 edition of eGrid (2007 data)
  
  IMPORTANT: Only Capacities & Heatrates defined here. Must specify a gen_params file, too.

 Created using ERCOT2007 Unit Summary.xlsx SVN v343
 with the following filters:
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
    
  When pasting from Excel, convert tabs to spaces using a tabstop of 16

  Sources: eGrid 2010 v1.1

 originally coded in GAMS by Bryan Palmintier 2011-10-14

 Ver   Date       Time   Who           What
 ---  ----------  -----  ------------- ---------------------------------
   1  2011-10-14  00:30  bpalmintier   Adapted from ieee_rts96_gens_sepunit.inc v6
   2  2011-10-16  16:40  bpalmintier   Corrected typo where Forney_Energy_Center_Combined_ #1&2
                                        previously mis-labeled as Ennis_Power_Company_Combined_#
   3  2011-10-17  15:20  bpalmintier   Added control flag gen_type_data_defined
   4  2012-02-07  21:05  bpalmintier   Scaled from MW to GW, Corrected extended types
   5  2012-06-21  10:15  bpalmintier   Wind bin size to 100MW (existing average for 39 plants = 95MW)
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
                Arthur_Von_Rosenberg_Combined
                Barney_M_Davis_1
                Barney_M_Davis_2
                Bastrop_Combined
                Big_Brown_1
                Big_Brown_2
                Bosque_County_Peaking_GT_1
                Bosque_County_Peaking_GT_2
                Bosque_County_Peaking_Units3to5_Combined
                Brazoz_Valley_Generating_Facility_Combined
                Bryan_6
                Cedar_Bayou_1
                Cedar_Bayou_2
                Coleto_Creek_1
                Colorado_Bend_Energy_Center_Combined_1
                Colorado_Bend_Energy_Center_Combined_2
                Comanche_Peak_1
                Comanche_Peak_2
                Dansby_1
                Decker_Creek_1
                Decker_Creek_2
                Decker_Creek_GT1
                Decker_Creek_GT2
                Decker_Creek_GT3
                Decker_Creek_GT4
                DeCordova_Steam_Electric_Station_1
                DeCordova_Steam_Electric_Station_CT1
                DeCordova_Steam_Electric_Station_CT2
                DeCordova_Steam_Electric_Station_CT3
                DeCordova_Steam_Electric_Station_CT4
                Ennis_Power_Company_Combined
                Forney_Energy_Center_Combined_1
                Forney_Energy_Center_Combined_2
                wind
                Exelon_LaPorte_Generating_Station_GT1
                Exelon_LaPorte_Generating_Station_GT2
                Exelon_LaPorte_Generating_Station_GT3
                Exelon_LaPorte_Generating_Station_GT4
                Fayette_Power_Project_1
                Fayette_Power_Project_2
                Fayette_Power_Project_3
                Freestone_Power_Generation_LP_Combined_1
                Freestone_Power_Generation_LP_Combined_2
                Frontera_Energy_Center_Combined
                Gibbons_Creek_1
                Graham_1
                Graham_2
                Greens_Bayou_5
                Greens_Bayou_73
                Greens_Bayou_74
                Greens_Bayou_81
                Greens_Bayou_82
                Greens_Bayou_83
                Greens_Bayou_84
                Guadalupe_Generating_Station_Combined_1
                Guadalupe_Generating_Station_Combined_2
                Handley_2
                Handley_3
                Handley_4
                Handley_5
                Hays_Energy_Project_U1
                Hays_Energy_Project_U2
                Hays_Energy_Project_U3
                Hays_Energy_Project_U4
                Hidalgo_Energy_Center_Combined
                J_K_Spruce_1
                J_K_Spruce_2
                J_T_Deely_1
                J_T_Deely_2
                Jack_County_Combined
                Kiamichi_Energy_Facility_Combined_1
                Kiamichi_Energy_Facility_Combined_2
                Lake_Creek_ST1
                Lake_Creek_ST2
                Lake_Hubbard_1
                Lake_Hubbard_2
                Lamar_Power_Project_Combined_1
                Lamar_Power_Project_Combined_2
                Laredo_3
                Leon_Creek_3
                Leon_Creek_4
                Leon_Creek_CGT1
                Leon_Creek_CGT2
                Leon_Creek_CGT3
                Leon_Creek_CGT4
                Limestone_1
                Limestone_2
                Lost_Pines_1_Power_Project_Combined
                Magic_Valley_Generating_Station_Combined
                Martin_Lake_1
                Martin_Lake_2
                Martin_Lake_3
                Midlothian_Energy_Facility_STK1
                Midlothian_Energy_Facility_STK2
                Midlothian_Energy_Facility_STK3
                Midlothian_Energy_Facility_STK4
                Midlothian_Energy_Facility_STK5
                Midlothian_Energy_Facility_STK6
                Monticello_1
                Monticello_2
                Monticello_3
                Morgan_Creek_5
                Morgan_Creek_6
                Morgan_Creek_CT1
                Morgan_Creek_CT2
                Morgan_Creek_CT3
                Morgan_Creek_CT4
                Morgan_Creek_CT5
                Morgan_Creek_CT6
                Mountain_Creek_3
                Mountain_Creek_6
                Mountain_Creek_7
                Mountain_Creek_8
                Newgulf_Cogen_GEN1
                North_Lake_1
                North_Lake_2
                North_Lake_3
                O_W_Sommers_1
                O_W_Sommers_2
                Odessa_Ector_Generating_Station_Combined_1
                Odessa_Ector_Generating_Station_Combined_2
                Oklaunion_1
                P_H_Robinson_1
                P_H_Robinson_2
                P_H_Robinson_3
                P_H_Robinson_4
                Permian_Basin_5
                Permian_Basin_6
                Permian_Basin_CT1
                Permian_Basin_CT2
                Permian_Basin_CT3
                Permian_Basin_CT4
                Permian_Basin_CT5
                Quail_Run_Energy_Center_Combined_1
                Quail_Run_Energy_Center_Combined_2
                R_W_Miller_1
                R_W_Miller_2
                R_W_Miller_3
                R_W_Miller_4
                R_W_Miller_5
                Ray_Olinger_1
                Ray_Olinger_2
                Ray_Olinger_3
                Ray_Olinger_4
                Rio_Nogales_Power_Project_Combined
                Sam_Bertron_3
                Sam_Bertron_4
                Sam_Bertron_ST1
                Sam_Bertron_ST2
                Sam_Rayburn_Units7to10_Combined
                San_Jacinto_Steam_Electric_Station_1
                San_Jacinto_Steam_Electric_Station_2
                San_Miguel_1
                Sand_Hill_5Combined
                Sand_Hill_SH1
                Sand_Hill_SH2
                Sand_Hill_SH3
                Sand_Hill_SH4
                Sandow_No_4_4
                Silas_Ray_10
                Silas_Ray_Units6and9_Combined
                Sim_Gideon_1
                Sim_Gideon_2
                Sim_Gideon_3
                South_Texas_Project_1
                South_Texas_Project_2
                Spencer_4
                Spencer_5
                Stryker_Creek_ST1
                Stryker_Creek_ST2
                T_H_Wharton_3Combined
                T_H_Wharton_4Combined
                T_H_Wharton_51
                T_H_Wharton_52
                T_H_Wharton_53
                T_H_Wharton_54
                T_H_Wharton_55
                T_H_Wharton_56
                Tenaska_Frontier_Generation_Station_Combined
                Tenaska_Gateway_Generation_Station_Combined
                Thomas_C_Ferguson_1
                Tradinghouse_1
                Tradinghouse_2
                Trinidad_6
                Twin_Oaks_Power_One_1
                Twin_Oaks_Power_One_2
                V_H_Braunig_1
                V_H_Braunig_2
                V_H_Braunig_3
                Valley_1
                Valley_2
                Valley_3
                W_A_Parish_1
                W_A_Parish_2
                W_A_Parish_3
                W_A_Parish_4
                W_A_Parish_5
                W_A_Parish_6
                W_A_Parish_7
                W_A_Parish_8
                W_B_Tuttle_1
                W_B_Tuttle_3
                W_B_Tuttle_4
                Wise_County_Power_LP_Combined
                Wolf_Hollow_I_LP_Combined
               /

*Establish the generator cluster type and extended cluster type names so that we can use them 
*in the data table
acronyms    coal_lig_st
            coal_sub_st
            ng_cc
            ng_gt
            ng_st
            u235_st
            ng_cc_midAge_med_hiEff
            ng_st_midAge_med_hiEff
            ng_cc_midAge_med_avgEff
            coal_lig_st_old_med_avgEff
            ng_gt_midAge_med_hiEff
            ng_cc_midAge_med_hiEff
            ng_st_midAge_small_avgEff
            coal_sub_st_midAge_med_hiEff
            ng_cc_midAge_small_hiEff
            u235_st
            ng_st_midAge_small_hiEff
            ng_gt_midAge_small_avgEff
            ng_st_midAge_med_avgEff
            ng_gt_midAge_med_avgEff
            coal_sub_st_old_med_avgEff
            coal_sub_st_midAge_med_avgEff
            coal_sub_st_midAge_small_avgEff
            coal_sub_st_midAge_small_hiEff
            ng_gt_old_small_avgEff
            ng_st_old_small_avgEff
            coal_sub_st_old_small_avgEff
            ng_st_old_med_avgEff
            coal_lig_st_midAge_med_hiEff
            coal_lig_st_midAge_med_avgEff
            ng_cc_midAge_small_avgEff
            coal_lig_st_midAge_small_avgEff
            ng_gt_midAge_small_hiEff
            ng_cc_old_small_avgEff
            ng_st_old_med_hiEff
            ng_cc_old_med_avgEff
            ng_gt_old_med_hiEff
            wind
;

*-- Generator Table Parameters
table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
                                                type            cap_cur         cap_max         fuel             heatrate       gen_size        extended_type
*                                               [code]          [GW]            [GW]            [name]           [MBTU/MWh]     [GW]            [code]
Arthur_Von_Rosenberg_Combined                   ng_cc           0.55            0.55            ng              7.499           0.55            ng_cc_midAge_med_hiEff
Barney_M_Davis_1                                ng_st           0.352           0.352           ng              11.415          0.352           ng_st_midAge_med_hiEff
Barney_M_Davis_2                                ng_st           0.351           0.351           ng              11.415          0.351           ng_st_midAge_med_hiEff
Bastrop_Combined                                ng_cc           0.7278          0.7278          ng              7.845           0.7278          ng_cc_midAge_med_avgEff
Big_Brown_1                                     coal_lig_st     0.5934          0.5934          coal_lig        10.698          0.5934          coal_lig_st_old_med_avgEff
Big_Brown_2                                     coal_lig_st     0.5934          0.5934          coal_lig        10.698          0.5934          coal_lig_st_old_med_avgEff
Bosque_County_Peaking_GT_1                      ng_gt           0.154           0.154           ng              7.639           0.154           ng_gt_midAge_med_hiEff
Bosque_County_Peaking_GT_2                      ng_gt           0.154           0.154           ng              7.639           0.154           ng_gt_midAge_med_hiEff
Bosque_County_Peaking_Units3to5_Combined        ng_cc           0.499           0.499           ng              7.639           0.499           ng_cc_midAge_med_avgEff
Brazoz_Valley_Generating_Facility_Combined      ng_cc           0.6756          0.6756          ng              7.462           0.6756          ng_cc_midAge_med_hiEff
Bryan_6                                         ng_st           0.054           0.054           ng              21.683          0.054           ng_st_midAge_small_avgEff
Cedar_Bayou_1                                   ng_st           0.765           0.765           ng              10.729          0.765           ng_st_midAge_med_hiEff
Cedar_Bayou_2                                   ng_st           0.765           0.765           ng              10.729          0.765           ng_st_midAge_med_hiEff
Coleto_Creek_1                                  coal_sub_st     0.6004          0.6004          coal_sub        10.133          0.6004          coal_sub_st_midAge_med_hiEff
Colorado_Bend_Energy_Center_Combined_1          ng_cc           0.2781          0.2781          ng              7.386           0.2781          ng_cc_midAge_small_hiEff
Colorado_Bend_Energy_Center_Combined_2          ng_cc           0.2781          0.2781          ng              7.386           0.2781          ng_cc_midAge_small_hiEff
Comanche_Peak_1                                 u235_st         1.215           1.215           u235            10.400          1.215           u235_st
Comanche_Peak_2                                 u235_st         1.215           1.215           u235            10.400          1.215           u235_st
Dansby_1                                        ng_st           0.105           0.105           ng              11.288          0.105           ng_st_midAge_small_hiEff
Decker_Creek_1                                  ng_st           0.321           0.321           ng              11.002          0.321           ng_st_midAge_med_hiEff
Decker_Creek_2                                  ng_st           0.405           0.405           ng              11.002          0.405           ng_st_midAge_med_hiEff
Decker_Creek_GT1                                ng_gt           0.0515          0.0515          ng              11.002          0.0515          ng_gt_midAge_small_avgEff
Decker_Creek_GT2                                ng_gt           0.0515          0.0515          ng              11.002          0.0515          ng_gt_midAge_small_avgEff
Decker_Creek_GT3                                ng_gt           0.0515          0.0515          ng              11.002          0.0515          ng_gt_midAge_small_avgEff
Decker_Creek_GT4                                ng_gt           0.0515          0.0515          ng              11.002          0.0515          ng_gt_midAge_small_avgEff
DeCordova_Steam_Electric_Station_1              ng_st           0.7992          0.7992          ng              12.147          0.7992          ng_st_midAge_med_avgEff
DeCordova_Steam_Electric_Station_CT1            ng_gt           0.0894          0.0894          ng              12.147          0.0894          ng_gt_midAge_med_avgEff
DeCordova_Steam_Electric_Station_CT2            ng_gt           0.0894          0.0894          ng              12.147          0.0894          ng_gt_midAge_med_avgEff
DeCordova_Steam_Electric_Station_CT3            ng_gt           0.0894          0.0894          ng              12.147          0.0894          ng_gt_midAge_med_avgEff
DeCordova_Steam_Electric_Station_CT4            ng_gt           0.0894          0.0894          ng              12.147          0.0894          ng_gt_midAge_med_avgEff
Ennis_Power_Company_Combined                    ng_cc           0.418           0.418           ng              7.361           0.418           ng_cc_midAge_med_hiEff
Exelon_LaPorte_Generating_Station_GT1           ng_gt           0.059           0.059           ng              12.676          0.059           ng_gt_midAge_small_avgEff
Exelon_LaPorte_Generating_Station_GT2           ng_gt           0.059           0.059           ng              12.676          0.059           ng_gt_midAge_small_avgEff
Exelon_LaPorte_Generating_Station_GT3           ng_gt           0.059           0.059           ng              12.676          0.059           ng_gt_midAge_small_avgEff
Exelon_LaPorte_Generating_Station_GT4           ng_gt           0.059           0.059           ng              12.676          0.059           ng_gt_midAge_small_avgEff
Fayette_Power_Project_1                         coal_sub_st     0.615           0.615           coal_sub        10.679          0.615           coal_sub_st_old_med_avgEff
Fayette_Power_Project_2                         coal_sub_st     0.615           0.615           coal_sub        10.679          0.615           coal_sub_st_midAge_med_avgEff
Fayette_Power_Project_3                         coal_sub_st     0.46            0.46            coal_sub        10.679          0.46            coal_sub_st_midAge_small_avgEff
Forney_Energy_Center_Combined_1                 ng_cc           0.8919          0.8919          ng              7.351           0.8919          ng_cc_midAge_med_hiEff
Forney_Energy_Center_Combined_2                 ng_cc           0.8919          0.8919          ng              7.351           0.8919          ng_cc_midAge_med_hiEff
Freestone_Power_Generation_LP_Combined_1        ng_cc           0.518           0.518           ng              7.522           0.518           ng_cc_midAge_med_avgEff
Freestone_Power_Generation_LP_Combined_2        ng_cc           0.518           0.518           ng              7.522           0.518           ng_cc_midAge_med_avgEff
Frontera_Energy_Center_Combined                 ng_cc           0.529           0.529           ng              7.535           0.529           ng_cc_midAge_med_avgEff
Gibbons_Creek_1                                 coal_sub_st     0.4535          0.4535          coal_sub        9.977           0.4535          coal_sub_st_midAge_small_hiEff
Graham_1                                        ng_st           0.2477          0.2477          ng              11.947          0.2477          ng_st_midAge_med_avgEff
Graham_2                                        ng_st           0.387           0.387           ng              11.947          0.387           ng_st_midAge_med_avgEff
Greens_Bayou_5                                  ng_st           0.4464          0.4464          ng              14.681          0.4464          ng_st_midAge_med_avgEff
Greens_Bayou_73                                 ng_gt           0.072           0.072           ng              14.681          0.072           ng_gt_old_small_avgEff
Greens_Bayou_74                                 ng_gt           0.072           0.072           ng              14.681          0.072           ng_gt_old_small_avgEff
Greens_Bayou_81                                 ng_gt           0.072           0.072           ng              14.681          0.072           ng_gt_old_small_avgEff
Greens_Bayou_82                                 ng_gt           0.072           0.072           ng              14.681          0.072           ng_gt_old_small_avgEff
Greens_Bayou_83                                 ng_gt           0.072           0.072           ng              14.681          0.072           ng_gt_old_small_avgEff
Greens_Bayou_84                                 ng_gt           0.072           0.072           ng              14.681          0.072           ng_gt_old_small_avgEff
Guadalupe_Generating_Station_Combined_1         ng_cc           0.5711          0.5711          ng              7.423           0.5711          ng_cc_midAge_med_hiEff
Guadalupe_Generating_Station_Combined_2         ng_cc           0.5711          0.5711          ng              7.423           0.5711          ng_cc_midAge_med_hiEff
Handley_2                                       ng_st           0.0748          0.0748          ng              13.823          0.0748          ng_st_old_small_avgEff
Handley_3                                       ng_st           0.4048          0.4048          ng              13.823          0.4048          ng_st_midAge_med_avgEff
Handley_4                                       ng_st           0.455           0.455           ng              13.823          0.455           ng_st_midAge_med_avgEff
Handley_5                                       ng_st           0.455           0.455           ng              13.823          0.455           ng_st_midAge_med_avgEff
Hays_Energy_Project_U1                          ng_cc           0.2417          0.2417          ng              7.158           0.2417          ng_cc_midAge_small_hiEff
Hays_Energy_Project_U2                          ng_cc           0.2417          0.2417          ng              7.158           0.2417          ng_cc_midAge_small_hiEff
Hays_Energy_Project_U3                          ng_cc           0.2528          0.2528          ng              7.158           0.2528          ng_cc_midAge_small_hiEff
Hays_Energy_Project_U4                          ng_cc           0.2528          0.2528          ng              7.158           0.2528          ng_cc_midAge_small_hiEff
Hidalgo_Energy_Center_Combined                  ng_cc           0.5513          0.5513          ng              7.219           0.5513          ng_cc_midAge_med_hiEff
J_K_Spruce_1                                    coal_sub_st     0.566           0.566           coal_sub        10.822          0.566           coal_sub_st_midAge_med_avgEff
J_K_Spruce_2                                    coal_sub_st     0.82            0.82            coal_sub        10.822          0.82            coal_sub_st_midAge_med_avgEff
J_T_Deely_1                                     coal_sub_st     0.486           0.486           coal_sub        14.073          0.486           coal_sub_st_old_small_avgEff
J_T_Deely_2                                     coal_sub_st     0.446           0.446           coal_sub        14.073          0.446           coal_sub_st_old_small_avgEff
Jack_County_Combined                            ng_cc           0.64            0.64            ng              7.284           0.64            ng_cc_midAge_med_hiEff
Kiamichi_Energy_Facility_Combined_1             ng_cc           0.685           0.685           ng              7.397           0.685           ng_cc_midAge_med_hiEff
Kiamichi_Energy_Facility_Combined_2             ng_cc           0.685           0.685           ng              7.397           0.685           ng_cc_midAge_med_hiEff
Lake_Creek_ST1                                  ng_st           0.0796          0.0796          ng              14.369          0.0796          ng_st_old_small_avgEff
Lake_Creek_ST2                                  ng_st           0.236           0.236           ng              14.369          0.236           ng_st_old_med_avgEff
Lake_Hubbard_1                                  ng_st           0.3965          0.3965          ng              12.159          0.3965          ng_st_midAge_med_avgEff
Lake_Hubbard_2                                  ng_st           0.531           0.531           ng              12.159          0.531           ng_st_midAge_med_avgEff
Lamar_Power_Project_Combined_1                  ng_cc           0.5454          0.5454          ng              7.768           0.5454          ng_cc_midAge_med_avgEff
Lamar_Power_Project_Combined_2                  ng_cc           0.5454          0.5454          ng              7.768           0.5454          ng_cc_midAge_med_avgEff
Laredo_3                                        ng_st           0.1152          0.1152          ng              11.592          0.1152          ng_st_midAge_small_avgEff
Leon_Creek_3                                    ng_st           0.075           0.075           ng              11.834          0.075           ng_st_old_small_avgEff
Leon_Creek_4                                    ng_st           0.1137          0.1137          ng              11.834          0.1137          ng_st_old_small_avgEff
Leon_Creek_CGT1                                 ng_gt           0.0574          0.0574          ng              11.834          0.0574          ng_gt_midAge_small_avgEff
Leon_Creek_CGT2                                 ng_gt           0.0574          0.0574          ng              11.834          0.0574          ng_gt_midAge_small_avgEff
Leon_Creek_CGT3                                 ng_gt           0.0574          0.0574          ng              11.834          0.0574          ng_gt_midAge_small_avgEff
Leon_Creek_CGT4                                 ng_gt           0.0574          0.0574          ng              11.834          0.0574          ng_gt_midAge_small_avgEff
Limestone_1                                     coal_lig_st     0.893           0.893           coal_lig        9.612           0.893           coal_lig_st_midAge_med_hiEff
Limestone_2                                     coal_lig_st     0.9568          0.9568          coal_lig        9.612           0.9568          coal_lig_st_midAge_med_hiEff
Lost_Pines_1_Power_Project_Combined             ng_cc           0.595           0.595           ng              7.217           0.595           ng_cc_midAge_med_hiEff
Magic_Valley_Generating_Station_Combined        ng_cc           0.801           0.801           ng              7.275           0.801           ng_cc_midAge_med_hiEff
Martin_Lake_1                                   coal_lig_st     0.7932          0.7932          coal_lig        11.090          0.7932          coal_lig_st_midAge_med_avgEff
Martin_Lake_2                                   coal_lig_st     0.7932          0.7932          coal_lig        11.090          0.7932          coal_lig_st_midAge_med_avgEff
Martin_Lake_3                                   coal_lig_st     0.7932          0.7932          coal_lig        11.090          0.7932          coal_lig_st_midAge_med_avgEff
Midlothian_Energy_Facility_STK1                 ng_cc           0.289           0.289           ng              7.460           0.289           ng_cc_midAge_small_hiEff
Midlothian_Energy_Facility_STK2                 ng_cc           0.289           0.289           ng              7.460           0.289           ng_cc_midAge_small_hiEff
Midlothian_Energy_Facility_STK3                 ng_cc           0.289           0.289           ng              7.460           0.289           ng_cc_midAge_small_hiEff
Midlothian_Energy_Facility_STK4                 ng_cc           0.289           0.289           ng              7.460           0.289           ng_cc_midAge_small_hiEff
Midlothian_Energy_Facility_STK5                 ng_cc           0.289           0.289           ng              7.460           0.289           ng_cc_midAge_small_hiEff
Midlothian_Energy_Facility_STK6                 ng_cc           0.289           0.289           ng              7.460           0.289           ng_cc_midAge_small_hiEff
Monticello_1                                    coal_lig_st     0.5934          0.5934          coal_lig        10.916          0.5934          coal_lig_st_old_med_avgEff
Monticello_2                                    coal_lig_st     0.5934          0.5934          coal_lig        10.916          0.5934          coal_lig_st_midAge_med_avgEff
Monticello_3                                    coal_lig_st     0.7932          0.7932          coal_lig        10.916          0.7932          coal_lig_st_midAge_med_avgEff
Morgan_Creek_5                                  ng_st           0.1704          0.1704          ng              13.844          0.1704          ng_st_old_med_avgEff
Morgan_Creek_6                                  ng_st           0.5175          0.5175          ng              13.844          0.5175          ng_st_midAge_med_avgEff
Morgan_Creek_CT1                                ng_gt           0.0894          0.0894          ng              13.844          0.0894          ng_gt_midAge_med_avgEff
Morgan_Creek_CT2                                ng_gt           0.0894          0.0894          ng              13.844          0.0894          ng_gt_midAge_med_avgEff
Morgan_Creek_CT3                                ng_gt           0.0894          0.0894          ng              13.844          0.0894          ng_gt_midAge_med_avgEff
Morgan_Creek_CT4                                ng_gt           0.0894          0.0894          ng              13.844          0.0894          ng_gt_midAge_med_avgEff
Morgan_Creek_CT5                                ng_gt           0.0894          0.0894          ng              13.844          0.0894          ng_gt_midAge_med_avgEff
Morgan_Creek_CT6                                ng_gt           0.0894          0.0894          ng              13.844          0.0894          ng_gt_midAge_med_avgEff
Mountain_Creek_3                                ng_st           0.0749          0.0749          ng              12.481          0.0749          ng_st_old_small_avgEff
Mountain_Creek_6                                ng_st           0.1357          0.1357          ng              12.481          0.1357          ng_st_old_small_avgEff
Mountain_Creek_7                                ng_st           0.136           0.136           ng              12.481          0.136           ng_st_old_small_avgEff
Mountain_Creek_8                                ng_st           0.5805          0.5805          ng              12.481          0.5805          ng_st_midAge_med_avgEff
Newgulf_Cogen_GEN1                              ng_gt           0.0787          0.0787          ng              13.784          0.0787          ng_gt_midAge_med_avgEff
North_Lake_1                                    ng_st           0.1768          0.1768          ng              11.651          0.1768          ng_st_old_med_avgEff
North_Lake_2                                    ng_st           0.1704          0.1704          ng              11.651          0.1704          ng_st_midAge_med_avgEff
North_Lake_3                                    ng_st           0.3613          0.3613          ng              11.651          0.3613          ng_st_midAge_med_avgEff
O_W_Sommers_1                                   ng_st           0.446           0.446           ng              12.109          0.446           ng_st_midAge_med_avgEff
O_W_Sommers_2                                   ng_st           0.446           0.446           ng              12.109          0.446           ng_st_midAge_med_avgEff
Odessa_Ector_Generating_Station_Combined_1      ng_cc           0.5676          0.5676          ng              7.604           0.5676          ng_cc_midAge_med_avgEff
Odessa_Ector_Generating_Station_Combined_2      ng_cc           0.5676          0.5676          ng              7.604           0.5676          ng_cc_midAge_med_avgEff
Oklaunion_1                                     coal_sub_st     0.72            0.72            coal_sub        10.582          0.72            coal_sub_st_midAge_med_avgEff
P_H_Robinson_1                                  ng_st           0.4845          0.4845          ng              13.008          0.4845          ng_st_midAge_med_avgEff
P_H_Robinson_2                                  ng_st           0.4845          0.4845          ng              13.008          0.4845          ng_st_midAge_med_avgEff
P_H_Robinson_3                                  ng_st           0.5805          0.5805          ng              13.008          0.5805          ng_st_midAge_med_avgEff
P_H_Robinson_4                                  ng_st           0.765           0.765           ng              13.008          0.765           ng_st_midAge_med_avgEff
Permian_Basin_5                                 ng_st           0.1149          0.1149          ng              13.750          0.1149          ng_st_old_small_avgEff
Permian_Basin_6                                 ng_st           0.5355          0.5355          ng              13.750          0.5355          ng_st_midAge_med_avgEff
Permian_Basin_CT1                               ng_gt           0.0894          0.0894          ng              13.750          0.0894          ng_gt_midAge_med_avgEff
Permian_Basin_CT2                               ng_gt           0.0894          0.0894          ng              13.750          0.0894          ng_gt_midAge_med_avgEff
Permian_Basin_CT3                               ng_gt           0.0894          0.0894          ng              13.750          0.0894          ng_gt_midAge_med_avgEff
Permian_Basin_CT4                               ng_gt           0.0894          0.0894          ng              13.750          0.0894          ng_gt_midAge_med_avgEff
Permian_Basin_CT5                               ng_gt           0.0894          0.0894          ng              13.750          0.0894          ng_gt_midAge_med_avgEff
Quail_Run_Energy_Center_Combined_1              ng_cc           0.298           0.298           ng              8.540           0.298           ng_cc_midAge_small_avgEff
Quail_Run_Energy_Center_Combined_2              ng_cc           0.275           0.275           ng              8.540           0.275           ng_cc_midAge_small_avgEff
R_W_Miller_1                                    ng_st           0.066           0.066           ng              12.666          0.066           ng_st_midAge_small_avgEff
R_W_Miller_2                                    ng_st           0.1             0.1             ng              12.666          0.1             ng_st_midAge_small_avgEff
R_W_Miller_3                                    ng_st           0.2             0.2             ng              12.666          0.2             ng_st_midAge_med_avgEff
R_W_Miller_4                                    ng_gt           0.1188          0.1188          ng              12.666          0.1188          ng_gt_midAge_med_avgEff
R_W_Miller_5                                    ng_gt           0.1188          0.1188          ng              12.666          0.1188          ng_gt_midAge_med_avgEff
Ray_Olinger_1                                   ng_st           0.075           0.075           ng              12.326          0.075           ng_st_midAge_small_avgEff
Ray_Olinger_2                                   ng_st           0.1134          0.1134          ng              12.326          0.1134          ng_st_midAge_small_avgEff
Ray_Olinger_3                                   ng_st           0.1566          0.1566          ng              12.326          0.1566          ng_st_midAge_med_avgEff
Ray_Olinger_4                                   ng_gt           0.0827          0.0827          ng              12.326          0.0827          ng_gt_midAge_med_avgEff
Rio_Nogales_Power_Project_Combined              ng_cc           0.8982          0.8982          ng              7.298           0.8982          ng_cc_midAge_med_hiEff
Sam_Bertron_3                                   ng_st           0.2253          0.2253          ng              11.572          0.2253          ng_st_old_med_avgEff
Sam_Bertron_4                                   ng_st           0.2253          0.2253          ng              11.572          0.2253          ng_st_midAge_med_avgEff
Sam_Bertron_ST1                                 ng_st           0.1878          0.1878          ng              11.572          0.1878          ng_st_old_med_avgEff
Sam_Bertron_ST2                                 ng_st           0.1878          0.1878          ng              11.572          0.1878          ng_st_old_med_avgEff
Sam_Rayburn_Units7to10_Combined                 ng_cc           0.1896          0.1896          ng              9.147           0.1896          ng_cc_midAge_small_avgEff
San_Jacinto_Steam_Electric_Station_1            ng_gt           0.0882          0.0882          ng              13.516          0.0882          ng_gt_midAge_med_avgEff
San_Jacinto_Steam_Electric_Station_2            ng_gt           0.0882          0.0882          ng              13.516          0.0882          ng_gt_midAge_med_avgEff
San_Miguel_1                                    coal_lig_st     0.41            0.41            coal_lig        12.148          0.41            coal_lig_st_midAge_small_avgEff
Sand_Hill_5Combined                             ng_cc           0.388           0.388           ng              7.328           0.388           ng_cc_midAge_med_hiEff
Sand_Hill_SH1                                   ng_gt           0.0514          0.0514          ng              7.328           0.0514          ng_gt_midAge_small_hiEff
Sand_Hill_SH2                                   ng_gt           0.0514          0.0514          ng              7.328           0.0514          ng_gt_midAge_small_hiEff
Sand_Hill_SH3                                   ng_gt           0.0514          0.0514          ng              7.328           0.0514          ng_gt_midAge_small_hiEff
Sand_Hill_SH4                                   ng_gt           0.0514          0.0514          ng              7.328           0.0514          ng_gt_midAge_small_hiEff
Sandow_No_4_4                                   coal_lig_st     0.5906          0.5906          coal_lig        11.163          0.5906          coal_lig_st_midAge_med_avgEff
Silas_Ray_10                                    ng_gt           0.061           0.061           ng              11.083          0.061           ng_gt_midAge_small_avgEff
Silas_Ray_Units6and9_Combined                   ng_cc           0.086           0.086           ng              11.083          0.086           ng_cc_old_small_avgEff
Sim_Gideon_1                                    ng_st           0.144           0.144           ng              11.456          0.144           ng_st_midAge_small_hiEff
Sim_Gideon_2                                    ng_st           0.144           0.144           ng              11.456          0.144           ng_st_midAge_small_hiEff
Sim_Gideon_3                                    ng_st           0.351           0.351           ng              11.456          0.351           ng_st_midAge_med_hiEff
South_Texas_Project_1                           u235_st         1.3543          1.3543          u235            10.400          1.3543          u235_st
South_Texas_Project_2                           u235_st         1.3543          1.3543          u235            10.400          1.3543          u235_st
Spencer_4                                       ng_st           0.0611          0.0611          ng              16.622          0.0611          ng_st_midAge_small_avgEff
Spencer_5                                       ng_st           0.0654          0.0654          ng              16.622          0.0654          ng_st_midAge_small_avgEff
Stryker_Creek_ST1                               ng_st           0.1768          0.1768          ng              11.375          0.1768          ng_st_old_med_hiEff
Stryker_Creek_ST2                               ng_st           0.5266          0.5266          ng              11.375          0.5266          ng_st_midAge_med_hiEff
T_H_Wharton_3Combined                           ng_cc           0.3183          0.3183          ng              9.529           0.3183          ng_cc_old_med_avgEff
T_H_Wharton_4Combined                           ng_cc           0.3291          0.3291          ng              9.529           0.3291          ng_cc_old_med_avgEff
T_H_Wharton_51                                  ng_gt           0.085           0.085           ng              9.529           0.085           ng_gt_old_med_hiEff
T_H_Wharton_52                                  ng_gt           0.085           0.085           ng              9.529           0.085           ng_gt_old_med_hiEff
T_H_Wharton_53                                  ng_gt           0.085           0.085           ng              9.529           0.085           ng_gt_old_med_hiEff
T_H_Wharton_54                                  ng_gt           0.085           0.085           ng              9.529           0.085           ng_gt_old_med_hiEff
T_H_Wharton_55                                  ng_gt           0.085           0.085           ng              9.529           0.085           ng_gt_old_med_hiEff
T_H_Wharton_56                                  ng_gt           0.085           0.085           ng              9.529           0.085           ng_gt_old_med_hiEff
Tenaska_Frontier_Generation_Station_Combined    ng_cc           0.9397          0.9397          ng              6.901           0.9397          ng_cc_midAge_med_hiEff
Tenaska_Gateway_Generation_Station_Combined     ng_cc           0.9396          0.9396          ng              7.475           0.9396          ng_cc_midAge_med_hiEff
Thomas_C_Ferguson_1                             ng_st           0.446           0.446           ng              10.994          0.446           ng_st_midAge_med_hiEff
Tradinghouse_1                                  ng_st           0.5805          0.5805          ng              11.838          0.5805          ng_st_midAge_med_avgEff
Tradinghouse_2                                  ng_st           0.7992          0.7992          ng              11.838          0.7992          ng_st_midAge_med_avgEff
Trinidad_6                                      ng_st           0.2393          0.2393          ng              13.508          0.2393          ng_st_midAge_med_avgEff
Twin_Oaks_Power_One_1                           coal_lig_st     0.1746          0.1746          coal_lig        10.860          0.1746          coal_lig_st_midAge_small_avgEff
Twin_Oaks_Power_One_2                           coal_lig_st     0.1746          0.1746          coal_lig        10.860          0.1746          coal_lig_st_midAge_small_avgEff
V_H_Braunig_1                                   ng_st           0.225           0.225           ng              11.161          0.225           ng_st_midAge_med_hiEff
V_H_Braunig_2                                   ng_st           0.252           0.252           ng              11.161          0.252           ng_st_midAge_med_hiEff
V_H_Braunig_3                                   ng_st           0.417           0.417           ng              11.161          0.417           ng_st_midAge_med_hiEff
Valley_1                                        ng_st           0.1989          0.1989          ng              13.664          0.1989          ng_st_midAge_med_avgEff
Valley_2                                        ng_st           0.5805          0.5805          ng              13.664          0.5805          ng_st_midAge_med_avgEff
Valley_3                                        ng_st           0.396           0.396           ng              13.664          0.396           ng_st_midAge_med_avgEff
W_A_Parish_1                                    ng_st           0.1878          0.1878          ng              10.382          0.1878          ng_st_old_med_hiEff
W_A_Parish_2                                    ng_st           0.1878          0.1878          ng              10.382          0.1878          ng_st_old_med_hiEff
W_A_Parish_3                                    ng_st           0.2992          0.2992          ng              10.382          0.2992          ng_st_midAge_med_hiEff
W_A_Parish_4                                    ng_st           0.5805          0.5805          ng              10.382          0.5805          ng_st_midAge_med_hiEff
W_A_Parish_5                                    coal_sub_st     0.7341          0.7341          coal_sub        10.382          0.7341          coal_sub_st_old_med_avgEff
W_A_Parish_6                                    coal_sub_st     0.7341          0.7341          coal_sub        10.382          0.7341          coal_sub_st_old_med_avgEff
W_A_Parish_7                                    coal_sub_st     0.6146          0.6146          coal_sub        10.382          0.6146          coal_sub_st_midAge_med_avgEff
W_A_Parish_8                                    coal_sub_st     0.6146          0.6146          coal_sub        10.382          0.6146          coal_sub_st_midAge_med_avgEff
W_B_Tuttle_1                                    ng_st           0.075           0.075           ng              17.474          0.075           ng_st_old_small_avgEff
W_B_Tuttle_3                                    ng_st           0.1136          0.1136          ng              17.474          0.1136          ng_st_midAge_small_avgEff
W_B_Tuttle_4                                    ng_st           0.1917          0.1917          ng              17.474          0.1917          ng_st_midAge_med_avgEff
wind                                            wind            3.71050         3.71050         wind            1.000           0.1             wind
Wise_County_Power_LP_Combined                   ng_cc           0.746           0.746           ng              7.609           0.746           ng_cc_midAge_med_avgEff
Wolf_Hollow_I_LP_Combined                       ng_cc           0.8096          0.8096          ng              7.882           0.8096          ng_cc_midAge_med_avgEff
;
