
*Update file to only require reserves as a function of installed wind capacity, rather than based on wind output/forecast

*Reserves for Wind
* Adapted the data from (De Jonghe, et al 2011) Table III based on average capacity factor
* for wind in ERCOT2007: 
*   New_R_Cap (MW_rsrv/MW_install) = Old_R_Cap 
*       + Old_R_Forecast(MW_rsrv/MW_out)*AvgAvail(MW_out/MW_install)
*
*  Up:   New = 0.65 + 0.125*0.263 = 0.097875
*  Down: New = 0.0625 + 0.0875*0.263 = 0.08551

$if declared pWindFlexUpForecast
	pWindFlexUpForecast = 0;
	
$if declared pWindFlexUpCapacity
	pWindFlexUpCapacity = 0.097875;
	
$if declared pWindFlexDownForecast
	pWindFlexDownForecast = 0;
	
$if declared pWindFlexDownCapacity
	pWindFlexDownCapacity = 0.08551;