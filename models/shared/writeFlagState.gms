
$ontext
----------------------------------------------------
  Helper script to put state of set/unset identifiers
  
Usage:

$batinclude %shared_dir%writeFlagState  FLAG_NAME  
  This form, assumes a binary on or off flag based on the flag's "set" status. ie if set = 1
  if unset = 0. As a result (for a "set" or on variable) a line of the form
    flag_FLAG_NAME, 1
  is written to the current put file
  
$batinclude %shared_dir%writeFlagState  FLAG_NAME "value" VALUE
  This form, the flag is treated as taking a real value if set. In which case a line of the form 
    valflag_FLAG_NAME, VALUE
  is written to the current put file. If the value is unset then a line of the form
    valflag_FLAG_NAME, off
  is written instead
  
Notes: 
  -- no quotes are needed around FLAG_NAME
  -- We use the "value" parameter because it allows us to check for blank VALUEs. It must 
      appear exactly as the quoted string "value"
	
  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   July 2011

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-08-02  23:05  bpalmintier   Adapted from WriteSummary v2
  2  2011-09-22  10:45  bpalmintier   Renamed $ifthen identifiers
-----------------------------------------------------
$offtext

* Check if we have two parameters
* Yes this is a kludge, but it is GAMS standard as seen in McCarl's user guide
$if "%2" == "onoff" $goto onoff_flag
$if "%2" == "value" $goto value_flag

* ---- Set/Unset branch
* An set/unset branch is either set of not set
$ifthen.check_set set %1
	put "flag_" "%1" ", 1" /
$else.check_set
	put "flag_" "%1" ", 0" /
$endif.check_set
*end of set/unset branch
$goto end_writeFlagStatus

* ---- On/off branch
$label onoff_flag
* An on/off branch can be either on or off or set/unset
$ifthen.check_set2 set %1
$ifthen.onoff %3==on
	put "flag_" "%1" ", 1" /
$elseif.onoff %3==1
	put "flag_" "%1" ", 1" /
$else.onoff
	put "flag_" "%1" ", 0" /
$endif.onoff
$else.check_set2
	    put "flag_" "%1" ", 0" /
$endif.check_set2
*end of no value branch
$goto end_writeFlagStatus

* ---- Value branch
$label value_flag
$ifthen set %1
$if "%3" == ""
	put "valflag_" "%1" ", blank"  /
$if not "%3" == ""
	put "valflag_" "%1" ", %3"  /
$else
	put "valflag_" "%1" ", off" /
$endif


$label end_writeFlagStatus
