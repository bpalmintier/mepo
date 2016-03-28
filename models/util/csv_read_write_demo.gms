$Title CSV read and write demonstration

$ontext
----------------------------------------------------
  The main goal here is to simply illustrate how to read in and write to csv files in GAMS
  
  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   May 2010

Ver   Date      Time  Who            What
---  ---------- ----- -------------- ---------------------------------
  1  2010-05-22 22:15  bpalmintier   Original code
----------------------------------------------------- 
$offtext

* ----- GAMS Options
* Allow declaration of empty sets & variables
$onempty 
* Allow additions to set elements with multiple set definitions
$onmulti
* Allow remove domain checking
$onwarning

*------ Our very simple model
sets
	rows	"generic collection of rows"
		/r1*r4/
	cols    "generic set of columns"
		/c1*c4/
	;
parameters
	numbers(rows, cols)    "some numbers to use in our model"
	;
variables
	vError           "the total square error between rows"
positive variables
	vMultiplier(rows)      "numbers to multiply times the rows to set rows to closest values"
	vResults(rows, cols)   "the scaled numbers"
	;
	
equations
	objective                "our objective: scale rows to be close to first row"
	calculation(rows, cols)  "do the scaling"
	constraint(rows)         "but without decreasing the row scale"
	total               "with a limit on the total multipliers"
	;
	
* now actually define the equations
objective .. vError =e= sum((rows,cols), vResults('r1',cols) - vResults(rows, cols));
calculation(rows, cols) .. vResults(rows, cols) =e= vMultiplier(rows)*numbers(rows, cols);
constraint(rows) .. vMultiplier(rows) =g= 1;
total .. sum(rows, vMultiplier(rows)) =l= 10;

*--- example of reading in a csv file
table
	numbers(rows, cols)
$ondelim
$include csv_demo.csv
$offdelim
;
	
model demo /all/
solve demo using LP minimizing vError

* ------ And write out the results
$batinclude put2csv "demo_result_table.csv" "table" "vResults.l(rows, cols)" rows cols
$batinclude put2csv "demo_result_list.csv" "list" "vMultiplier.l(rows)" rows


