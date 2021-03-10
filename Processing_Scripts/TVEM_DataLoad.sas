/******************************************************************************/
/****                          MouseTracking TVEM                          ****/
/******************************************************************************/
/* This script was written by Alaina Pearce in 2019 for the		      */
/* purpose of processing the DMK SC_mouse tracking food choice		      */
/* task. Specifically, loads and converts datasets for TVEM models	      */
/*									      */  
/*     Copyright (C) 2019 Alaina L Pearce		      		      */
/*									      */  
/*     This program is free software: you can redistribute it and/or modify   */
/*     it under the terms of the GNU General Public License as published by.  */
/*     the Free Software Foundation, either version 3 of the License, or      */
/*     (at your option) any later version.		     		      */
/*									      */  
/*     This program is distributed in the hope that it will be useful,	      */
/*     but WITHOUT ANY WARRANTY; without even the implied warranty of	      */
/*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the	      */
/*     GNU General Public License for more details.		      	      */
/*									      */ 
/*     You should have received a copy of the GNU General Public License      */
/*     along with this program.  If not, see <https://www.gnu.org/licenses/>. */

/* NOTE: must change file paths! 					      */
/* if have similar directory structure you can find-replace the following     */
/* string with your path: '/path/to/model/'				      */

ods listing;

/* Add Library for TVEM Macro */
*CHANGE path below to macro;
LIBNAME tvemdir "/path/to/model/OSF_PhysBeh_2019/Macro_TVEM_v311";

/* Point to macro */
*CHANGE path below to macro;
%INCLUDE "/path/to/model/OSF_PhysBeh_2019/Macro_TVEM_v311/Tvem_v311.sas";

/* Add library for Data */
*CHANGE path below to data;
LIBNAME datadir "/path/to/model/OSF_PhysBeh_2019/Data/Databases/";

/* allow SAS to continue to run in batch mode after syntax error */
options NOSYNTAXCHECK;

/******************************************/
/**   All Trials: Tstamp_nodelete   **/
/******************************************/

/* Load data */
*CHANGE path below;
PROC IMPORT
     DATAFILE="/path/to/model/OSF_PhysBeh_2019/Data/Databases/MouseTAngles_long.csv"
     OUT=DATADIR.angles_all
     DBMS=csv
     REPLACE;
     GETNAMES=YES;
     DATAROW=2;
RUN;

DATA DATADIR.angles_all;
     SET DATADIR.angles_all;
     
     IF sex = 'Girl' THEN sex_dummy = 1;
        ELSE sex_dummy = 0;
        
     IF Angle = 'NA' THEN Angle = '';
     
     Angle_num = input(Angle, 8.);

     SCSR_LDif_int = LikeDif*percSC_success;
     SCSR_HDif_int = HealthDif*percSC_success;
     SCSR_TDif_int = TasteDif*percSC_success;

     sex_LDif_int = LikeDif*sex_dummy;
     sex_HDif_int = HealthDif*sex_dummy;
     sex_TDif_int = TasteDif*sex_dummy;

     age_LDif_int = LikeDif*cAge_yr;
     age_HDif_int = HealthDif*cAge_yr;
     age_TDif_int = TasteDif*cAge_yr;

     BMIp_LDif_int = LikeDif*cBodyMass_p;
     BMIp_HDif_int = HealthDif*cBodyMass_p;
     BMIp_TDif_int = TasteDif*cBodyMass_p;

RUN;

*make dataset with only 4th quartile for SCSR;
DATA DATADIR.angles_allscsrQ1;
    SET DATADIR.angles_all;
    IF (percSC_success LT 0.42) THEN OUTPUT;
RUN;

*make dataset with only 1st quartile for SCSR;
DATA DATADIR.angles_allscsrQ4;
    SET DATADIR.angles_all;
    IF (percSC_success GT 0.57) THEN OUTPUT;
RUN;

*make dataset with only 2nd/3rd quartile for SCSR;
DATA DATADIR.angles_allscsrC;
    SET DATADIR.angles_all;
    IF (percSC_success GE 0.42 AND percSC_success LE 0.57) THEN OUTPUT;
RUN;

*make dataset for girls;
DATA DATADIR.angles_allF;
    SET DATADIR.angles_all;
    IF (sex = 'Girl') THEN OUTPUT;
RUN;

*make dataset for boys;
DATA DATADIR.angles_allM;
    SET DATADIR.angles_all;
    IF (sex = 'Boy') THEN OUTPUT;
RUN;

*make dataset with only 1st quartile for BMIp;
DATA DATADIR.angles_allBMIpQ1;
    SET DATADIR.angles_all;
    IF (cBodyMass_p LE 54) THEN OUTPUT;
RUN;

*make dataset with only 4th quartile for BMIp;
DATA DATADIR.angles_allBMIpQ4;
    SET DATADIR.angles_all;
    IF (cBodyMass_p Ge 95) THEN OUTPUT;
RUN;

*make dataset with only 2nd/3rd quartile for BMIp;
DATA DATADIR.angles_allBMIpC;
    SET DATADIR.angles_all;
    IF (cBodyMass_p GT 54 AND cBodyMass_p LT 95) THEN OUTPUT;
RUN;


*make dataset with only 1st quartile for Age;
DATA DATADIR.angles_allAgeQ1;
    SET DATADIR.angles_all;
    IF (cAge_yr LE 8.5) THEN OUTPUT;
RUN;

*make dataset with only 4th quartile for Age;
DATA DATADIR.angles_allAgeQ4;
    SET DATADIR.angles_all;
    IF (cAge_yr GE 10.5) THEN OUTPUT;
RUN;

*make dataset with only 2nd/3rd quartile for Age;
DATA DATADIR.angles_allAgeC;
    SET DATADIR.angles_all;
    IF (cAge_yr LT 10.5 AND cAge_yr GT 8.5) THEN OUTPUT;
RUN;


/******************************************/
/**  SC Trials: Tstamp_nodelete    **/
/******************************************/

/* Load data */
*CHANGE path below;
PROC IMPORT
     DATAFILE="/path/to/model/OSF_PhysBeh_2019/Data/Databases/MouseTAngles_SCoutcome_long.csv"
     OUT=DATADIR.angles_SC
     DBMS=csv
     REPLACE;
     GETNAMES=YES;
     DATAROW=2;
RUN;

DATA DATADIR.angles_SC;
     SET DATADIR.angles_SC;
     
     IF sex = 'Girl' THEN sex_dummy = 1;
        ELSE sex_dummy = 0;

     IF Angle = 'NA' THEN Angle = '';
     
     Angle_num = input(Angle, 8.);

     IF TrialType = 'SCgood' then TT_dummy = 1;
        ELSE TT_dummy = 0;
RUN;


/*********************************************/
/**   SCgood Trials: Tstamp_nodelete   **/
/*********************************************/

/* Load data */
*CHANGE path below;
PROC IMPORT
     DATAFILE="/path/to/model/OSF_PhysBeh_2019/Data/Databases/MouseTAngles_SCgood_long.csv"
     OUT=DATADIR.angles_SCgood
     DBMS=csv
     REPLACE;
     GETNAMES=YES;
     DATAROW=2;
RUN;

DATA DATADIR.angles_SCgood;
     SET DATADIR.angles_SCgood;

     IF sex = 'Girl' THEN sex_dummy = 1;
        ELSE sex_dummy = 0;
        
     IF Angle = 'NA' THEN Angle = '';

     Angle_num = input(Angle, 8.);

     SCSR_LDif_int = LikeDif*percSC_success;
     SCSR_HDif_int = HealthDif*percSC_success;
     SCSR_TDif_int = TasteDif*percSC_success;

     sex_LDif_int = LikeDif*sex_dummy;
     sex_HDif_int = HealthDif*sex_dummy;
     sex_TDif_int = TasteDif*sex_dummy;

     age_LDif_int = LikeDif*cAge_yr;
     age_HDif_int = HealthDif*cAge_yr;
     age_TDif_int = TasteDif*cAge_yr;

     BMIp_LDif_int = LikeDif*cBodyMass_p;
     BMIp_HDif_int = HealthDif*cBodyMass_p;
     BMIp_TDif_int = TasteDif*cBodyMass_p;
RUN;

*make dataset with only 4th quartile for SCSR;
DATA DATADIR.angles_SCgoodscsrQ1;
    SET DATADIR.angles_SCgood;
    IF (percSC_success LT 0.42) THEN OUTPUT;
RUN;

*make dataset with only 1st quartile for SCSR;
DATA DATADIR.angles_SCgoodscsrQ4;
    SET DATADIR.angles_SCgood;
    IF (percSC_success GT 0.57) THEN OUTPUT;
RUN;

*make dataset with only 2nd/3rd quartile for SCSR;
DATA DATADIR.angles_SCgoodscsrC;
    SET DATADIR.angles_SCgood;
    IF (percSC_success GE 0.42 AND percSC_success LE 0.57) THEN OUTPUT;
RUN;

*make dataset for girls;
DATA DATADIR.angles_SCgoodF;
    SET DATADIR.angles_SCgood;
    IF (sex = 'Girl') THEN OUTPUT;
RUN;

*make dataset for boys;
DATA DATADIR.angles_SCgoodM;
    SET DATADIR.angles_SCgood;
    IF (sex = 'Boy') THEN OUTPUT;
RUN;

*make dataset with only 1st quartile for BMIp;
DATA DATADIR.angles_SCgoodBMIpQ1;
    SET DATADIR.angles_SCgood;
    IF (cBodyMass_p LE 54) THEN OUTPUT;
RUN;

*make dataset with only 4th quartile for BMIp;
DATA DATADIR.angles_SCgoodBMIpQ4;
    SET DATADIR.angles_SCgood;
    IF (cBodyMass_p Ge 95) THEN OUTPUT;
RUN;

*make dataset with only 2nd/3rd quartile for BMIp;
DATA DATADIR.angles_SCgoodBMIpC;
    SET DATADIR.angles_SCgood;
    IF (cBodyMass_p GT 54 AND cBodyMass_p LT 95) THEN OUTPUT;
RUN;


*make dataset with only 1st quartile for Age;
DATA DATADIR.angles_SCgoodAgeQ1;
    SET DATADIR.angles_SCgood;
    IF (cAge_yr LE 8.5) THEN OUTPUT;
RUN;

*make dataset with only 4th quartile for Age;
DATA DATADIR.angles_SCgoodAgeQ4;
    SET DATADIR.angles_SCgood;
    IF (cAge_yr GE 10.5) THEN OUTPUT;
RUN;

*make dataset with only 2nd/3rd quartile for Age;
DATA DATADIR.angles_SCgoodAgeC;
    SET DATADIR.angles_SCgood;
    IF (cAge_yr LT 10.5 AND cAge_yr GT 8.5) THEN OUTPUT;
RUN;

/*********************************************/
/**  CHILD SCfail Trials: Tstamp_nodelete   **/
/*********************************************/

/* Load data */
*CHANGE path below;
PROC IMPORT
     DATAFILE="/path/to/model/OSF_PhysBeh_2019/Data/Databases/MouseTAngles_SCfail_long.csv"
     OUT=DATADIR.angles_SCfail
     DBMS=csv
     REPLACE;
     GETNAMES=YES;
     DATAROW=2;
RUN;

DATA DATADIR.angles_SCfail;
     SET DATADIR.angles_SCfail;

     IF sex = 'Girl' THEN sex_dummy = 1;
        ELSE sex_dummy = 0;
        
     IF Angle = 'NA' THEN Angle = '';

     Angle_num = input(Angle, 8.);

     SCSR_LDif_int = LikeDif*percSC_success;
     SCSR_HDif_int = HealthDif*percSC_success;
     SCSR_TDif_int = TasteDif*percSC_success;

     sex_LDif_int = LikeDif*sex_dummy;
     sex_HDif_int = HealthDif*sex_dummy;
     sex_TDif_int = TasteDif*sex_dummy;

     age_LDif_int = LikeDif*cAge_yr;
     age_HDif_int = HealthDif*cAge_yr;
     age_TDif_int = TasteDif*cAge_yr;

     BMIp_LDif_int = LikeDif*cBodyMass_p;
     BMIp_HDif_int = HealthDif*cBodyMass_p;
     BMIp_TDif_int = TasteDif*cBodyMass_p;
RUN;

*make dataset with only 4th quartile for SCSR;
DATA DATADIR.angles_SCfailscsrQ1;
    SET DATADIR.angles_SCfail;
    IF (percSC_success LT 0.42) THEN OUTPUT;
RUN;

*make dataset with only 1st quartile for SCSR;
DATA DATADIR.angles_SCfailscsrQ4;
    SET DATADIR.angles_SCfail;
    IF (percSC_success GT 0.57) THEN OUTPUT;
RUN;

*make dataset with only 2nd/3rd quartile for SCSR;
DATA DATADIR.angles_SCfailscsrC;
    SET DATADIR.angles_SCfail;
    IF (percSC_success GE 0.42 AND percSC_success LE 0.57) THEN OUTPUT;
RUN;

*make dataset for girls;
DATA DATADIR.angles_SCfailF;
    SET DATADIR.angles_SCfail;
    IF (sex = 'Girl') THEN OUTPUT;
RUN;

*make dataset for boys;
DATA DATADIR.angles_SCfailM;
    SET DATADIR.angles_SCfail;
    IF (sex = 'Boy') THEN OUTPUT;
RUN;

*make dataset with only 1st quartile for BMIp;
DATA DATADIR.angles_SCfailBMIpQ1;
    SET DATADIR.angles_SCfail;
    IF (cBodyMass_p LE 54) THEN OUTPUT;
RUN;

*make dataset with only 4th quartile for BMIp;
DATA DATADIR.angles_SCfailBMIpQ4;
    SET DATADIR.angles_SCfail;
    IF (cBodyMass_p Ge 95) THEN OUTPUT;
RUN;

*make dataset with only 2nd/3rd quartile for BMIp;
DATA DATADIR.angles_SCfailBMIpC;
    SET DATADIR.angles_SCfail;
    IF (cBodyMass_p GT 54 AND cBodyMass_p LT 95) THEN OUTPUT;
RUN;


*make dataset with only 1st quartile for Age;
DATA DATADIR.angles_SCfailAgeQ1;
    SET DATADIR.angles_SCfail;
    IF (cAge_yr LE 8.5) THEN OUTPUT;
RUN;

*make dataset with only 4th quartile for Age;
DATA DATADIR.angles_SCfailAgeQ4;
    SET DATADIR.angles_SCfail;
    IF (cAge_yr GE 10.5) THEN OUTPUT;
RUN;

*make dataset with only 2nd/3rd quartile for Age;
DATA DATADIR.angles_SCfailAgeC;
    SET DATADIR.angles_SCfail;
    IF (cAge_yr LT 10.5 AND cAge_yr GT 8.5) THEN OUTPUT;
RUN;