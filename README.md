# FoodChoice-TVEM
Data and analysis code for the paper: Individual Differences in the Influence of Taste and Health Impact Successful Dietary Self-Control: A Mouse Tracking Food Choice Study in Children. Physiology and Behavior 2020 (under review)

The scripts included in the Open Science Framework project were written by Alaina Pearce in 2019 for the purpose of processing the data from a study using Sullivan et al., (2015) mouse tracking food choice task in children. The processing of mouse trajectories was adapted from 'updatedCode.m' publicly provided by Nicolette Sullivan on OSF (https://osf.io/2bctm/). 

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


This repository only contains the task and processing scripts. To see full data and analysis scripts used in the Pearce et al. (under review) paper, please see the Open Science Framework project page: https://osf.io/sz4dj/

These scripts are not guaranteed to work for new data or under new directory configurations, however, they should work if the entire project is downloaded with the data and no changes are made to directories. To use these scripts, you will need MATLAB2017 or later, LaTex, and R/Rstudio. Be sure that all required libraries are installed in R and your LaTex is linked with Rstudio prior to running. 

To use Time-Varying Effect Modeling as done in Pearce et al., (under review), you will also need SAS 9.4 to run the TVEM models. The TVEM macro can be downlaoded from: https://www.methodology.psu.edu/ra/tvem/

Directory Structure:

-MouseTracking_FoodChoice_task: contains all scripts and images for the Food Choice Mouse Tracking task from Sullivan et al., (2015). The task is the same as that paper but the images have been changed.

-Processing_Scripts: contains matlab and r scripts used to process raw output from the Mouse Tracking Food Choice Task
NOTE: check file paths/directory structure after downloading or scripts will may not work - there is one raw data file in Data directory for testing.

Processing Steps:
1) Process the raw data using SC_MouseTracking_DMK_pwrapper.m: this script is a wrapper for the other two Matlab scripts. SC_MouseTracking_ProcRawMatfiles.m processes the raw data and produces the datasets needed to do analyses in R. SC_MouseTracking_RawTrajectories.m is optional and is only used if specified in the wrapper function. This script produces .pdfs depicting each trial's trajectory for each participant and takes some time to run. The purpose of this would be if you wanted to inspect individual trajectories or identify change of mind trials.

2) Use R to complete the analyses. Each script is number with the recommended order of use is attempting to reproduce the analysis steps in Pearce et al., (under review). The MouseTracking_functions.R is a list of functions called by the numbered .R scripts to generate needed databases for analyses. The functions.R script is a list of handy functions for analyses and graphing. If you are working with your own data, you will need to update all .R scripts to reflect the correct column indices in order for them to work properly.
