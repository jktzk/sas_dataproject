* 
Programmed by: Joshua M Kotzker 
Programmed on: 2022-12-03
Programmed to: Submit as Final Exam Part 2
;
x "cd L:\ST445";
filename InputRaw "Data\BookData\BeverageCompanyCaseStudy";
libname InputDS "Data\BookData\BeverageCompanyCaseStudy";
libname Results "Results\FinalProjectPhase1";

x "cd S:\Documents\FinalExam";
libname Exam ".";


ods _all_ close;
ods listing;
ods noproctitle;
ods listing image_dpi = 300;
ods pdf file = "KotzkerFinalReport.pdf";

*activity 2.1 means summary;
title 'Activity 2.1';
title2 'Summary of Units Sold';
title3 'Single Unit Packages';
proc means data = Results.alldrinks sum min max nonobs ;
  where productCategory = 'Soda: Cola' and stateFips = 13 or statefips = 37 or stateFips = 45;
  class stateFips productName size unitSize;
  var unitssold;
run;
title;
title2;
title3;


*freq data for 2.3 had issues here;
proc freq data= Results.alldrinks;
  where index(productCategory,'Soda: Cola') ne 0 
      and (index(size,'12 oz') ne 0 or index(size,'liter') ne 0 or index(size,'20 oz') ne 0)
      and (stateFips = 13 or statefips = 37 or stateFips = 45);
  tables productName*stateFips*size;
run;

*bar graphs for 3.1;
title 'Activity 3.1';
title2 'Single-Unit 12 oz Sales' height = 8pt;
title3 'Regular, Non-Cola Sodas' height = 8pt;
*fix labels, double check observations, missing inputs opaque;
proc sgplot data = Exam.alldrinks;
  where index(productcategory,"Soda: Non-Cola") ne 0 
        and index(type,'Non-Diet') ne 0 
        and index(size,'12 oz') ne 0 
        and (stateFips = 13 or statefips = 37 or stateFips = 45);
  hbar statefips / response = unitssold stat = sum group = productName groupdisplay = cluster;
  keylegend / location = inside position = bottomright across = 1;
  xaxis label = 'Total Sold' values = (0 to 3000000 by 500000);
run;
title;
title2;
title3;

*grouped vbar graphs for 3.3;
title 'Activity 3.3';
title2 'Average Weekly Sales, Non-Diet Energy Drinks' height = 8pt;
title3 'For 8 oz Cans in Georgia' height = 8pt; 
*data skin =, key opaque, nolabel x axis, make weekly  ;
proc sgplot data= Results.alldrinks;
  where index(productcategory,"Energy") ne 0 
        and index(type,'Non-Diet') ne 0 
        and stateFips = 13
        and index(productname,'Mega') eq 0
        and (index(productname,'Big Zip-Berry') ne 0
            or index(productname,'Big Zip-Grape') ne 0
            or index(productname,'Zip-Berry') ne 0 
            or index(productname,'Zip-Grape') ne 0 
            or index(productname,'Zip-Orange') ne 0);
  vbar productname / response = unitssold stat = sum group = unitsize groupdisplay = cluster dataskin = sheen;
  keylegend / location = outside position = bottom across=3 opaque;
  xaxis display = (nolabel);
  yaxis label = 'Weekly Average Sales' values =(0 to 120 by 20);
run;
title;
title2;
title3;

*grouped vbar for 3.6;
title 'Activity 3.6';
title2 'Weekly Average Sales, Nutritional Water';
title3 'Single-Unit Packages';
*transparancy for wide bar match legend format;  
proc sgplot data= Results.act3_6results;
  hbar productname / response = unitssold_mean barwidth = .54 fillattrs=(color=red);
  hbar productname / response = unitssold_median barwidth = .9 fillattrs=(color=blue transparency=.4);
  xaxis label = 'Georgia, North Carolina and South Carolina';
  keylegend / location = inside position = topright across=1 noborder;
  yaxis display = (nolabel);
run;
title;
title2;
title3;


*summary for 4.1;
title 'Activity 4.1';
title2 'Weekly Sales Summaries';
title3 'Cola Products, 20 oz Bottles, Individual Units';
proc means data = Results.alldrinks mean median q1 q3 nonobs maxdec=0;
  where index(productcategory,"Soda: Cola") ne 0
        and index(size,'20 oz') ne 0 
        and unitsize = 1;
  class region type flavor;
  var unitssold;
  format unitssold ;
run;
title;
title2;
title3;

*histogram for 4.2;
title 'Activity 4.2';
title2 'Weekly Sales Distributions';
title3 'Cola Products, 12 Packs of 20 oz Bottles';
footnote 'All States';
proc sgpanel data = Results.alldrinks;
  where index(productcategory,"Soda: Cola") ne 0
        and index(size,'20 oz') ne 0
        and unitsize = 12;
  panelby region type / columns = 2 novarname;
  histogram unitssold / binstart = 125 binwidth = 250 scale=proportion;
  colaxis label = 'Units Sold';
  rowaxis display=(nolabel) valuesformat = percent7.;
run;
footnote;
title;
title2;
title3;

*https://documentation.sas.com/doc/en/vdmmlcdc/8.1/grstatproc/n0mjz9ktgnse58n14deqdvnnxarp.htm highlow documentation for 4.4 graph;

title 'Activity 4.4';
title2 'Cola: 20 oz Bottles, Individual Units';
title3 'Sales Inter-Quartile Ranges';
proc sgpanel data = Results.act4_4results ;
  panelby region type / columns = 2 novarname;
  highlow x = date high = unitssold_Q3 low = unitssold_Q1;
  format date MONYY.;
  colaxis interval = month;
run;
title;
title2;
title3;


*proc print for optional;
title 'Optional Activity';
title2 'Product Information and Categorization';

proc print data = Results.classification;
run;
title;
title2;


*panels for 5.5;
title 'Activity 5.5';
title2 'Sales North and South Carolina Sales in August';
title3 '12 oz, Single Unit, Cola Flavor';
*/transparent and change size;
proc sgpanel data = Results.act5_5results;
  where date ge 08/01/00 and date le 08/31/99;
  where statefips = 37 or statefips = 45;
  panelby type / columns = 1 novarname;
  hbar date / results = unitsales;
  colaxis label = 'Sales'
  keylegend / location = outside position = bottom across = 1;
run;
title;
title2;
title3;

*report data for 6.2;
title 'Activity 6.2';
title2 'Quarterly Sales Summaries for 12oz Single-Unit Products';
title3 'Maryland Only';

proc report data = Results.alldata;
  where statefips = 24
        and index(size,'12 oz') ne 0 
        and unitsize = 1;
  columns type productname date unitssold=median unitssold
          unitssold=low unitssold=high;
  rbreak after / summarize;
  define type / group 'Beverage Type';
  define productname / group 'Beverage Name';
  define date / group 'Quarter' format  = qtrr.;
  define median / median 'Median Weekly Sales';
  define unitssold / 'Units Sold';
  define low / min 'Lowest Weekly Sales';
  define high / max 'Highest Weekly Sales';
run;
title;
title2;
title3;


*left this for last, poor time management showing here. need to iterate across the row using a do while imagine, ran out of time;

data Exam.act7_1 (drop: i);
infile InputRaw(Sodas.csv) firstobs = 6 dsd truncover dlm=',';
input number flavor $ @;
do i = 1 to 9;
    input size;
run;



*proc report for 7.4. i had issues getting the date to go in order and have the styles align for the next few;
title 'Activity 7.4';
title2 'Quarterly Sales Summaries for 12oz Single-Unit Products';
title3 'Maryland Only';
proc report data = Results.alldata style(header) = [fontfamily ='Arial Black' backgroundcolor=grey55 color=vib];
  where statefips = 24
        and index(size,'12 oz') ne 0 
        and unitsize = 1;
  columns type productname date unitssold=median unitssold
          unitssold=low unitssold=high;
  rbreak after / summarize;
  define type / group 'Beverage Type';
  define productname / group 'Beverage Name';
  define date / group 'Quarter' format  = qtrr.;
  define median / median 'Median Weekly Sales';
  define unitssold / 'Units Sold';
  define low / min 'Lowest Weekly Sales';
  define high / max 'Highest Weekly Sales';
  compute date;
    if date = 1 and _break_ eq '' then do;
        call define(_row_,'style','style=[backgroundcolor =greyEE]');
    end;
    if date = 'II' then do;
        call define(_row_,'style','style=[backgroundcolor =greyFF]');
    end;
    if date = IV then do;
        call define(_row_,'style','style=[backgroundcolor =greyGG]');
    end;        
    if date = III  then do;
        call define(_row_,'style','style=[backgroundcolor =greyHH]');
    end;  
  endcomp;  
run;
title;
title2;
title3;


*proc report 7.5;
title 'Activity 7.5';
title2 'Quarterly Per-Capita Sales Summaries';
title3 '12oz Single-Unit Lemonade';
title4 'Maryland Only';
footnote 'Flagged Rows: Sales Less Than 7.5 per 1000 for Diet; Less Than 30 per 1000 for Non-Diet';
proc report data = Results.alldata style(header) = [fontfamily ='Arial Black' backgroundcolor=grey55 color=vib];
  where statefips = 24
        and index(size,'12 oz') ne 0 
        and unitsize = 1
        and index(productname,'Lemonade') ne 0;
  columns countyname type date unitssold salesPerThousand obs=edit;
  rbreak after / summarize;
  define date / group 'Quarter' format  = qtrr.;
  define type / group 'Product Type';
  define countyname / group 'County';
  define unitssold / 'Total Sales';
  define salesPerThousand / 'Sales per 1000';
  define edit /noprint;

  compute edit; edit=1;
    if index(type,'Non-Diet') ne 0 and salesperthousand lt 30 then do;
        call define(_row_,'style','style=[backgroundcolor =greyEE]');
        call define('_c5_','style','style=[color =cxFF3333]');
    end;
    else if salesperthousand lt 7.5 then do;
        call define(_row_,'style','style=[backgroundcolor =greyEE]');
        call define('_c5_','style','style=[color =cxFF3333]');
    end;  
  endcomp;  
run;
footnote;

title;
title2;
title3;
title4;
ods pdf close;
quit;
