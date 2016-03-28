
$ontext
----------------------------------------------------
 Helper script to compute standardized powt-processing summary information for Advanced Power models  
	
  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   July 2011

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-07-15  22:00  bpalmintier   extracted from OpsLp.gms
  2  2011-07-20  15:00  bpalmintier   Corrected Renewable shedding calculations
  3  2011-09-22  16:22  bpalmintier   Added mip gap computation
  4  2011-09-28  04:15  bpalmintier   Corrected $if for pMipGap
  5  2011-10-09  12:15  bpalmintier   Added pUcIntEnabled
  6  2012-01-26  15:35  bpalmintier   Added scenario support for stochastic UC, multi-period planning, etc.
  7  2012-02-03  00:15  bpalmintier   Adjusted for carbon emissions by generator
  8  2012-02-18  22:45  bpalmintier   Corrected divide by zero error for startups of unbuilt gens
  9  2012-05-02  10:45  bpalmintier   Separate demand (D) into blocks (B) and time sub-periods (T)
-----------------------------------------------------
$offtext

PARAMETERS
pEnergyGen   (G, S)    "Electricity Generation by plant [TWh]"
pEnergyTotal    (S)    "Total electricity Generation for the system [TWh]"
pRenewableShed (B, T, G, S)    "Average Renewable energy shed during period [GWh/hr]"
pTotalRenewableShedByGen(G, S)    "Total Renewable energy shed for each generator [GWh]"
pTotalCarbonEmissions(S)        "Total carbon emissions [Kt CO2e]"

pCapTotal (G, S)       "Total installed capacity [GW]"
pRenewPercent(S)       "Percent of total energy from renewables"
$if set unit_commit pUcIntEnabled(G)   "Unit Commitment Integer enabled (1), disabled (0), or not unit_commit (na)"
$if set model_name $if set use_mip $if %use_mip% == yes  pMipGap "relative Mixed-Integer duality gap"
;

$ifthen defined vNewCapacity
	pCapTotal(G, S) = vNewCapacity.l(G, S)+pGen(G,'cap_cur', S);
$else
	pCapTotal (G, S) = pGen(G, 'cap_cur', S);
$endif

*Scale pEnergyGen from GWh to TWh
pEnergyGen(G, S) = sum[(B, T), vPwrOut.l(B, T, G, S)*pDemand(B, T, 'dur', S)]/1e3;
pEnergyTotal(S) = sum[(G), pEnergyGen(G, S)];
pRenewableShed(B, T,G,S)$(G_RPS(G)) = (pCapTotal(G, S)*pGenAvail(B, T, G, S) - vPwrOut.l(B, T, G, S));
pTotalRenewableShedByGen(G, S)$(G_RPS(G)) = sum[(B, T), pRenewableShed(B, T,G,S)*pDemand(B, T, 'dur',S)];
pTotalCarbonEmissions(S) = sum[(G), vCarbonEmissions.l(G, S)];

pRenewPercent(S) = sum[(G_RPS), pEnergyGen(G_RPS,S)] / pEnergyTotal(S);

$if set model_name $if set use_mip $if %use_mip% == yes pMipGap = abs((%model_name%.Objval - %model_name%.Objest)/%model_name%.Objval);

$ifthen set unit_commit
*Identify Unit Commitment State for each generator
* Default to na (not under unit commitment)
    pUcIntEnabled(G) = na;
* Set to zero for all gens under unit commitment (including continuous)
    pUcIntEnabled(G)$G_UC(G) = 0;
* Finally mark those under integer unit commitment with a 1
    pUcIntEnabled(G)$G_UC_INT(G) = 1;
$endif

$ifthen set startup
$ifthen.v declared vStartup
PARAMETERS
    pPerUnitStartUpCount(G, S)  "Average number of startups per generator type [starts/yr]"
    ;

    pPerUnitStartupCount(G, S)
        $(
$ifthen.fix_cap set fix_cap
            pGen(G, 'cap_cur', S)
$else.fix_cap
            vCapInUse.l(G,S)
$endif.fix_cap
            > 0)
        = 
        sum[(B, T), vStartup.l(B, T, G, S) /
$ifthen.fix_cap set fix_cap
                    pGen(G, 'cap_cur', S)
$else.fix_cap
                    vCapInUse.l(G,S)
$endif.fix_cap
                * pGen(G, 'gen_size', S)];
$endif.v
$endif

