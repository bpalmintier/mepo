*Start Block Quote
$ontext
-------------------------------------------------
Parameter update to make Wind beat Nuke for Baseload using EIA AEO2011 Cost numbers


Estimated using: 
    Screen Curves.xlsx v11

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   January 2012

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2012-01-31  11:50  bpalmintier   Original version based on carbon_cap_update v3
-------------------------------------------------
$offtext

pGen('Wind', 'c_cap',S) = pGen('Wind', 'c_cap',S) * 0.5;