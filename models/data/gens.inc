* -----------------------------------------------------
* Generator data for capacity planning for use with a family of capacity planning models including:
*  StaticCapPlan, ToyCapPlan, etc.
*
*  Sample generation data
*
*  Sources:
*   Generator Technical and Cost Parameters...
*    DoE Annual Energy Outlook, 2010 Table 8.2 Generator Cost Assumptions
*
*    with life estimates based on:
*      Royal Academy of Engineering. (2004). The cost of generating electricity. 
*      London: Royal Academy of Engineering.
*
*    and ramping limits:
*      Sheer educated conjecture
*
*    Technology Mapping:
*                    DOE AEO2010
*      Nuke       Advanced Nuclear
*      Coal       Scrubbed Coal, New
*      CCGT       Adv Gas/Oil Comb Cycle
*      CT         Adv Comb Turbine
*      Wind       Wind
*
*    Wind Data...
*      Actual ERCOT 2009 Wind production as percent of corresponding installed wind capacity, 
*      with bins correlated to demand load duration curve bins. Values in bin are averages. This
*      data was created using: ERCOT_2009_Hourly_Wind&Load_GAMS_formatter.xlsx ver.6
*
* Notes & Assumptions:
*   - Capital Costs are Total Overnight costs (including Contingency & Optimism)
*   - Heatrates are 2009 heatrates
*   - Costs in 2008 $'s
*   - Need to find real unit commitment numbers, these are wild guesses
*   - Installed capacities are stylized versions of ERCOT
*
* originally coded in GAMS by Bryan Palmintier 2010-04-08
*
*Ver   Date       Time  Who            What
*---  ----------  ----- -------------- ---------------------------------
*  1  2010-04-08        bpalmintier    Original data
*  2  2010-05-20  23:45 bpalmintier    Added Wind & adapted separate avail + capacity credit
*  3  2010-07-31  08:21 bpalmintier    Reverted to actual EIA plant size values
*  4  2010-09-07  20:23 bpalmintier    Separated pGenAvailData for time varying availability
*  5  2010-09-08  23:55  bpalmintier   Added ramp_limits (option) for ramp constrained dispatch
*  6  2010-09-09  01:55  bpalmintier   Added startup costs & minimum output for unit commitment
*  7  2010-11-14  14:00  bpalmintier   Added quick_start, converted "fract" to "p.u" (per unit)
*  8  2010-11-14  15:40  bpalmintier   Added spinning reserves & regulation up/down parameters
*  9  2010-11-14  19:10  bpalmintier   Put spin_rsv into the table, rather than calculated from ramp
* 10  2010-11-16  23:50  bpalmintier   Adjusted Reserve & Ramp numbers based on chats with experts
* 11  2011-07-20  03:00  bpalmintier   Moved availability info to gens_avail.csv
* 12  2011-09-23  16:30  bpalmintier   Introduced stylized ERCOT existing capacities for operations testing
* 13  2011-10-11  14:15  bpalmintier   Renamed plant_size to gen_size (also related flags)
*----------------------------------------------------- 
                                                                                                                             
* ---- Define the list of generation technologies
sets
         GEN_PARAMS  generation table parameters
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
               /

         G           generation
               /Nuke
                Coal
                CCGT
                CT
                Wind
               /
                             
               
* ----- And the parameters for these generators
*-- Part 1: Cost & related data
table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
            c_var_om   c_fix_om      c_cap    life       fuel    heatrate   lead_time 
*            [$/MWh]  [$/MW-yr]     [$/MW]    [yr]     [name]   [MMBTU/MWh]       [yr]
Nuke            0.51      92040    3820000      40       u235      10.488           6
Coal            4.69      28150    2223000      30       coal       9.200           4
CCGT            2.04      11960     968000      30         ng       6.752           3
CT              3.24      10770     648000      20         ng       9.289           2
Wind               0      30980    1966000      20       wind       1               3
;

*-- Part 2: Capacity, Carbon, and contraints
table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
             cap_cur   cap_max  co2_embed   co2_ccs    p_min  cap_credit   gen_size
*               [MW]      [MW]     [t/GW]    [p.u.]   [p.u.]      [p.u.]         [MW]
Nuke            5400       Inf          0         0        0        0.9          1350
Coal           19200       Inf          0         0        0        0.85          600
CCGT           26000       Inf          0         0        0        0.85          400
CT             24610       Inf          0         0        0        0.85          230
Wind            9000       Inf          0         0        0        0.1            50
;

*-- Part 3: Unit Commitment
table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
             ramp_max     unit_min    c_start_fix       fuel_start    max_start
*           [p.u./hr]         [MW]      [$/start]     [MBTU/start]   [start/yr]
Nuke             0.01         1250         810000                0           2
Coal             0.1           300          81000                0          50
CCGT             0.8           150          21000                0         300
CT               6              10              0                0         Inf
Wind             1               0              0                0         Inf
;

*-- Part 4: Reserve Details
table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
           quick_start      reg_up  reg_down    spin_rsv
*               [p.u.]      [p.u.]    [p.u.]      [p.u.]
Nuke                 0        0         0              0
Coal                 0        0.002     0.002      0.017
CCGT                 0        0.025     0.025       0.25
CT                   1        0.05      0.05         0.5
Wind                 0        0         0              0
;

*-- Part 5: Time dependent availability table
* Moved to gen_avail.csv