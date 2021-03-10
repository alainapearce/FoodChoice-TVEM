# This script was written by Alaina Pearce in 2019 for the
# purpose of processing the DMK SC_mouse tracking food choice
# task. Specifically, this script extracts reaction time for
# food choice based on choice difficulty as defined by Sullivan
# et al., (2015) - supplemental materials for Pearce et al., 2020
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
####           RT Loop           ####
####                             ####
#####################################
#### RT by Difficulty Left Liking Left - Right (difficulty) ####
#rating differences are Right - Left because moving to the right food is positive angle
#therefore, all differences were right - left in Matlab script so need to multiply by -1 to reflect (Left-Right Liking Dif)
#from Sullivan 2015: "Figure 3a depicts the average choice curve for each condition, 
#plotting the probability of choosing left against the relative value of the left item (measured by likingleft – likingright)".

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
  MouseT_parDat_ABS = rep(MouseT_sumDat_reg[rows_matchID, ], each = 6)
  MouseT_parDat_CHOICE = rep(MouseT_sumDat_reg[rows_matchID, ], each = 9)
  
  par_RTdifficulty_ABS = MouseTracking_RT_ABSdifficulty_par(dsetname)
  par_RTdifficulty_CHOICE = MouseTracking_RT_CHOICEdifficulty_par(dsetname)
  
  if (p == 1){
    MouseT_RTdifficulty_ABS = cbind(MouseT_parDat_ABS, par_RTdifficulty_ABS)
    MouseT_RTdifficulty_CHOICE = cbind(MouseT_parDat_CHOICE, par_RTdifficulty_CHOICE)
  } else {
    MouseT_RTdifficulty_ABS = rbind(MouseT_RTdifficulty_ABS, cbind(MouseT_parDat_ABS, par_RTdifficulty_ABS))
    MouseT_RTdifficulty_CHOICE = rbind(MouseT_RTdifficulty_CHOICE, cbind(MouseT_parDat_CHOICE, par_RTdifficulty_CHOICE))
  }
}


## names for Lchoice probability dataset ####
names(MouseT_RTdifficulty_ABS) = c(names(MouseT_parDat_ABS), 'LikeDif_ABS', 
                               'nSCtrial_mouse', 'nSCtrial_keyboard',
                               'percSC_success_mouse', 'percSC_success_keyboard',
                               'nLikeDif_mouse', 'nLikeDif_keyboard', 
                               'RTmean_mouse', 'RTmean_keyboard', 'RTmedian_mouse', 
                               'RTmedian_keyboard', 'RTcv_mouse', 'RTcv_keyboard')

names(MouseT_RTdifficulty_CHOICE) = c(names(MouseT_parDat_CHOICE), 'LikeDif_CHOICE', 
                               'nSCtrial_mouse', 'nSCtrial_keyboard',
                               'percSC_success_mouse', 'percSC_success_keyboard',
                               'nLikeDif_mouse', 'nLikeDif_keyboard', 
                               'RTmean_mouse', 'RTmean_keyboard', 'RTmedian_mouse', 
                               'RTmedian_keyboard', 'RTcv_mouse', 'RTcv_keyboard')
                               

#### write out ####
write.csv(MouseT_RTdifficulty_ABS, 'Data/DMK_org_MouseTrack_RT_Difficulty_ABS.csv', row.names = FALSE)
write.csv(MouseT_RTdifficulty_CHOICE, 'Data/DMK_org_MouseTrack_RT_Difficulty_CHOICE.csv', row.names = FALSE)


