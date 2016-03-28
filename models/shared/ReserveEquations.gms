
$ontext
----------------------------------------------------
Common Reserves Formulation for Advanced Power Family of models
----------------------------------------------------
  Abstracts out the various reserve formulations for Advanced Power Family of Models.
  
Includes the following reserve options:
  -- Separate Reserves, corresponding to "classic" ancillary services: Spinning Reserves,
      Regulation up & down, Quick-start, Renewable driven reserves, Load Following
  -- Combined "flexibility" reserves: where everything is combined into two classes: Flexibility
      Up and Flexibility Down
  

Command Line Parameters Implemented Here:
  --adj_rsrv_for_nse=(off)  Adjust reserves for non-served energy. This uses actual power
                  production rather than total desired demand for setting reserve requirements.
                  This distinction is only significant if there is non-served energy. When
                  enabled (old default for SVN=479-480), then non-served energy provides a way
                  to reduce reserve requirements. [Default= use total non-adjusted demand]
  --rsrv=(none)  Specify Type of reserve calculation. Options are:
        =separate  Enforce separate reserve requirements based on "classic" ancillary
                    services plus additions for renewable uncertainty. This includes Reg Up, 
                    Reg Down, Spin Up, & Quick Start
        =flex      Use combined "flexibility" reserves grouped simply into flex up and flex down
        =both      Compute both separate and flexibility reserves
        =(none)    If not set, no reserve limits are computed
    Note: this include file assumes that rsrv has been set
  --non_uc_rsrv_up_offline=0   For non-unit commitment generators, the fraction of non-running 
                    generation capacity to use toward UP reserves. This parameter has no
                    effect on UC generators. deJonge assumes 0.6, NETPLAN assumes 1.0, 
                    (default=0). 
  --non_uc_rsrv_down_offline=0 For non-unit commitment generators, the fraction of non-running 
                    generation capacity to use toward DOWN reserves. This parameter has no
                    effect on UC generators. deJonge assumes 0.6, NETPLAN assumes 1.0, 
                    (default=0).
  --no_quick_st=(off)     Flag to zero out quickstart reserve contribution to spinning/flex up 
                           reserves. Useful when non_uc_rsrv... > 0

Additional control variables:
   %separate_rsrv%   Set if rsrv = separate or both
   %flex_rsrv%       Set if rsrv = flex or both
   %capacity_G%      Alias to specify total capacity by generator. This allows easy use of either
                      vCapInUse(G) or pGen(G, 'cap_cur') for expansion or operation only
                      optimizations respectively. If not set by the caller, we assume operations
                      only and set it to pGen(G,'cap_cur').
  %load_for_rsrv%    Alias to allow use of either total production or total demand as "load" 
                      for reserves calculation.

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   September 2011

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-09-23  11:05  bpalmintier   Extracted from UnitCommit v4
  2  2011-09-23  15:00  bpalmintier   Introduced capacity_G alias for total capacity to reduce $ifs
  3  2011-09-23  16:05  bpalmintier   Converted to $setglobal so our changes propagate to caller
  4  2011-09-29  22:05  bpalmintier   Allow additional spinning reserve to substitute for quick start
  5  2011-10-09  14:05  bpalmintier   Bugfix: remove spinning reserves from FlexDown
  6  2011-10-11  14:15  bpalmintier   Renamed plant_size to gen_size (also related flags)
  7  2011-10-14  18:05  bpalmintier   MAJOR: Wind for sep reserves, LoadFollowDown, Add (not max) contingency & load
  8  2011-10-22  07:50  bpalmintier   Bugfix: fixed substitution of vRegDown for vNetLoadFollowDown 
  9  2012-01-25  23:55  bpalmintier   Added scenario support for stochastic UC, multi-period planning, etc.
  10 2012-03-07  12:05  bpalmintier   Added support for partial period simulation through D_SIM
  11 2012-05-02  12:35  bpalmintier   Separate demand (D) into blocks (B) and time sub-periods (T)
  12 2012-08-31  00:35  bpalmintier   Allow non-served energy to reduce reserve needs (old behavior with --rsrv_use_tot_demand=1)
  13 2012-08-31  07:15  bpalmintier   UPDATE: default to rsrv to demand (without nse). Flag renamed to adj_rsrv_for_nse
  14 2012-09-02  17:08  bpalmintier   Replace all $set with $setglobal (to prevent scope errors)
  15 2012-09-06  09:38  bpalmintier   Add no_quick_st, non_uc_rsrv_down_offline and non_uc_rsrv_up_offline
-----------------------------------------------------
$offtext

*================================*
*  Additional Control Variables  *
*================================*
$ifthen.any_rsrv set rsrv
$if %rsrv% == flex $setglobal flex_rsrv
$if %rsrv% == separate $setglobal separate_rsrv
$ifthen %rsrv% == both
$setglobal flex_rsrv
$setglobal separate_rsrv
$endif
$endif.any_rsrv

*Default to NOT adjusting reserves for non-served energy (faster?)
$if NOT set adj_rsrv_for_nse $setglobal adj_rsrv_for_nse off

$ifthen.ar4n NOT adj_rsrv_for_nse==off
$ifthen not set no_nse
$setglobal load_for_rsrv   (pDemand(B,T,'power', S) - vNonServed(B, T,S))
$else
$setglobal load_for_rsrv   pDemand(B,T,'power', S)
$endif
$else.ar4n
$setglobal load_for_rsrv   pDemand(B,T,'power', S)
$endif.ar4n

$if NOT set capacity_G $setglobal capacity_G pGen(G, 'cap_cur', S)

$if not set non_uc_rsrv_up_offline $setglobal non_uc_rsrv_up_offline 0
$if not set non_uc_rsrv_down_offline $setglobal non_uc_rsrv_down_offline 0

*================================*
*         Declarations           *
*================================*

* ======  Declare the data parameters. Actual data imported from include files
scalars

*   pWindForecastError "forecast error as a fraction of wind capacity for quick start reserves [p.u.]"
*    pSpinResponseTime           "Response time for Spinning Reserves                        [minutes]"
*    pQuickStartLoadFract        "addition Fraction of load for non-spin reserves            [p.u.]"
    pSpinReserveLoadFract       "addition Fraction of load for spin reserves                [p.u.]"
    pSpinReserveMinGW           "minimum spining reserve                                    [GW]"
    pReplaceReserveGW           "offline replacement reserves to fill-in if spinning reserves are called [GW]"
    pRegUpLoadFract             "additional Fraction of load for regulation up              [p.u.]"
    pRegDownLoadFract           "Fraction of load over unit minimums for regulation down    [p.u.]"
    pQuickStSpinSubFract        "Fraction of Spinning Reserves that can be supplied by off-line generators [p.u.]"

*Additional Reserves for Wind see (De Jonghe, et al 2011)
* pWindFlexUpForecast=A_POS, pWindFlexUpCapacity=B_POS, pWindFlexDownForecast=A_NEG, pWindFlexDownCapacity=B_NEG
    pWindFlexUpForecast     "Additional up reserves based on wind power output (forecast)  [fraction of PwrOur]"
    pWindFlexUpCapacity     "Additional up reserves based on installed wind capacity [fraction of Wind capacity]"
    pWindFlexDownForecast   "Additional down reserves based on wind power output (forecast)  [fraction of PwrOur]"
    pWindFlexDownCapacity   "Additional down reserves based on installed wind capacity [fraction of Wind capacity]"

* ======  Declare Variables
positive variables

$ifthen set separate_rsrv
   vSpinReserve    (B,T,G,S)     "Contingency Spinning reserves service provision by generator class [GW]"
   vNetLoadFollowDown(B,T,G,S)     "Load follow down reserves service provision by generator class [GW]"
   vRegUp          (B,T,G,S)     "Regulation up reserves service provision by generator class [GW]"
   vRegDown        (B,T,G,S)     "Regulation down reserves service provision by generator class [GW]"
$ifthen.no_qs not set no_quick_st
  vQuickStart     (B,T,G,S)     "Non-spin reserves service provision by generator class [GW]"
$endif.no_qs
$endif

$ifthen set flex_rsrv
   vFlexUp    (B,T,G,S)  "Flexibility up   (Spinning + QuickStart + RegUp + Renewable Up) reserves [GW]"
   vFlexDown  (B,T,G,S)  "Flexibility down (RegDown + Renewable Down) reserves [GW]"
$endif
   ;

* ======  Declare Equations
equations
$ifthen set flex_rsrv
    ePwrMaxFlexRsrv   (B,T, G, S)  "output w/ reserves lower than available max       [GW]"
    ePwrMinFlexRsrv   (B,T, G, S)  "output w/ reserves greater than installed min     [GW]"
    ePwrMaxFlexRsrvUC (B,T, G, S)  "output w/ reserves lower than committed max       [GW]"
    ePwrMinFlexRsrvUC (B,T, G, S)  "output w/ reserves greater than committed min     [GW]"

    eFlexUp    (B,T, S)     "Provide required flexibility up reserves (aka Positive Balance) [GW]"
    eFlexDown  (B,T, S)     "Provide required flexibility down reserves (aka Negative Balance) [GW]"
    
    eFlexUpMaxOnLine    (B,T,G,S) "Ensure that only some of the flex reserves come from off-line (quick start) gens [GW]"
$ifthen.no_qs not set no_quick_st
    eFlexUpMax    (B,T,G,S)     "Stay below max spinning reserves on-line generators of each class can supply [GW]"
$endif.no_qs
    eFlexDownMax  (B,T,G,S)     "Stay below max regulation up reserves on-line generators of each class can supply [GW]"
$endif

$ifthen set separate_rsrv
   ePwrMaxSepRsrv   (B,T, G, S)  "output w/ reserves lower than available max       [GW]"
   ePwrMinSepRsrv   (B,T, G, S)  "output w/ reserves greater than installed min     [GW]"
   ePwrMaxSepRsrvUC (B,T, G, S)  "output w/ reserves lower than committed max       [GW]"
   ePwrMinSepRsrvUC (B,T, G, S)  "output w/ reserves greater than committed min     [GW]"

   eSpinReserve    (B,T, S)     "Provide required spinning reserves [GW]"
   eNetLoadFollowDown(B,T, S)     "Provide required load following down reserves [GW]"
   eRegUp          (B,T, S)     "Provide required regulation up reserves [GW]"
   eRegDown        (B,T, S)     "Provide required regulation down reserves [GW]"
$ifthen.no_qs not set no_quick_st
   eQuickStart     (B,T, S)     "Provide required non-spinning reserves [GW]"
$endif.no_qs

   eSpinReserveMax    (B,T,G,S)     "Stay below max spinning reserves on-line generators of each class can supply [GW]"
   eNetLoadFollowDownMax(B,T,G,S)     "Stay below max load following down on-line generators of each class can supply [GW]"
   eRegUpMax          (B,T,G,S)     "Stay below max regulation up reserves on-line generators of each class can supply [GW]"
   eRegDownMax        (B,T,G,S)     "Stay below max regulation down on-line generators of each class can supply [GW]"
$ifthen.no_qs not set no_quick_st
   eQuickStartMax     (B,T,G,S)     "Stay below max non-spin reserves off-line generators of each class can supply [GW]"
$endif.no_qs
$endif
   ;

*================================*
*     The Actual Equations       *
*================================*
* Important: we must be included into a larger model, so no objective function defined

*====== Generation output less than upper limit(s)
* There are multiple limits here for different circumstances
* 1) Simplest (ePwrMaxFlexRsrv) is power out < installed capacity. But here there are twists since we
*    allow time varing availability, and for some capacity to be moth-balled and hence not in
*    active use. In addition, we also need to ensure headroom for reserves up. 
* 2) For generation subject to unit commitment, things change slightly since we now only output
*    power up to the number of units that are turned on (ePwrMaxFlexRsrvUC)
* 3) If separate reserves are computed, they should not be simply added to the flexibility 
*    reserves, but rather we want to take max(FlexUp, sum(other up reserves). In LP we do this
*    by adding an additional equation for the sum(other up reserves) term. (ePwrMaxSepRsrv)
* Furthermore,  we might choose to derate the power output of the plant separately from 
* availability (typically for simple models), this can be done by taking the minimum of availability
* and the derate factor. Since both arer parameters, this is a valid (MI)LP formulation. Note that
* this derating is already taken into account for in eUnitCommit for the UC equations.

*====================================*
*  Combined (Flexibility) Reserves   *
*====================================*
* == Output (& Flex Reserves) must be below the generator upper limits (ePwrMaxFlexRsrv)
* These equations are used for the no reserves case and for combined (Flexibility) reserves
* they are also active when separate reserves are used as described in #3 above.
*
*Note: the $subset(setname) format only defines the equation for members of G that are also in G_UC
*Note: Availability is handled in eState for unit commitment constrained generators
$ifthen.flex set flex_rsrv                            
ePwrMaxFlexRsrv (B,T, G, S)$( B_SIM(B)
                            and not G_UC(G) ) .. 
                        vPwrOut(B,T, G, S) + vFlexUp(B,T,G, S) =l= %capacity_G% * 
$ifthen set derate
                            min( pGen(G, 'derate', S),
$else
                            (
$endif
                            pGenAvail(B,T, G, S)
                            );

* == Output Upper Limit for UnitCommitment Gens (ePwrMaxFlexRsrvUC)
* Note: we only include the flexible up output if it can't be provided by quick start units.
ePwrMaxFlexRsrvUC (B,T, G, S)$( B_SIM(B)
                              and G_UC(G) ) .. 
                            vPwrOut(B,T, G, S) 
                            + vFlexUp(B,T,G,S)$(pGen(G, 'quick_start', S) = 0)
                            =l= vUnitCommit(B,T,G,S) * pGen(G, 'gen_size', S);

*====== Generation output greater than lower limit(s)
* Here we find a complementary situation to the PwrMax equations described above

* == Power greater than lower limits (ePwrMinFlexRsrv)
* For simple models we might use a "technology minimum output" as a proxy for
* baseload plants. This lower limit is applied to entire generator category and is ignored by 
* using p_min=0 or not defining p_min (unspecified parameters default to zero).
*
* Note: we keep this active for G_UC to enforce p_min if required
ePwrMinFlexRsrv (B,T, G, S)$B_SIM(B) ..   vPwrOut(B,T, G, S) =g= %capacity_G% * pGen(G,'p_min', S)
                            + vFlexDown(B,T,G,S);


* == Power greater than lower limits for Unit Commitment (ePwrMinFlexRsrvUC)
* Minimum power output for commitment generators under UC
*Note: the $subset(setname) format only defines the equation for members of G that are also in G_UC
ePwrMinFlexRsrvUC (B,T, G, S)$( B_SIM(B)
                              and G_UC(G) ) .. vPwrOut(B,T, G, S)
                            =g=
                            vUnitCommit(B,T,G,S) * pGen(G, 'unit_min', S)
                            + vFlexDown(B,T,G,S);
                            
*=== Combined Flexibility Reserves including additional reserves as a function of Renewables
* These reserves combine all upward reserve requirements (Spin, Load Follow Up, Regulation Up, 
* Renewable Flexibility Up) into FlexUp and all downward reserve requirements (Load Follow Down, 
* Regulation Down, Renewable Follow Up

*Equivalent to (De Jonghe, et al 2011) eq 16 & 18 with BP addition of baseline (non-wind)
*requirement to meet Spin Reserve + Reg Up
    eFlexUp    (B,T, S)$B_SIM(B) .. sum[(G), vFlexUp(B,T, G, S)] =g=
                            %load_for_rsrv% * (pSpinReserveLoadFract + pRegUpLoadFract)
                            + pSpinReserveMinGW
                            + pWindFlexUpForecast * sum[(G)$G_WIND(G), vPwrOut(B,T, G, S)]
                            + pWindFlexUpCapacity * sum[(G)$G_WIND(G), %capacity_G%];

    eFlexDown  (B,T, S)$B_SIM(B) .. sum[(G), vFlexDown(B,T, G, S)] =g=
                            %load_for_rsrv% * (pSpinReserveLoadFract + pRegDownLoadFract)
                            + pWindFlexDownForecast * sum[(G)$G_WIND(G), vPwrOut(B,T, G, S)]
                            + pWindFlexDownCapacity * sum[(G)$G_WIND(G), %capacity_G%];

* Compute the maximum reserves per generator as a function of capabilities.
* Note: ePwrMaxFlexRsrv and ePwrMinFlexRsrv ensure that we do not double count capacity

    eFlexUpMaxOnLine    (B,T,G,S)$B_SIM(B) .. (1 - pQuickStSpinSubFract) * vFlexUp(B,T,G,S) =l=
                                    (pGen(G, 'spin_rsv', S) + pGen(G, 'reg_up', S))
                                    *(
                                        (vUnitCommit(B,T, G, S)*pGen(G, 'gen_size', S))$G_UC(G) +
                                        (vPwrOut(B,T, G, S) 
                                            + %non_uc_rsrv_up_offline% 
                                                * (%capacity_G% - vPwrOut(B,T, G, S))
                                        )$(not G_UC(G))
                                    );

$ifthen not set no_quick_st
    eFlexUpMax    (B,T,G,S)$B_SIM(B) .. vFlexUp(B,T,G,S) =l=
                                    (pGen(G, 'spin_rsv', S) + pGen(G, 'reg_up', S))
                                    *(
                                        (vUnitCommit(B,T, G, S)*pGen(G, 'gen_size', S))$G_UC(G) +
                                        (vPwrOut(B,T, G, S))$(not G_UC(G))
                                    )
                                    + pGen(G, 'quick_start', S)*( %capacity_G%
                                        - (
                                            (vUnitCommit(B,T, G, S)*pGen(G, 'gen_size', S))$G_UC(G) +
                                            (vPwrOut(B,T, G, S) 
                                                + %non_uc_rsrv_up_offline% 
                                                    * (%capacity_G% - vPwrOut(B,T, G, S))
                                            )$(not G_UC(G))
                                          )
                                    );
$endif
*Equivalent to (De Jonghe, et al 2011) eq 12 with the BP correction that off-line generators can't
*be used to provide downward flexibility, using BP field names and assuming the spin_rsv and 
*reg_up limits are additive
    eFlexDownMax    (B,T,G,S)$B_SIM(B) .. vFlexDown(B,T,G,S) =l=
                                    (pGen(G, 'spin_rsv', S) + pGen(G, 'reg_down', S))*(
                                        (vUnitCommit(B,T, G, S)*pGen(G, 'gen_size', S))$G_UC(G) +
                                        (vPwrOut(B,T, G, S) 
                                            + %non_uc_rsrv_down_offline% 
                                                * (%capacity_G% - vPwrOut(B,T, G, S))
                                        )$(not G_UC(G))
                                    );
$endif.flex


*======================*
*  Separate Reserves   *
*======================*
* == Output + Individual Reserves must be below the generator upper limits (ePwrMaxSepRsrv)
* These equations are used for the separate reserves case
$ifthen.sep_rsrv set separate_rsrv
ePwrMaxSepRsrv (B,T, G, S)$( B_SIM(B)
                           and not G_UC(G) ) .. 
                            %capacity_G% * 
$ifthen set derate
                            min( pGen(G, 'derate', S),
$else
                            (
$endif
                                pGenAvail(B,T, G, S)
                            ) =g=
                            vPwrOut(B,T, G, S)
                            + vSpinReserve(B,T, G, S)$(pGen(G, 'spin_rsv', S))
                            + vRegUp(B,T, G, S)$(pGen(G, 'reg_up', S))
                            ;
                            
* == Output Upper Limit for UnitCommitment Gens with Separate Reserves (ePwrMaxSepRsrvUC)
ePwrMaxSepRsrvUC (B,T, G, S)$( B_SIM(B)
                             and G_UC(G) ) .. vUnitCommit(B,T,G,S) * pGen(G, 'gen_size', S)
                            =g=
                            vPwrOut(B,T, G, S)
                            + vSpinReserve(B,T, G, S)$(pGen(G, 'spin_rsv', S))
                            + vRegUp(B,T, G, S)$(pGen(G, 'reg_up', S))
                            ;

* == Output + Individual Reserves must be above the generator lower limits (ePwrMinSepRsrv)
* These equations are used for the separate reserves case
ePwrMinSepRsrv (B,T, G, S)$B_SIM(B) ..   vPwrOut(B,T, G, S) =g= %capacity_G% * pGen(G,'p_min', S)
                        + vRegDown(B,T,G,S)$(pGen(G, 'reg_down', S))
                        + vNetLoadFollowDown(B,T, G, S);


* == Output + Individual Reserves above the lower limits for Unit Commitment(ePwrMinSepRsrvUC)
ePwrMinSepRsrvUC (B,T, G, S)$( B_SIM(B) 
                             and G_UC(G) ) .. vPwrOut(B,T, G, S)
                            =g=
                            vUnitCommit(B,T,G,S) * pGen(G, 'unit_min', S)
                            + vRegDown(B,T,G,S)$(pGen(G, 'reg_down', S))
                            + vNetLoadFollowDown(B,T, G, S);

*=== Separate Ancillary Services

*=== Ensure we have enough reserves for each operating period
* == Spinning Reserves (eSpinReserve) aka secondary reserves
*  Focus on contingencies (ie outages or failures) only. Here we compute the required
*  level as the greater of the specified minimum (typically set to the largest on-line plant
*  or transmission tie)
    eSpinReserve    (B,T, S)$B_SIM(B) .. sum[(G)$(pGen(G, 'spin_rsv', S)), vSpinReserve(B,T, G, S)] 
                            =g= (1 - pQuickStSpinSubFract)
                             * (    pSpinReserveMinGW
                                    + %load_for_rsrv% * pSpinReserveLoadFract
                                    + pWindFlexUpForecast * sum[(G)$G_WIND(G), vPwrOut(B,T, G, S)]
                                    + pWindFlexUpCapacity * sum[(G)$G_WIND(G), %capacity_G%]
                                );

* == Quick Start Reserves (eQuickStart) aka tertiary reserves
*  Allow QuickStart units (off-line or demand) to substitute for a fraction of secondary reserves
$ifthen.no_qs not set no_quick_st
    eQuickStart     (B,T, S)$B_SIM(B) .. sum[(G)$(pGen(G, 'quick_start', S)), vQuickStart(B,T, G, S)]
                            + sum[(G)$(pGen(G, 'spin_rsv', S)), vSpinReserve(B,T, G, S)]
                           =g=
                            pReplaceReserveGW
                            + pSpinReserveMinGW
                            + %load_for_rsrv% * pSpinReserveLoadFract
                            + pWindFlexUpForecast * sum[(G)$G_WIND(G), vPwrOut(B,T, G, S)]
                            + pWindFlexUpCapacity * sum[(G)$G_WIND(G), %capacity_G%]
                            ;
$endif.no_qs
* == Load Follow Down (eNetLoadFollowDown) aka secondary reserves
*  Handles second to second variations. Computed as a specified fraction of the load.
    eNetLoadFollowDown (B,T, S)$B_SIM(B) .. sum[(G)$(pGen(G, 'spin_rsv', S)), vNetLoadFollowDown(B,T, G, S)] 
                                =g= %load_for_rsrv% * pSpinReserveLoadFract
                                    + pWindFlexDownForecast * sum[(G)$G_WIND(G), vPwrOut(B,T, G, S)]
                                    + pWindFlexDownCapacity * sum[(G)$G_WIND(G), %capacity_G%];
                                ;

* == Regulation Up (eRegUp) aka primary reserves
*  Handles second to second variations. Computed as a specified fraction of the load.
    eRegUp          (B,T, S)$B_SIM(B) .. sum[(G)$(pGen(G, 'reg_up', S)), vRegUp(B,T, G, S)] =g=
                            %load_for_rsrv% * pRegUpLoadFract;

* == Regulation Down (eRegDown) aka primary reserves
*  Handles second to second variations. Computed as a specified fraction of the load.
    eRegDown        (B,T, S)$B_SIM(B) .. sum[(G)$(pGen(G, 'reg_down', S)), vRegDown(B,T, G, S)] =g=
                            %load_for_rsrv% * pRegDownLoadFract;

*=== Reserve Capability by reserve class and unit
* Compute the maximum reserves per generator as a function of capabilities.
* Note: ePwrMaxFlexRsrv and ePwrMinFlexRsrv (above) ensure that we do not double count capacity
* These equations are only created for generators capable of supplying the specified service


* == Generator limits on Spinning Reserves (eSpinReserveMax) aka secondary reserves
* Based on commitment state if available. For non-UC plants, we use output power as a proxy
* for quantity/amount of committed generation
    eSpinReserveMax    (B,T,G,S)$( B_SIM(B)
                                 and pGen(G, 'spin_rsv', S) ) ..
                                    vSpinReserve(B,T,G,S)
                                    =l=
                                    pGen(G, 'spin_rsv', S)*(
                                        (vUnitCommit(B,T, G, S)*pGen(G, 'gen_size', S))$G_UC(G) +
                                        (vPwrOut(B,T, G, S) 
                                            + %non_uc_rsrv_up_offline% 
                                                * (%capacity_G% - vPwrOut(B,T, G, S))
                                        )$(not G_UC(G))
                                    );


* == Generator limits on Load Following Down (eNetLoadDownMax) aka primary reserves
* Based on commitment state if available. For non-UC plants, we use output power as a proxy
* for quantity/amount of committed generation
    eNetLoadFollowDownMax(B,T,G,S)$( B_SIM(B)
                                   and pGen(G, 'spin_rsv', S) ) ..
                                    vNetLoadFollowDown(B,T,G,S)
                                    =l=
                                    pGen(G, 'spin_rsv', S)*(
                                        (vUnitCommit(B,T, G, S)*pGen(G, 'gen_size', S))$G_UC(G) +
                                        (vPwrOut(B,T, G, S) 
                                            + %non_uc_rsrv_down_offline% 
                                                * (%capacity_G% - vPwrOut(B,T, G, S))
                                        )$(not G_UC(G))
                                    );

* == Generator limits on Regulation Up (eRegUpMax) aka primary reserves
* Based on commitment state if available. For non-UC plants, we use output power as a proxy
* for quantity/amount of committed generation
    eRegUpMax(B,T,G,S)$( B_SIM(B)
                       and pGen(G, 'reg_up', S) ) ..
                                    vRegUp(B,T,G,S)
                                    =l=
                                    pGen(G, 'reg_up', S)*(
                                        (vUnitCommit(B,T, G, S)*pGen(G, 'gen_size', S))$G_UC(G) +
                                        (vPwrOut(B,T, G, S) 
                                            + %non_uc_rsrv_up_offline% 
                                                * (%capacity_G% - vPwrOut(B,T, G, S))
                                        )$(not G_UC(G))
                                    );

* == Generator limits on Regulation Down (eRegDownMax) aka primary reserves
* Based on commitment state if available. For non-UC plants, we use output power as a proxy
* for quantity/amount of committed generation
    eRegDownMax(B,T,G,S)$( B_SIM(B)
                         and pGen(G, 'reg_down', S) ) ..
                                    vRegDown(B,T,G,S)
                                    =l=
                                    pGen(G, 'reg_down', S)*(
                                        (vUnitCommit(B,T, G, S)*pGen(G, 'gen_size', S))$G_UC(G) +
                                        (vPwrOut(B,T, G, S) 
                                            + %non_uc_rsrv_down_offline% 
                                                * (%capacity_G% - vPwrOut(B,T, G, S))
                                        )$(not G_UC(G))
                                    );

* == Generator limits on Quick Start (eQuickStartMax) aka tertiary reserves
* Here we care about the number of units that are OFF (rather than on as for other reserves). So
* we base the limit on available capacity minus that which is on-line. On-line quantity is based
* on commitment state if available. For non-UC plants, we use output power as a proxy
* for quantity/amount of committed generation.
$ifthen.no_qs not set no_quick_st
    eQuickStartMax(B,T,G,S)$( B_SIM(B)
                            and pGen(G, 'quick_start', S) ) ..
                            vQuickStart(B,T,G,S)
                            =l=
* Quick start capability times
                            pGen(G, 'quick_start', S)
                                *(
* Total available capacity
                                    %capacity_G% *
$ifthen set derate
                                        min( pGen(G, 'derate', S),
$else
                                        (
$endif
                                           pGenAvail(B,T, G, S)
                                        )
* Minus capacity already in use
                                    - (
                                        (vUnitCommit(B,T, G, S)*pGen(G, 'gen_size', S))$G_UC(G) +
                                        (vPwrOut(B,T, G, S))$(not G_UC(G))
                                      )
                                );
$endif.no_qs
$endif.sep_rsrv
