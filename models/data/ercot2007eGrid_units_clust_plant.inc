
$ontext
 -----------------------------------------------------
 Generator data for operations & capacity planning with the Advanced Power Family of models

  ERCOT Unit-Level Data from 2010 edition of eGrid (2007 data)
  
  Clustered by: PLANT (ie only units of same type in same plant)
  
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
   Semi-automated cluster by grouping units of the same fuel-prime mover combination from
   a single plant into a cluster.

  When pasting from Excel, convert tabs to spaces using a tabstop of 16

  Sources: eGrid 2010 v1.1

 originally coded in GAMS by Bryan Palmintier 2011-10-14

 Ver   Date       Time   Who           What
 ---  ----------  -----  ------------- ---------------------------------
   1  2011-10-14  00:30  bpalmintier   Adapted from ercot2007eGrid_gens_sepunit.inc v3
   2  2011-10-16  16:40  bpalmintier   Corrected typo where Forney_Energy_Center_Combined_ #1&2
                                        previously mis-labeled as Ennis_Power_Company_Combined_#
   3  2011-10-17  15:20  bpalmintier   Added control flag gen_type_data_defined
   4  2012-02-07  21:05  bpalmintier   Scaled from MW to GW
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

         G           "generation: Units Grouped by Plan and type"
               /
                Arthur_Von_Rosenberg
                Barney_M_Davis
                Bastrop_Energy_Center
                Big_Brown
                Bosque_County_Peaking_CCGT
                Bosque_County_Peaking_GT
                Brazos_Valley_Generating_Facility
                Bryan
                Cedar_Bayou
                Coleto_Creek
                Colorado_Bend_Energy_Center
                Comanche_Peak
                Dansby_ST
                DeCordova_Steam_Electric_Station_GT
                DeCordova_Steam_Electric_Station_ST
                Decker_Creek_GT
                Decker_Creek_ST
                Ennis_Power_Company_LLC
                Exelon_LaPorte_Generating_Station
                Fayette_Power_Project
                Forney_Energy_Center
                Freestone_Power_Generation_LP
                Frontera_Energy_Center
                Gibbons_Creek
                Graham
                Greens_Bayou
                Guadalupe_Generating_Station
                Handley
                Hays_Energy_Project
                Hidalgo_Energy_Center
                J_K_Spruce
                J_T_Deely
                Jack_County
                Kiamichi_Energy_Facility
                Lake_Creek_ng_ST
                Lake_Hubbard
                Lamar_Power_Project
                Laredo
                Leon_Creek
                Limestone
                Lost_Pines_1_Power_Project
                Magic_Valley_Generating_Station
                Martin_Lake
                Midlothian_Energy_Facility
                Monticello
                Morgan_Creek
                Mountain_Creek
                Newgulf_Cogen
                North_Lake
                O_W_Sommers
                Odessa_Ector_Generating_Station
                Oklaunion
                P_H_Robinson
                Permian_Basin_GT
                Permian_Basin_ST
                Quail_Run_Energy_Center
                R_W_Miller_GT
                R_W_Miller_ST
                Ray_Olinger_GT
                Ray_Olinger_ST
                Rio_Nogales_Power_Project
                Sam_Bertron_ST
                Sam_Rayburn_CCGT
                San_Jacinto_Steam_Electric_Station
                San_Miguel
                Sand_Hill_CCGT
                Sand_Hill_ng_GT
                Sandow_No_4
                Silas_Ray_CCGT
                Silas_Ray_oil_IC
                Sim_Gideon
                South_Texas_Project
                Spencer
                Stryker_Creek_ng_ST
                T_H_Wharton_CCGT
                T_H_Wharton_GT
                Tenaska_Frontier_Generation_Station
                Tenaska_Gateway_Generating_Station
                Thomas_C_Ferguson
                Tradinghouse
                Trinidad_ng_ST
                Twin_Oaks_Power_One
                V_H_Braunig
                Valley
                W_A_Parish_Coal
                W_A_Parish_ng_ST
                W_B_Tuttle
                Wise_County_Power_LP
                Wolf_Hollow_I_LP
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
            coal_lig_st_midAge_med_avgEff
            coal_lig_st_midAge_med_hiEff
            coal_lig_st_midAge_small_avgEff
            coal_lig_st_old_med_avgEff
            coal_sub_st_midAge_med_avgEff
            coal_sub_st_midAge_med_hiEff
            coal_sub_st_midAge_small_hiEff
            coal_sub_st_old_med_avgEff
            ng_cc_midAge_med_avgEff
            ng_cc_midAge_med_hiEff
            ng_cc_midAge_small_avgEff
            ng_cc_old_med_avgEff
            ng_cc_old_med_hiEff
            ng_cc_old_small_avgEff
            ng_gt_midAge_med_avgEff
            ng_gt_midAge_med_hiEff
            ng_gt_midAge_small_avgEff
            ng_gt_old_med_hiEff
            ng_st_midAge_med_avgEff
            ng_st_midAge_med_hiEff
            ng_st_midAge_small_avgEff
            ng_st_midAge_small_hiEff
            ng_st_old_med_avgEff
            ng_st_old_med_hiEff
            u235_st
            wind
            ;

*-- Generator Table Parameters
table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
                                                type            cap_cur         cap_max         fuel             heatrate       gen_size        extended_type
*                                               [code]          [GW]            [MW]            [name]           [MBTU/MWh]     [MW]            [code]
Arthur_Von_Rosenberg                            ng_cc           0.5500          0.5500          ng              7.499           0.5500          ng_cc_midAge_med_hiEff
Barney_M_Davis                                  ng_st           0.7030          0.7030          ng              11.415          0.3515          ng_st_midAge_med_hiEff
Bastrop_Energy_Center                           ng_cc           0.7278          0.7278          ng              7.845           0.7278          ng_cc_midAge_med_avgEff
Big_Brown                                       coal_lig_st     1.1868          1.1868          coal_lig        10.698          0.5934          coal_lig_st_old_med_avgEff
Bosque_County_Peaking_CCGT                      ng_cc           0.4990          0.4990          ng              7.639           0.4990          ng_cc_midAge_med_avgEff
Bosque_County_Peaking_GT                        ng_gt           0.3080          0.3080          ng              7.639           0.1540          ng_gt_midAge_med_hiEff
Brazos_Valley_Generating_Facility               ng_cc           0.6756          0.6756          ng              7.462           0.6756          ng_cc_old_med_hiEff
Bryan                                           ng_st           0.0540          0.0540          ng              21.683          0.0540          ng_st_midAge_small_avgEff
Cedar_Bayou                                     ng_st           1.5300          1.5300          ng              10.729          0.7650          ng_st_midAge_med_hiEff
Coleto_Creek                                    coal_sub_st     0.6004          0.6004          coal_sub        10.133          0.6004          coal_sub_st_midAge_med_hiEff
Colorado_Bend_Energy_Center                     ng_cc           0.5562          0.5562          ng              7.386           0.2781          ng_cc_midAge_med_hiEff
Comanche_Peak                                   u235_st         2.4300          2.4300          u235            10.400          1.2150          u235_st
Dansby_ST                                       ng_st           0.1050          0.1050          ng              11.288          0.1050          ng_st_midAge_small_hiEff
DeCordova_Steam_Electric_Station_GT             ng_gt           0.3576          0.3576          ng              12.147          0.0894          ng_gt_midAge_med_avgEff
DeCordova_Steam_Electric_Station_ST             ng_st           0.7992          0.7992          ng              12.147          0.7992          ng_st_midAge_med_avgEff
Decker_Creek_GT                                 ng_gt           0.2060          0.2060          ng              11.002          0.0515          ng_gt_midAge_med_avgEff
Decker_Creek_ST                                 ng_st           0.7260          0.7260          ng              11.002          0.3630          ng_st_midAge_med_hiEff
Ennis_Power_Company_LLC                         ng_cc           0.4180          0.4180          ng              7.361           0.4180          ng_cc_midAge_med_hiEff
Exelon_LaPorte_Generating_Station               ng_gt           0.2360          0.2360          ng              12.676          0.0590          ng_gt_midAge_med_avgEff
Fayette_Power_Project                           coal_sub_st     1.6900          1.6900          coal_sub        10.679          0.5633          coal_sub_st_old_med_avgEff
Forney_Energy_Center                            ng_cc           1.7838          1.7838          ng              7.351           0.8919          ng_cc_midAge_med_hiEff
Freestone_Power_Generation_LP                   ng_cc           1.0360          1.0360          ng              7.522           0.5180          ng_cc_midAge_med_avgEff
Frontera_Energy_Center                          ng_cc           0.5290          0.5290          ng              7.535           0.5290          ng_cc_midAge_med_avgEff
Gibbons_Creek                                   coal_sub_st     0.4535          0.4535          coal_sub        9.977           0.4535          coal_sub_st_midAge_small_hiEff
Graham                                          ng_st           0.6347          0.6347          ng              11.947          0.3174          ng_st_midAge_med_avgEff
Greens_Bayou                                    ng_st           0.8784          0.8784          ng              14.681          0.1255          ng_st_midAge_med_avgEff
Guadalupe_Generating_Station                    ng_cc           1.1422          1.1422          ng              7.423           0.5711          ng_cc_midAge_med_hiEff
Handley                                         ng_st           1.3896          1.3896          ng              13.823          0.3474          ng_st_old_med_avgEff
Hays_Energy_Project                             ng_cc           0.9890          0.9890          ng              7.158           0.2473          ng_cc_midAge_med_hiEff
Hidalgo_Energy_Center                           ng_cc           0.5513          0.5513          ng              7.219           0.5513          ng_cc_midAge_med_hiEff
J_K_Spruce                                      coal_sub_st     1.3860          1.3860          coal_sub        10.822          0.6930          coal_sub_st_midAge_med_avgEff
J_T_Deely                                       coal_sub_st     0.9320          0.9320          coal_sub        14.073          0.4660          coal_sub_st_old_med_avgEff
Jack_County                                     ng_cc           0.6400          0.6400          ng              7.284           0.6400          ng_cc_midAge_med_hiEff
Kiamichi_Energy_Facility                        ng_cc           1.3700          1.3700          ng              7.397           0.6850          ng_cc_midAge_med_hiEff
Lake_Creek_ng_ST                                ng_st           0.3156          0.3156          ng              14.369          0.1578          ng_st_old_med_avgEff
Lake_Hubbard                                    ng_st           0.9275          0.9275          ng              12.159          0.4638          ng_st_midAge_med_avgEff
Lamar_Power_Project                             ng_cc           1.0908          1.0908          ng              7.768           0.5454          ng_cc_midAge_med_avgEff
Laredo                                          ng_st           0.1152          0.1152          ng              11.592          0.1152          ng_st_midAge_small_avgEff
Leon_Creek                                      ng_st           0.4183          0.4183          ng              11.834          0.0697          ng_st_old_med_avgEff
Limestone                                       coal_lig_st     1.8498          1.8498          coal_lig        9.612           0.9249          coal_lig_st_midAge_med_hiEff
Lost_Pines_1_Power_Project                      ng_cc           0.5950          0.5950          ng              7.217           0.5950          ng_cc_midAge_med_hiEff
Magic_Valley_Generating_Station                 ng_cc           0.8010          0.8010          ng              7.275           0.8010          ng_cc_midAge_med_hiEff
Martin_Lake                                     coal_lig_st     2.3796          2.3796          coal_lig        11.090          0.7932          coal_lig_st_midAge_med_avgEff
Midlothian_Energy_Facility                      ng_cc           1.7340          1.7340          ng              7.460           0.2890          ng_cc_midAge_med_hiEff
Monticello                                      coal_lig_st     1.9800          1.9800          coal_lig        10.916          0.6600          coal_lig_st_old_med_avgEff
Morgan_Creek                                    ng_st           1.2243          1.2243          ng              13.844          0.1530          ng_st_old_med_avgEff
Mountain_Creek                                  ng_st           0.9271          0.9271          ng              12.481          0.2318          ng_st_old_med_avgEff
Newgulf_Cogen                                   ng_gt           0.0787          0.0787          ng              13.784          0.0787          ng_gt_midAge_med_avgEff
North_Lake                                      ng_st           0.7085          0.7085          ng              11.651          0.2362          ng_st_old_med_avgEff
O_W_Sommers                                     ng_st           0.8920          0.8920          ng              12.109          0.4460          ng_st_midAge_med_avgEff
Odessa_Ector_Generating_Station                 ng_cc           1.1352          1.1352          ng              7.604           0.5676          ng_cc_midAge_med_avgEff
Oklaunion                                       coal_sub_st     0.7200          0.7200          coal_sub        10.582          0.7200          coal_sub_st_midAge_med_avgEff
P_H_Robinson                                    ng_st           2.3145          2.3145          ng              13.008          0.5786          ng_st_midAge_med_avgEff
Permian_Basin_GT                                ng_gt           0.4470          0.4470          ng              13.750          0.0894          ng_gt_midAge_med_avgEff
Permian_Basin_ST                                ng_st           0.6504          0.6504          ng              13.750          0.3252          ng_st_old_med_avgEff
Quail_Run_Energy_Center                         ng_cc           0.5730          0.5730          ng              8.540           0.2865          ng_cc_midAge_med_avgEff
R_W_Miller_GT                                   ng_gt           0.2376          0.2376          ng              12.666          0.1188          ng_gt_midAge_med_avgEff
R_W_Miller_ST                                   ng_st           0.3660          0.3660          ng              12.666          0.1220          ng_st_midAge_med_avgEff
Ray_Olinger_GT                                  ng_gt           0.0827          0.0827          ng              12.326          0.0827          ng_gt_midAge_med_avgEff
Ray_Olinger_ST                                  ng_st           0.3450          0.3450          ng              12.326          0.1150          ng_st_midAge_med_avgEff
Rio_Nogales_Power_Project                       ng_cc           0.8982          0.8982          ng              7.298           0.8982          ng_cc_midAge_med_hiEff
Sam_Bertron_ST                                  ng_st           0.8262          0.8262          ng              11.572          0.2066          ng_st_old_med_avgEff
Sam_Rayburn_CCGT                                ng_cc           0.1896          0.1896          ng              9.147           0.1896          ng_cc_midAge_small_avgEff
San_Jacinto_Steam_Electric_Station              ng_gt           0.1764          0.1764          ng              13.516          0.0882          ng_gt_midAge_med_avgEff
San_Miguel                                      coal_lig_st     0.4100          0.4100          coal_lig        12.148          0.4100          coal_lig_st_midAge_small_avgEff
Sand_Hill_CCGT                                  ng_cc           0.3880          0.3880          ng              7.328           0.3880          ng_cc_midAge_med_hiEff
Sand_Hill_ng_GT                                 ng_gt           0.2056          0.2056          ng              7.328           0.0514          ng_gt_midAge_med_hiEff
Sandow_No_4                                     coal_lig_st     0.5906          0.5906          coal_lig        11.163          0.5906          coal_lig_st_midAge_med_avgEff
Silas_Ray_CCGT                                  ng_cc           0.0860          0.0860          ng              11.083          0.0860          ng_cc_old_small_avgEff
Silas_Ray_oil_IC                                ng_gt           0.0610          0.0610          ng              11.083          0.0610          ng_gt_midAge_small_avgEff
Sim_Gideon                                      ng_st           0.6390          0.6390          ng              11.456          0.2130          ng_st_midAge_med_hiEff
South_Texas_Project                             u235_st         2.7086          2.7086          u235            10.400          1.3543          u235_st
Spencer                                         ng_st           0.1265          0.1265          ng              16.622          0.0633          ng_st_midAge_small_avgEff
Stryker_Creek_ng_ST                             ng_st           0.7034          0.7034          ng              11.375          0.3517          ng_st_old_med_hiEff
T_H_Wharton_CCGT                                ng_cc           0.6474          0.6474          ng              9.529           0.3237          ng_cc_old_med_avgEff
T_H_Wharton_GT                                  ng_gt           0.5100          0.5100          ng              9.529           0.0850          ng_gt_old_med_hiEff
Tenaska_Frontier_Generation_Station             ng_cc           0.9397          0.9397          ng              6.901           0.9397          ng_cc_midAge_med_hiEff
Tenaska_Gateway_Generating_Station              ng_cc           0.9396          0.9396          ng              7.475           0.9396          ng_cc_midAge_med_hiEff
Thomas_C_Ferguson                               ng_st           0.4460          0.4460          ng              10.994          0.4460          ng_st_midAge_med_hiEff
Tradinghouse                                    ng_st           1.3797          1.3797          ng              11.838          0.6899          ng_st_midAge_med_avgEff
Trinidad_ng_ST                                  ng_st           0.2393          0.2393          ng              13.508          0.2393          ng_st_midAge_med_avgEff
Twin_Oaks_Power_One                             coal_lig_st     0.3492          0.3492          coal_lig        10.860          0.1746          coal_lig_st_midAge_small_avgEff
V_H_Braunig                                     ng_st           0.8940          0.8940          ng              11.161          0.2980          ng_st_midAge_med_hiEff
Valley                                          ng_st           1.1754          1.1754          ng              13.664          0.3918          ng_st_midAge_med_avgEff
W_A_Parish_Coal                                 coal_sub_st     2.6974          2.6974          coal_sub        10.382          0.6744          coal_sub_st_old_med_avgEff
W_A_Parish_ng_ST                                ng_st           1.2553          1.2553          ng              10.382          0.3138          ng_st_old_med_hiEff
W_B_Tuttle                                      ng_st           0.3803          0.3803          ng              17.474          0.1268          ng_st_old_med_avgEff
Wise_County_Power_LP                            ng_cc           0.7460          0.7460          ng              7.609           0.7460          ng_cc_midAge_med_avgEff
Wolf_Hollow_I_LP                                ng_cc           0.8096          0.8096          ng              7.882           0.8096          ng_cc_midAge_med_avgEff
wind                                            wind            3.7105          3.7105          wind            1.000           0.1             wind
;