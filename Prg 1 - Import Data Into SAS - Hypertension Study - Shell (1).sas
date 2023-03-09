*************	P	R	O	G	R	A	M		H	E	A	D	E	R	*****************
*****************************************************************************************
*																						*
*	PROGRAM:	Prg 1 - Import Data Into SAS - Hypertension Study.sas                   *
*	PURPOSE:	Create SAS data sets from all source data files                         *
*	AUTHOR:		Jud Blatchford															*
*	CREATED:	2018-09-18																*
*	                                                                                    *
*	COURSE:		BIOS 6680 - Data Management Using SAS                                   *
*	DATA USED:	Source.Scans                                                            *
*	SOFTWARE:	SAS (r) Proprietary Software 9.4 (TS1M5)								*
*	MODIFIED:	DATE		BY	REASON													*
*				----------	---	-------------------------------------------------------	*
*				20YY-MM-DD	PJB															*
*	                                                                                    *
*****************************************************************************************
***********************************************************************************; RUN;


*   Instructions:
    1)  Change the path in the %LET statement to the location of the BIOS 6680 course root folder
    2)  Submit the %LET and LIBNAME statements below   *;
*	Note:  Forward slashes are used for portability across operating environments   *;

%LET    CourseRoot = C:\Users\Juan\Desktop\CU Classes\SAS\6688;
LIBNAME HypSrc  "&CourseRoot\Hypertension Study\Data\1_Source";
LIBNAME HypImpt "&CourseRoot\Hypertension Study\Data\2_Import";



*	Importing SAS Data    *;

DATA HypImpt.ndi;
SET HypSrc.ndi;
RUN;
proc print data= HypSrc.ndi;
run;
/*proc contents data = HypSrc.ndi;*/
/*run;*/

*	Importing In-stream Data   *;

DATA HypImpt.States;
INFILE DATALINES DELIMETER = ‘,’;
INPUT	StateNum
			StateCd		:$2.
			StateNm		:$20.	;
DATALINES;
15 IA Iowa
24 MS Mississippi
44 UT Utah
;

proc print data = HypImpt.States;
*	Importing Microsoft Excel Data   *;

*	Importing 'Utah Vitals.xlsx'   *;
PROC IMPORT
	DATAFILE = "&CourseRoot\Hypertension Study\Data\1_Source\Utah Vitals.xlsx"
	OUT = HypImpt.Utah_Vitals_2010
	DBMS = XLSX
	REPLACE;
SHEET = "Vitals10";
RUN;
PROC IMPORT
	DATAFILE = "&CourseRoot\Hypertension Study\Data\1_Source\Utah Vitals.xlsx"
	OUT = HypImpt.Utah_Vitals_2011
	DBMS = XLSX
	REPLACE;
SHEET = "Vitals11";
RUN;
PROC IMPORT
	DATAFILE = "&CourseRoot\Hypertension Study\Data\1_Source\Utah Vitals.xlsx"
	OUT = HypImpt.Utah_Vitals_2012
	DBMS = XLSX
	REPLACE;
SHEET = "Vitals12";
RUN;
PROC IMPORT
	DATAFILE = "&CourseRoot\Hypertension Study\Data\1_Source\Utah Vitals.xlsx"
	OUT = HypImpt.Utah_Vitals_2013
	DBMS = XLSX
	REPLACE;
SHEET = "Vitals13";
RUN;
PROC IMPORT
	DATAFILE = "&CourseRoot\Hypertension Study\Data\1_Source\Utah Vitals.xlsx"
	OUT = HypImpt.Utah_Vitals_2014
	DBMS = XLSX
	REPLACE;
SHEET = "Vitals14";
RUN;

LIBNAME UVital XLSX "";


*	Importing 'VIT_IA.xls'   *;
PROC IMPORT
DATAFILE = "&CourseRoot\Hypertension Study\Data\1_Source\VIT_IA.xls"
OUT = HypImpt.VIT_IA
DBMS = XLS
REPLACE;
RUN;
PROC PRINT DATA = HypImpt.Vit_ia;
run;
*	Importing Column-Aligned Raw Data   *;



*	Importing Delimited Raw Data   *;



*	Importing Raw Data In Uncommon Structures   *;



;	*';	*";	*/;	QUIT;	RUN;
*	End of Program   *; RUN;

