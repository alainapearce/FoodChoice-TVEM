# This script was written by Alaina Pearce in 2019 for the
# purpose of processing the DMK SC_mouse tracking food choice
# task. Specifically, this script extracts processed food
# rating data from the Sullivan et al., (2015) food choice
# mouse tracking task
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
MouseT_sumDat = read.csv('Data/SC_MouseTrack_compiledDat.csv', header = TRUE)
#remove 164 (no self control trials)-means no difference in ratings for most trials so cannot estimate individual models
MouseT_sumDat_reg = MouseT_sumDat[MouseT_sumDat$ParID != 164, ]

#####################################
####                             ####
####    Initial Food Ratings     ####
####                             ####
#####################################
#loop through participants to build the database of ratings ####
IDs = unique(MouseT_sumDat_reg$ParID)
for(p in 1:length(IDs)){
  #dataset name changes by participant ID. note, need to update date if reprocess
  rate_dsetname = paste('Data/ProcessedData/SC_MouseTracking_Processed_FoodRatings', IDs[p], '10-Sep-2019.csv', sep = '_')
  rate_dset = read.csv(rate_dsetname, header = TRUE)

  if(p == 1){
    fullrating_dat = rate_dset[c(1, 4:80)]
  } else {
    fullrating_dat = rbind(fullrating_dat, rate_dset[c(1, 4:80)])
  }
}


#make better label collumns for rows ####
fullrating_dat$rating = ifelse(fullrating_dat$Rating == 'Health_RT', 'Health', 
                         ifelse(fullrating_dat$Rating == 'Taste_RT', 'Taste',
                                ifelse(fullrating_dat$Rating == 'Like_RT', 'Like',
                                       as.character(fullrating_dat$Rating))))
fullrating_dat$measure = ifelse(fullrating_dat$Rating == 'Health_RT', 'RT', 
                         ifelse(fullrating_dat$Rating == 'Taste_RT', 'RT',
                                ifelse(fullrating_dat$Rating == 'Like_RT', 'RT',
                                       'likert')))
fullrating_dat = fullrating_dat[c(1, 3:80)]

#merge with summary dataset ####
#the merge will automattically add multiple rows of 
#MouseT_sumDat_ratings to match number of row that ParID has in full_dat
SC_FoodRating_data = merge(MouseT_sumDat_reg, fullrating_dat, by = "ParID")

#split by measure ####
SC_FoodRating_likert = SC_FoodRating_data[SC_FoodRating_data$measure == 'likert', ]
SC_FoodRating_RT = SC_FoodRating_data[SC_FoodRating_data$measure == 'RT', ]

#get row means/sums for foods ####
SC_FoodRating_likert$Avg_rating = rowMeans(SC_FoodRating_likert[29:104])
SC_FoodRating_RT$AvgRT = rowMeans(SC_FoodRating_RT[29:104])

#make likert dataset long ####
SC_FoodRating_likert_long = reshape2::melt(SC_FoodRating_likert, id.vars = names(SC_FoodRating_likert)[c(1:28, 105:107)])
SC_FoodRating_likert_long$Likert_rating = SC_FoodRating_likert_long$value
SC_FoodRating_likert_long$Food_Item = SC_FoodRating_likert_long$variable
SC_FoodRating_likert_long = SC_FoodRating_likert_long[c(1:31, 34:35)]


#####################################
####                             ####
####       Export Data           ####
####                             ####
#####################################
write.csv(SC_FoodRating_likert_long, 'Data/Databases/MouseT_FoodRatingsLikert_LongDat.csv', row.names = FALSE)

