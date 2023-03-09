*************	P	R	O	G	R	A	M		H	E	A	D	E	R	*****************
*****************************************************************************************
*																						*
*	PROGRAM:	Prg 3 - Analysis and Report - Hypertension Study.sas                    *
*	PURPOSE:	Create 'HypAnalysis2' data set, perform analyses, and create report     *
*	AUTHOR:		Jud Blatchford															*
*	CREATED:	2018-11-14																*
*	                                                                                    *
*	COURSE:		BIOS 6680 - Data Management Using SAS                                   *
*	DATA USED:	Tabs. Demog, Contact, Vitals, NDI                                       *
*	SOFTWARE:	SAS (r) Proprietary Software 9.4 (TS1M4)								*
*	MODIFIED:	DATE		BY	REASON													*
*				----------	---	-------------------------------------------------------	*
*				20YY-MM-DD	PJB															*
*	                                                                                    *
*****************************************************************************************
***********************************************************************************; RUN;


*   Instructions:
    1)  Change the path in the %LET statement to the location of the BIOS 6680 course root folder
    2)  Submit the %LET and LIBNAME statements below   *;
%LET	CourseRoot = C:\Users\Juan\Desktop\CU Classes\SAS\6688;
LIBNAME HypTabs	"&CourseRoot/Hypertension Study/Data/3_Tabulations";
LIBNAME HypAnl "&CourseRoot/Hypertension Study/Data/4_Analysis";
libname HypRslt "&CourseRoot/Hypertension Study/Data/5_Results";
OPTIONS	FMTSEARCH = (CanTabs.CanFormats WORK LIBRARY HypTabs.HypFormats)
		NOFMTERR;

*	Step 1: Create 'HypAnl.HypAnalysis2' Data Set   *; RUN;

*	Create a temporary data set containing the most recent visit for each person   *;
data work.temp;
set hyptabs.vitals;
run;
proc sql; * Only Using the ones in recent visit date;
create table Work.Recent as
select *
from work.temp
group by SSN
having VisitDt = MAX(VisitDt)
;
quit;
proc print data =work.recent;run;
*	Match-merge 4 data sets together to create the 'HypAnalysis2' Data Set   *;
proc print data = HypTabs.COntact;run;
data HypAnl.HypAnalysis2;
merge HypTabs.Contact (IN= InContact)
 Work.Recent (IN= InVitals)
 HypTabs.Demog (IN = InDemog)
 HypTabs.NDI (IN = InNDI);
by SSN;
AgeAtVisit = (VisitDt - BirthDt)/365;
if InVitals = 1 AND InDemog = 1 AND InContact = 1;

/*if InNDI = . then HypRelDeathInd =0;*/
/* if InNDI = 0 then HypRelDeathInd = 0;*/
/*else if InNDI = 1 then HypRelDeathInd = 1;*/
if InVitals = 1 and InDemog = 1 and InContact = 1 and InNDI = 0 then HypRelDeathInd = 0;

keep SSN StateCd GenderCd EthCd RaceCd AgeAtVisit SBP DBP WtLb HypRelDeathInd ;
format AgeAtVisit 2.0;
run;
proc contents data = HypAnl.HypAnalysis2;run;
proc freq data= HypAnl.HypAnalysis2;
tables HypRelDeathInd;run;
proc print data = HypAnl.HypAnalysis2;run;
*	Step 2: Perform a Chi-Square Test and Save the Results   *; RUN;

ods trace on;
proc freq data = HypAnl.HypAnalysis2;
tables HypRelDeathInd *StateCd / cumcol nopercent norow chisq;
run;
ods trace off;

ODS PATH WORK.TEMPLAT(UPDATE) SASHELP.Tmplmst(READ);
proc template;
  edit Base.Freq.CrossTabFreqs;  
	edit Percent;
	  format=7.4 ;           
	end;
	edit ColPercent;
	  format=7.4 ;
	end;
  end;
run;

ODS OUTPUT	CrossTabFreqs = HypRslt.StatePercents (keep = StateCd HypRelDeathInd Frequency ColPercent 
Where = (HypRelDeathInd =1 and missing(StateCd)=0));
ods output ChiSq = HypRslt.ChisqResults (drop =Table where = (Statistic = 'Chi-Square'));
proc freq data = HypAnl.HypAnalysis2;
tables HypRelDeathInd *StateCd / cumcol nopercent norow chisq;
run;

proc template;
  delete Base.Freq.CrossTabFreqs;
run;

proc print data = HypRslt.StatePercents;run;
/*proc print data = HypRslt.StatePercents;run;*/
/*proc print data = HypRslt.ChisqResults;run;*/
/*proc print data = work.try;run;*/
*	Step 3: Create a Vertical Bar Chart   *; RUN;

title "Hypertension-Related Death Rates By State";
footnote 'Created by Juan Vargas';
PROC SGPLOT data = HypRslt.StatePercents noautolegend;

refline 1.8 / axis = Y
			   label = 'National Average = 1.8'
				labelloc= INSIDE
				labelpos = MAX
				lineattrs = (Color = INDIGO
								pattern = shortdash
								thickness = 1);

vbar StateCd / response = colpercent 
				datalabel 
				stat = sum
				group = HypRelDeathInd
				fillattrs= (color = lightsalmon);
yaxis 
	offsetmin = 0
	labelattrs = (weight = bold)
	values = (0 to 4 by 1 )
	label = "Percent"
	valueattrs = (weight = bold)
	grid;

xaxis offsetmin = 0.25
	label = 'State Code'
	labelattrs = (weight = bold)
	grid;

format StateCd $StateCd.;

run;
title;
footnote;


*	Step 4: Write a Macro named 'RunANOVA' to Perform an ANOVA and Save the Results   *; RUN;

*	Step 4.1: Write PROC ANOVA code which will perform a single ANOVA   *;
/*ODS OUTPUT;*/
/*PROC ANOVA data =;*/
ods trace on;
proc anova data = HypAnl.HypAnalysis2;
class StateCd;
Model  DBP = StateCd;
run;
quit;
ods trace off;

ods output  ModelAnova = Work.hi;
proc anova data = HypAnl.HypAnalysis2;
class StateCd;
Model  DBP = StateCd;
run;
quit;
proc print data = Work.hi;run;
*	Step 4.2: Put the code from Step 4.1 inside a macro definition which specifies 2
				macro variables, named 'Number' and 'Variable'

	Step 4.3: Modify the code to incorporate the 2 macro variables   *;

%MACRO RunANOVA (Number = , Variable =);
ODS OUTPUT ModelANOVA = Work.ANOVAResults&Number.;
proc anova data = HypAnl.HypAnalysis2;
class StateCd;
Model &Variable = StateCd;
run;
quit;
%MEND RunANOVA;

*	Run the 'RunANOVA' macro 4 times!
		It should be run for 1) AgeAtVisit, 2) SBP, 3) DBP, and 4) WtLb   *;
%RunANOVA (Number= 1, Variable = AgeAtVisit)
%RunANOVA (Number= 2, Variable = SBP)
%RunANOVA (Number= 3, Variable = DBP)
%RunANOVA (Number= 4, Variable = WtLb)

;*	Combine the 4 saved data sets into a single data set named 'HypRslt.ANOVAResults'   *;
DATA HypRslt.ANOVAResults (keep = Dependent FValue ProbF);
set work.ANOVAResults:;
run;
proc print data = HypRslt.ANOVAResults;run;



*	Step 5: Create a Report   *; RUN;
*			Material from Lecture 5.2   *;

Options nodate number;
ODS PDF file = "C:\Users\Juan\Desktop\CU Classes\SAS\6688\Prg 3 – Analysis Report – Hypertension Study.pdf";
title "Chi-Square Test of Independence Results";
footnote 'Created by Juan Vargas';
proc report data = HypRslt.Chisqresults;
column Statistic ("Statistical Results" (DF Value Prob));
define Statistic / 'Test';
define Prob / format = 4.2 'P-Value';
define Value / format = 4.2;
run;
title;
footnote;
*	Use PROC REPORT to display the results of the Chi-Square test (from 'HypRslt.ChiSqResults')   *;


*	Copy-and-paste the code from Step 3 to include the figure in the report   *;

title "Hypertension-Related Death Rates By State";
footnote 'Created by Juan Vargas';
PROC SGPLOT data = HypRslt.StatePercents noautolegend;

refline 1.8 / axis = Y
			   label = 'National Average = 1.8'
				labelloc= INSIDE
				labelpos = MAX
				lineattrs = (Color = INDIGO
								pattern = shortdash
								thickness = 1);

vbar StateCd / response = colpercent 
				datalabel 
				stat = sum
				group = HypRelDeathInd
				fillattrs= (color = lightsalmon);
yaxis 
	offsetmin = 0
	labelattrs = (weight = bold)
	values = (0 to 4 by 1 )
	label = "Percent"
	valueattrs = (weight = bold)
	grid;

xaxis offsetmin = 0.25
	label = 'State Code'
	labelattrs = (weight = bold)
	grid;

format StateCd $StateCd.;

run;
title;
footnote;

*	Use PROC PRINT to include the 4 ANOVA results (from 'HypRslt.ANOVAResults')   *;
title "Analysis of Variance Results";
footnote1 "Created by Juan Vargas";
proc print data = HypRslt.ANOVAResults obs= 'Variable' split = '*';
label Dependent = 'Variable*Name'
		FValue = 'F*Statistic'
		ProbF = 'P-Value';
		run;
title;
footnote;

ODS PDF CLOSE;




;	*';	*";	*/;	QUIT;	RUN;
*	End of Program   *; RUN;

