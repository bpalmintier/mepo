
$ontext
 -----------------------------------------------------
 Generator data for capacity planning for use with ToyCapPlan model

  Data based on ERCOT system in 2009 with hydro and combined heat and power removed

  When pasting from Excel, convert tabs to spaces using a tabstop of 14

  Sources:
    Costs and Technical Data:
      Northwest Power Study 2010 Appendix I
    
    ERCOT Existing Capacity & Heatrates:
      Thermal Plants:  EGrid 2010 (2007 data) agregated using ERCOT2007 Plant Summary.xlsx
      Wind:            Peak installed capacity from 2009 Timeseries from ERCOT (see 
                        ERCOT_2009_Hourly_Wind&Load_GAMS_formatter.xlsx)

 originally coded in GAMS by Bryan Palmintier 2011-04-20

 Ver   Date       Time   Who           What
 ---  ----------  -----  ------------- ---------------------------------
   1  2011-04-20  13:52  bpalmintier   Adapted from gens_csv.inc v8 and ercot2009_update v1
   2  2011-04-20  16:52  bpalmintier   Increased plant sizes for smaller DP state space without binning
   3  2011-06-15  01:12  bpalmintier   Adapted for caller importing avail files
 4&5  2011-07            bpalmintier   Using NW Power study 2010 cost and tech limits. Nuke startup=0
   6  2011-07-21  01:00  bpalmintier   ERCOT 2007 eGrid Data for existing capacity. Separate HR for old and new
   7  2011-07-24  01:00  bpalmintier   Added max_cap_factor and derate columns
   8  2011-07-24  18:10  bpalmintier   Tweaked installed capacity for even integer existing units
   9  2011-08-02  23:10  bpalmintier   Added proxy water use and limit data
  10  2011-08-04  00:10  bpalmintier   BUGFIX: added comma after max_cap_fact
  11  2011-09-26  01:30  bpalmintier   Removed unused reference to data_dir
  12  2011-10-11  14:15  bpalmintier   Renamed plant_size to gen_size (also related flags)
----------------------------------------------------- 
$offtext

* ---- Define the list of generation technologies
sets
         GEN_PARAMS  generation table parameters
*Note by including this list again here, we can add attributes in this document without breaking
*Old models such as ToyCapPlan
               /
                cap_credit  "Capacity Credit during peak block           [p.u.]"
                c_var_om    "variable O&M cost                           [$/MWh]"
                c_fix_om    "fixed O&M cost                              [$/MW-yr]"
                c_cap       "total capital cost                          [$/MW]"
                life        "economic lifetime for unit                  [yr]"
                heatrate    "heatrate for generator (inverse efficiency) [kBTU/MW]"
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
                derate       "Derating factor for simple (non-reserves) cap planning [p.u.]"
                h2o_withdraw_var "Water withdrawl per MMBTU fuel use           [gal/MMBTU]"
                h2o_withdraw_max "Maximum water withdrawl by generation type [Ggal]"
               /

         G           generation
               /New_Nuclear
                New_Coal
                New_NG_CCGT
                New_NG_CT
                Wind
                Nuclear
                Coal
                NG_CCGT
                NG_ST
                NG_Peak
               /
                             
               
*-- Part 1-4: Generator Table Parameters
* ----- Import parameters from CSV file
* Make GAMS OK with reading CSV (and related) data fields
$ondelim

table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
name,           cap_cur,  cap_max,  c_var_om,  c_fix_om,  c_cap,    life,   fuel,   heatrate,    lead_time,  co2_embed,  co2_ccs,   p_min,  cap_credit,  gen_size,  ramp_max,   unit_min,  c_start_fix,    fuel_start,     max_start,      quick_start,    reg_up, reg_down,  spin_rsv, max_cap_fact,     derate,  h2o_withdraw_var,   h2o_withdraw_max
*               [MW],     [MW],     [$/MWh],   [$/MW-yr], [$/MW],   [yr],   [name], [MMBTU/MWh],  [yr],       [t/GW],     [p.u.],   [p.u.],  [p.u.],      [MW],        [p.u./hr],  [MW],      [$/start],      [MMBTU/start],   [start/yr],     [p.u.],         [p.u.], [p.u.],    [p.u.],   [p.u.]           [p.u.],   [gal/MMBTU],            [Ggal]
New_Nuclear,    0,        Inf,      1,         90000,     5500000,  30,     u235,   10.4,        6,          0,          0,        0.7,     0.96,        1350,        0.1,        945,       100000,         10000,          1,              0,              0,      0,         0,        0.9,               0.9,          100,                 Inf 
New_Coal,       0,        Inf,      2.75,      60000,     2500000,  30,     coal,   9,          4,           0,          0,        0,       0.93,        600,         0.3,        300,       20000,          10000,          50,             0,              0.006,  0.006,     0.05      0.85,              0.85,          75,                 Inf 
New_NG_CCGT,    0,        Inf,      1.7,       14000,     1120000,  30,     ng,     6.93,       2.5,         0,          0,        0,       1,           400,         1,          280,       5000,           1000,           300,            0,              0.02,   0.02,      0.17      0.89,              0.89,          50,                 Inf
New_NG_CT,      0,        Inf,      1,         11000,      610000,   30,     ng,     11.87,      1.25,        0,          0,        0,       0.95,        230,         6,          20,        100,            0,              Inf,            1,              0.12,   0.12,      1         0.91,              0.91,          50,                 Inf
Wind,           8962,     Inf,      2,         40000,     2100000,  20,     wind,   1,          3,           0,          0,        0,       0.05,        50,          1,          0,         0,              0,              Inf,            0,              0,      0,         0         1,                 1,              0,                 Inf
Nuclear,        5138.6,   5138.6,   1,         90000,     0,        30,     u235,   10.4,       6,           0,          0,        0.9,     0.96,        1284.65,     0.1,        1156,       100000,         10000,          1,              0,              0,      0,         0        0.9,               0.9,          100,                 Inf
Coal,           16405.2,  16405.2,  2.75,      60000,     0,        30,     coal,   10.84,      4,           0,          0,        0,       0.93,        607.60,      0.3,        304,       20000,          10000,          50,             0,              0.006,  0.006,     0.05      0.85,              0.85,          75,                 Inf
NG_CCGT,        23690.4,  23690.4,  1.7,       14000,     0,        30,     ng,     7.58,       2.5,         0,          0,        0,       1,           394.84,      1,          276,       5000,           1000,           300,            0,              0.02,   0.02,      0.17      0.89,              0.89,          50,                 Inf
NG_ST,          20372.46, 20372.46, 1.7,       14000,     0,        30,     ng,     12.64,      2.5,         0,          0,        0,       1,           399.46,      1,          280,       5000,           1000,           50,             0,              0.02,   0.02,      0.17      0.85,              0.85,          75,                 Inf
NG_Peak,        4056.48,  4056.48,  1,         11000,     0,        30,     ng,     12.47,      1.25,        0,          0,        0,       0.95,        225.36,      6,          20,        100,            0,              Inf,            1,              0.12,   0.12,      1         0.91,              0.91,          50,                 Inf
;
$offdelim
