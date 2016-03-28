
$offlisting
$ontext
----------------------------------------------------
Helper Function for writing variables to CSV files using put
----------------------------------------------------
A collection of functions for writing variables to csv files
  
Call in GAMS:
 $batinclude put2csv filename "list" data row_sets [prefix]
 $batinclude put2csv filename "table" data row_sets col_sets [prefix]
 
Parameters:
  filename  the file to write to. By default this filename will be automatically
             opened and closed by put2csv. Use "" to handle the put and putclose statements
             within the calling function
  type      the format type for writing the variable to csv. See the list of supported
             types below
  data      An object to write to csv. This can be any valid gams object that can
             be put. Examples: A scalar or parameter name, or a qualified variable name
             such as variable.l or variable.m. For items defined over sets, the set
             names must also be included in proper order as in var.l(s1,s2). 
             IMPORTANT: data must not have any spaces
  row_set   Defines the name(s) of the set that is (are) looped over when listing row labels
             & data. Multiple sets must be joined by periods when passed such as A.B.C
  col_set   For table data, defines the set(s) to loop over for column headings & data
  prefix    prefix to prepend to row labels. Enclose strings in "'string'"
  
Notes:
  - Rutherford provides a similar gams2csv utility, but its usage is somewhat limited.
     Put2csv provides the following improvements:
        -- Direct support for variables and equations (e.g. you can use vMyVariable.l 
            or .m directly, without first creating a parameter to hold the this value)
        -- Cleaner, streamlined output format without introductory variable labels and
            without extra indenting for data tables. 
        -- Ability to handle file opening and closing for simple calls
  - works with parameters, variables, and equations. For variables and equations, specify
    the desired suffix such as variable.l(SETS)
  - Uses the alternative control structure format ($onend). The caller must return to the
     default format if desired. In other words, this code uses if... endif, loop... endloop etc.
     If your code uses the default if{} format then you need to use $offend after calling put2csv.
  - A maximum of 5 dimensions for each row & col are supported
  - put2csv uses the currently defined defaults for precision and other formatting
    parameters. Set these using .lw, .nw, .nd, .sw, .tw, etc. Such use requires 
    controlling the file open & close in the calling function
  - String based prefixes must be double quoted using different quote types since the 
     $batinclude process strips off the first set and we would like to enable the use of
     non-string prefixes such as using an outer loop of SET.tl

Examples:

 [1] Write a variable as a list to a named file
    $batinclude put2csv.gms "put2csv_test_list.csv" "list" vCapacity.l(G) G "'prefix_'"

 [2] Write a variable as a table to a named file
    $batinclude put2csv.gms "put2csv_test_table.csv" "table" vPwrOut.l(DEM,G) G DEM "'prefix_'"
 
 [3] Write multiple dimensional data in various configurations to the same caller controlled file

    *Build up a multi-D array
        sets
            A  "first dimension"
                /a1   "Element-A1-"
                 a2   "Element-A2-"
                 a3   "Element-A3-"
                /
            B  "second dimension"
                /b1*b3/
            C  "third dimension"
                /c1*c3/
            D  "fourth dimension"
                /d1*d3/
            E  "fifth dimension"
                /e1*e3/
            F  "sixth dimension"
                /f1*f3/
        ;
        parameters
            pData5(A, B, C, D, E)  "5 dimensional data"
            pData6(A, B, C, D, E, F)  "6 dimensional data"
            ;
            
            pData5(A,B,C,D,E) = uniform(0,10);
            pData6(A,B,C,D,E,F) = uniform(0,10);
    
    * ----- Write Results to CSV file
    
    *Now test various shapes of output in the same file
        FILE multi_d    /"put2csv_test_multiD.csv"/;
        PUT multi_d;
    *Allow maximum page width to prevent truncation
        multi_d.pw=32767;
        
    $batinclude put2csv.gms "" "list"  pData5(A,B,C,D,E) A.B.C.D.E   A.te(A)
    $batinclude put2csv.gms "" "table" pData5(A,B,C,D,E) A.B.C.D   E "A.te(A)"
    $batinclude put2csv.gms "" "table" pData5(A,B,C,D,E) A.B.C   D.E "'3x2_'"
    $batinclude put2csv.gms "" "table" pData5(A,B,C,D,E) A.B   C.D.E "'2x3_'"
    $batinclude put2csv.gms "" "table" pData5(A,B,C,D,E) A   B.C.D.E "'1x4_'"
    
        put "Full 6-D data set as 1x5" /
    $batinclude put2csv.gms "" "table" pData6(A,B,C,D,E,F) A   B.C.D.E.F
    
    *Close our put file
        putclose        
        
        

Originally Coded in GAMS by:
  Bryan Palmintier, MIT
  May 2010

Ver   Date      Time  Who            What
---  ---------- ----- -------------- ---------------------------------
  1  2010-05-19 23:45  bpalmintier    Original Version with 2d_var
  2  2010-05-20 12:50  bpalmintier    Degugging, renamed-> table, added list option
  3  2010-11-14 20:50  bpalmintier    Added optional prefix for row labels
  4  2011-09-30 13:50  bpalmintier    Set page width to max to reduce truncation
  5  2012-01-27 16:00  bpalmintier    Use $onend for consistency with AdvPwrSetup
  6  2012-01-28 18:13  bpalmintier    Expanded for up to 5 dimensions for row & column
----------------------------------------------------- 
$offtext
$if set p2c_debug $onlisting

* ----- GAMS Options
* Prevent any $ commands from propagating to our caller
$offglobal
$onend

* ----- Handle Parameters -----
$setargs p2c_filename p2c_type p2c_var p2c_row p2c_col p2c_prefix *

* -- Setup file, if need
$ifthen not "%p2c_filename%" == ""
$setnames %p2c_filename% directory p2c_file_root extension
	FILE %p2c_file_root% /"%p2c_filename%"/; 
	PUT %p2c_file_root%; 
*Allow maximum page width to prevent truncation
    %p2c_file_root%.pw=32767;

$endif

* ----- Split apart p2c_row & p2c_column into up to components -----
* Separate period delimited string into up to 5 components. Empty variables if string has
* fewer components
$setcomps %p2c_row% p2c_r1 p2c_r2 p2c_r3 p2c_r4 p2c_r5 
$setcomps %p2c_col% p2c_c1 p2c_c2 p2c_c3 p2c_c4 p2c_c5

* Note: can't build up a new control variable b/c tokens are only paste once

* ----- Write Results to CSV file based on specified p2c_type -----

* ----- Two-Dimensional Table from a p2c_variable
$iftheni "%p2c_type%" == "table"
*First print p2c_column headers
	loop (%p2c_c1%
*build up comma delimited loop indicies
$if not "%p2c_c2%" == "" ,%p2c_c2%
$if not "%p2c_c3%" == "" ,%p2c_c3%
$if not "%p2c_c4%" == "" ,%p2c_c4%
$if not "%p2c_c5%" == "" ,%p2c_c5%
	) do
*build up period delimited heading
		put ', ' %p2c_c1%.tl:0;
$if not "%p2c_c2%" == "" put "." %p2c_c2%.tl:0
$if not "%p2c_c3%" == "" put "." %p2c_c3%.tl:0
$if not "%p2c_c4%" == "" put "." %p2c_c4%.tl:0
$if not "%p2c_c5%" == "" put "." %p2c_c5%.tl:0
	endloop;
	put /;
	
* Now print the the data table, one p2c_row at a time with headers
	loop    (%p2c_r1%
*build up comma delimited loop indicies
$if not "%p2c_r2%" == "" ,%p2c_r2%
$if not "%p2c_r3%" == "" ,%p2c_r3%
$if not "%p2c_r4%" == "" ,%p2c_r4%
$if not "%p2c_r5%" == "" ,%p2c_r5%
	        ) do
*build up period delimited heading
		put %p2c_prefix% %p2c_r1%.tl:0;
$if not "%p2c_r2%" == "" put "." %p2c_r2%.tl:0
$if not "%p2c_r3%" == "" put "." %p2c_r3%.tl:0
$if not "%p2c_r4%" == "" put "." %p2c_r4%.tl:0
$if not "%p2c_r5%" == "" put "." %p2c_r5%.tl:0

* Loop to print out row contents
		loop (%p2c_c1%
*build up comma delimited loop indicies
$if not "%p2c_c2%" == "" ,%p2c_c2%
$if not "%p2c_c3%" == "" ,%p2c_c3%
$if not "%p2c_c4%" == "" ,%p2c_c4%
$if not "%p2c_c5%" == "" ,%p2c_c5%
	         ) do
			    put ',' %p2c_var%;
		endloop;
		put /;
	endloop;

* ----- Single p2c_column output from a p2c_variable
$elseifi "%p2c_type%" == "list"
* Note: using the p2c_col entry as  p2c_prefix
* Now print the the data table, one p2c_row at a time with headers
	loop   (%p2c_r1%
*build up comma delimited loop indicies
$if not "%p2c_r2%" == "" ,%p2c_r2%
$if not "%p2c_r3%" == "" ,%p2c_r3%
$if not "%p2c_r4%" == "" ,%p2c_r4%
$if not "%p2c_r5%" == "" ,%p2c_r5%
	        ) do
*build up period delimited heading
		put %p2c_col%  %p2c_r1%.tl:0;
$if not "%p2c_r2%" == "" put "." %p2c_r2%.tl:0
$if not "%p2c_r3%" == "" put "." %p2c_r3%.tl:0
$if not "%p2c_r4%" == "" put "." %p2c_r4%.tl:0
$if not "%p2c_r5%" == "" put "." %p2c_r5%.tl:0

		put ',' %p2c_var%;
		put /;
	endloop;

$endif

* ----- close file if needed 
$ifthen not "%p2c_filename%" == ""
	putclose
$endif

$onlisting