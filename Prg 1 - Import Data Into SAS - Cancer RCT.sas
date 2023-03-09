*************	P	R	O	G	R	A	M		H	E	A	D	E	R	*****************
*****************************************************************************************
*																						*
*	PROGRAM:	Prg 1 - Import Data Into SAS - Cancer RCT.sas                           *
*	PURPOSE:	Create SAS data sets from all source data files                         *
*	AUTHOR:		Jud Blatchford															*
*	CREATED:	2017-08-06																*
*	                                                                                    *
*	COURSE:		BIOS 6680 - Data Management Using SAS                                   *
*	DATA USED:	Source.Scans                                                            *
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
*	Note:  Forward slashes are used for portability across operating environments   *;

%LET    CourseRoot = C:/Dropbox/2 - Education/7 - Teaching/1 - SAS/BIOS 6680 - Data Management Using SAS/4 - Projects/2018 Programming Project;
LIBNAME CanSrc  "&CourseRoot/Cancer RCT/Data/1_Source";
LIBNAME CanImpt "&CourseRoot/Cancer RCT/Data/2_Import";



*	Importing SAS Data    *;
DATA	CanImpt.Scans;
	SET	CanSrc.Scans;
	RUN;



*	Importing In-stream Data   *;
DATA	CanImpt.Sites;
	INFILE	DATALINES	DELIMITER = ',';
	INPUT	SiteCd
			SiteAbrv	:$4.
			SiteNm		:$35.	;
	DATALINES;
1,NJCC,New Jersey Cancer Center
2,OICR,Oregon Institute of Cancer Research
;



*	Importing Microsoft Excel Data   *;

*	Importing 'Laboratory.xlsx'   *;
LIBNAME NJCCLabs XLSX "&CourseRoot/Cancer RCT/Data/1_Source/Laboratory.xlsx";

DATA	CanImpt.Laboratory_2015;
	SET	NJCCLabs.NJCC___2015;
	RUN;

DATA	CanImpt.Laboratory_2016;
	SET	NJCCLabs.NJCC___2016;
	RUN;

LIBNAME NJCCLabs CLEAR;

*	Importing 'Lab Data.xls'   *;
LIBNAME OICRLabs EXCEL "&CourseRoot/Cancer RCT/Data/1_Source/Lab Data.xls";

DATA	CanImpt.Lab_Data_Pt1;
		SET	OICRLabs.'Pt_1$'N;
	RUN;

DATA	CanImpt.Lab_Data_Pt2;
		SET	OICRLabs.'Pt_2$'N;
	RUN;

DATA	CanImpt.Lab_Data_Pt3;
		SET	OICRLabs.'Pt_3$'N;
	RUN;

DATA	CanImpt.Lab_Data_Pt4;
		SET	OICRLabs.'Pt_4$'N;
	RUN;

DATA	CanImpt.Lab_Data_Pt5;
		SET	OICRLabs.'Pt_5$'N;
	RUN;

LIBNAME OICRLabs CLEAR;



*	Importing Microsoft Access Data   *;
LIBNAME	AEData	ACCESS	"&CourseRoot/Cancer RCT/Data/1_Source/AELog.accdb";	

DATA	CanImpt.AELog;
	SET	AEData.'Adverse Events'N;
	RUN;

LIBNAME	AEData	CLEAR;



*	Importing Column-Aligned Raw Data   *;
DATA	CanImpt.DM;
	INFILE	"&CourseRoot/Cancer RCT/Data/1_Source/DM.txt";
	INPUT	@1	ID		2.
			@3	GENDER	$6.
			@9	ETHNIC	$22.
			@35	RACE	$16.
			@51	DOB		MMDDYY10.;
	RUN;



*	Importing Delimited Raw Data   *;
DATA	CanImpt.Address;
	INFILE	"&CourseRoot/Cancer RCT/Data/1_Source/Address.csv"	DELIMITER = ','	MISSOVER	DSD;
	INPUT	ID			:$3.
			First		:$10.
			Middle		:$10.
			Last		:$20.
			Street_Num
			Street_Name	:$30.
			Zip
			HOME		:$14.
			CELL		:$12.	;
	RUN;



*	Importing Raw Data In Uncommon Structures   *;
DATA	CanImpt.Arms;
	INFILE	"&CourseRoot/Cancer RCT/Data/1_Source/Arms.dat"	DELIMITER = '|';
	INPUT	Subject_ID	:$4.
			START_DATE	:DATE9.
			Treat		:$9.	@@;
	RUN;

DATA	CanImpt.groups;
	INFILE	"&CourseRoot/Cancer RCT/Data/1_Source/groups.dat"	DELIMITER = ':,';

	INPUT	Treatment	:$21.
			pt_id		@;
		OUTPUT;

	INPUT	pt_id	@;
		OUTPUT;

	IF	_N_ = 1 THEN DO; * This is because the 1st record has 3 subjects, but the 2nd record only has 2 *;
		INPUT	pt_id;
		OUTPUT;
	END;

	RUN;

DATA	CanImpt.Demographics;
	INFILE	"&CourseRoot/Cancer RCT/Data/1_Source/Demographics.dat"	N = 2; * Specifies the number of records to keep in the input buffer *;
	INPUT		patient	2
				gender	3
				Hisp	4
				race	5
			#2	@1	BirthDt		$ 1-10	/* #2 instructs SAS to read from the 2nd record */
				@11	OnStudy		MMDDYY6.;
	RUN;

DATA	CanImpt.PatInfo;
	INFILE	"&CourseRoot/Cancer RCT/Data/1_Source/PatInfo.dat"	N = 3	DLMSTR='::'	MISSOVER DSD;
	INPUT		pat			:$4.
				pat_name	:$30.
			/	Address		:$50.
			#3	Phone_H		:$13.
				Phone_C		;
	RUN;



;	*';	*";	*/;	QUIT;	RUN;
*	End of Program   *; RUN;

