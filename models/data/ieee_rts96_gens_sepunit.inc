
$ontext
 -----------------------------------------------------
 Generator data for capacity planning for use with ToyCapPlan model

  IEEE Reliability Test System (1996) Data

  When pasting from Excel, convert tabs to spaces using a tabstop of 8

  Sources:
[1] Reliability Test System Task Force, "IEEE Reliability Test System," IEEE Transactions on 
Power Apparatus and Systems, vol. 98, pp. 2047-2054, Nov. 1979.

[2] C. Grigg et al., "The IEEE Reliability Test System-1996. A report prepared by the
Reliability Test System Task Force of the Application of Probability
Methods Subcommittee," IEEE Transactions on Power Systems, vol. 14, no. 3, pp. 1010-1020, Aug. 1999.

 originally coded in GAMS by Bryan Palmintier 2011-09-26

 Ver   Date       Time   Who           What
 ---  ----------  -----  ------------- ---------------------------------
   1  2011-09-26  02:35  bpalmintier   Adapted from ieee_rts96_gens.inc v1
   2  2011-09-27  22:22  bpalmintier   Added piecewise linear fuel use table
   3  2011-09-29  04:22  bpalmintier   Added min up and down times
   4  2011-10-06  20:30  bpalmintier   BUGFIX: corrected heat rates (/1000)
   5  2011-10-09  15:20  bpalmintier   Added generation type to pGenData
   6  2011-10-11  14:15  bpalmintier   Renamed plant_size to gen_size (also related flags)
   7  2011-10-17  15:20  bpalmintier   Added control flag gen_type_data_defined
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
                c_fix_om    "fixed O&M cost                              [$/MW-yr]"
                c_cap       "total capital cost                          [$/MW]"
                life        "economic lifetime for unit                  [yr]"
                heatrate    "heatrate for generator (inverse efficiency) [kBTU/MW]"
                p0_fuel     "fuel use at zero power out (heatrate intercept) [MMBTU]"
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
                min_up       "Minimum up (operating) time                [hr]"
                min_down     "Minimum down (off) time                    [hr]"
               /

         G           "generation"
               /Oil_St_12MW_1*Oil_St_12MW_5
                Oil_CT_20MW_1*Oil_CT_20MW_4
* Not Included: Hydro_50MW
                Coal_St_76MW_1*Coal_St_76MW_4
                Oil_St_100MW_1*Oil_St_100MW_3
                Coal_St_155MW_1*Coal_St_155MW_4
                Oil_St_197MW_1*Oil_St_197MW_3
                Coal_St_350MW_1*Coal_St_350MW_1
                Nuke_400MW_1*Nuke_400MW_2
               /
        HR_SEG       "piece-wise linear fuel use segments (slope=heatrate)"
*Adjust range for the maximum number of segments used in the approximation
                /seg1*seg3/ 

        PWL_COEF    "Coefficients for piecewise linear representation"
                /
                 slope
                 intercept
                /
;                

*Establish the generator type names so that we can use them in the data table
acronyms    oil_st_12,
            oil_ct_20,
            coal_st_76,
            oil_st_100,
            coal_st_155,
            oil_st_197,
            coal_st_350,
            nuke_400
            ;

*-- Generator Table Parameters
table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
                                     type        cap_cur       cap_max       c_fix_om      c_var_om      life          fuel          heatrate      p0_fuel       p_min         cap_credit    gen_size    unit_min      ramp_max      c_start_fix   fuel_start    max_start     quick_start   reg_up        reg_down      spin_rsv      max_cap_fact  min_up  min_down
*                                   [code]       [MW]          [MW]          [$/MW-yr]     [$/MWh]       [yr]          [name]        [MMBTU/MWh]   [MMBTU]       [p.u.]        [p.u.]        [MW]          [MW]          [p.u./hr]     [$/start]     [MBTU/start]  [start/yr]    [p.u.]        [p.u.]        [p.u.]        [p.u.]        [p.u.]          [hr]    [hr]
Oil_St_12MW_1*Oil_St_12MW_5       oil_st_12      12            12            10000         0.9           30            oil_6         10.948         10.812         0             1             12            2.40          5.00          0             68            364           0           0.083333333   0.083333333   0.833333333     1              2       4
Oil_CT_20MW_1*Oil_CT_20MW_4       oil_ct_20      20            20            300           5             30            oil_2         12.385         42.075         0             1             20            15.80         9.00          0             5             Inf           0           0.15          0.15          1.5             1              1       1
* Not Included: Hydro_50MW                                                                                                                                                                                                                                                                                        
Coal_St_76MW_1*Coal_St_76MW_4     coal_st_76     76            76            10000         0.9           30            coal          10.672         87.001         0             1             76            15.20         1.58          0             596           364           0           0.026315789   0.026315789   0.263157895     1              4       8
Oil_St_100MW_1*Oil_St_100MW_3     oil_st_100    100           100            8500          0.8           30            oil_6          8.999         93.075         0             1             100           25.00         4.20          0             566           364           0           0.07          0.07          0.7             1              8       8
Coal_St_155MW_1*Coal_St_155MW_4   coal_st_155   155           155            7000          0.8           30            coal           8.706        131.783         0             1             155           54.25         1.16          0             953           364           0           0.019354839   0.019354839   0.193548387     1              8       8
Oil_St_197MW_1*Oil_St_197MW_3     oil_st_197    197           197            5000          0.7           30            oil_6          8.975        113.643         0             1             197           68.95         0.91          0             775           364           0           0.015228426   0.015228426   0.152284264     1             10      12  
Coal_St_350MW_1*Coal_St_350MW_1   coal_st_350   350           350            4500          0.7           30            coal           9.023        149.189         0             1             350           140.00        0.69          0             4468          52            0           0.011428571   0.011428571   0.114285714     1             48      24  
Nuke_400MW_1*Nuke_400MW_2         nuke_400      400           400            5000          0.3           30            u235           9.079        358.535         0             1             400           100.00        3.00          0             0             1             0           0             0             0               1              1       1
;

*Use type information for extended type
pGenData(G, 'extended_type') = pGenData(G, 'type');



* Piece-wise linear fuel use table (slope=heatrate)
table  pGenHrSegments(G, HR_SEG, PWL_COEF)
                                seg1.slope  seg1.intercept   seg2.slope  seg2.intercept  seg3.slope  seg3.intercept  
*                              [MMBTU/MWh]      [MMBTU]     [MMBTU/MWh]      [MMBTU]    [MMBTU/MWh]      [MMBTU]
Oil_St_12MW_1*Oil_St_12MW_5        10.155        14.068          10.900         9.600        12.400        -4.800
Oil_CT_20MW_1*Oil_CT_20MW_4        10.023        79.632          12.395        41.684        14.400         1.980
Coal_St_76MW_1*Coal_St_76MW_4       9.657       113.240          10.672        74.683        12.400       -30.400
Oil_St_100MW_1*Oil_St_100MW_3       8.401       114.950           9.065        81.733         9.652        34.800
Coal_St_155MW_1*Coal_St_155MW_4     8.386       155.068           8.713       124.620         9.128        73.160
Oil_St_197MW_1*Oil_St_197MW_3       8.590       148.932           9.026        97.397         9.424        34.672
Coal_St_350MW_1*Coal_St_350MW_1     8.640       218.400           9.067       121.333         9.500         0
Nuke_400MW_1*Nuke_400MW_2           8.899       385.200           9.078       349.333         9.320       272.000
;     
