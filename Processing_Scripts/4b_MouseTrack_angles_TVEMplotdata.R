# This script was written by Alaina Pearce in 2019 for the
# purpose of processing the DMK SC_mouse tracking food choice
# task. Specifically, this script extracts plot values from 
# TVEM models.
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
####  Get all Plot Data Files  ####
####                             ####
#####################################
#### Load all Plot Data files from FinalModels_All ####

#get file list
filepaths_FinalMods = list.files(path = "./Data/TVEM_FinalModels/", pattern="*plot_data.sas7bdat", full.names=TRUE)
filenames_FinalMods = list.files(path = "./Data/TVEM_FinalModels/", pattern="*plot_data.sas7bdat", full.names=FALSE)

for(f in 1:length(filepaths_FinalMods)){
  dat = read_sas(filepaths_FinalMods[f])
  prefix = strsplit(filenames_FinalMods[f], '_')
  
  model_str = paste(prefix[[1]][1], prefix[[1]][2], sep = '')
  names(dat) = paste(model_str, names(dat), sep = '_')
  
  if(f == 1){
    FinalMods_plotData = data.frame(seq(1,100,1), dat)
    names(FinalMods_plotData)[1] = "TimePoint"
  } else {
    FinalMods_plotData = cbind(FinalMods_plotData, dat)
  }
}


#####################################
####                             ####
####        Export Data          ####
####                             ####
#####################################
#### export data ####
write.csv(FinalMods_plotData, 'Data/Databases/TVEM_FinalMods_PlotData.csv', row.names = FALSE)
