/******************************************************************************/
/****                          MouseTracking TVEM                          ****/
/******************************************************************************/
/* This script was written by Alaina Pearce in 2019 for the		      */
/* purpose of processing the DMK SC_mouse tracking food choice		      */
/* task. Specifically, runs the final TVEM models in SAS.		      */
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


/* Create pdf of results */
ods _all_ close;

options nonumber nodate;
ods pdf style=printer printer=pdfa
    file="/path/to/model/TVEM_FinalModels_MainAnalyses_output.pdf"
    contents=yes pdftoc=2;
ods startpage=bygroup;
ods trace on;
ods noproctitle;
ods escapechar = '^';

/* Add Library for TVEM Macro */
LIBNAME tvemdir "/path/to/model/Macro_TVEM_v311";

/* Add library for Data */
LIBNAME datadir "/path/to/model/Data/MouseT_AnglesDatabases_Long";

/* Add liberary for TVEM output */
LIBNAME T "/path/to/model/TVEM/FinalModels_Child/";

/* Point to macro */
%INCLUDE "/path/to/model/Macro_TVEM_v311/Tvem_v311.sas";

/* allow SAS to continue to run in batch mode after syntax error */
options NOSYNTAXCHECK;

/******************************************************************/
/******************************************************************/
/**                       CHILD ONLY DATA                        **/
/******************************************************************/
/******************************************************************/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 20 pt}CHILD All Trials: Final Liking Models';

/****************************************************************************/
/**  CHILD All Trials-Tstamp_nodelete: Intercept k2 LikeDif cubic          **/
/****************************************************************************/
/*bspline 2 - cubic*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD All Trials: Final Liking Model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Intercept - 2, LikeDif - cubic, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.angles_tstamp_nodelete_ch,
        output_prefix = T.l_k2c_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/All_LMod_Rslope_k2c_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif,
        method = B-spline,
        knots = 2 0 ,
        random = slope);

/***************************************************************************************/
/**  CHILD All Trials-Tstamp_nodelete: Intercept k2 LDif cubic Sex k2 Sex X LDif k1   **/
/***************************************************************************************/
/*bspline 2 - c - 2 - 1*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD All Trials: Final Liking + Sex + Liking X Sex Model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Int-2, LDif-c, sex-2, sexLDif-1, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.angles_tstamp_nodelete_ch,
        output_prefix = T.lsex2c21_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/All_LSexMod_Rslope_k2c21_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif sex_dummy sex_LDif_int,
        method = B-spline,
        knots = 2 0 2 1,
        random = slope);


/*******************************************************************************/
/**  CHILD All Trials-Tstamp_nodelete: Intercept k2 LDif cubic Age Constant   **/
/*******************************************************************************/
/*bspline 2 - c  */
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD All Trials: Final Liking + Age (constant) Model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Int-5, LDif-c, age-constant random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.angles_tstamp_nodelete_ch,
        output_prefix = T.lage2c_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/All_LAgeMod_Rslope_k2_ageCon_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif,
        method = B-spline,
        knots = 2 0 ,
        random = slope,
        invar_effect = cAge_yr);


/********************************************************************************************/
/**  CHILD All Trials-Tstamp_nodelete: Intercept k2 LDif cubic BMIp k1 BMIp X LDif cubic   **/
/********************************************************************************************/

/*bspline 2 - c - 1 - c*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD All Trials: Final Liking + BMIp + BMIp X Liking  Model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Int-5, LDif-c, BMIp-1, BMIpLDif-c, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.angles_tstamp_nodelete_ch,
        output_prefix = T.lbmi2c1c_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/All_LBMIpMod_Rslope_k2c1c_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif cBodyMass_p BMIp_LDif_int,
        method = B-spline,
        knots = 2 0 1 0,
        random = slope);



/************************************************************************************************/
/**  CHILD All Trials-Tstamp_nodelete: Intercept k2 LDif cubic Hunger k1 Hunger X LDif cubic   **/
/************************************************************************************************/

/*bspline 2 - c - 1 - c*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD All Trials: Final Liking + Hunger + Hunger X Liking  Model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Int-5, LDif-c, hunger-1, hungerLDif-c, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.angles_tstamp_nodelete_ch,
        output_prefix = T.lhun2c1c_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/All_LHungerMod_Rslope_k2c1c_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif Hunger Hunger_LDif_int,
        method = B-spline,
        knots = 2 0 1 0 ,
        random = slope);

/************************************************************************************************/
/**  CHILD All Trials-Tstamp_nodelete: Intercept k2 LDif cubic SCSR k1 SCSR X LDif cubic   **/
/************************************************************************************************/

/*bspline 2 - c - 1 - c*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD All Trials: Final Liking + SCSR + SCSR X Liking  Model';
ods pdf text = '^S={just=center font_size=16pt}CHILD: B-splines: Int-5, LDif-c, SCSR-1, scsrLDif-c, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.angles_tstamp_nodelete_ch,
        output_prefix = T.lscsr2c1c_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/All_LSCSRMod_Rslope_k2c1c_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif percSC_success SCSR_LDif_int,
        method = B-spline,
        knots = 2 0 1 0,
        random = slope);

/**************************************************************************************/
/**************************************************************************************/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 20 pt}CHILD SC Trials: Final Liking Models';

/*********************************************************************************************/
/**  CHILD SC Trials-Tstamp_nodelete: Intercept k3 LikeDif k1 SCout cubic LikeDif X SCout k1**/
/*********************************************************************************************/

/*bspline 2 - c - c - c*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Trials: Final Liking + SCout + SCout X Liking  Model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Int-2, LDif-c, SCout-c, SCoutLDif-1, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglessc_tstamp_nodelete_ch,
        output_prefix = T.lout2cc1_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCout_LMod_Rslope_k2cc1_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif TT_dummy TT_Ldif_Int,
        method = B-spline,
        knots = 2 0 0 1,
        random = slope);

/**************************************************************************************/
/**************************************************************************************/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 20 pt}CHILD SC Good Trials: Final Liking Models';

/*********************************************************************************************/
/**  CHILD SC Good Trials-Tstamp_nodelete: Intercept k3 LikeDif k1**/
/*********************************************************************************************/

/*bspline 2 - 1 */
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Good Trials: Final Liking';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Intercept - 2, LikeDif - 1, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscgood_tstamp_nodelete_ch,
        output_prefix = T.gl21_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCgood_LMod_Rslope_k21_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif,
        method = B-spline,
        knots = 2 1 ,
        random = slope);

/*********************************************************************************************/
/**  CHILD SC Good Trials-Tstamp_nodelete: Intercept k3 LikeDif k1 Sex cubic LikeDif X Sex k2**/
/*********************************************************************************************/

/*bspline 2 - 1 - cubic - 2*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Good Trials: Final Liking + Sex + Liking X Sex model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Intercept - 2, LikeDif - 1, Sex - c, SexLDif -2, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscgood_tstamp_nodelete_ch,
        output_prefix = T.glsex21c2_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCgood_LSexMod_Rslope_k21c2_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif sex_dummy sex_LDif_int,
        method = B-spline,
        knots = 2 1 0 2 ,
        random = slope);



/*********************************************************************************************/
/**  CHILD SC Good Trials-Tstamp_nodelete: Intercept k3 LikeDif k1 Age cubic LikeDif X Age cubic **/
/*********************************************************************************************/

/*bspline 2 - 1 - cubic - cubic*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Good Trials: Final Liking + Age + Liking X Age model';
ods pdf text = '^S={just=center font_size=16pt}CHILD: B-splines: Intercept - 2, LikeDif - 1, Age - c, AgeLDif -c, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscgood_tstamp_nodelete_ch,
        output_prefix = T.glage21cc_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCgood_LAgeMod_Rslope_k21cc_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif cAge_yr age_LDif_int,
        method = B-spline,
        knots = 2 1 0 0 ,
        random = slope);

/*********************************************************************************************/
/**  CHILD SC Good Trials-Tstamp_nodelete: Intercept k3 LikeDif k1 BMIp cubic LikeDif X BMIp cubic **/
/*********************************************************************************************/

/*bspline 2 - 1 - cubic - cubic */
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Good Trials: Final Liking + BMIp + Liking X BMIp model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Intercept - 2, LikeDif - 1, BMIp - c, BMIpLDif -c, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscgood_tstamp_nodelete_ch,
        output_prefix = T.glbmi21cc_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCgood_LBMIMod_Rslope_k21cc_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif cBodyMass_p BMIp_LDif_int,
        method = B-spline,
        knots = 2 1 0 0 ,
        random = slope);

/*********************************************************************************************/
/**  CHILD SC Good Trials-Tstamp_nodelete: Intercept k3 LikeDif k1 Hunger k1 LikeDif X Hunger cubic **/
/*********************************************************************************************/

/*bspline 2 - 1 - 1 - cubic*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Good Trials: Final Liking + Hunger + Liking X Hunger model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Intercept - 2, LikeDif - 1, Hunger - 1, HungerLDif -c, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscgood_tstamp_nodelete_ch,
        output_prefix = T.glhun211c_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCgood_LHungerMod_Rslope_k211c_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif Hunger Hunger_LDif_int,
        method = B-spline,
        knots = 2 1 1 0 ,
        random = slope);

/*********************************************************************************************/
/**  CHILD SC Good Trials-Tstamp_nodelete: Intercept k3 LikeDif k1 SCSR k5 LikeDif X SCSR cubic **/
/*********************************************************************************************/

/*bspline 2 - 1 - 1 - cubic*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Good Trials: Final Liking + SCSR + Liking X SCSR model';
ods pdf text = '^S={just=center font_size=16pt}CHILD: B-splines: Intercept - 2, LikeDif - 1, SCSR - 5, SCSRLDif -c, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscgood_tstamp_nodelete_ch,
        output_prefix = T.lscsrk215c_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCgood_LSCSRMod_Rslope_k215c_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif percSC_success SCSR_LDif_int,
        method = B-spline,
        knots = 2 1 5 0 ,
        random = slope);

/**************************************************************************************/
/**************************************************************************************/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 20 pt}CHILD SC Fail Trials: Final Liking Models';

/*********************************************************************************************/
/**  CHILD SC Fail Trials-Tstamp_nodelete: Intercept cubic LikeDif k3 **/
/*********************************************************************************************/

/*bspline cubic - 3 */
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Fail Trials: Final Liking';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Intercept - c, LikeDif - 3, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscfail_tstamp_nodelete_ch,
        output_prefix = T.flc3_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCfail_LMod_Rslope_kc3_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif,
        method = B-spline,
        knots = 0 3 ,
        random = slope);

/*********************************************************************************************/
/**  CHILD SC Fail Trials-Tstamp_nodelete: Intercept cubic LikeDif k3 Sex k3 LikeDif X Sex cubic **/
/*********************************************************************************************/

/*bspline cubic - 3 - 3 - cubic*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Fail Trials: Final Liking + Sex + Liking X Sex model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Intercept - c, LikeDif - 3, Sex - 3, SexLDif -c, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscfail_tstamp_nodelete_ch,
        output_prefix = T.flsexc33c_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCfail_LSexMod_Rslope_kc33c_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif sex_dummy sex_LDif_int,
        method = B-spline,
        knots = 0 3 3 0 ,
        random = slope);

/*********************************************************************************************/
/**  CHILD SC Fail Trials-Tstamp_nodelete: Intercept cubic LikeDif k3 Age k2 LikeDif X Age k1 **/
/*********************************************************************************************/

/*bspline cubic - 3 - 2 - 1*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Fail Trials: Final Liking + Age + Liking X Age model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Intercept - c, LikeDif - 3, Age - 2, AgeLDif -1, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscfail_tstamp_nodelete_ch,
        output_prefix = T.flagec321_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCfail_LAgeMod_Rslope_kc321_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif cAge_yr age_LDif_int,
        method = B-spline,
        knots = 0 3 2 1 ,
        random = slope);


/*********************************************************************************************/
/**  CHILD SC Fail Trials-Tstamp_nodelete: Intercept cubic LikeDif k3 BMI k2 LikeDif X BMI cubic **/
/*********************************************************************************************/

/*bspline cubic - 3 - 2 - cubic*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Fail Trials: Final Liking + BMI + Liking X BMI model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Intercept - c, LikeDif - 3, BMIp - 2, BMIpLDif -c, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscfail_tstamp_nodelete_ch,
        output_prefix = T.flbmikc32c_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCfail_LBMIpMod_Rslope_kc32c_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif cBodyMass_p BMIp_LDif_int,
        method = B-spline,
        knots = 0 3 2 0 ,
        random = slope);

/*********************************************************************************************/
/**  CHILD SC Fail Trials-Tstamp_nodelete: Intercept cubic LikeDif k3 BMI constant  **/
/*********************************************************************************************/

/*bspline cubic - 3 */
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Fail Trials: Final Liking + BMI constant model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Intercept - c, LikeDif - Constant, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscfail_tstamp_nodelete_ch,
        output_prefix = T.flbmikc3_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCfail_LBMIpMod_Rslope_kc3_BMIcon_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif,
        method = B-spline,
        knots = 0 3 ,
        random = slope,
        invar_effect = cBodyMass_p);

/*********************************************************************************************/
/**  CHILD SC Fail Trials-Tstamp_nodelete: Intercept cubic LikeDif k3 Hunger k2 LikeDif X Hunger cubic **/
/*********************************************************************************************/

/*bspline cubic - 3 - 2 - cubic*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Fail Trials: Final Liking + Hunger + Liking X Hunger model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Intercept - c, LikeDif - 3, Hunger - 2, HungerLDif -c, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscfail_tstamp_nodelete_ch,
        output_prefix = T.flhunc32c_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCfail_LHungerMod_Rslope_kc32c_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif Hunger Hunger_LDif_int,
        method = B-spline,
        knots = 0 3 2 0 ,
        random = slope);

/*********************************************************************************************/
/**  CHILD SC Fail Trials-Tstamp_nodelete: Intercept cubic LikeDif k3 Hunger constant  **/
/*********************************************************************************************/

/*bspline cubic - 3 */
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Fail Trials: Final Liking + Hunger constant model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Intercept - c, LikeDif - 3, Hunger -constant, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscfail_tstamp_nodelete_ch,
        output_prefix = T.flhunc3_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCfail_LHungerMod_Rslope_kc3_hunCon_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif,
        method = B-spline,
        knots = 0 3 ,
        random = slope,
        invar_effect = Hunger);

/*********************************************************************************************/
/**  CHILD SC Fail Trials-Tstamp_nodelete: Intercept cubic LikeDif k3 SCSR k4 SCSR x Ldif k3  **/
/*********************************************************************************************/

/*bspline cubic - 3 - 4 - 3*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Fail Trials: Final Liking + SCSR constant model';
ods pdf text = '^S={just=center font_size=16pt}CHILD: B-splines: Intercept - c, LikeDif - 3, SCSR - 4, SCSRLDif -3, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscfail_tstamp_nodelete_ch,
        output_prefix = T.flsrkc343_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCfail_LSCSRMod_Rslope_kc343_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif percSC_success SCSR_LDif_int,
        method = B-spline,
        knots = 0 3 4 3 ,
        random = slope);



/**************************************************************************************/
/**************************************************************************************/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 20 pt}CHILD All Trials: Final Taste + Health Models';

/**************************************************************************************/
/**  CHILD All Trials-Tstamp_nodelete: Intercept k2 HealthDif cubic TasteDif cubic   **/
/**************************************************************************************/
/*bspline 2 - cubic - 5*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD All Trials: Final Health + Taste model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Intercetp - 2, HealthDif - c, TasteDif - 5,random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.angles_tstamp_nodelete_ch,
        output_prefix = T.ht_k2c5_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/All_HTDif_Rslope_k2c5_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept HealthDif TasteDif,
        method = B-spline,
        knots = 2 0 5 ,
        random = slope);

/*********************************************************************************************************************************/
/**  CHILD All Trials-Tstamp_nodelete: Intercept k2 HealthDif cubic TasteDif cubic Sex cubic Sex X HDif cubic Sex X TDif cubic  **/
/*********************************************************************************************************************************/

/*bspline 2 - cubic - cubic - 2 - c - 2*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD All Trials: Final Health + Taste + Sex + Health X Sex + Taste X Sex model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Int-2, HDif-c, TDif-c, Sex-2, SexHDif-c, SexTDif-2, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.angles_tstamp_nodelete_ch,
        output_prefix = T.htsex2cc2c2_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/All_HTSexMod_Rslope_k2cc2c2_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept HealthDif TasteDif sex_dummy sex_Hdif_int sex_Tdif_int,
        method = B-spline,
        knots = 2 0 0 2 0 2 ,
        random = slope);


/*********************************************************************************************************************************/
/**  CHILD All Trials-Tstamp_nodelete: Intercept k2 HealthDif cubic TasteDif cubic Age cubic Age X HDif cubic Age X TDif cubic  **/
/*********************************************************************************************************************************/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD All Trials: Final Health + Taste + Age + Health X Age + Taste X Age model';
ods pdf text = '^S={just=center font_size=16pt}CHILD: B-splines: Int-2, HDif-c, TDif-c, Age-c, AgeHDif-c, AgeTDif-c, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.angles_tstamp_nodelete_ch,
        output_prefix = T.htage2ccccc_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/All_HTAgeMod_Rslope_k2ccccc_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept HealthDif TasteDif cAge_yr age_Hdif_int age_Tdif_int,
        method = B-spline,
        knots = 2 0 0 0 0 0 ,
        random = slope);

/************************************************************************************************************************************/
/**  CHILD All Trials-Tstamp_nodelete: Intercept k2 HealthDif cubic TasteDif cubic BMIp cubic BMIp X HDif cubic BMIp X TDif cubic  **/
/************************************************************************************************************************************/
/*bspline 2 - cubic - cubic - cubic - cubic - cubic*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD All Trials: Final Health + Taste + BMIp + Health X BMIp + Taste X BMIp model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Int-2, HDif-c, TDif-c, BMI-c, BMIHDif-c, BMITDif-c, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.angles_tstamp_nodelete_ch,
        output_prefix = T.htbmi2ccccc_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/All_HTBMIMod_Rslope_k2ccccc_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept HealthDif TasteDif cBodyMass_p BMIp_Hdif_int BMIp_Tdif_int,
        method = B-spline,
        knots = 2 0 0 0 0 0 ,
        random = slope);

/******************************************************************************************************************************************/
/**  CHILD All Trials-Tstamp_nodelete: Intercept k2 HealthDif cubic TasteDif cubic Hunger cubic Hunger X HDif cubic Hunger X TDif cubic  **/
/******************************************************************************************************************************************/
/*bspline 2 - cubic - cubic - 1 - cubic - 1*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD All Trials: Final Health + Taste + Hunger + Health X Hunger + Taste X Hunger model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Int-2, HDif-c, TDif-c, Hunger-1, HungerHDif-c, HungerTDif-1, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.angles_tstamp_nodelete_ch,
        output_prefix = T.hthun2cc1c1_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/All_HTHungerMod_Rslope_k2cc1c1_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept HealthDif TasteDif Hunger Hunger_Hdif_int Hunger_Tdif_int,
        method = B-spline,
        knots = 2 0 0 1 0 1 ,
        random = slope);

/******************************************************************************************************************************************/
/**  CHILD All Trials-Tstamp_nodelete: Intercept k2 HealthDif cubic TasteDif cubic SCSR k1 SCSR X HDif cubic SCSR X TDif cubic  **/
/******************************************************************************************************************************************/
/*bspline 2 - cubic - cubic - 1 - cubic - 1*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD All Trials: Final Health + Taste + SCSR + SCSR X Hunger + SCSR X Hunger model';
ods pdf text = '^S={just=center font_size=16pt}CHILD: B-splines: Int-2, HDif-c, TDif-c, SCSR-1, SCSRHDif-c, SCSRTDif-c, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.angles_tstamp_nodelete_ch,
        output_prefix = T.htscsr2cc1cc_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/All_HTSCSRMod_Rslope_k2cc1cc_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept HealthDif TasteDif percSC_success SCSR_Hdif_int SCSR_Tdif_int,
        method = B-spline,
        knots = 2 0 0 1 0 0 ,
        random = slope);

/**************************************************************************************/
/**************************************************************************************/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 20 pt}CHILD SC Trials: Final Taste + Health Models';

/*********************************************************************************************************************************************/
/**  CHILD SC Trials-Tstamp_nodelete: Intercept k2 HealthDif cubic TasteDif cubic SCout cubic HealthDif x SCout k1 TasteDif x SCout cubic   **/
/*********************************************************************************************************************************************/

/*bspline 2 - c - c - c - 1 - c*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Trials: Final Health + Taste + SCout + Health X SCout + Taste X SCout model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Int-2, HDif-c, Tdif-c, SCout-c, SCoutHDif-1, SCoutTdif-c, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglessc_tstamp_nodelete_ch,
        output_prefix = T.htout2ccc1c_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCout_HTMod_Rslope_k2ccc1c_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept HealthDif TasteDif TT_dummy TT_HDif_Int TT_TDif_Int,
        method = B-spline,
        knots = 2 0 0 0 1 0,
        random = slope);

/**************************************************************************************/
/**************************************************************************************/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 20 pt}CHILD SC Good Trials: Final Taste + Health Models';

/*********************************************************************************************************************************************/
/**  CHILD SC Good Trials-Tstamp_nodelete: Intercept k2 HealthDif 1 TasteDif cubic    **/
/*********************************************************************************************************************************************/

/*bspline 2 - 1 - cubic */
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Good Trials: Final Health + Taste model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Int-2, HDif-1, TDif-cubic, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscgood_tstamp_nodelete_ch,
        output_prefix = T.ght21c,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCgood_HTMod_Rslope_k21c_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept HealthDif TasteDif,
        method = B-spline,
        knots = 2 1 0 ,
        random = slope);

/*********************************************************************************************************************************************/
/**  CHILD SC Good Trials-Tstamp_nodelete: Intercept k2 HealthDif 1 TasteDif cubic Sex 1 HealthDif x Sex k4 TasteDif x Sex cubic   **/
/*********************************************************************************************************************************************/

/*bspline 2 - 1 - cubic - 1 - 4 - cubic */
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Good Trials: Final Health + Taste + Sex + Health X Sex + Taste X Sex model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Int-2, HDif-1, TDif-cubic, sex-1, sexHdif-4, sexTdif-c, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscgood_tstamp_nodelete_ch,
        output_prefix = T.ghtsex21c14c,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCgood_HTSexMod_Rslope_k21c14c_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept HealthDif TasteDif sex_dummy sex_HDif_int sex_TDif_int,
        method = B-spline,
        knots = 2 1 0 1 4 0 ,
        random = slope);

/*********************************************************************************************/
/**  CHILD SC Good Trials-Tstamp_nodelete: Intercept k2 Health k1 Taste cubic Age Constnat HealthTaste Difference Models   **/
/*********************************************************************************************/

/*bspline 2 - 1 - cubic*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Good Trials: Final Health + Taste + Age Constant model';
ods pdf text = '^S={just=center font_size=16pt}CHILD: B-splines: Int-2, HDif-1, TDif-cubic, Age-constant, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscgood_tstamp_nodelete_ch,
        output_prefix = T.ghtage21c,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCgood_HTAgeMod_Rslope_k21c_AgeCon_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept HealthDif TasteDif,
        method = B-spline,
        knots = 2 1 0 ,
        random = slope,
        invar_effect = cAge_yr);


/*********************************************************************************************************************************************/
/**  CHILD SC good Trials-Tstamp_nodelete: Intercept k2 HealthDif 1 TasteDif cubic BMIp cubic HealthDif x BMIp cubic TasteDif x BMIp cubic   **/
/*********************************************************************************************************************************************/

/*bspline 2 - 1 - c - c - c - c*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Trials: Final Health + Taste + BMIp + Health X SCout + Taste X BMI model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Int-2, HDif-1, TDif-cubic, bmi-c, bmiHdif-c, bmiTdif-c, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscgood_tstamp_nodelete_ch,
        output_prefix = T.ghtbmi21cccc,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCgood_HTBMIpMod_Rslope_k21cccc_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept HealthDif TasteDif cBodyMass_p BMIp_HDif_int BMIp_TDif_int,
        method = B-spline,
        knots = 2 1 0 0 0 0 ,
        random = slope);



/*********************************************************************************************************************************************/
/**  CHILD SC good Trials-Tstamp_nodelete: Intercept k2 HealthDif 1 TasteDif cubic Hunger cubic HealthDif x Hunger cubic TasteDif x Hunger cubic   **/
/*********************************************************************************************************************************************/

/*bspline 2 - 1 - c - c - c - c*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Trials: Final Health + Taste + Hunger + Health X Hunger + Taste X Hunger model';
ods pdf text = '^S={just=center font_size=16pt}CHILD: B-splines: Int-2, HDif-1, TDif-cubic, hunger-c, hunHdif-c, hunTdif-c, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscgood_tstamp_nodelete_ch,
        output_prefix = T.ghthun21cccc,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCgood_HThunMod_Rslope_k21cccc_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept HealthDif TasteDif Hunger Hunger_HDif_int Hunger_TDif_int,
        method = B-spline,
        knots = 2 1 0 0 0 0 ,
        random = slope);

/*********************************************************************************************************************************************/
/**  CHILD SC good Trials-Tstamp_nodelete: Intercept k2 HealthDif 1 TasteDif cubic SCSR k2 HealthDif x SCSR k1 TasteDif x SCSR cubic   **/
/*********************************************************************************************************************************************/

/*bspline 2 - 1 - cubic - 2 - 1 - cubic*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Trials: Final Health + Taste + SCSR + Health X SCSR + Taste X SCSR model';
ods pdf text = '^S={just=center font_size=16pt}CHILD: B-splines: Int-2, HDif-1, TDif-cubic, SCSR-2, SCSRHdif-1, SCSRTdif-c, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscgood_tstamp_nodelete_ch,
        output_prefix = T.ghtsr21c21c_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCgood_HTSCSRMod_Rslope_k21c21c_TstampNodelete,
        id = ParID, 
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept HealthDif TasteDif percSC_success SCSR_HDif_int SCSR_TDif_int,
        method = B-spline,
        knots = 2 1 0 2 1 0 ,
        random = slope);


/**************************************************************************************/
/**************************************************************************************/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 20 pt}CHILD SC Fail Trials: Final Taste + Health Models';

/*********************************************************************************************************************************************/
/**  CHILD SC Fail Trials-Tstamp_nodelete: Intercept k2 HealthDif k1 TasteDif k3c   **/
/*********************************************************************************************************************************************/

/*bspline 2 - 1 - 3 */
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Fail Trials: Final Health + Taste model';
ods pdf text = '^S={just=center font_size=16pt}CHILD: B-splines: Int-2, HDif-1, TDif-3, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscfail_tstamp_nodelete_ch,
        output_prefix = T.fht213,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCfail_HTMod_Rslope_k213_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept HealthDif TasteDif,
        method = B-spline,
        knots = 2 1 3 ,
        random = slope);

/*********************************************************************************************************************************************/
/**  CHILD SC Fail Trials-Tstamp_nodelete: Intercept k2 HealthDif k1 TasteDif k3c Sex cubic  HealthDif x Sex cubic TasteDif x Sex cubic   **/
/*********************************************************************************************************************************************/

/*bspline 2 - 1 - 3 - cubic - cubic - cubic */
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Fail Trials: Final Health + Taste + Sex + Health X Sex + Taste X Sex model';
ods pdf text = '^S={just=center font_size=16pt}CHILD: B-splines: Int-2, HDif-1, TDif-3, sex-c, sexHdif-c, sexTdif-c, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscfail_tstamp_nodelete_ch,
        output_prefix = T.fhtsex213ccc,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCfail_HTSexMod_Rslope_k213ccc_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept HealthDif TasteDif sex_dummy sex_HDif_Int sex_TDif_Int,
        method = B-spline,
        knots = 2 1 3 0 0 0 ,
        random = slope);


/*********************************************************************************************************************************************/
/**  CHILD SC Fail Trials-Tstamp_nodelete: Intercept k2 HealthDif k1 TasteDif k3 Age cubic HealthDif x Age cubic TasteDif x Age k1   **/
/*********************************************************************************************************************************************/

/*bspline 2 - 1 - 3 - cubic - cubic - 1 */
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Fail Trials: Final Health + Taste + Age + Health X Age + Taste X Age model';
ods pdf text = '^S={just=center font_size=16pt}CHILD: B-splines: Int-2, HDif-1, TDif-3, age-c, ageHdif-c, ageTdif-1, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscfail_tstamp_nodelete_ch,
        output_prefix = T.fhtage213cc1,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCfail_HTAgeMod_Rslope_k213cc1_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept HealthDif TasteDif cAge_yr age_HDif_Int age_TDif_Int,
        method = B-spline,
        knots = 2 1 3 0 0 1 ,
        random = slope);


/*********************************************************************************************************************************************/
/**  CHILD SC Fail Trials-Tstamp_nodelete: Intercept k2 HealthDif k1 TasteDif k3 BMIp constant   **/
/*********************************************************************************************************************************************/

/*bspline 2 - 1 - 3 - cubic - cubic - 1 */
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Fail Trials: Final Health + Taste + BMIp constant model';
ods pdf text = '^S={just=center font_size=16pt}CHILD: B-splines: Int-2, HDif-1, TDif-3, BMI-constant, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscfail_tstamp_nodelete_ch,
        output_prefix = T.fhtbmi213_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCfail_HTBMIpMod_Rslope_k213_BMIpCon_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept HealthDif TasteDif,
        method = B-spline,
        knots = 2 1 3 ,
        random = slope,
        invar_effect = cBodyMass_p);

/*********************************************************************************************************************************************/
/**  CHILD SC Fail Trials-Tstamp_nodelete: Intercept k2 HealthDif k1 TasteDif k3 Hunger cubic HealthDif x Hunger cubic TasteDif x Hunger cubic   **/
/*********************************************************************************************************************************************/

/*bspline 2 - 1 - 3 - cubic - cubic - cubic */
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Fail Trials: Final Health + Taste + Hunger + Health X Hunger + Taste X Hunger model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Int-2, HDif-1, TDif-3, Hunger-c, HungerHdif-c, HungerTdif-1, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscfail_tstamp_nodelete_ch,
        output_prefix = T.fhthun213ccc_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCfail_HTHungerpMod_Rslope_k213ccc_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept HealthDif TasteDif Hunger Hunger_HDif_Int Hunger_TDif_Int,
        method = B-spline,
        knots = 2 1 3 0 0 0 ,
        random = slope);


/***********************************************************************************************/
/**  CHILD SC Fail Trials-Tstamp_nodelete: Intercept k2 HealthDif k1 TasteDif k3 SCSR k1 SCSR x LDif k3 **/
/***********************************************************************************************/

/*bspline 2 - 1 - 3 - 4 - 3 - 1*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}CHILD SC Fail Trials: Final Health + Taste + SCSR + Health X SCSR + Taste X SCSR model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Int-2, HDif-1, TDif-3, SCSR-4, SCSRHdif-3, SCSRTdif-1, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

%TVEM(
        dist = normal,
        data = DATADIR.anglesscfail_tstamp_nodelete_ch,
        output_prefix = T.fhtscsr213431_,
        outfilename = /path/to/model/TVEM/FinalModels_Child/SCfail_HTSCSRMod_Rslope_k213431_TstampNodelete,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept HealthDif TasteDif percSC_success SCSR_HDif_Int SCSR_TDif_Int,
        method = B-spline,
        knots = 2 1 3 4 3 1 ,
        random = slope);


ods pdf close;

