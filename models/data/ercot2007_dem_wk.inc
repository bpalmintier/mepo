
$ontext
-----------------------------------------------------
Sequential Hourly Demand data for ONE WEEK ONLY.
For ERCOT for use with The Advanced Power family of models

  This data was created using: ERCOT_2007_Hourly_Wind&Load_GAMS_formatter.xlsx (SVN v379M)
  Actual recorded data from ERCOT POI page: 
    http://planning.ercot.com/data/hourly-windoutput/2007/
  
  Data from the week starting: Saturday 2007-Mar-17 (5/17/2007)
  Which contains both the PEAK WIND and the MINIMUM DEMAND (a difficult combination)

  When pasting from Excel, convert tabs to spaces using a tabstop of 12

 originally coded in GAMS by Bryan Palmintier 2010-03-30

History:
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-10-14  01:15  bpalmintier   Adapted from ieee_rts96_dem_wk v1
  2  2011-10-14  11:45  bpalmintier   Updated to use hour of year block names for availability subset matching
  3  2012-02-07  21:05  bpalmintier   Scaled from MW to GW
  4  2012-05-04  11:55  bpalmintier   Adapted for separate blocks (B) and time sub-periods (T)
-----------------------------------------------------
$offtext

* Declare the actual set members (blocks, hours, etc) and add hr_of_yr cross reference
sets
    DEM_PARAMS  "demand block table parameters from load duration curve"
       /
        avail_idx   "corresponding hour of the year index for avail lookup"
        dur         "duration of block                 [hrs]"
        power       "average power demand during block [GW]"
       /

    B           "Demand blocks (e.g. weeks or ldc)"
        /wk/
    T           "Demand time sub-periods (e.g. hours or ldc sub-blocks)"
        /t001*t168/
;

* The actual demand data table:
table    pDemandData(B, T, DEM_PARAMS)   "Demand data"
            avail_idx   dur         power
*           [#]         [hr]        [GW]
wk.t001     1800        1           25.953
wk.t002     1801        1           24.590
wk.t003     1802        1           23.380
wk.t004     1803        1           22.972
wk.t005     1804        1           22.574
wk.t006     1805        1           23.016
wk.t007     1806        1           24.046
wk.t008     1807        1           25.918
wk.t009     1808        1           26.662
wk.t010     1809        1           27.809
wk.t011     1810        1           28.507
wk.t012     1811        1           28.570
wk.t013     1812        1           28.279
wk.t014     1813        1           27.755
wk.t015     1814        1           27.440
wk.t016     1815        1           27.264
wk.t017     1816        1           27.456
wk.t018     1817        1           27.521
wk.t019     1818        1           27.550
wk.t020     1819        1           27.507
wk.t021     1820        1           29.046
wk.t022     1821        1           29.100
wk.t023     1822        1           28.001
wk.t024     1823        1           26.448
wk.t025     1824        1           24.560
wk.t026     1825        1           23.288
wk.t027     1826        1           22.468
wk.t028     1827        1           22.020
wk.t029     1828        1           21.749
wk.t030     1829        1           21.952
wk.t031     1830        1           22.415
wk.t032     1831        1           23.210
wk.t033     1832        1           23.812
wk.t034     1833        1           25.131
wk.t035     1834        1           26.096
wk.t036     1835        1           26.849
wk.t037     1836        1           27.366
wk.t038     1837        1           27.937
wk.t039     1838        1           27.915
wk.t040     1839        1           28.002
wk.t041     1840        1           28.225
wk.t042     1841        1           28.546
wk.t043     1842        1           28.783
wk.t044     1843        1           29.117
wk.t045     1844        1           31.351
wk.t046     1845        1           31.346
wk.t047     1846        1           30.007
wk.t048     1847        1           27.343
wk.t049     1848        1           24.902
wk.t050     1849        1           23.421
wk.t051     1850        1           22.637
wk.t052     1851        1           22.417
wk.t053     1852        1           22.548
wk.t054     1853        1           23.382
wk.t055     1854        1           26.120
wk.t056     1855        1           29.934
wk.t057     1856        1           29.934
wk.t058     1857        1           30.362
wk.t059     1858        1           31.130
wk.t060     1859        1           31.819
wk.t061     1860        1           32.093
wk.t062     1861        1           32.320
wk.t063     1862        1           32.574
wk.t064     1863        1           32.789
wk.t065     1864        1           32.910
wk.t066     1865        1           32.890
wk.t067     1866        1           32.455
wk.t068     1867        1           32.082
wk.t069     1868        1           33.812
wk.t070     1869        1           33.500
wk.t071     1870        1           31.746
wk.t072     1871        1           28.570
wk.t073     1872        1           25.839
wk.t074     1873        1           24.442
wk.t075     1874        1           23.609
wk.t076     1875        1           23.219
wk.t077     1876        1           23.282
wk.t078     1877        1           23.890
wk.t079     1878        1           26.408
wk.t080     1879        1           30.314
wk.t081     1880        1           30.243
wk.t082     1881        1           30.389
wk.t083     1882        1           31.194
wk.t084     1883        1           31.814
wk.t085     1884        1           31.953
wk.t086     1885        1           32.397
wk.t087     1886        1           32.718
wk.t088     1887        1           33.013
wk.t089     1888        1           33.128
wk.t090     1889        1           33.097
wk.t091     1890        1           32.559
wk.t092     1891        1           32.375
wk.t093     1892        1           33.847
wk.t094     1893        1           33.701
wk.t095     1894        1           31.927
wk.t096     1895        1           29.055
wk.t097     1896        1           26.376
wk.t098     1897        1           24.781
wk.t099     1898        1           23.998
wk.t100     1899        1           23.486
wk.t101     1900        1           23.321
wk.t102     1901        1           24.010
wk.t103     1902        1           26.893
wk.t104     1903        1           30.668
wk.t105     1904        1           30.575
wk.t106     1905        1           30.786
wk.t107     1906        1           31.580
wk.t108     1907        1           32.240
wk.t109     1908        1           32.622
wk.t110     1909        1           33.115
wk.t111     1910        1           33.574
wk.t112     1911        1           34.107
wk.t113     1912        1           34.399
wk.t114     1913        1           34.391
wk.t115     1914        1           33.900
wk.t116     1915        1           33.239
wk.t117     1916        1           34.733
wk.t118     1917        1           34.635
wk.t119     1918        1           32.581
wk.t120     1919        1           29.500
wk.t121     1920        1           26.770
wk.t122     1921        1           24.937
wk.t123     1922        1           23.954
wk.t124     1923        1           23.521
wk.t125     1924        1           23.302
wk.t126     1925        1           24.013
wk.t127     1926        1           26.640
wk.t128     1927        1           30.685
wk.t129     1928        1           30.393
wk.t130     1929        1           30.860
wk.t131     1930        1           31.455
wk.t132     1931        1           32.150
wk.t133     1932        1           32.414
wk.t134     1933        1           32.805
wk.t135     1934        1           33.073
wk.t136     1935        1           33.184
wk.t137     1936        1           33.158
wk.t138     1937        1           32.915
wk.t139     1938        1           32.658
wk.t140     1939        1           32.136
wk.t141     1940        1           33.880
wk.t142     1941        1           33.651
wk.t143     1942        1           32.035
wk.t144     1943        1           29.223
wk.t145     1944        1           26.793
wk.t146     1945        1           24.973
wk.t147     1946        1           24.198
wk.t148     1947        1           23.588
wk.t149     1948        1           23.506
wk.t150     1949        1           24.251
wk.t151     1950        1           26.662
wk.t152     1951        1           30.804
wk.t153     1952        1           30.981
wk.t154     1953        1           31.202
wk.t155     1954        1           31.979
wk.t156     1955        1           32.654
wk.t157     1956        1           32.960
wk.t158     1957        1           33.300
wk.t159     1958        1           33.487
wk.t160     1959        1           33.220
wk.t161     1960        1           33.458
wk.t162     1961        1           33.259
wk.t163     1962        1           32.904
wk.t164     1963        1           32.008
wk.t165     1964        1           32.990
wk.t166     1965        1           32.685
wk.t167     1966        1           31.268
wk.t168     1967        1           29.229
;
