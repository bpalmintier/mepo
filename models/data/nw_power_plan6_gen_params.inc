
$ontext
 -----------------------------------------------------
NORTHWEST POWER PLAN #6 (2010) Data
  Representative generator parameter data (no capacity information) for use with the
  advanced power family of models

  Formatted using Generator Data Formatter (SVN v266M)
  When pasting from Excel detab with tab spacing of 16

  Sources:
    Costs and Technical Data:
      Northwest Power Study 2010 Appendix I:
        Northwest Power and Conservation Council, 2010. Sixth Northwest Conservation and 
        Electric Power Plan, Available at: http://www.nwcouncil.org/energy/powerplan/6/.
        
Technology Mapping
                NW Power Plan                                                                   WECC (for startupfuel usage)
Coal_ST         Supercritical pulverized coal                                                                   Coal Large Recent
Coal IGCC       Coal-fired Gasification Combined-cycle                                                                          No IGCC data, assumed equal to Coal Large Recent
NG_CC           Combined Cycle NG                                                                               Combined Cycle old (lower than new?)
NG_GT           Heavy Duty Frame Gas Turbine                                                                    CT old (lower than new?)
NG_GT_AERO      Aeroderivative Gas Turbine                                                                       - 
NG_ST           Average of Coal & NGCT                                                                          Steam
Wind            Wind                                                                            
PV_Util         Utility-scale Photovoltaic (Si-flat plate, single axis track)                                                                   
U235_ST         Gen III+ (Advanced) LWR                                                                          - 
Coal_ST w/ CCS  Super critical pulverized coal with 90% CCS                                                                     No Coal CCS data, assumed equal to Coal Large Recent
NG_CC w/ CCS    Use ratios from coal w/ and w/o CCS applied to CCGT baseline                                                                    No NG with CCS data, assumed equal to Combined Cycle old (as above)
Coal IGCC w/CCS Coal-fired Gasification Combined-cycle with CCS                                                                 No IGCC data, assumed equal to Coal Large Recent
NG_IC           NG Reciprocating Engine Generator Plant (Note: 12 gens per plant)                                                                               

 originally coded in GAMS by Bryan Palmintier 2011-10

 Ver   Date       Time   Who           What
 ---  ----------  -----  ------------- ---------------------------------
   1  2011-10-14  03:15  bpalmintier   Adapted from ieee_rts96_gens.inc v5
   2  2011-11-08  17:40  bpalmintier   Major updates to correct data and add CCS
   3  2011-11-08  21:35  bpalmintier   Define full acronyms in case some types not used
   4  2012-02-03  16:40  bpalmintier   SCALED units (GW, etc) & Added coal_igcc and coal_igcc_ccs
   5  2012-05-04  15:54  bpalmintier   Added maintenance data and PV
   6  2012-08-05  16:42  bpalmintier   Updated Wind cap credit to 10.5%
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
                ng_ic
               /
        ;
        
parameters
    pGenDefaults(GEN_TYPE, GEN_PARAMS)
    ;

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
        ng_ic
        ;

        
* Generator Table Parameters
* ----- Import parameters from CSV file
* Make GAMS OK with reading CSV (and related) data fields
table    pGenDefaults(GEN_TYPE, GEN_PARAMS)   "Generation Defaults Data Table"
                type            c_var_om        c_fix_om        c_cap           life            heatrate        lead_time       co2_embed       co2_ccs         p_min           cap_credit      gen_size        ramp_max        unit_min_pu     fuel_start      c_start_fix     max_start       quick_start     reg_up          reg_down        spin_rsv        max_cap_fact    derate          min_up          min_down        efor            maint_wks       repair_hr
*               [code]          [$/MWh]         [M$/GW-yr]      [M$/GW]         [yr]            [MMBTU/MWh]     [yr]            [Mt/GW]         [p.u.]          [p.u.]          [p.u.]          [GW]            [p.u./hr]       [p.u.]          [BTUe9/start]   [K$/start]      [start/yr]      [p.u.]          [p.u.]          [p.u.]          [p.u.]          [p.u.]          [p.u.]          [hr]            [hr]            [hr]            [wk/yr]         [hr]
coal_lig_st     coal_lig_st     2.75            60              3500            30              9.00            7               0               0               0               0.93            0.450           0.3             0.50            2.60236         3.58095         104             0               0.0025          0.0025          0.050           0.85            0.85            24              12              0.07            5               40
coal_sub_st     coal_sub_st     2.75            60              3500            30              9.00            7               0               0               0               0.93            0.450           0.3             0.50            2.60236         3.58095         104             0               0.0025          0.0025          0.050           0.85            0.85            24              12              0.07            5               40
coal_igcc       coal_igcc       6.3             45              3600            30              8.68            7               0               0               0               0.9             0.623           0.1             0.70            2.60236         3.58095         52              0               0.0008          0.0008          0.017           0.81            0.81            48              24              0.10            4               100
ng_cc           ng_cc           1.7             14              1160            30              6.93            4.5             0               0               0               1               0.385           1               0.30            0.58947         9.25091         365             0               0.0083          0.0083          0.167           0.89            0.89            6               12              0.06            3               32
ng_gt           ng_gt           1               11              610             30              11.96           2.75            0               0               0               0.95            0.081           6               0.25            0.18772         7.81123         Inf             0               0.0500          0.0500          1.000           0.91            0.91            0               0               0.05            2               88
ng_gt_aero      ng_gt_aero      4               13              1050            30              9.3             2.75            0               0               0               0.95            0.090           6               0.25            0               1               Inf             1               0.0500          0.0500          1.000           0.91            0.91            0               0               0.05            2               88
ng_st           ng_st           2.225           37              2330            30              9.00            5.75            0               0               0               0.965           0.310           0.30            0.50            2.60236         3.58095         52              0               0.0025          0.0025          0.050           0.85            0.85            24              12              0.07            5               40
u235_st         u235_st         1               90              5500            30              10.4            10              0               0               0               0.96            1.350           0.1             0.80            0               100             1               0               0.0000          0.0000          0.00            0.9             0.9             48              24              0.04            4               112
wind            wind            2               40              2100            20              1               4.5             0               0               0               0.105            0.050           1               0.00            0               0               Inf             0               0.0000          0.0000          0.00            1               1               0               0               0.00            0               0
pv_util         pv_util         0               36              9000            25              1               3               0               0               0               0.5             0.020           1               0.00            0               0               Inf             0               0.0000          0.0000          0.00            1               1               0               0               0.00            0               0
coal_sub_st_ccs coal_sub_st_ccs 5.86            128             5635            30              11.88           9               0               0.9             0               0.93            0.450           0.3             0.50            2.60236         3.58095         52              0               0.0025          0.0025          0.050           0.85            0.85            24              12              0.07            5               40
ng_cc_ccs       ng_cc_ccs       3.62            29.867          1867.6          30              9.15            5.8             0               0.9             0               1               0.385           1               0.30            0.58947         9.25091         365             0               0.0083          0.0083          0.167           0.89            0.89            6               12              0.06            3               32
coal_igcc_ccs   coal_igcc_ccs   8.50            60              4800            30              10.76           9               0               0.88            0               0.9             0.518           0.1             0.70            2.60236         3.58095         52              0               0.0008          0.0008          0.017           0.81            0.81            48              24              0.10            4               100
ng_ic           ng_ic           10              13              1150            30              8.85            2.75            0               0               0               0.95            0.100           7               0.05            0               0               Inf             1               0.0583          0.0583          1.000           0.93            0.93            0               0               0.05            1               56
;