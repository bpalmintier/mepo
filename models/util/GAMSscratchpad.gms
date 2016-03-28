
*GAMS Quick test scratchpad

set s /s1*s3/;
scalar a;
a = 3;

FILE outfile /"GAMSscratchpadOUT.txt"/; 
PUT outfile;

loop[ (s),
        put s.tl:0 "" " test"/
    ];

*execute 'mkdir junk'

$setcomps this.is.a.test w1 w2 w3 w4 w5 w6

put "w1:":0 "%w1%" /
put "w2:":0 "%w2%" /
put "w3:":0 "%w3%" /
put "w4:":0 "%w4%" /
put "w5:":0 "%w5%" /
put "w6:":0 "%w6%" /

$setcomps that.was.also.kind.of.silly w1 w2

put "w1:":0 "%w1%" /
put "w2:":0 "%w2%" /
put "w3:":0 "%w3%" /

$setcomps we.clear? w1 w2 w3 w4 w5 w6

put "w1:":0 "%w1%" /
put "w2:":0 "%w2%" /
put "w3:":0 "%w3%" /
put "w4:":0 "%w4%" /
put "w5:":0 "%w5%" /
put "w6:":0 "%w6%" /

$if set w2 put "w2:set" /
$if not set w2 put "w2: NOT set" /
$if set w3 put "w3:set" /
$if not set w3 put "w3: NOT set" /

$ifi "%w2%" == "" put "w2: Empty"/
$ifi "CHECK%w2%" == "CHECK" put "w2: Empty CHECK"/
$if not "%w2%" == "" put "w2: Not Empty"/
$if not "CHECK%w2%" == "CHECK" put "w2: Not Empty CHECK"/
$if "%w3%" == "" put "w3: Empty"/
$if "CHECK%w3%" == "CHECK" put "w3: Empty CHECK"/
