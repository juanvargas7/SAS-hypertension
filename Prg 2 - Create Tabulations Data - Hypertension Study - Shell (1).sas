*************	P	R	O	G	R	A	M		H	E	A	D	E	R	*****************
*****************************************************************************************
*																						*
*	PROGRAM:	Prg 2 - Create Tabulations Data - Hypertension Study.sas                *
*	PURPOSE:	Create Tabulations data sets from the source data                       *
*	AUTHOR:		JV EL ORIGINAL														*
*	CREATED:	2017-09-25																*
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

/*proc format library = HypTabs.HypFormats;*/
/*value $StateCd*/
/*	"IA"="Iowa"*/
/*	"MS"= "Mississippi"*/
/*	"UT" = "Utah";*/
/*run;*/
/*proc format library = HypTabs.HypFormats;*/
/*value $RaceCd */
/*	  "O"="Other"*/
/*	  "W"= "White"*/
/*	  "B"="Black"*/
/*	  "A"="Asian";*/
/*run;*/
/*proc format library = HypTabs.HypFormats;*/
/*value GenderCd*/
/*	1 = "Male"*/
/*	2 = "Female";*/
/*run; */
/*proc format library = HypTabs.HypFormats;*/
/*value $EthCd*/
/*	"H" = "Hispanic"*/
/*	"N" = "Non-Hispanic";*/
/*	run;*/
/*proc format library = HypTabs.HypFormats;*/
/*value $EthRaceCd */
/*	"HIS" = "Hispanic"*/
/*	"NHA" = "NH Asian"*/
/*	"NHB" = "NH Black"*/
/*	"NHO" = "Other Race"*/
/*	"NHW" = "NH White";*/
/*	run;*/
/*proc  format library = HypTabs.HypFormats;*/
/*value IndVbl*/
/*	1= "Yes"*/
/*	0="No";*/
/*	value CODCd*/
/*		. = "Unknown"*/
/*		1 = 'Heart Disease'*/
/*		2 = "Heart Failure"*/
/*		3 = "Stroke"*/
/*		4 = "Other COD"*/
/*		OTHER = 'Unanticipated Value';*/
/**/
/*;run;*/


%LET    CourseRoot = C:\Users\Juan\Desktop\CU Classes\SAS\6688;
LIBNAME HypImpt "&CourseRoot\Hypertension Study\Data\2_Import";
LIBNAME HypTabs "&CourseRoot\Hypertension Study\Data\3_Tabulations";



*	Setting System Options   *;
OPTIONS	FMTSEARCH = (HypTabs.HypFormats WORK LIBRARY)
		NOFMTERR
;run;



/*proc print data = HypImpt.States;run;*/
/*proc contents data = HypImpt.States;run;*/
*	DATA SET:  States   *;
DATA	HypTabs.States(LABEL = "Study States");
	SET	HypImpt.States;
	BY StateNum;
	LABEL StateNum = "State Number"
		  StateCd = 'State Code'
		  StateNm = 'State Name';


	RUN;
proc sort data = HypTabs.States;
by StateNum;run;
proc print data = HypTabs.States;run;
/*proc contents data = HypTabs.States;run;*/


  										*	DATA SET:  Contact   *;

									*	Creating data for Iowa   *;
/*proc print data = HypImpt.IowaResidents;run;*/
DATA	WORK.Contact_IA (LABEL ="Contact Information");
	SET	HypImpt.IowaResidents(RENAME =(City=Ct
										ZipCd = ZipCdd));
	LENGTH StateCd $ 2 Inits $ 3;
	FORMAT StateCd $StateCd.;
	RETAIN SSN Inits Ct ZipCode;

	IF State = "IOWA" THEN StateCd = "IA";
	City = PROPCASE(Ct," ");
	Inits =SCAN(Initials,-1,',')||SCAN(Initials,1,','); 
	ZipCd = PUT(ZipCdd,5.);
	KEEP SSN Inits City StateCd ZipCd;
	RUN;
/*proc print data = Work.Contact_IA;run;*/
/*proc contents data = Work.Contact_IA ;run;*/
proc sort data = Work.Contact_IA;
by SSN;
run;



									*	Creating data for Mississippi   *!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!;
/**/
proc print data = HypImpt.MS_Citizens;run;
DATA	WORK.Contact_MS (KEEP = SSN Inits City StateCd ZipCd);
	
	
	SET	HypImpt.MS_Citizens (RENAME = (SocSecNum = SSN));
	LENGTH City $ 20
		   Inits $ 3
		   StateCd $ 2;
    FORMAT StateCd $StateCd.;
	Inits = SUBSTR(FirstInit,1,1)||SUBSTR(MiddleInit,1,1)||SUBSTR(LastInit,1,1);
	City = SCAN(CityState,1,',');
	State = UPCASE(SCAN(CityState,2,','));
	IF State = " MISSISSIPPI" THEN StateCd = "MS";
	else StateCd = 'MS';*Esto es lo que se modifica;
	
	RUN;
proc sort data = Work.Contact_MS;
by SSN;
run;
proc print data = Work.Contact_MS;run;
/*proc contents data = Work.Contact_MS;run;*/



									*	Creating data for Utah   *!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!;  
/*proc print data = HypImpt.UT_Records;run;*/
/*proc contents data = HypImpt.UT_Records;run;*/
DATA	WORK.Contact_UT  (KEEP = SSN Inits City ZipCd StateCd IID);


	SET	HypImpt.UT_Records (RENAME= (Inits = Initials));
	LENGTH Inits $ 3
		    City $ 20
			StateCd $ 2
			SSN $ 11;
	FORMAT StateCd StateCd.;
	City= SCAN(CitySt,1,',');
	StateCd = SCAN(CitySt,-1,' ');
	ZipCd = ZipCode;
	IID = PUT(ID,z9.);
    Inits= TRANWRD(SCAN(Initials,1,'.')||SCAN(Initials,3,'.')||SCAN(Initials,2,'. ')," ","-");
	SSN = SUBSTR(IID,1,3)||'-'||SUBSTR(IID,4,2)||'-'||SUBSTR(IID,6,4);
	RUN;
proc sort data = Work.Contact_UT;
by SSN;
run;
/*proc print data = Work.Contact_UT;run;*/
/*proc contents data = Work.contact_UT;run;*/



					*	Creating Combined Data Set  DONE *;
DATA	HypTabs.Contact (LABEL = "Contact Information");
RETAIN SSN Inits City StateCd ZipCd;
	SET	WORK.Contact_IA 
		WORK.Contact_MS 
		WORK.Contact_UT;
	LABEL SSN = 'Social Security Number'
		  Inits = 'Subject Initials'
		  City = 'City'
		  StateCd = 'State Code'
		  ZipCd = 'Zip Code';
	DROP IID;
	RUN;
proc sort data = HypTabs.Contact;
by SSN ;
run;
proc print data = HypTabs.Contact;run;
proc contents data = HypTabs.Contact;run;


													*	DATA SET:  Demog   *;

									*	Creating data for Iowa   *!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!;
/*proc print data = HypImpt.IowaResidents;run;*/
/*proc contents data = HypImpt.IowaResidents;run;*/
DATA	WORK.Demog_IA(KEEP = SSN GenderCd EthCd RaceCd BirthDt EthRaceCd);

	SET	HypImpt.IowaResidents;	
	LENGTH EthCd $ 1
		   EthRaceCd $ 3
			RaceCd $ 1;
	FORMAT RaceCd $RaceCd. EthCd $EthCd.  BirthDt MMDDYYS10. GenderCd GenderCd. EthRaceCd $EthRaceCd.;
	IF Sex = "FEMALE" THEN GenderCd = 2;ELSE GenderCd = 1;
	RaceCd = SUBSTR(Race,1,1);
	IF Ethnicity = "HISPANIC" THEN EthCd = "H";ELSE EthCd = "N";
	EthRaceCdd = COMPRESS(CATX("",EthCd,RaceCd));
	IF EthRaceCdd = "NO" THEN EthRaceCd = "NHO";
	ELSE IF SUBSTR(EthRaceCdd,1,1) = "H" THEN EthRaceCd = "HIS";
	ELSE IF EthRaceCdd = "NA" THEN EthRaceCd = "NHA";
	ELSE IF EthRaceCdd = "NB" THEN EthRaceCd = "NHB";
	ELSE EthRaceCd = "NHW";
	
	RUN;
proc sort data = Work.Demog_IA;
BY SSN;
run;
/*proc print data = Work.Demog_IA;run;*/
/*proc contents data = Work.Demog_IA;run;*/


										*	Creating data for Mississippi   *;

/*proc print data = HypImpt.MS_Citizens;run;*/
/*proc contents data = HypImpt.MS_Citizens;run;*/
DATA	WORK.Demog_MS (KEEP = SSN GenderCd EthCd RaceCd BirthDt EthRaceCd);

	SET	HypImpt.MS_Citizens (RENAME = (SocSecNum = SSN));
	LENGTH  EthCd $ 1 
			EthRaceCd $ 3 
			RaceCd $ 1;
	FORMAT RaceCd $RaceCd. GenderCd GenderCd. EthCd $EthCd. EthRaceCd $EthRaceCd. BirthDt MMDDYYS10. ;

	IF SUBSTR(Gender,1,1) = "M" THEN GenderCd = 1;ELSE GenderCd = 2;
	IF SUBSTR(Eth,1,1) = "N" THEN EthCd = "N";ELSE EthCd = "H";
	IF SUBSTR(Racial,1,1) = "A" THEN RaceCd = "B";ELSE RaceCd = "W";
	BirthDt = INPUT(DOB,date9.);
	EthRaceCdd = COMPRESS(CATX("",EthCd,RaceCd));
	IF EthRaceCdd = "NO" THEN EthRaceCd = "NHO";
	ELSE IF SUBSTR(EthRaceCdd,1,1) = "H" THEN EthRaceCd = "HIS";
	ELSE IF EthRaceCdd = "NA" THEN EthRaceCd = "NHA";
	ELSE IF EthRaceCdd = "NB" THEN EthRaceCd = "NHB";
	ELSE EthRaceCd = "NHW";
	RUN;
proc sort data = Work.Demog_MS;
by SSN;
run;
proc print data = Work.Demog_MS;run;
/*proc contents data = Work.Demog_MS;run;*/
proc freq data = work.demog_ms;run;
															*	Creating data for Utah   *;
/*proc print data = HypImpt.UT_Records;run;*/
/*proc contents data = HypImpt.UT_Records;run;*/
DATA	WORK.Demog_UT (KEEP =  SSN GenderCd EthCd RaceCd BirthDt EthRaceCd ID);

	SET	HypImpt.UT_Records(RENAME=(EthnicityCode = EthCd 
									RaceCode=RaceCd));
	LENGTH EthRaceCd $ 3
			SSN $ 11;
	FORMAT RaceCd $RaceCd. GenderCd GenderCd. EthCd $EthCd. EthRaceCd $EthRaceCd. BirthDt MMDDYYS10. ;

	IDD = PUT(ID,z9.);
	SSN = CATX('-',SUBSTR(IDD,1,3),SUBSTR(IDD,4,2),SUBSTR(IDD,6,4));
	IF GenderCode = "M" THEN GenderCd = 1; ELSE GenderCd = 2;
	BirthDt = INPUT(COMPRESS(PUT(BirthMonth,z2.)||PUT(BirthDay,z2.)||PUT(BirthYear,4.)),MMDDYY8.);
	EthRaceCdd = COMPRESS(CATX("",EthCd,RaceCd));
	IF EthRaceCdd = "NO" THEN EthRaceCd = "NHO";
	ELSE IF SUBSTR(EthRaceCdd,1,1) = "H" THEN EthRaceCd = "HIS";
	ELSE IF EthRaceCdd = "NA" THEN EthRaceCd = "NHA";
	ELSE IF EthRaceCdd = "NB" THEN EthRaceCd = "NHB";
	ELSE EthRaceCd = "NHW";	

	RUN;
proc sort data = Work.Demog_UT;
by SSN;
run;
/*proc print data = Work.Demog_UT;run;*/
/*proc contents data = Work.Demog_UT;run;*/

									*	Creating Combined Data Set   *;

DATA	HypTabs.Demog (LABEL = "Demographics");
	RETAIN SSN GenderCd EthCd RaceCd EthRaceCd BirthDt;
	SET	WORK.Demog_IA
		WORK.Demog_MS
		WORK.Demog_UT;

	by SSN;
	LABEL SSN = 'Social Security Number'
		  GenderCd = 'Gender Code'
			EthCd = 'Ethnicity Code'
			RaceCd = 'Race Code'
			EthRaceCd = 'Ethnicity/Race Code'
			BirthDt = 'Birth Date';
DROP ID;
	RUN;
proc sort data = HypTabs.Demog;
by SSN;
run;
proc print data = HypTabs.Demog;run;
proc contents data = HypTabs.Demog;run;


										*	DATA SET:  Vitals   *;

									*	Creating data for Iowa   *@@@@@@@@@@@@@@@@@@@@@@@^^^^^^^^^^^^^;

/*proc print data = HypImpt.Vit_IA;run;*/
/*proc contents data = HypImpt.Vit_IA;run;*/
DATA	WORK.Vitals_IA(KEEP = SSN VisitDt HtIn WtLb SBP DBP);	
SET	HypImpt.Vit_IA;

	
	FORMAT VisitDt date9. HtIn 2. WtLb 3.;
	
	HtIn = HtCm*(0.394);
	WtLb = WtKg*(2.205);
	RUN;
proc sort data = Work.Vitals_IA;
by SSN VisitDt;
run;
/*proc print data = Work.Vitals_IA;run;*/
/*proc contents data = Work.Vitals_IA;run;*/



							*	Creating data for Mississippi   *;
/*proc print data = HypImpt.Mississippi_VS;run;*/
DATA	WORK.Vitals_MS(KEEP = SSN VisitDt HtIn WtLb SBP DBP);

	SET	HypImpt.Mississippi_VS(RENAME=(VisitDate = VisitDt
										Height = HtIn
										Weight = WtLb));
	FORMAT EthCd $EthCd. VisitDt date9.;
	length SSN $ 11.;
	

	RUN;
proc sort data = Work.Vitals_MS;
by SSN VisitDt;
run;
/*proc print data = Work.Vitals_MS;run;*/
/*proc contents data= Work.Vitals_MS;run;*/


								*	Creating data for Utah   *;

data Work.Sorting;
set HypImpt.Utah_vitals_2010 - HypImpt.Utah_vitals_2014 (RENAME = (SSN = SSNN));
LENGTH SSN $11;
SSN = CATX('-',SUBSTR(SSNN,1,3),SUBSTR(SSNN,4,2),SUBSTR(SSNN,6,4));
run;
proc sort data = Work.Sorting;
by SSN;
run;
/*proc print data = Work.Sorting;run;*/
proc contents data = Work.Sorting;run;

/*proc print data = HypImpt.Utah_vitals_2010;run;*/
/*proc contents data = HypImpt.Utah_vitals_2010;run;*/

DATA	WORK.Vitals_UT (DROP =SSNN);
	SET Work.Sorting;
	by SSN ApptDate;
	Length SSN $ 11.;

	RETAIN SSN ApptDate HtIn WtLb SBP DBP;
	ARRAY Test{4} DBP HtIn SBP WtLb;
	IF FIRST.ApptDate = 1 THEN CALL MISSING(OF Test{*});
INDEX = 1*(Measure = 'Diastolic BP')+
	    2*(Measure = 'Height (In)')+
		3*(Measure = 'Systolic BP')+
		4*(Measure = 'Weight (Lb)');
Test{Index} = Value;
IF LAST.ApptDate=1;
RENAME ApptDate= VisitDt;
DROP VALUE Index Measure;
FORMAT VisitDt date9.;
run;
proc sort data = work.Vitals_UT;
by SSN VisitDt;run;

/*proc print data = Work.Vitals_UT;run;*/
/*proc contents data = Work.Vitals_UT;run;*/


/* Sort data set */

/* Re-structure data set */





*	Creating Combined Data Set   *;
DATA	HypTabs.Vitals (LABEL = "Vital Signs");
RETAIN SSN VisitDt HtIn WtLb SBP DBP;
LENGTH SSN $ 11;
	SET	WORK.Vitals_IA
		WORK.Vitals_MS
		WORK.Vitals_UT;
		
	
	LABEL SSN = 'Social Security Number'
		  VisitDt = 'Visit Date'
			HtIn = 'Height (In)'
			WtLb='Weight (Lb)'
			SBP = 'Systolic BP (mmHg)'
			DBP = 'Diastolic BP (mmHg)';
	RETAIN SSN VisitDt HtIn WtLb SBP DBP ;
	RUN;
proc sort data = HypTabs.Vitals;
by SSN VisitDt;
run;
proc print data = HypTabs.Vitals;run;
proc contents data = HypTabs.Vitals;run;
/* Sort final data set */




											*	DATA SET:  NDI   *;
/*proc print data = HypImpt.NDI;run;*/
/*proc contents data = HypImpt.NDI;run;*/
DATA HypTabs.NDI (LABEL = "Death Data");
	SET	HypImpt.NDI;
	RETAIN SSN DeathDt ICD10 CODCd HypRelDeathInd;
	FORMAT HypRelDeathInd IndVbl. CODCd CODCd.;
	
	LABEL SSN = "Social Security Number"
		  DeathDt = "Death Date"
			ICD10= "ICD 10 Code"
			CODCd = "Cause of Death Code"
			HypRelDeathInd = "Hypertension-Related Death";
	cd = SUBSTR(ICD10,1,3);
	 IF cd = "I63" THEN CODCd = 3;
	ELSE IF cd = "I50" THEN CODCd = 2;
	ELSE IF cd = "I25" THEN CODCd = 1;
	ELSE CODCd = 4;
	
	IF CODCd IN (1,2,3)  THEN HypRelDeathInd = 1;
	ELSE HypRelDeathInd = 0;
	keep SSN DeathDt ICD10 CODCd HypRelDeathInd;
	RUN;
PROC SORT data = HypTabs.NDI;
by SSN;
run;
proc print data = HypTabs.NDI;run;
proc contents data = HypTabs.NDI;run;
proc freq data= HypTabs.NDI;
tables CODCd HypRelDeathInd;run;

;	*';	*";	*/;	QUIT;	RUN;
*	End of Program   *; RUN;

