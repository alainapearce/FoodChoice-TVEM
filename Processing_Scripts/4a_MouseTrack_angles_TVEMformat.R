# This script was written by Alaina Pearce in 2019 for the
# purpose of processing the DMK SC_mouse tracking food choice
# task. Specifically, this script formats mouse angle data to 
# be used in TVEM analyses in SAS
# 
#     Copyright (C) 2019 Alaina L Pearce
# 
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <https://www.gnu.org/licenses/>.

############ Basic Data Load/Setup ############
library(reshape2)
library(lsr)
library(rstudioapi)
library(haven)

#####################################
####                             ####
####     directory toggle        ####
####                             ####
#####################################
#set working directory to location of script--not needed when called 
#through Rmarkdown doc. Uncomment below if running locally/manually
#this.dir = getActiveDocumentContext()$path
#setwd(dirname(this.dir))
#####################################
####                             ####
####   source data/functions     ####
####                             ####
#####################################
source('MouseTracking_functions.R')
MouseT_sumDat = read.csv('Data/Databases/SC_MouseTrack_compiledDat.csv', header = TRUE)

#####################################
####                             ####
####  Collate Individual Angles  ####
####                             ####
#####################################
#### Get angles by timepoint in long format ####

#no selfcontrol trials because ratings never differed so need to exclude 164
#taste and health ratings perfectly collinear on selfcontrol trials (all -4 and 4)
MouseT_sumDat_reg = MouseT_sumDat[MouseT_sumDat$ParID != 164 & MouseT_sumDat$ParID != 132, ]

#note: type can be 'all', 'SC' (self control), 'notSC', 'SCgood', or 'SCfail'
#rating differences are Right - Left because moving to the right food is positive angle

IDs = unique(MouseT_sumDat_reg$ParID)

for(p in 1:length(IDs)){
  #dataset name changes by participant ID. note, need to update date if reprocess
  dsetname = paste('SC_MouseTracking_Processed_LinearInt_anglewide', IDs[p], '10-Sep-2019.csv', sep = '_')
  
  #run the regression function and the last columns of the dataset on the rows with matching IDs
  #add to database. The first option, second option is trial type. The second method/how is for the
  #method the angles were calculated and if downward were excluded
  
  parAngle_data_long = MouseTracking_Angles_TVEMformat_par(dsetname, 'all', 'Tstamp_nodelete')
  
  #merge with summary data and other participants
  if (p == 1){
    parAngle_data_long = merge(parAngle_data_long, MouseT_sumDat_reg[c(1, 4:5, 9:14, 17:18, 21)], by = c('ParID'))
    Angle_data_long = parAngle_data_long
  } else {
    parAngle_data_long = merge(parAngle_data_long, MouseT_sumDat_reg[c(1, 4:5, 9:14, 17:18, 21)], by = c('ParID'))
    Angle_data_long = rbind(Angle_data_long, parAngle_data_long)
  }
}

#####################################
####                             ####
####        Subset Data          ####
####                             ####
#####################################
#add intercept 
Angle_data_long$intercept = 1
Angle_data_long$cAge_yr = Angle_data_long$cAge_mo/12

## separate angle data for Tstamp_nodelete based on age and SC trial ####
Angle_data_SCgood_long = Angle_data_long[Angle_data_long$SC_Trial == 'Y' & Angle_data_long$SC_TrialSuccess =='Y', ]
Angle_data_SCgood_long$TrialType = 'SCgood'

Angle_data_SCfail_long = Angle_data_long[Angle_data_long$SC_Trial == 'Y' & Angle_data_long$SC_TrialSuccess == 'N', ]
Angle_data_SCfail_long$TrialType = 'SCfail'

Angle_data_SCoutcome_long = rbind(Angle_data_SCgood_long, Angle_data_SCfail_long)

#####################################
####                             ####
####        Export Data          ####
####                             ####
#####################################
#### export data ####
write.csv(Angle_data_long, 'Data/Databases/MouseTAngles_long.csv', row.names = FALSE)
write.csv(Angle_data_SCoutcome_long, 'Data/Databases/MouseTAngles_SCoutcome_long.csv', row.names = FALSE)
write.csv(Angle_data_SCgood_long, 'Data/Databases/MouseTAngles_SCgood_long.csv', row.names = FALSE)
write.csv(Angle_data_SCfail_long, 'Data/Databases/MouseTAngles_SCfail_long.csv', row.names = FALSE)
