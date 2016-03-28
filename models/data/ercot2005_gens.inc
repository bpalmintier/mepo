* -----------------------------------------------------
* Generator data for capacity planning for use with ToyCapPlan model
*
*  ERCOT Generators 2005
*
*  Sources:
*    eGrid2007 (2005 data) for:
*       - plant names
*       - capacity
*       - (nominal) heatrates
*       - fuel types (Note: SUB and LIG both mapped to "coal")
*
*     Notes: 
*       - plants with some less common fuel types are not included. See ERCOT gen list.xlsx
*       - wind farms merged into existing capacity for Wind gen type
*
*   Data for new plants and missing data (var costs, etc.) based on categorical data from:
*
*    DoE Annual Energy Outlook, 2010 Table 8.2 Generator Cost Assumptions
*
*  with some numbers based on:
*    Royal Academy of Engineering. (2004). The cost of generating electricity. 
*    London: Royal Academy of Engineering.
*  specifically:
*   - life estimates (Note: life estimates for all existing plants taken as 20years)
*
*  Technology Mapping:
*                  DOE AEO2010
*    Nuke       Advanced Nuclear
*    Coal       Scrubbed Coal, New
*    CCGT       Adv Gas/Oil Comb Cycle
*    CT         Adv Comb Turbine
*    Wind       Wind
*
* Notes & Assumptions:
*   - Capital Costs are Total Overnight costs (including Contingency & Optimism)
*   - Heatrates are 2009 heatrates
*   - Costs in 2008 $'s
*   - Royal Academy costs (2004 pounds) estimated as 2008 $ by multiplying by 2
*
* originally coded in GAMS by Bryan Palmintier 2010-04-08
*
*Ver   Date       Time  Who            What
*---  ----------  ----- -------------- ---------------------------------
*  1  2010-09-07  21:00  bpalmintier   Adapted from gens8760_csv.inc ver 1
*  2  2011-10-11  14:15  bpalmintier   Renamed plant_size to gen_size (also related flags)
*  3  2012-09-02  17:08  bpalmintier   Replace all $set with $setglobal (to prevent scope errors)
*----------------------------------------------------- 
               
* -- Setup default (empty) path to csv include file. Typically this will be overridden.
$if NOT set data_dir    $setglobal data_dir   

* ---- Define the list of generation technologies
sets
         GEN_PARAMS  generation table parameters
*Note by including this list again here, we can add attributes in this document without breaking
*Old models such as ToyCapPlan
               /cap_credit  "Capacity Credit during peak block           [fraction]"
                c_var_om    "variable O&M cost                           [$/MWh]"
                c_fix_om    "fixed O&M cost                              [$/MW-yr]"
                c_cap       "total capital cost                          [$/MW]"
                life        "economic lifetime for unit                  [yr]"
                heatrate    "heatrate for generator (inverse efficiency) [kBTU/MW]"
                fuel        "name of fuel used                           [name]"
                cap_cur     "Current installed capacity for generation   [MW]"
                cap_max     "Maximum installed capacity for generation   [MW]"
                co2_embed   "CO2_eq emissions from plant construction    [t per MW]"
                co2_ccs     "Fraction of carbon capture & sequestration  [fraction]"
                p_min       "minimum power output (for baseload)         [fraction]"
                lead_time   "Delay from construction to operation        [yr]"
                gen_size  "typical discrete plant size                 [MW]"
               /

         G           generation
               /
                New_Nuke
                New_Coal
                New_CCGT
                New_CT
                Wind
                Oklaunion
                Limestone
                Canyon
                Lewisville
                Eagle_Pass
                J_L_Bates
                Laredo
                La_Palma
                Lake_Hubbard
                Mountain_Creek
                Cedar_Bayou
                Deepwater
                Greens_Bayou
                Hiram_Clarke
                P_H_Robinson
                Sam_Bertron
                T_H_Wharton
                W_A_Parish
                Webster
                Eagle_Mountain
                Graham
                Handley
                Morgan_Creek
                Permian_Basin
                Big_Brown
                Lake_Creek
                Stryker_Creek
                Tradinghouse
                Trinidad
                Valley
                Decker_Creek
                Holly_Street
                Morris_Sheppard
                Silas_Ray
                Bryan
                C_E_Newman
                Ray_Olinger
                Abbott_TP_3
                Dunlap_TP_1
                H_4
                H_5
                Nolte
                TP_4
                Austin
                Buchanan
                Granite_Shoals
                Inks
                Marble_Falls
                Marshall_Ford
                Sim_Gideon
                Leon_Creek
                O_W_Sommers
                V_H_Braunig
                W_B_Tuttle
                North_Texas
                R_W_Miller
                Pearsall
                Sam_Rayburn
                Powerlane_Plant
                Spencer
                Thomas_C_Ferguson
                Barney_M__Davis
                Amistad_Dam___Power
                Gibbons_Creek
                Comanche_Peak
                Martin_Lake
                Monticello
                Coleto_Creek
                Fayette_Power_Project
                J_T_Deely
                San_Miguel
                Dansby
                South_Texas_Project
                Falcon_Dam___Power
                Sam_Rayburn_hydro
                Whitney
                Sandow_No_4
                Twin_Oaks_Power_One
                J_K_Spruce
                Robert_D_Willis
                San_Jacinto_Steam_Electric_Station
                Arthur_Von_Rosenberg
                Sand_Hill
                DeCordova_Steam_Electric_Station
                Chocolate_Bayou_Works
                Seadrift_Coke_LP
                Central_Utility_Plant
                Valero_Refinery_Corpus_Christi_East
                Celanese_Engineering_Resin
                Enterprise_Products_Operating
                Bayou_Cogen_Plant
                Baylor_University_Cogen
                Chocolate_Bayou_Plant
                ExxonMobil_Baytown_Refinery
                Pasadena
                ExxonMobil_Baytown_Turbine
                Clear_Lake_Cogeneration_Ltd
                Victoria_Texas_Plant
                Corpus_Refinery
                Houston_Chemical_Complex_Battleground
                Rice_University
                Paris_Generating_Station
                Hal_C_Weaver_Power_Plant
                Signal_Hill_Wichita_Falls_Power_LP
                Newgulf_Cogen
                Union_Carbide_Seadrift_Cogen
                Texas_City_Plant_Union_Carbide
                Texas_Petrochemicals
                Southwest_Texas_State_University
                Shell_Deer_Park
                Corpus_Christi
                TXU_Sweetwater_Generating_Plant
                Altura_Cogen
                Valero_Refining_Texas_Houston
                Valero_Refining_Texas_City
                Point_Comfort_Operations
                Sandow_Station
                Dow_Chemical_Texas_Operation
                Power_Station_4
                C_R_Wing_Cogen_Plant
                S_L_Cogeneration
                Westhollow_Technology_Center
                Benedum_Plant
                Midkiff_Plant
                University_of_Texas_at_San_Antonio
                University_of_Texas_at_Dallas
                Oyster_Creek_Unit_VIII
                Johnson_County
                Fullerton
                Sweeny_Cogen_Facility
                Yates_Gas_Plant
                Pasadena_Cogeneration
                Jameson_Gas_Processing_Plant
                Bridgeport_Gas_Processing_Plant
                Gregory_Power_Facility
                Midlothian_Energy_Facility
                Lamar_Power_Project
                Frontera_Energy_Center
                Magic_Valley_Generating_Station
                Rio_Nogales_Power_Project
                Wolf_Hollow_I__L_P_
                Hays_Energy_Project
                Guadalupe_Generating_Station
                Lost_Pines_1_Power_Project
                Bastrop_Energy_Center
                Bosque_County_Peaking
                Channelview_Cogeneration_Plant
                Corpus_Christi_Energy_Center
                Odessa_Ector_Generating_Station
                Ennis_Tractebel_Power_LP
                Freestone_Power_Generation_LP
                Jack_Energy_Facility
                Channel_Energy_Center
                BASF_Freeport_Works
                Ingleside_Cogeneration
                Wise_County_Power_LP
                Baytown_Energy_Center
                Brazos_Valley_Generating_Facility
                Exelon_LaPorte_Generating_Station
                Deer_Park_Energy_Center
                Green_Power_2
                Forney_Energy_Center
                Hidalgo_Energy_Center
                EG178_Facility
/
                             
parameter
    pGenAvailData(D, G)   "Complete long-term availability data"
    ;
               
*-- Part 1-3: Generator Table Parameters
* ----- Import parameters from CSV file
* TODO: make generator list automatic
* Make GAMS OK with reading CSV (and related) data formats
$ondelim

* Actually read in the parameter table from CSV
table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
$include %data_dir%ercot2005_gen_data.csv
;

*-- Part 4: Time dependent availability table
* -- Read hourly availability tables for wind
* Make GAMS OK with reading CSV (and related) data formats
table    pGenAvailData(D, G) "Generator availability Table"
$include %data_dir%wind_avail8760.csv
;
* Return to normal GAMS space delimited data formats
$offdelim

* -- Assign fixed availability (traditional generators, when maintenance not included)
* Note: use explicit assignment b/c can't enter a transposed table
pGenAvailData(D,'Oklaunion')=0.85;
pGenAvailData(D,'Limestone')=0.85;
pGenAvailData(D,'Canyon')=0.4331;
pGenAvailData(D,'Lewisville')=0.3423;
pGenAvailData(D,'Eagle_Pass')=0.5243;
pGenAvailData(D,'J_L_Bates')=0.85;
pGenAvailData(D,'Laredo')=0.85;
pGenAvailData(D,'La_Palma')=0.85;
pGenAvailData(D,'Lake_Hubbard')=0.85;
pGenAvailData(D,'Mountain_Creek')=0.85;
pGenAvailData(D,'Cedar_Bayou')=0.85;
pGenAvailData(D,'Deepwater')=0.85;
pGenAvailData(D,'Greens_Bayou')=0.85;
pGenAvailData(D,'Hiram_Clarke')=0.85;
pGenAvailData(D,'P_H_Robinson')=0.85;
pGenAvailData(D,'Sam_Bertron')=0.85;
pGenAvailData(D,'T_H_Wharton')=0.85;
pGenAvailData(D,'W_A_Parish')=0.85;
pGenAvailData(D,'Webster')=0.85;
pGenAvailData(D,'Eagle_Mountain')=0.85;
pGenAvailData(D,'Graham')=0.85;
pGenAvailData(D,'Handley')=0.85;
pGenAvailData(D,'Morgan_Creek')=0.85;
pGenAvailData(D,'Permian_Basin')=0.85;
pGenAvailData(D,'Big_Brown')=0.85;
pGenAvailData(D,'Lake_Creek')=0.85;
pGenAvailData(D,'Stryker_Creek')=0.85;
pGenAvailData(D,'Tradinghouse')=0.85;
pGenAvailData(D,'Trinidad')=0.85;
pGenAvailData(D,'Valley')=0.85;
pGenAvailData(D,'Decker_Creek')=0.85;
pGenAvailData(D,'Holly_Street')=0.85;
pGenAvailData(D,'Morris_Sheppard')=0.1295;
pGenAvailData(D,'Silas_Ray')=0.85;
pGenAvailData(D,'Bryan')=0.85;
pGenAvailData(D,'C_E_Newman')=0.85;
pGenAvailData(D,'Ray_Olinger')=0.85;
pGenAvailData(D,'Abbott_TP_3')=0.5949;
pGenAvailData(D,'Dunlap_TP_1')=0.6782;
pGenAvailData(D,'H_4')=0.5384;
pGenAvailData(D,'H_5')=0.5499;
pGenAvailData(D,'Nolte')=0.5255;
pGenAvailData(D,'TP_4')=0.3435;
pGenAvailData(D,'Austin')=0.3589;
pGenAvailData(D,'Buchanan')=0.1573;
pGenAvailData(D,'Granite_Shoals')=0.1148;
pGenAvailData(D,'Inks')=0.1911;
pGenAvailData(D,'Marble_Falls')=0.1432;
pGenAvailData(D,'Marshall_Ford')=0.244;
pGenAvailData(D,'Sim_Gideon')=0.85;
pGenAvailData(D,'Leon_Creek')=0.85;
pGenAvailData(D,'O_W_Sommers')=0.85;
pGenAvailData(D,'V_H_Braunig')=0.85;
pGenAvailData(D,'W_B_Tuttle')=0.85;
pGenAvailData(D,'North_Texas')=0.85;
pGenAvailData(D,'R_W_Miller')=0.85;
pGenAvailData(D,'Pearsall')=0.85;
pGenAvailData(D,'Sam_Rayburn')=0.85;
pGenAvailData(D,'Powerlane_Plant')=0.85;
pGenAvailData(D,'Spencer')=0.85;
pGenAvailData(D,'Thomas_C_Ferguson')=0.85;
pGenAvailData(D,'Barney_M__Davis')=0.85;
pGenAvailData(D,'Amistad_Dam___Power')=0.1861;
pGenAvailData(D,'Gibbons_Creek')=0.85;
pGenAvailData(D,'Comanche_Peak')=0.9;
pGenAvailData(D,'Martin_Lake')=0.85;
pGenAvailData(D,'Monticello')=0.85;
pGenAvailData(D,'Coleto_Creek')=0.85;
pGenAvailData(D,'Fayette_Power_Project')=0.85;
pGenAvailData(D,'J_T_Deely')=0.85;
pGenAvailData(D,'San_Miguel')=0.85;
pGenAvailData(D,'Dansby')=0.85;
pGenAvailData(D,'South_Texas_Project')=0.9;
pGenAvailData(D,'Falcon_Dam___Power')=0.2036;
pGenAvailData(D,'Sam_Rayburn_hydro')=0.2916;
pGenAvailData(D,'Whitney')=0.2021;
pGenAvailData(D,'Sandow_No_4')=0.85;
pGenAvailData(D,'Twin_Oaks_Power_One')=0.85;
pGenAvailData(D,'J_K_Spruce')=0.85;
pGenAvailData(D,'Robert_D_Willis')=0.2705;
pGenAvailData(D,'San_Jacinto_Steam_Electric_Station')=0.85;
pGenAvailData(D,'Arthur_Von_Rosenberg')=0.85;
pGenAvailData(D,'Sand_Hill')=0.85;
pGenAvailData(D,'DeCordova_Steam_Electric_Station')=0.85;
pGenAvailData(D,'Chocolate_Bayou_Works')=0.85;
pGenAvailData(D,'Seadrift_Coke_LP')=0.85;
pGenAvailData(D,'Central_Utility_Plant')=0.85;
pGenAvailData(D,'Valero_Refinery_Corpus_Christi_East')=0.85;
pGenAvailData(D,'Celanese_Engineering_Resin')=0.85;
pGenAvailData(D,'Enterprise_Products_Operating')=0.85;
pGenAvailData(D,'Bayou_Cogen_Plant')=0.85;
pGenAvailData(D,'Baylor_University_Cogen')=0.85;
pGenAvailData(D,'Chocolate_Bayou_Plant')=0.85;
pGenAvailData(D,'ExxonMobil_Baytown_Refinery')=0.85;
pGenAvailData(D,'Pasadena')=0.85;
pGenAvailData(D,'ExxonMobil_Baytown_Turbine')=0.85;
pGenAvailData(D,'Clear_Lake_Cogeneration_Ltd')=0.85;
pGenAvailData(D,'Victoria_Texas_Plant')=0.85;
pGenAvailData(D,'Corpus_Refinery')=0.85;
pGenAvailData(D,'Houston_Chemical_Complex_Battleground')=0.85;
pGenAvailData(D,'Rice_University')=0.85;
pGenAvailData(D,'Paris_Generating_Station')=0.85;
pGenAvailData(D,'Hal_C_Weaver_Power_Plant')=0.85;
pGenAvailData(D,'Signal_Hill_Wichita_Falls_Power_LP')=0.85;
pGenAvailData(D,'Newgulf_Cogen')=0.85;
pGenAvailData(D,'Union_Carbide_Seadrift_Cogen')=0.85;
pGenAvailData(D,'Texas_City_Plant_Union_Carbide')=0.85;
pGenAvailData(D,'Texas_Petrochemicals')=0.85;
pGenAvailData(D,'Southwest_Texas_State_University')=0.85;
pGenAvailData(D,'Shell_Deer_Park')=0.85;
pGenAvailData(D,'Corpus_Christi')=0.85;
pGenAvailData(D,'TXU_Sweetwater_Generating_Plant')=0.85;
pGenAvailData(D,'Altura_Cogen')=0.85;
pGenAvailData(D,'Valero_Refining_Texas_Houston')=0.85;
pGenAvailData(D,'Valero_Refining_Texas_City')=0.85;
pGenAvailData(D,'Point_Comfort_Operations')=0.85;
pGenAvailData(D,'Sandow_Station')=0.85;
pGenAvailData(D,'Dow_Chemical_Texas_Operation')=0.85;
pGenAvailData(D,'Power_Station_4')=0.85;
pGenAvailData(D,'C_R_Wing_Cogen_Plant')=0.85;
pGenAvailData(D,'S_L_Cogeneration')=0.85;
pGenAvailData(D,'Westhollow_Technology_Center')=0.85;
pGenAvailData(D,'Benedum_Plant')=0.85;
pGenAvailData(D,'Midkiff_Plant')=0.85;
pGenAvailData(D,'University_of_Texas_at_San_Antonio')=0.85;
pGenAvailData(D,'University_of_Texas_at_Dallas')=0.85;
pGenAvailData(D,'Oyster_Creek_Unit_VIII')=0.85;
pGenAvailData(D,'Johnson_County')=0.85;
pGenAvailData(D,'Fullerton')=0.85;
pGenAvailData(D,'Sweeny_Cogen_Facility')=0.85;
pGenAvailData(D,'Yates_Gas_Plant')=0.85;
pGenAvailData(D,'Pasadena_Cogeneration')=0.85;
pGenAvailData(D,'Jameson_Gas_Processing_Plant')=0.85;
pGenAvailData(D,'Bridgeport_Gas_Processing_Plant')=0.85;
pGenAvailData(D,'Gregory_Power_Facility')=0.85;
pGenAvailData(D,'Midlothian_Energy_Facility')=0.85;
pGenAvailData(D,'Lamar_Power_Project')=0.85;
pGenAvailData(D,'Frontera_Energy_Center')=0.85;
pGenAvailData(D,'Magic_Valley_Generating_Station')=0.85;
pGenAvailData(D,'Rio_Nogales_Power_Project')=0.85;
pGenAvailData(D,'Wolf_Hollow_I__L_P_')=0.85;
pGenAvailData(D,'Hays_Energy_Project')=0.85;
pGenAvailData(D,'Guadalupe_Generating_Station')=0.85;
pGenAvailData(D,'Lost_Pines_1_Power_Project')=0.85;
pGenAvailData(D,'Bastrop_Energy_Center')=0.85;
pGenAvailData(D,'Bosque_County_Peaking')=0.85;
pGenAvailData(D,'Channelview_Cogeneration_Plant')=0.85;
pGenAvailData(D,'Corpus_Christi_Energy_Center')=0.85;
pGenAvailData(D,'Odessa_Ector_Generating_Station')=0.85;
pGenAvailData(D,'Ennis_Tractebel_Power_LP')=0.85;
pGenAvailData(D,'Freestone_Power_Generation_LP')=0.85;
pGenAvailData(D,'Jack_Energy_Facility')=0.85;
pGenAvailData(D,'Channel_Energy_Center')=0.85;
pGenAvailData(D,'BASF_Freeport_Works')=0.85;
pGenAvailData(D,'Ingleside_Cogeneration')=0.85;
pGenAvailData(D,'Wise_County_Power_LP')=0.85;
pGenAvailData(D,'Baytown_Energy_Center')=0.85;
pGenAvailData(D,'Brazos_Valley_Generating_Facility')=0.85;
pGenAvailData(D,'Exelon_LaPorte_Generating_Station')=0.85;
pGenAvailData(D,'Deer_Park_Energy_Center')=0.85;
pGenAvailData(D,'Green_Power_2')=0.85;
pGenAvailData(D,'Forney_Energy_Center')=0.85;
pGenAvailData(D,'Hidalgo_Energy_Center')=0.85;
pGenAvailData(D,'EG178_Facility')=0.85;;


