Import Market Data From The Fred rent home prices income cpi

github
https://tinyurl.com/yb7x7d4n
https://github.com/rogerjdeangelis/utl-import-market-data-from-the-fred-rent-home-prices-income-cpi

SAS  Forum
https://tinyurl.com/y8s6hwfn
https://communities.sas.com/t5/SAS-Programming/The-SASEFRED-engine-cannot-be-found/m-p/528519

Source for code
http://lenkiefer.com/2017/04/11/fred-plot/

Related Yahoo finance
https://github.com/rogerjdeangelis/utl-using-r-quantmod-and-yahoo-finance-to-get-the-latest-stock-stats

INPUT
=====

 Online FRED data

                                    DATA DESCRIPTIONS

     VAR           NAME               DESCRIPTION                           SOURCE

  CUUR0000SEHA     cpi.rent           CPI-U Rent of primary residences      U.S. Bureau of Labor Statistics
  HPIPONM226S      hpi                FHFA Purchase-only house price index  Federal Housing Finance Agency (FHFA)
  A229RC0         income              Per capita disposable income          U.S. Bureau of Economic Analysis
  CUSR0000SA0L2    cpi.less.shelter   CPI-U All items less shelter          U.S. Bureau of Labor Statistics


EXAMPLE OUTPUT  (monthly 1915-- Present)
=========================================

 WORK.WANT total obs=1,249


               CPIU_     FHFA_HOUSE_    PER_CAPITA_     CPIU_ITEMS_
   DATE         RENT     PRICE_INDEX       INCOME      LESS_SHELTER

 01JAN2017    303.467       240.15         44738          227.313
 01FEB2017    304.211       242.21         44930          227.119
 01MAR2017    304.868       243.55         45052          226.383
 01APR2017    305.477       245.34         45063          226.571
 01MAY2017    306.379       246.29         45225          226.063
 01JUN2017    307.314       247.05         45202          225.930
 01JUL2017    308.173       248.56         45332          226.005
 01AUG2017    309.479       250.40         45492          226.965
 01SEP2017    310.268       251.66         45685          228.261
 01OCT2017    311.501       253.56         45857          228.168
 01NOV2017    312.670       254.84         45978          229.060
 01DEC2017    313.904       256.24         46114          229.384

PROCESS
=======

%utl_submit_r64("
library(quantmod);
library(SASxport);
df= getSymbols('CUUR0000SEHA',src='FRED', auto.assign=F);
dfcuu = data.frame(date=time(df), coredata(df) );
dfhpi =getSymbols('HPIPONM226S',src='FRED', auto.assign=F);
dfhpi = data.frame(date=time(dfhpi), coredata(dfhpi) );
dfinc=getSymbols('A229RC0',src='FRED', auto.assign=F);
dfinc = data.frame(date=time(dfinc), coredata(dfinc) );
dfcus= getSymbols('CUSR0000SA0L2',src='FRED', auto.assign=F);
dfcus = data.frame(date=time(dfcus), coredata(dfcus) );
write.xport(dfcuu,dfhpi,dfinc,dfcus,file='d:/xpt/finance.xpt');
");

data want(rename=(
   CUUR0000 = CPIU_Rent
   HPIPONM2 = FHFA_house_price_index
   A229RC0  = Per_capita_income
   CUSR0000 = CPIU_items_less_shelter));

  retain date;
  label
    CUUR0000 = 'CPI-U Rent of primary residences'
    HPIPONM2 = 'FHFA Purchase-only house price index'
    A229RC0  = 'Per capita disposable income'
    CUSR0000 = 'CPI-U All items less shelter'
    ;
   format date date9.;
   if _n_=0 then do; %let rc=%sysfunc(dosubl('
      data DFCUU; set xpt.DFCUU;run;quit;
      data DFHPI; set xpt.DFHPI;run;quit;
      data DFINC; set xpt.DFINC;run;quit;
      data DFCUS; set xpt.DFCUS;run;quit;
      '));
   end;

   merge DFCUU DFHPI DFINC DFCUS;
   by date;

run;quit;


proc print data=want(where=('01JAN2017'd<=date<='31DEC2017'd)) width=min;
run;quit;

OUTPUT (see above)


