# FoodChoice-TVEM
Data and analysis code for the paper: Individual Differences in the Influence of Taste and Health Impact Successful Dietary Self-Control: A Mouse Tracking Food Choice Study in Children. Physiology and Behavior 2020 (under review)

The scripts included in the Open Science Framework project were written by Alaina Pearce in 2019 for the purpose of processing the data from a study using Sullivan et al., (2015) mouse tracking food choice task in children. The processing of mouse trajectories was adapted from 'updatedCode.m' publicly provided by Nikki Sullivan on OSF (https://osf.io/2bctm/). 

    Copyright (C) 2019 Alaina L Pearce

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.



These scripts are not guaranteed to work for new data or under new directory configurations, however, they should work if the entire project is downloaded with the data and no changes are made to directories. To use these scripts, you will need MATLAB2017 or later, LaTex, and R/Rstudio. Be sure that all required libraries are installed in R and your LaTex is linked with Rstudio prior to running. To reproduce the results you will also need SAS 9.4 to run the TVEM models.

Directory Structure:
-Main Directory: contains all scripts and the .Rpoj and .Rmd 
note: SAS_batch is a bash script that can be used for submitting your .SAS code to a high performance computing cluster. It is meant to take an input variable that is your script name (e.g., qsub SAS_batch -F "TVEM_DataLoad.sas"). This will likely need to be adjusted to your cluster's specifications.

-Data:
  -Databases: all databases from Matlab, R, and SAS_data.sas output to here. Also contains child demographic information.
  -ProcessedData: all of the individual participants' processed data from Matlab - this is used in R scripts to characterize trajectories
  -RawData: all raw data from task
  -TVEM_FinalModels: all the output from TVEM_FinalModels.sas - this does not contain the output from testing the knots for each model. That information is presented in tables in Supplemental Materials but not included in this project. If using on your own data, you will need to first find the best fitting model by sequentially testing different number of knots. Only the plot data is included in OSF, but TVEM does output more files when the models are run.

-Macro_TVEM_v311: contains TVEM SAS macro. For more information see: https://www.methodology.psu.edu/ra/tvem/

-SC_MouseTrack_Figs: this is the directory that the .Rmd file saves figures to. If you change the name of this directory you will need to edit the .Rmd file to reflect the change

Processing Steps:
1) Process the raw data using SC_MouseTracking_DMK_pwrapper.m: this script is a wrapper for the other two Matlab scripts. SC_MouseTracking_ProcRawMatfiles.m processes the raw data and produces the datasets needed to do analyses in R. SC_MouseTracking_RawTrajectories.m is optional and is only used if specified in the wrapper function. This script produces .pdfs depicting each trial's trajectory for each participant and takes some time to run. The purpose of this would be if you wanted to inspect individual trajectories or identify change of mind trials.

2) Use R to complete the analyses. The SC_MouseTracking_setup.R has all the analyses scripted and is sourced from the .Rmd file. Each section of the setup file has instructions of which scripts need to be run to create the needed databases. The MouseTracking_functions.R is a list of functions called by the numbered .R scripts to generate needed databases for analyses. The functions.R script is a list of handy functions for analyses and graphing. Both of these are sourced from within other scripts and shouldn't need editing. If you are working with your own data, you will need to update all .R scripts to reflect the correct column indices in order for them to work properly.

Using with own data:
If you are trying to use these scripts with your own data, here a few things to keep in mind:
1) you will have to update all paths in all scripts. 
2) your database may have a different number of demographic columns--this means you will have to check and edit ALL R scripts to reflect the proper columns indices. SAS scripts will also have to be updated with different naming conventions.
