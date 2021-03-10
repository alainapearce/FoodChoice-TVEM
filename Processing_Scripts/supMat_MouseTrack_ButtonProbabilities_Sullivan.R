# This script was written by Alaina Pearce in 2019 for the
# purpose of processing the DMK SC_mouse tracking food choice
# task. Specifically, this script extracts probability of choosing
# left vs right food based on button or mouse block as done in 
# Sullivan et al., (2015) - supplemental materials for Pearce et al., 2020
# Physiology and Behavior
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
#set working directory to location of script--not needed when called 
#through Rmarkdown doc. Uncomment below if running locally/manually
#library(rstudioapi)
#this.dir = getActiveDocumentContext()$path
#setwd(dirname(this.dir))
source('functions.R')
source('MouseTracking_functions.R')
MouseT_sumDat = read.csv('Data/DMK_org_MouseTrack_Dat.csv', header = TRUE)
#remove 164 (no self control trials)
MouseT_sumDat_reg = MouseT_sumDat[MouseT_sumDat$ParID != 164, ]
#####################################
####                             ####
####   get log odds functions    ####
####                             ####
#####################################
#### Probability of Choosing Left Liking Left - Right (difficulty) ####
#In matlab script calculated the difference as Right-Left because that is what is used 
#for the angle regressions. Need to adjust in function.

#get participants
IDs = unique(MouseT_sumDat_reg$ParID)
for(p in 1:length(IDs)){
  #get the rows that match the ID
  rows_matchID = MouseT_sumDat_reg$ParID == IDs[p]
  
  #use for debugging to see which participant is bugged out
  #print(IDs[p])
  
  #dataset name changes by participant ID. note, need to update date if reprocess
  dsetname = paste('SC_MouseTracking_Processed', IDs[p], '10-Sep-2019.csv', sep = '_')

  #add to database
  MouseT_parDat = rep(MouseT_sumDat_reg[rows_matchID, ], each = 9)
  par_Lprob_mouse = MouseTracking_logodds_Left_par(dsetname, 'mouse')
  par_Lprob_keyboard = MouseTracking_logodds_Left_par(dsetname, 'keyboard')
  
  if (p == 1){
    MouseT_Lchoice_prob_mouse = cbind(MouseT_parDat, par_Lprob_mouse)
    MouseT_Lchoice_prob_keyboard = cbind(MouseT_parDat, par_Lprob_keyboard)
  } else {
    MouseT_Lchoice_prob_mouse = rbind(MouseT_Lchoice_prob_mouse, cbind(MouseT_parDat, par_Lprob_mouse))
    MouseT_Lchoice_prob_keyboard = rbind(MouseT_Lchoice_prob_keyboard, cbind(MouseT_parDat, par_Lprob_keyboard))
    
  }
}

## Stack dsets ####
MouseT_Lchoice_prob_mouse$TrialType = 'mouse'
MouseT_Lchoice_prob_keyboard$TrialType = 'keyboard'
MouseT_Lchoice_prob = rbind(MouseT_Lchoice_prob_mouse, MouseT_Lchoice_prob_keyboard)
## names for Lchoice probability dataset ####
names(MouseT_Lchoice_prob) = c(names(MouseT_parDat), 'b0_int', 'b1_LDif', 'b0_int_SC', 
                               'b1_LDif_SC', 'b0_int_notSC', 'b1_LDif_notSC', 'b0_int_ex', 
                               'b1_LDif_ex', 'b0_int_SCex', 'b1_LDif_SCex', 'b0_int_notSCex', 
                               'b1_LDif_notSCex', 'LikeDif', 'nTrials', 'nLchoice', 
                               'prob_Lchoice', 'nTrials_SC', 'nLchoice_SC', 'prob_Lchoice_SC', 
                               'nTrials_notSC', 'nLchoice_notSC', 'prob_Lchoice_notSC', 
                               'nTrials_ex', 'nLchoice_ex', 'prob_Lchoice_ex', 'nTrials_SCex', 
                               'nLchoice_SCex', 'prob_Lchoice_SCex','nTrials_notSCex', 
                               'nLchoice_notSCex', 'prob_Lchoice_notSCex', 'TrialType')



#### export ####

write.csv(MouseT_Lchoice_prob, 'Data/DMK_org_MouseTrackLchoice_prob.csv', row.names = FALSE)


