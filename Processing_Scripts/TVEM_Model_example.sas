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

*set up pdf output;

options nonumber nodate;
ods pdf style=printer printer=pdfa
    file="/path/to/model/TVEM_FinalModels_output.pdf"
    contents=yes pdftoc=2;
ods startpage=bygroup;
ods trace on;
ods noproctitle;
ods escapechar = '^';

/* Add Library for TVEM Macro */
*CHANGE path below;
LIBNAME tvemdir "/path/to/model/Macro_TVEM_v311";

/* Add library for Data */
*CHANGE path below;
LIBNAME datadir "/path/to/model/Data/Databases";

/* Add liberary for TVEM output */
*CHANGE path below;
*need to have short name due to 14 char limit on output files;
LIBNAME T "/path/to/model/Data/TVEM_FinalModels/";

/* Point to macro */
*CHANGE path below;
%INCLUDE "/path/to/model/Macro_TVEM_v311/Tvem_v311.sas";

/* allow SAS to continue to run in batch mode after syntax error */
options NOSYNTAXCHECK;

/******************************************************************/
/******************************************************************/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 20 pt} All Trials: Final Liking Models';

/******************************************************/
/**  All Trials: Intercept k2 LikeDif cubic          **/
/******************************************************/
/*bspline 2 - cubic*/
ods pdf startpage = now;
ods pdf text = '^S={just=center font_size = 16pt}All Trials: Final Liking Model';
ods pdf text = '^S={just=center font_size=16pt}B-splines: Intercept - 2, LikeDif - cubic, random intercept and slope';
ods pdf text = '^S={just=center font_size = 16pt}';

*CHANGE path below;
%TVEM(
        dist = normal,
        data = DATADIR.angles_all,
        output_prefix = T.l_k2c_,
        
        outfilename = /path/to/model/Data/TVEM_FinalModels/All_LMod_Rslope_k2c,
        id = ParID,
        time = TimePoint,
        dv = Angle_num,
        tvary_effect = intercept LikeDif,
        method = B-spline,
        knots = 2 0 ,
        random = slope);


ods pdf close;

