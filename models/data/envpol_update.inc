
* Update to match MATLAB results, but allow direct control of new capacity
*  Update:  2012-02-07  21:05  bpalmintier   Scaled from MW to GW

pWACC = 0.08;
pPriceNonServed = 100000;
pDemandScale(S)=1.3401;

pRPS(S)=0.2;

*Existing Generation
pGenData('Nuclear', 'cap_cur') = 5.1386;
pGenData('Nuclear', 'cap_max') = 5.1386;
pGenData('Nuclear','gen_size') = 2.000;
pGenData('Coal', 'cap_cur') = 1.64052;
pGenData('Coal', 'cap_max') = 1.64052;
pGenData('Coal','gen_size') = 2.000;
pGenData('NG_CCGT', 'cap_cur') = 23.6904;
pGenData('NG_CCGT', 'cap_max') = 23.6904;
pGenData('NG_CCGT','gen_size') = 2.000;
pGenData('NG_ST', 'cap_cur') = 20.3725;
pGenData('NG_ST', 'cap_max') = 20.3725;
pGenData('NG_ST','gen_size') = 2.000;
pGenData('NG_Peak', 'cap_cur') = 4.05648;
pGenData('NG_Peak', 'cap_max') = 4.05648;
pGenData('NG_Peak','gen_size') = 2.000;

*New Generation
pGenData('New_Nuclear', 'cap_cur') = 18.000;
pGenData('New_Nuclear', 'cap_max') = pGenData('New_Nuclear', 'cap_cur');
pGenData('New_Nuclear','gen_size') = 2.000;
pGenData('New_Coal', 'cap_cur') = 6.000;
pGenData('New_NG_CCGT','cap_cur') = 4.000;
pGenData('New_NG_CT', 'cap_cur') = 0;
pGenData('Wind', 'cap_cur') = pGenData('Wind', 'cap_cur') + 30.000;
pGenData('Wind', 'cap_max') = pGenData('Wind', 'cap_cur');
pGenData('Wind','gen_size') = 2.000;
