# This script was written by Alaina Pearce in 2019 for the
# purpose of processing the DMK SC_mouse tracking food choice
# task. Specifically, this script extracts beta coeffecients
# from linear regessions using the method from Sullivan et al
# (2015) to examine the influence of health, taste and liking 
# on mouse angle trajectory.
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
library(mefa)

#####################################
####                             ####
####     directory toggle        ####
####                             ####
#####################################
#set working directory to location of script--not needed when called 
#through Rmarkdown doc. Uncomment below if running locally/manually
#library(rstudioapi)
#this.dir = getActiveDocumentContext()$path
#setwd(dirname(this.dir))
#####################################
####                             ####
####   source data/functions     ####
####                             ####
#####################################
source('functions.R')
source('MouseTracking_functions.R')
MouseT_sumDat = read.csv('Data/Databases/SC_MouseTrack_compiledDat.csv', header = TRUE)

#####################################
####                             ####
####  Individual Regressions     ####
####                             ####
#####################################
#### Do regression analyses for angle data ####

#no selfcontrol trials because ratings never differed so need to exclude 164
#taste and health ratings perfectly collinear on selfcontrol trials (all -4 and 4)
MouseT_sumDat_reg = MouseT_sumDat[MouseT_sumDat$ParID != 164 & MouseT_sumDat$ParID != 132, ]

#note: type can be 'all', 'SC' (self control), 'notSC', 'SCgood', or 'SCfail'
IDs = unique(MouseT_sumDat_reg$ParID)
for(p in 1:length(IDs)){
  #get the rows that match the ID
  rows_matchID = MouseT_sumDat_reg$ParID == IDs[p]
  
  #get par data repeated
  MouseT_parDat = rep(MouseT_sumDat_reg[rows_matchID, ], each = 9)
  
  #add new columns and names
  SC_newReg_data = cbind(MouseT_parDat, matrix(NA, ncol = 105, nrow = 9))
  names(SC_newReg_data) = c(names(MouseT_parDat), 'method','rating', 'measure', 'tail', paste('t', c(1:101), sep = ''))
  
  #copy to other dsets want
  SCgood_newReg_data = SC_newReg_data
  SCfail_newReg_data = SC_newReg_data

  #use for debugging to see which participant is bugged out
  #print(IDs[p])
  
  #dataset name changes by participant ID. note, need to update date if reprocess
  dsetname = paste('SC_MouseTracking_Processed_LinearInt_anglewide', IDs[p], '10-Sep-2019.csv', sep = '_')
  
  #run the regression function and the last columns of the dataset on the rows with matching IDs
  #add to database
  SCgood_newReg_data[29:133] = MouseTracking_reg_par(dsetname, 'SCgood')
  SCfail_newReg_data[29:133] = MouseTracking_reg_par(dsetname, 'SCfail')

  if (p == 1){
    MouseT_SCgood_regDat = SCgood_newReg_data
    MouseT_SCfail_regDat = SCfail_newReg_data
  } else {
    MouseT_SCgood_regDat = rbind(MouseT_SCgood_regDat, SCgood_newReg_data)
    MouseT_SCfail_regDat = rbind(MouseT_SCfail_regDat, SCfail_newReg_data)
  }
}


#####################################
####                             ####
####     Group Path T-test       ####
####                             ####
#####################################
## T-test for Coef > 0; coef sign maintained ####
MouseT_SCgood_coef_ttest_Tstamp_nodelete=MouseTracking_ttest_coef(MouseT_SCgood_regDat, 'sign')
MouseT_SCfail_coef_ttest_Tstamp_nodelete=MouseTracking_ttest_coef(MouseT_SCfail_regDat, 'sign')

## Get sig time for T-tests ####
#TrialType is simply to label the typs of ttest/reg loaded in. It is only a lable. The values 
#are dependent on the regression function that was fed to the ttest_coef and then here.
MouseT_SCgood_sig_ttest_Tstamp_nodelete = coeff_lastsig_ttest(MouseT_SCgood_coef_ttest_Tstamp_nodelete, 'SCgood')
MouseT_SCfail_sig_ttest_Tstamp_nodelete = coeff_lastsig_ttest(MouseT_SCfail_coef_ttest_Tstamp_nodelete, 'SCfail')

#####################################
####                             ####
####    Individual Sig Times     ####
####                             ####
#####################################
## get earliest significant time for each person ####
MouseT_SCgood_ind_sigTimes_Tstamp_nodelete = MouseTracking_ind_sigTimes(MouseT_SCgood_regDat)
MouseT_SCfail_ind_sigTimes_Tstamp_nodelete = MouseTracking_ind_sigTimes(MouseT_SCfail_regDat)

#####################################
####                             ####
#### Process Individual Sig Times ####
####                             ####
#####################################
#stack SC outcome datasets
MouseT_SCgood_ind_sigTimes_Tstamp_nodelete$TrialType = 'SCgood'
MouseT_SCfail_ind_sigTimes_Tstamp_nodelete$TrialType = 'SCfail'
MouseT_SCoutcome_ind_sigTimes_Tstamp_nodelete = rbind(MouseT_SCgood_ind_sigTimes_Tstamp_nodelete, MouseT_SCfail_ind_sigTimes_Tstamp_nodelete)

#get median split on self control abilities
SCmedian = median(MouseT_sumDat$percSC_success)
MouseT_SCoutcome_ind_sigTimes_Tstamp_nodelete$SC_group = ifelse(MouseT_SCoutcome_ind_sigTimes_Tstamp_nodelete$percSC_success > SCmedian,
                                                                "High", "Low")


#get the number of intervals (10 or more time points) that showed significant points
MouseT_SCoutcome_ind_sigTimes_Tstamp_nodelete$nSig10_Int = rowSums(matrix(c(as.numeric(MouseT_SCoutcome_ind_sigTimes_Tstamp_nodelete$lastSig_10=='Y'),
                                                                  as.numeric(!is.na(MouseT_SCoutcome_ind_sigTimes_Tstamp_nodelete$`2ndSig10_last`)), 
                                                                  as.numeric(!is.na(MouseT_SCoutcome_ind_sigTimes_Tstamp_nodelete$`3rdSig10_last`)),
                                                                  as.numeric(!is.na(MouseT_SCoutcome_ind_sigTimes_Tstamp_nodelete$`4thSig10_last`))), ncol = 4), na.rm =TRUE)

#total number of significant time points
MouseT_SCoutcome_ind_sigTimes_Tstamp_nodelete$nSigTP_overall = rowSums(MouseT_SCoutcome_ind_sigTimes_Tstamp_nodelete[c(37, 40, 43, 46)], na.rm =TRUE)

#Indicator for no sig time points
MouseT_SCoutcome_ind_sigTimes_Tstamp_nodelete$NoSigTP_int = ifelse(MouseT_SCoutcome_ind_sigTimes_Tstamp_nodelete$nSigTP_overall == 0, 'Y', 'N') 

#####################################
####                             ####
####        Export Data          ####
####                             ####
#####################################
#### export data ####
write.csv(MouseT_SCgood_regDat, 'Data/Databases/MouseT_SCgood_regDat_Tstamp_nodelete.csv', row.names = FALSE)
write.csv(MouseT_SCfail_regDat, 'Data/Databases/MouseT_SCfail_regDat_Tstamp_nodelete.csv', row.names = FALSE)

write.csv(MouseT_SCgood_coef_ttest_Tstamp_nodelete, 'Data/Databases/MouseT_SCgood_coef_ttest_Tstamp_nodelete.csv', row.names = FALSE)
write.csv(MouseT_SCfail_coef_ttest_Tstamp_nodelete, 'Data/Databases/MouseT_SCfail_coef_ttest_Tstamp_nodelete.csv', row.names = FALSE)

write.csv(MouseT_SCgood_sig_ttest_Tstamp_nodelete, 'Data/Databases/MouseT_SCgood_sig_ttest_Tstamp_nodelete.csv', row.names = FALSE)
write.csv(MouseT_SCfail_sig_ttest_Tstamp_nodelete, 'Data/Databases/MouseT_SCfail_sig_ttest_Tstamp_nodelete.csv', row.names = FALSE)

write.csv(MouseT_SCoutcome_ind_sigTimes_Tstamp_nodelete, 'Data/Databases/MouseT_SCoutcome_ind_sigTimes_Tstamp_nodelete.csv', row.names = FALSE)


