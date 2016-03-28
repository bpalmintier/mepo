
$ontext
----------------------------------------------------
  Maintenance scheduling for Advanced Power Family of Models.
  

Command Line Parameters Implemented Here:
    --maint=(off)    Enforce minimum up and down time constraints (default: ignore)
    --maint_lp=(off) Relax integer constraints on maintenance decisions (default: use integers) 

Additional control variables:

IMPORTANT: unlike most equation $include files, this file must be loaded AFTER reading in
the generator datafile. That way our $macros expand properly

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   May 2012

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2012-05-04  13:45  bpalmintier   Original Code
  2  2012-05-04  23:35  bpalmintier   Added max_maint as basic crew limit heuristic
  3  2012-08-20  15:35  bpalmintier   Added costs for maintenance
  4  2012-08-23  13:05  bpalmintier   Added maint_lp to ignore maintenance integers
  5  2012-08-24  11:20  bpalmintier   BUGFIX: scale maintenance costs by block duration
-----------------------------------------------------
$offtext

*================================*
*         Declarations           *
*================================*
* ======  Declare Control Variables
* Default to 15% of capacity maximum on maintenance (plus 1, so always feasible)
$if not set max_maint $setglobal max_maint 0.15

* ======  Declare Parameters
parameter
    pBlockDurWk(B, S)              "duration for each block in weeks"
    ;
    
* ======  Declare Sets
set
    GEN_PARAMS
       /
        maint_wks   "Annual weeks of maintenance                    [wk/yr]"
        c_maint_wk   "Cost per week of maintenance                  [M$/wk]"
       / 
    ;

* ======  Declare Variables
positive variables
    vMaintCost(S)     "Total maintenance cost for scenario"
    vCapOffMaint(B, T, G, S)    "Quantity of capacity available off maintenance [GW]"
$ifthen not set maint_lp
integer variables
$endif
* Note taking a queue from Ostrowski (2012) the extra integers actually help with modern
* solvers. See UnitCommitment for more
    vOnMaint(B, G, S)       "Number of units on maintenance in a block"
    vMaintBegin(B, G, S)    "Number of units starting maintenance during the block [integer]"
    vMaintEnd(B, G, S)      "Number of units finishing maintenance during the block [integer]"
    ;

* ======  Declare Equations
equations
    eMaintCost(S)         "Compute total maintenance cost for scenario"
    eMaintState(B, G, S)        "Compute maintenance begin and end"
    eMaintTime (B, G, S)        "Sum total maintenance over the time horizon"
    eTotalMaint(G, S)           "Sum total maintenance over the time horizon"
    eCapOffMaint(B, T, G, S)    "Compute resulting capacity available for dispatch"
    eMaintMax(B, G, S)          "Limit quantity of each gen type on maintenance simultaneously"
    ;

*================================*
*     The Actual Equations       *
*================================*
* Important: we must be included into a larger model, so no objective function defined

* == Compute total maintenance cost (eMaintState)
* Note: this formulation is the same as the unit commitment state formulation
eMaintCost(S)  .. 
    vMaintCost(S) 
    =e= sum[(B, G)$(pGen(G, 'maint_wks', S) > 0), vOnMaint(B, G, S) * pGen(G, 'c_maint_wk', S) * pBlockDurWk(B, S)];

* == Compute maintenance begin and end (eMaintState)
* Note: this formulation is the same as the unit commitment state formulation
eMaintState  (B, G, S)$(pGen(G, 'maint_wks', S) > 0)  .. 
    vOnMaint(B, G, S) 
    =e= vOnMaint(B--1, G, S) + vMaintBegin(B, G, S) - vMaintEnd(B, G, S);

* == Need to have sufficient Maintenance (scaled by time horizon) (eTotalMaint)
eTotalMaint(G, S)$(pGen(G, 'maint_wks', S) > 0) ..
    sum[(B), vOnMaint(B, G, S) * pBlockDurWk(B, S)] 
    =g= pGen(G, 'maint_wks', S) * %max_cap_G% / pGen(G, 'gen_size', S) * pFractionOfYear(S);

* == Compute resulting capacity available for dispatch (eCapOffMaint)
* Note: must include for all generators, even without maintenance to ensure there is a
* reasonable upper limit on their dispatch
eCapOffMaint(B, T, G, S) ..
    vCapOffMaint(B, T, G, S) =e= %max_cap_G% - vOnMaint(B, G, S) * pGen(G, 'gen_size', S);

* == Limit quantity of each gen type on maintenance simultaneously (MaintMax)
eMaintMax(B, G, S)$(pGen(G, 'maint_wks', S) > 0) ..
    vOnMaint(B, G, S) =l= 1 + %max_maint% * %max_cap_G% / pGen(G, 'gen_size', S);

* == Once started, must take full time for maintanence (eMaintTime)
* Note: this formulation is basically the same as the min up/down time formulation
* the primary difference is that we sum over block duration to allow reasonable maintenance
* plans for partial year time periods
eMaintTime(B, G, S)$(pGen(G, 'maint_wks', S) > 0) ..
    vOnMaint(B, G, S)
    =g=
    vMaintBegin(B, G, S) 
    + vMaintBegin(B--1, G, S)$(pGen(G, 'maint_wks', S) 
                                > pBlockDurWk(B, S) )
    + vMaintBegin(B--2, G, S)$(pGen(G, 'maint_wks', S)
                                > pBlockDurWk(B, S) + pBlockDurWk(B--1, S) )
    + vMaintBegin(B--3, G, S)$(pGen(G, 'maint_wks', S) 
                                > pBlockDurWk(B, S) + pBlockDurWk(B--1, S) + pBlockDurWk(B--2, S) )
    + vMaintBegin(B--4, G, S)$(pGen(G, 'maint_wks', S)
                                > pBlockDurWk(B, S) + pBlockDurWk(B--1, S) + pBlockDurWk(B--2, S)
                                    + pBlockDurWk(B--3, S) )
    + vMaintBegin(B--5, G, S)$(pGen(G, 'maint_wks', S)
                                > pBlockDurWk(B, S) + pBlockDurWk(B--1, S) + pBlockDurWk(B--2, S)
                                    + pBlockDurWk(B--3, S) + pBlockDurWk(B--4, S) )
    + vMaintBegin(B--6, G, S)$(pGen(G, 'maint_wks', S)
                                > pBlockDurWk(B, S) + pBlockDurWk(B--1, S) + pBlockDurWk(B--2, S)
                                    + pBlockDurWk(B--3, S) + pBlockDurWk(B--4, S) 
                                    + pBlockDurWk(B--5, S) )
    + vMaintBegin(B--7, G, S)$(pGen(G, 'maint_wks', S)
                                > pBlockDurWk(B, S) + pBlockDurWk(B--1, S) + pBlockDurWk(B--2, S)
                                    + pBlockDurWk(B--3, S) + pBlockDurWk(B--4, S) 
                                    + pBlockDurWk(B--5, S) + pBlockDurWk(B--6, S) )
    + vMaintBegin(B--8, G, S)$(pGen(G, 'maint_wks', S)
                                > pBlockDurWk(B, S) + pBlockDurWk(B--1, S) + pBlockDurWk(B--2, S)
                                    + pBlockDurWk(B--3, S) + pBlockDurWk(B--4, S) 
                                    + pBlockDurWk(B--5, S) + pBlockDurWk(B--6, S)
                                    + pBlockDurWk(B--7, S) )
    + vMaintBegin(B--9, G, S)$(pGen(G, 'maint_wks', S) 
                                > pBlockDurWk(B, S) + pBlockDurWk(B--1, S) + pBlockDurWk(B--2, S)
                                    + pBlockDurWk(B--3, S) + pBlockDurWk(B--4, S) 
                                    + pBlockDurWk(B--5, S) + pBlockDurWk(B--6, S)
                                    + pBlockDurWk(B--7, S) + pBlockDurWk(B--8, S) )
    ;