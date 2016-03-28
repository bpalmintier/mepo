*Start Block Quote
$ontext
-------------------------------------------------
Parameter updates for ERCOT 2009 Using Separate Units

Note # of units per technology based on upper limit defaults from StaticCapPlan (very conservative)
We are nice and limit wind investments to a more reasonable level

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   September 2010

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-07-24  03:30  bpalmintier   Adapted from:
                                         - ercot2009_gens.inc v7
                                         - gens_sepunit_ercot2009_week.inc v2
  2  2011-07-26  02:30  bpalmintier   Expanded range of new generator options to meet 1.5 demand scaling
  3  2011-07-26  09:50  bpalmintier   Reduced range of new gens for only 1.2x demand scale
  4  2011-10-11  14:15  bpalmintier   Renamed plant_size to gen_size (also related flags)
-------------------------------------------------
$offtext

* ---- Define the list of generation technologies
sets
    GEN_PARAMS  "generation table parameters"
*Note by including this list again here, we can add attributes in this document without breaking
*Old models such as ToyCapPlan
        /cap_credit  "Capacity Credit during peak block           [p.u.]"
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
        fuel_start  "Fuel usage to start up a unit               [MBTU/start/unit]"
        quick_start "Fraction of capacity avail for non-spin reserves [p.u.]" 
        reg_up      "Fraction of capacity avail for regulation up reserves [p.u.]" 
        reg_down    "Fraction of capacity avail for regulation down reserves [p.u.]" 
        spin_rsv    "Fraction of capacity avail for spinning reserves [p.u.]" 
        max_start   "Maximum number of startups per plant per year [starts/yr]"
        max_cap_fact "Maximum capacity factor, use for maintanence [p.u.]"
        derate       "Derating factor for simple (non-reserves) cap planning [p.u.]"
        /

    G           "generation"
        /
        Wind
        New_Nuclear1*New_Nuclear11
        New_Coal1*New_Coal25
        New_NG_CCGT1*New_NG_CCGT36
        New_NG_CT1*New_NG_CT61
        Nuclear1*Nuclear4
        Coal1*Coal27
        NG_CCGT1*NG_CCGT60
        NG_ST1*NG_ST51
        NG_Peak1*NG_Peak18
        /
                             
               
*-- Part 1-4: Generator Table Parameters
* ----- Import parameters from CSV file
* Make GAMS OK with reading CSV (and related) data fields
$ondelim

table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
name,                          cap_cur,  cap_max,  c_var_om,  c_fix_om,  c_cap,    life,   fuel,   heatrate,    lead_time,  co2_embed,  co2_ccs,   p_min,  cap_credit,  gen_size,  ramp_max,   unit_min,  c_start_fix,    fuel_start,     max_start,      quick_start,    reg_up, reg_down,  spin_rsv, max_cap_fact,     derate
*                              [MW],     [MW],     [$/MWh],   [$/MW-yr], [$/MW],   [yr],   [name], [MBTU/MWh],  [yr],       [t/GW],     [p.u.],   [p.u.],  [p.u.],      [MW],        [p.u./hr],  [MW],      [$/start],      [MBTU/start],   [start/yr],     [p.u.],         [p.u.], [p.u.],    [p.u.],   [p.u.]            [p.u.]
New_Nuclear1*New_Nuclear11,    0,        1350,      1,         90000,     5500000,  30,     u235,   10.4,        6,          0,          0,        0,       0.96,        1350,        0.1,        945,       100000,         10000,          1,              0,              0,      0,         0,        0.9               0.9
New_Coal1*New_Coal25,          0,        600,       2.75,      60000,     2500000,  30,     coal,   9,          4,           0,          0,        0,       0.93,        600,         0.3,        300,       20000,          10000,          50,             0,              0.006,  0.006,     0.05      0.85              0.85
New_NG_CCGT1*New_NG_CCGT36,    0,        400,       1.7,       14000,     1120000,  30,     ng,     6.93,       2.5,         0,          0,        0,       1,           400,         1,          280,       5000,           1000,           300,            0,              0.02,   0.02,      0.17      0.89              0.89
New_NG_CT1*New_NG_CT61,       0,        230,       1,         11000,     610000,   30,     ng,     11.87,      1.25,        0,          0,        0,       0.95,        230,         6,          20,        100,            0,              Inf,            1,              0.12,   0.12,      1         0.91              0.91
Wind,                          8962,     Inf,      2,         40000,     2100000,  20,     wind,   1,          3,           0,          0,        0,       0.05,        50,          1,          0,         0,              0,              Inf,            0,              0,      0,         0         1                 1
Nuclear1*Nuclear4,             1284.65,  1284.65,   1,         90000,     0,        30,     u235,   10.4,       6,           0,          0,        0,       0.96,        1284.65,     0.1,        1156,       100000,         10000,          1,              0,              0,      0,         0        0.9               0.9
Coal1*Coal27,                  607.60,   607.60,    2.75,      60000,     0,        30,     coal,   10.84,      4,           0,          0,        0,       0.93,        607.60,      0.3,        304,       20000,          10000,          50,             0,              0.006,  0.006,     0.05      0.85              0.85
NG_CCGT1*NG_CCGT60,            394.84,   394.84,    1.7,       14000,     0,        30,     ng,     7.58,       2.5,         0,          0,        0,       1,           394.84,      1,          276,       5000,           1000,           300,            0,              0.02,   0.02,      0.17      0.89              0.89
NG_ST1*NG_ST51,                399.46,   399.46,    1.7,       14000,     0,        30,     ng,     12.64,      2.5,         0,          0,        0,       1,           399.46,      1,          280,       5000,           1000,           50,             0,              0.02,   0.02,      0.17      0.85              0.85
NG_Peak1*NG_Peak18,            225.36,   225.36,    1,         11000,     0,        30,     ng,     12.47,      1.25,        0,          0,        0,       0.95,        225.36,      6,          20,        100,            0,              Inf,            1,              0.12,   0.12,      1         0.91              0.91
;
$offdelim
