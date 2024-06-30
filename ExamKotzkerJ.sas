* 
Programmed by: Joshua M Kotzker 
Programmed on: 2022-11-25
Programmed to: Submit as Final Exam Part 1
;


x "cd L:\ST445";
filename InputRaw "Data\BookData\BeverageCompanyCaseStudy";
libname InputDS "Data\BookData\BeverageCompanyCaseStudy";
libname Results "Results";
libname Forms "Data";

x "cd S:\Documents\FinalExam";
libname Exam ".";


options nodate fmtsearch = (Forms);

*access shared filed and close library after making a local copy;

libname county access "L:\st445\Data\BookData\BeverageCompanyCaseStudy\2016Data.accdb";
data Exam.Counties;
  set county.counties;
run;
libname county clear;

*read in noncolasouth using only column input and one formatted;
data Exam.NonColaSouth;
    infile InputRaw("Non-Cola--NC,SC,GA.dat") truncover firstobs=7;
    input stateFips 1-2 countyFips 3-5@;
    attrib productname length = $200 size length=$200;
    input productname $ 6-25 size $ 26-35  Quantity 36-38 @39 date mmddyy10. unitssold 49-55;
run;



*read in energysouth using only list input. for the rest of the data steps I could not
figure out how to concat the sets together without correctly formatting / cleaning date before hand;
data Exam.EnergySouth;
    infile InputRaw("Energy--NC,SC,GA.txt") dsd truncover firstobs=2 dlm='09'x;
    input stateFips countyfips @;
    attrib productname length=$200 size length=$200;
    input productname : $ size $ Quantity date : date9. unitssold;
run;


*read in othersouth using list input;
data Exam.OtherSouth;
    infile InputRaw("Other--NC,SC,GA.csv") truncover firstobs=2 dlm=',';
    input stateFips countyfips @;
    attrib productname length=$ 200;
    input productname : $ size $ Quantity date : date9. unitssold;
run;

*read in noncolanorth using formatted input/;
data Exam.NonColaNorth(drop=_:);
    infile InputRaw("Non-Cola--DC-MD-VA.dat") truncover firstobs=5;
    input stateFips 2. @3 countyFips 3. @6 code $200. @31 _date $10. @;
    if index(_date,'/') = 3
      then date= input(_date,mmddyy10.);
    else date= input(_date,date9.);
    input @41 unitssold comma7.;
run;

*read in energy north using lisst input;/
data Exam.EnergyNorth(drop=_:);
    infile InputRaw("Energy--DC-MD-VA.txt") truncover firstobs=2 dlm='09'x;
    input stateFips countyfips code : $200. _date $10. @; 
    if index(_date,'/') = 3
      then date= input(_date,MMDDYY10.);
    else date= input(_date,DATE9.);
    input unitssold;
run;


*read in othernorth using list input;
data Exam.OtherNorth;
    infile InputRaw("Other--DC-MD-VA.csv") truncover firstobs=2 dlm=',';
    input stateFips countyfips code : $200. date : ANYDTDTE. unitssold;
run;


*/https://documentation.sas.com/doc/en/vdmmlcdc/8.1/lefunctionsref/n0rrwqm16uiv4vn1t0jj0jvidgao.htm#:~:text=The%20LOWCASE%20function%20copies%20the,altered%20value%20as%20a%20result.*/
concat vertical join for the 6 preliminary data sets. i recognize a lot of the cleaning is incorrect and far from an optimal way
to approach it. in hindsight i wish i had given myself much more time to complete this;
data Exam.AllDrinks(drop = code);
  attrib  statename            format= $50.      label= 'State Name'
          stateFips            format= BEST12.   label= 'State FIPS'
          countyName           format= $50.      label= 'County Name'
          countyFips           format= BEST12.   label= 'County FIPS'
          region               format= $8.       label= 'Region'
          productname                            label= 'Beverage Name'
          type                                   label= 'Beverage Type'
          flavor                                 label= 'Beverage Flavor'
          productCategory                        label= 'Beverage Category'
          productSubCategory                     label= 'Beverage Sub-Category'
          size                                   label= 'Beverage Volume'
          unitSize             format= BEST12.   label= 'Beverage Quantity'
          container                              label= 'Beverage Container'
          date                 format= DATE9.    label= 'Sale Date'
          unitsSold            format= COMMA7.   label= 'Units Sold'
        ;
  set Exam.NonColaNorth(in = inNZ)
      Exam.EnergyNorth (in = inNE)
      Exam.OtherNorth (in = inNO)
      InputDS.coladcmdva (in = inNC)
      Exam.NonColaSouth (in = inSZ)
      Exam.EnergySouth(in = inSE)
      Exam.OtherSouth(in = inSO)
      InputDS.colancscga(in = inSC)
      ;
      
      _rtype = 1*inNZ + 2*inNE + 3*inNO + 4*inNC + 5*inSZ + 6*inSE + 7*inSO + 8*inSC;


  if _rtype eq 1
    then region = 'North';
    else if _rtype eq 1
    then region = 'North';
    else region = 'South';
  if code ne '.' then do;
     productname = substr(code,3,1);
     format productname $prodnames.;
     end;
  productname = propcase(productname);
  if _rtype eq 1
     then productCategory = 'Soda: Non-Cola';
     else if _rtype eq 5
     then productCategory = 'Soda: Non-Cola';
     else if _rtype eq 2
            then productCategory = 'Energy';
     else if _rtype eq 6
            then productCategory = 'Energy';
     else if _rtype eq 4
            then productCategory = 'Soda: Cola';
     else if _rtype eq 8
            then productCategory = 'Energy';
     else if _rtype eq 3 then do;
            if scan(productname,2,' ') ='Water'
            then productCategory = 'Nutritional Water';
            else productCategory = 'Non-Soda Ades';
            end;
     else if _rtype eq 7 then do;
            if scan(productname,2,' ') ='Water'
            then productCategory = 'Nutritional Water';
            else productCategory = 'Non-Soda Ades';
            end;
  _dietcut = compress(productname,'Diet');
  _grapecut = compress(productname,'Grape');
  _orangecut = compress(productname,'Orange');
  _berryucut = compress(productname,'Berry');
  _lemonadecut = compress(productname,'Lemonade');
  _orangeadecut = compress(productname,'Orangeade');
  _cherrycolacut = compress(productname,'Cherry Cola');
  _colacut = compress(productname,'Cola');
  _vanillacolacut = compress(productname,'Vanilla Cola');
  _citrussplashcut = compress(productname, 'Citrus Splash');
  _grapefizzycut = compress(productname, 'Grape Fizzy');
  _zestycut = compress(productname, 'Professor Zesty');
  _orangefizzycut = compress(productname, 'Orange Fizzy');
  _llimecut = compress(productname, 'Lemon-Lime');


  if scan(_dietcut,1,3) = 'Big'
     then productSubCategory = 'Big Zip';
  if scan(_dietcut,1,3) = 'Mega'
     then productSubCategory = 'Mega Zip';
  if scan(_dietcut,1,3) = 'Zip'
     then productSubCategory = 'Zip';
  if productSubCategory ^= '' then
     if _grapecut = productname then
        if _orangecut then flavor = 'Berry';
        else flavor = 'Orange';
     else flavor = 'Grape';
  if _lemonadecut ^= productname then flavor = 'Lemonade';
  if _orangeadecut ^= productname then flavor = 'Orangeade';
  if _cherrycolacut ^= productname then flavor = 'Cherry cola';
  if _colacut ^= productname then flavor = 'Cola';
  if _vanillacolacut ^= productname then flavor = 'Vanilla Cola';
  if _citrussplashcut ^= productname then flavor = 'Citrus Splash';
  if _zestycut ^= productname then flavor = 'Zesty';
  if _orangefizzycut ^= productname then flavor = 'Orange Fizzy';
  if _llimecut ^= productname then flavor = 'Lemon-Lime';
  
  if productname = _dietcut
     then type = 'Non-Diet';
     else type = 'Diet';

  size = lowcase(size);
  _containercheck = compress(size,,'d');
  _sizecontainercheck = compress(size,,'ai');


  if _containercheck = 'liter'
  then container = 'Bottle'
  ;
  else if _sizecontainercheck = '20'
  then container = 'Bottle'
  ;
  else container = 'Can';

 
run;

*begin sorting for horizontal merge. I did not run any of the code below in fear of loosing too much time;
proc sort data = Exam.AllDrinks;
by state;
run;

proc sort data = Exam.Counties;
by state;
run;

*this is where a correct horizontal merge by state would go;
data Exam.AllData;
    attrib  popestimate2016      format= COMMA10.  label= 'Estimated Population in 2016'
            popestimate2017      format= COMMA10.  label= 'Estimated Population in 2017'
            salesPerThousand     format= 7.4       label= 'Sales per 1,000'
          ;
    merge AllDrinks
          Counties;
    by state;
    salesPerThousand = (unitssold / ((popestimate2016 + popestimate2017)/2)) * 1000;
run;

*below is where correct proc report sets for the activities would go, reported based on requested metrics and variables;
proc report data= Exam.AllData out= Exam.threesix;
  columns productname salesPerThousand;
  where productcategory = 'Water';
run;

proc report data = Exam.AllData out = Exam.fourfour;
  columns salesPerThousand type;
  where size = '20 oz';
run;

proc report data = Exam.allData out=Exam.optinalactivity;
  columns productname type productcategory productsubcategory flavor size container;
run;

proc report data = Exam.allData out=Exam.fivefive;
  columns date salesPerThousand state;
  where size = '12 oz';
  where flavor = 'Cola';
  where unitsize = 1;
run;







         
