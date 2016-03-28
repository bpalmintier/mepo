
$ontext
 -----------------------------------------------------
EIA AEO2011 Cost Data With NW Power Plan Technical Data
  Representative generator parameter data (no capacity information) for use with the
  advanced power family of models

  Formatted using Generator Data Formatter (SVN v337)
  When pasting from Excel detab with tab spacing of 16

  Sources:
    Costs:
      EIA Annual Energy Outlook 2011 Generator Assumtions (also used by NEMS):
        US Energy Information Administration [EIA], 2010. Updated Capital Cost Estimates for 
        Electricity Generation Plants (AEO 2011), Washington, DC: US Department of Energy. 
        Available at: http://www.eia.gov/oiaf/beck_plantcosts/.
    Technical Data:
      Northwest Power Study 2010 Appendix I:
        Northwest Power and Conservation Council, 2010. Sixth Northwest Conservation and 
        Electric Power Plan, Available at: http://www.nwcouncil.org/energy/powerplan/6/.

Generator Mapping                                                                                               
                EAI AEO2011 (NEMS) Name                         NW Power Plan (for non-cost data)                               Note
Coal_ST         Dual Unit Advanced PC                           Supercritical pulverized coal                                   Used only 1/2 capacity b/c we want unit level data
Coal IGCC       Dual Unit Coal IGCC                             Coal-fired Gasification Combined-cycle                          Used only 1/2 capacity b/c we want unit level data
NG_CC           Advanced NGCC                                   Combined Cycle NG                                               
NG_GT           Advanced CT (F-class)                           Heavy Duty Frame Gas Turbine                                    
NG_GT_AERO      Advanced CT (F-class)                           Aeroderivative Gas Turbine                                      
NG_ST           Average of Coal & NGCT                          Average of Coal & NGCT                                          
U235_ST         Dual Unit Nuclear                               Gen III+ (Advanced) LWR                                         Used only 1/2 capacity b/c we want unit level data
Wind            On-shore Wind                                                                   
PV_Util         Photovoltaic (150MW plant)                      Utility-scale Photovoltaic (Si-flat plate, single axis track)                                   
Coal_ST w/ CCS  Dual Unit Advanced PC with CCS                  Super critical pulverized coal with 90% CCS                                     
NG_CC w/ CCS    Advanced NGCC with CCS                          Use ratios from coal w/ and w/o CCS applied to CCGT baseline                                    
Coal IGCC w/CCS Single Unit Coal IGCC                           Coal-fired Gasification Combined-cycle with CCS                 No double unit data
Wind_off        Off-shore Wind                                  N/A                                             
PV_Dist         Photovoltaic (7MW plant)                        N/A                                             

 originally coded in GAMS by Bryan Palmintier 2011-10

 Ver   Date       Time   Who           What
 ---  ----------  -----  ------------- ---------------------------------
   1  2011-11-09  00:15  bpalmintier   Adapted from nw_power_plan6_gen_params v3
   2  2012-01-04  15:45  bpalmintier   Corrected cost data for wind & coal
   3  2012-01-30  05:04  bpalmintier   Scale units for GW demand
   4  2012-02-03  13:54  bpalmintier   Additional scaling & comment updates
   5  2012-02-03  16:34  bpalmintier   Added coal_igcc and coal_igcc_ccs
   6  2012-05-04  15:24  bpalmintier   Added maintenance data and PV
   7  2012-08-05  16:42  bpalmintier   Updated Wind cap credit to 10.5%
----------------------------------------------------- 
$offtext

* ---- Define the list of generation technologies
sets
         GEN_PARAMS  "generation table parameters"
*Note by including this list again here, we can add attributes in this document without breaking
*Old models such as ToyCapPlan
               /
                type        "Generator Prime Mover & Fuel code"
                unit_min_pu  "Minimum power output in per unit           [p.u.]"
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
                min_up      "Minimum up (operating) time                [hr]"
                min_down    "Minimum down (off) time                    [hr]"
                derate      "Derating factor for simple (non-reserves) cap planning [p.u.]"
                efor        "Effective Forced Outage rate (unplan down hr/avail hr) [p.u.]"
                maint_wks   "Annual weeks of maintenance                    [wk/yr]"
                repair_hr   "Mean time for repairs                          [hr]"
               /

         GEN_TYPE           "generation type"
               /
                coal_lig_st
                coal_sub_st
                coal_igcc
                ng_cc
                ng_gt
                ng_gt_aero
                ng_st
                u235_st
                wind
                pv_util
                coal_sub_st_ccs
                ng_cc_ccs
                coal_igcc_ccs
                wind_off
                pv_dist
               /
        ;
        
parameters
    pGenDefaults(GEN_TYPE, GEN_PARAMS)
    ;

* Have to list types as acronyms so we can use them in the table
acronyms    
        coal_lig_st
        coal_sub_st
        coal_igcc
        ng_cc
        ng_gt
        ng_gt_aero
        ng_st
        u235_st
        wind
        pv_util
        coal_sub_st_ccs
        ng_cc_ccs
        coal_igcc_ccs
        wind_off
        pv_dist
        ;

        
* Generator Table Parameters
* ----- Import parameters from CSV file
* Make GAMS OK with reading CSV (and related) data fields
table    pGenDefaults(GEN_TYPE, GEN_PARAMS)   "Generation Defaults Data Table"
                type            c_var_om        c_fix_om        c_cap           life            heatrate        lead_time       co2_embed       co2_ccs         p_min           cap_credit      gen_size        ramp_max        unit_min_pu     fuel_start      c_start_fix     max_start       quick_start     reg_up          reg_down        spin_rsv        max_cap_fact    derate          min_up          min_down        efor            maint_wks       repair_hr
*               [code]          [$/MWh]         [M$/GW-yr]      [M$/GW]         [yr]            [MMBTU/MWh]     [yr]            [Mt/GW]         [p.u.]          [p.u.]          [p.u.]          [GW]            [p.u./hr]       [p.u.]          [BTUe9/start]   [K$/start]      [start/yr]      [p.u.]          [p.u.]          [p.u.]          [p.u.]          [p.u.]          [p.u.]          [hr]            [hr]            [hr]            [wk/yr]         [hr]
coal_lig_st     coal_lig_st     4.25            29.67           2844            30              8.80            7               0               0               0               0.93            0.650           0.3             0.5             2.60236         3.58095         104             0               0.003           0.003           0.05            0.85            0.85            24              12              0.07            5               40
coal_sub_st     coal_sub_st     4.25            29.67           2844            30              8.80            7               0               0               0               0.93            0.650           0.3             0.5             2.60236         3.58095         104             0               0.003           0.003           0.05            0.85            0.85            24              12              0.07            5               40
coal_igcc       coal_igcc       6.87            48.9            3221            30              8.80            7               0               0               0               0.9             0.650           0.1             0.7             2.60236         3.58095         52              0               0.001           0.001           0.02            0.81            0.81            48              24              0.1             4               100
ng_cc           ng_cc           3.11            14.62           1003            30              6.43            4.5             0               0               0               1               0.400           1               0.3             0.58947         9.25091         365             0               0.008           0.008           0.17            0.89            0.89            6               12              0.06            3               32
ng_gt           ng_gt           9.87            6.7             665             30              9.75            2.75            0               0               0               0.95            0.210           6               0.25            0.18772         7.81123         Inf             0               0.050           0.050           1.00            0.91            0.91            0               0               0.05            2               88
ng_gt_aero      ng_gt_aero      9.87            6.7             665             30              9.75            2.75            0               0               0               0.95            0.210           6               0.25            0               1               Inf             1               0.050           0.050           1.00            0.91            0.91            0               0               0.05            2               88
ng_st           ng_st           3.68            22.145          1923.5          30              8.80            5.75            0               0               0               0.965           0.310           0.3             0.5             2.60236         3.58095         52              0               0.003           0.003           0.05            0.85            0.85            24              12              0.07            5               40
u235_st         u235_st         2.04            88.75           5335            30              10.4            10              0               0               0               0.96            1.118           0.1             0.8             0               100             1               0               0.000           0.000           0.00            0.9             0.9             48              24              0.042           4               112
wind            wind            0               28.07           2438            20              1               4.5             0               0               0               0.105            0.100           1               0               0               0               Inf             0               0.000           0.000           0.00            1               1               0               0               0               0               0
pv_util         pv_util         0               16.7            4755            25              1               3               0               0               0               0.5             0.150           1               0               0               0               Inf             0               0.000           0.000           0.00            1               1               0               0               0               0               0
coal_sub_st_ccs coal_sub_st_ccs 9.05            63.21           4579            30              12.00           9               0               0.9             0               0.93            0.650           0.3             0.5             2.60236         3.58095         52              0               0.003           0.003           0.05            0.85            0.85            24              12              0.07            5               40
ng_cc_ccs       ng_cc_ccs       6.45            30.25           2060            30              7.525           5.79            0               0.9             0               1               0.385           1               0.3             0.58947         9.25091         365             0               0.008           0.008           0.17            0.89            0.89            6               12              0.06            3               32
coal_igcc_ccs   coal_igcc_ccs   8.04            69.3            5348            30              10.70           9               0               0.88            0               0.9             0.520           0.1             0.7             2.60236         3.58095         52              0               0.001           0.001           0.02            0.81            0.81            48              24              0.1             4               100
wind_off        wind_off        0               53.33           5975            20              1               6               0               0               0               0.05            0.400           1               0               0               0               Inf             0               0               0               0               1               1               0               0               0               0               0
pv_dist         pv_dist         0               26.04           6050            25              1               3               0               0               0               0.5             0.007           1               0               0               0               Inf             0               0               0               0               1               1               0               0               0               0               0
;