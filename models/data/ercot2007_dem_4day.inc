
$ontext
-----------------------------------------------------
Sequential Hourly Demand data for FOUR DAYS (96hr) ONLY.
For ERCOT for use with The Advanced Power family of models

  This data was created using: ERCOT_2007_Hourly_Wind&Load_GAMS_formatter.xlsx (SVN v221)
  Actual recorded data from ERCOT POI page: 
    http://planning.ercot.com/data/hourly-windoutput/2007/
  
  Data from the 4days starting: Saturday 2007-Mar-17
  Which contains both the PEAK WIND and the MINIMUM DEMAND (a difficult combination)

  When pasting from Excel, convert tabs to spaces using a tabstop of 8

 originally coded in GAMS by Bryan Palmintier 2010-03-30

History:
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-11-28  22:20  bpalmintier   Adapted from adapted from ercot2007_dem_wk.inc v2
  2  2012-02-07  21:05  bpalmintier   Scaled from MW to GW
  3  2012-06-23  10:45  bpalmintier   Adapted for separate blocks (B) and time sub-periods (T)
-----------------------------------------------------
$offtext

*---- ERCOT2007 demand as sequential hourly -----
* Declare the actual set members (blocks, hours, etc)
set
    DEM_PARAMS  "demand block table parameters from load duration curve"
       /
        avail_idx   "corresponding hour of the year index for avail lookup"
        dur         "duration of block                 [hrs]"
        power       "average power demand during block [GW]"
       /

    B           "Demand blocks (e.g. weeks or ldc)"
        /onlyB/
    T           "Demand time sub-periods (e.g. hours or ldc sub-blocks)"
        /t1800*t1895/

* The actual demand data table:
table    pDemandData(B, T, DEM_PARAMS)   "Demand data"
            avail_idx   dur         power
*             [#]       [hr]        [GW]
onlyB.t1800   1800      1           25.953
onlyB.t1801   1801      1           24.590
onlyB.t1802   1802      1           23.380
onlyB.t1803   1803      1           22.972
onlyB.t1804   1804      1           22.574
onlyB.t1805   1805      1           23.016
onlyB.t1806   1806      1           24.046
onlyB.t1807   1807      1           25.918
onlyB.t1808   1808      1           26.662
onlyB.t1809   1809      1           27.809
onlyB.t1810   1810      1           28.507
onlyB.t1811   1811      1           28.570
onlyB.t1812   1812      1           28.279
onlyB.t1813   1813      1           27.755
onlyB.t1814   1814      1           27.440
onlyB.t1815   1815      1           27.264
onlyB.t1816   1816      1           27.456
onlyB.t1817   1817      1           27.521
onlyB.t1818   1818      1           27.550
onlyB.t1819   1819      1           27.507
onlyB.t1820   1820      1           29.046
onlyB.t1821   1821      1           29.100
onlyB.t1822   1822      1           28.001
onlyB.t1823   1823      1           26.448
onlyB.t1824   1824      1           24.560
onlyB.t1825   1825      1           23.288
onlyB.t1826   1826      1           22.468
onlyB.t1827   1827      1           22.020
onlyB.t1828   1828      1           21.749
onlyB.t1829   1829      1           21.952
onlyB.t1830   1830      1           22.415
onlyB.t1831   1831      1           23.210
onlyB.t1832   1832      1           23.812
onlyB.t1833   1833      1           25.131
onlyB.t1834   1834      1           26.096
onlyB.t1835   1835      1           26.849
onlyB.t1836   1836      1           27.366
onlyB.t1837   1837      1           27.937
onlyB.t1838   1838      1           27.915
onlyB.t1839   1839      1           28.002
onlyB.t1840   1840      1           28.225
onlyB.t1841   1841      1           28.546
onlyB.t1842   1842      1           28.783
onlyB.t1843   1843      1           29.117
onlyB.t1844   1844      1           31.351
onlyB.t1845   1845      1           31.346
onlyB.t1846   1846      1           30.007
onlyB.t1847   1847      1           27.343
onlyB.t1848   1848      1           24.902
onlyB.t1849   1849      1           23.421
onlyB.t1850   1850      1           22.637
onlyB.t1851   1851      1           22.417
onlyB.t1852   1852      1           22.548
onlyB.t1853   1853      1           23.382
onlyB.t1854   1854      1           26.120
onlyB.t1855   1855      1           29.934
onlyB.t1856   1856      1           29.934
onlyB.t1857   1857      1           30.362
onlyB.t1858   1858      1           31.130
onlyB.t1859   1859      1           31.819
onlyB.t1860   1860      1           32.093
onlyB.t1861   1861      1           32.320
onlyB.t1862   1862      1           32.574
onlyB.t1863   1863      1           32.789
onlyB.t1864   1864      1           32.910
onlyB.t1865   1865      1           32.890
onlyB.t1866   1866      1           32.455
onlyB.t1867   1867      1           32.082
onlyB.t1868   1868      1           33.812
onlyB.t1869   1869      1           33.500
onlyB.t1870   1870      1           31.746
onlyB.t1871   1871      1           28.570
onlyB.t1872   1872      1           25.839
onlyB.t1873   1873      1           24.442
onlyB.t1874   1874      1           23.609
onlyB.t1875   1875      1           23.219
onlyB.t1876   1876      1           23.282
onlyB.t1877   1877      1           23.890
onlyB.t1878   1878      1           26.408
onlyB.t1879   1879      1           30.314
onlyB.t1880   1880      1           30.243
onlyB.t1881   1881      1           30.389
onlyB.t1882   1882      1           31.194
onlyB.t1883   1883      1           31.814
onlyB.t1884   1884      1           31.953
onlyB.t1885   1885      1           32.397
onlyB.t1886   1886      1           32.718
onlyB.t1887   1887      1           33.013
onlyB.t1888   1888      1           33.128
onlyB.t1889   1889      1           33.097
onlyB.t1890   1890      1           32.559
onlyB.t1891   1891      1           32.375
onlyB.t1892   1892      1           33.847
onlyB.t1893   1893      1           33.701
onlyB.t1894   1894      1           31.927
onlyB.t1895   1895      1           29.055
;
