# This script was written by Alaina Pearce in 2019 for the
# purpose of processing the DMK SC_mouse tracking food choice
# task. Specifically, this script compiles all relevant non-
# task data
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

############ Basic Data Load/Setup ###########
#set working directory to location of script--not needed when called 
#through Rmarkdown doc. Uncomment below if running locally/manually
#library(rstudioapi)
#this.dir = getActiveDocumentContext()$path
#setwd(dirname(this.dir))

## load data ####
childDat = read.csv('Data/DMK_childDat.csv')
MouseT_sumDat = read.csv('Data/Databases/SC_MouseTracking_10-Sep-2019.csv')

##merge with child data ####
MouseT_sumDat = merge(MouseT_sumDat, childDat, by.x = 'ParID', by.y = 'ID', all.x = TRUE)

#### export data ####
write.csv(MouseT_sumDat, 'Data/Databases/SC_MouseTrack_compiledDat.csv', row.names = FALSE)


