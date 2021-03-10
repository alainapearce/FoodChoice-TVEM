# This script was written by Alaina Pearce in 2019 for the
# purpose of processing the DMK SC_mouse tracking food choice
# task. Specifically, this script contains all analyses for 
# Pearce et al., 2020 Physiology and Behavior
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

############ Basic Data Load/Setup########
library(reporttools)
library(scales)
library(xtable)
library(car)
library(lme4)
library(lmerTest)
library(ggplot2)
library(MASS)
library(emmeans)
library(reshape2)
library(lsr)
library(stats)
library(eeptools)
library(plyr)
library(memisc)
library(rstudioapi)
library(sm)
library(quantmod)
library(emmeans)
library(psych)

#set working directory to location of script--not needed when called 
#through Rmarkdown doc. Uncomment below if running locally/manually
#this.dir = getActiveDocumentContext()$path
#setwd(dirname(this.dir))

source('functions.R')
source('MouseTracking_functions.R')
##load datasets
#run if have not compiled the following datasets:
#1)SC_MouseTrack_compiledDat.csv
#source(1_MouseTrack_compileData.R)

#summary data for task
MouseT_sumDat = read.csv('Data/Databases/SC_MouseTrack_compiledDat.csv', header = TRUE)

#####################################
####                            
####    Demo Data               ####
####                            
#####################################
##OBstatus
OBstatus_tab = xtabs(~cBMI_group, data = MouseT_sumDat)

##Weight Class
WeightClass_tab = xtabs(~cBodyMass_class, data = MouseT_sumDat)

##Age
MouseT_sumDat$cAge_yr = MouseT_sumDat$cAge_mo/12
age_mean = mean(MouseT_sumDat$cAge_yr, na.rm = TRUE)
age_sd = sd(MouseT_sumDat$cAge_yr, na.rm = TRUE)
age_range = range(MouseT_sumDat$cAge_yr, na.rm = TRUE)

##BMI percentile
BMIp_mean = mean(MouseT_sumDat$cBodyMass_p, na.rm = TRUE)
BMIp_sd = sd(MouseT_sumDat$cBodyMass_p, na.rm = TRUE)
BMIp_range = range(MouseT_sumDat$cBodyMass_p, na.rm = TRUE)

##mEducation
mED_tab = xtabs(~mEducation, data = MouseT_sumDat)

##Sex
sex_tab = xtabs(~sex, data = MouseT_sumDat)

##Race
race_tab = xtabs(~cRace, data = MouseT_sumDat)

##Ethnicity
ethnicity_tab = xtabs(~cEthnicity, data = MouseT_sumDat)

##SES
SES_tab = xtabs(~income, data = MouseT_sumDat)

## BMI percentile/Zscore and Age/Sex
Age.BMIp_cor = cor.test(MouseT_sumDat$cBodyMass_p, MouseT_sumDat$cAge_yr)
sex.BMIp_ttest = t.test(cBodyMass_p~sex, data = MouseT_sumDat)

#### ####
#### ####
#####################################
####                            
####       Hunger Ratings       
####                            
#####################################
#### Table: Hunger 
hunger_tab = xtabs(~factor(Hunger), data = MouseT_sumDat)

#### Cor: Hunger and BMI percentile
hunger_cBMIp_cor = cor.test(MouseT_sumDat$Hunger, MouseT_sumDat$cBodyMass_p)

#### ttest: Hunger and Sex
hunger_sex_ttest = t.test(Hunger~sex, data = MouseT_sumDat)

#### Cor: Hunger and Age
hunger_Age_cor = cor.test(MouseT_sumDat$Hunger, MouseT_sumDat$cAge_yr)

#### ####
#### ####
#####################################
####                            
####     Food Rating Data        ####
####                            
#####################################
# Load datasets ####
#run if have not compiled the following datasets:
#1) MouseT_FoodRatings_Dat.csv
#source('2_MouseTrack_FoodRatings.R')
##add ED information
SC_FoodRating_foodED_long = read.csv('Data/Databases/MouseT_foodED.csv', header = TRUE)

#data
SC_FoodRating_likert_long = read.csv('Data/Databases/MouseT_FoodRatingsLikert_LongDat.csv', header = TRUE)
SC_FoodRating_likert_long$cAge_yr = SC_FoodRating_likert_long$cAge_mo/12
SC_FoodRating_likert_long$ParID = factor(SC_FoodRating_likert_long$ParID)

#subset by rating
SC_FoodRating_likert_long.health = SC_FoodRating_likert_long[SC_FoodRating_likert_long$rating == 'Health', ]
SC_FoodRating_likert_long.taste = SC_FoodRating_likert_long[SC_FoodRating_likert_long$rating == 'Taste', ]
SC_FoodRating_likert_long.liking = SC_FoodRating_likert_long[SC_FoodRating_likert_long$rating == 'Like', ]

## make wide with sub dsets
#Likert rating wide by food
SC_FoodRating_likert = dcast(SC_FoodRating_likert_long[c(1, 17, 20:21, 29:31, 34, 32:33)], ParID + sex + cBodyMass_z + cBodyMass_p + rating + measure + Avg_rating + cAge_yr ~ Food_Item, value.var = "Likert_rating")

#Likert rating wide by rating
SC_FoodRating_likert_widebyrating = dcast(SC_FoodRating_likert_long[c(1, 17, 20:21, 29:31, 34, 32:33)], ParID + sex + cBodyMass_z + cBodyMass_p + measure + cAge_yr + Food_Item ~ rating, value.var = "Likert_rating")

#Likert rating wide by rating for average value 
##need to make wide by food and rating to reduce to 1 row per participant. 
##since interested in average rating, there is only 1 value per rating per participant that 
##repeated when data is in long format. This means all foods will get same value when cast
##to wide format. So can choose just 1 food to get avg rating for all 3 ratings and rename 
##variables
SC_FoodRating_likert_widebyrating_avg = dcast(SC_FoodRating_likert_long[c(1, 17, 20:21, 29:31, 34, 29, 33)], ParID + sex + cBodyMass_z + cBodyMass_p + measure + cAge_yr ~ Food_Item + rating, value.var = "Avg_rating")
SC_FoodRating_likert_widebyrating_avg = SC_FoodRating_likert_widebyrating_avg[1:9]
names(SC_FoodRating_likert_widebyrating_avg) = c(names(SC_FoodRating_likert_widebyrating_avg)[1:6], 'Health_avg', 'Taste_avg', 'Liking_avg')

#ED information
HighED_foods = SC_FoodRating_foodED_long[SC_FoodRating_foodED_long$EDgroup == 'HighED', ]
HighED_foods$Name = factor(HighED_foods$Name)
LowED_foods = SC_FoodRating_foodED_long[SC_FoodRating_foodED_long$EDgroup == 'LowED', ]
LowED_foods$Name = factor(LowED_foods$Name)

#get rowMeans for the columns whose names match the strings in "HighED" or "LowED" _foods vectors
#use paste and "|" to make a string of names separated by 'or' logical (|), then can use grepl to 
#seletec columns matching the list of names
SC_FoodRating_likert$HighED_Avg_rating = rowMeans(SC_FoodRating_likert[grepl(paste0(levels(HighED_foods$Name), collapse = "|"), names(SC_FoodRating_likert))])
SC_FoodRating_likert$LowED_Avg_rating = rowMeans(SC_FoodRating_likert[grepl(paste0(levels(LowED_foods$Name), collapse = "|"), names(SC_FoodRating_likert))])

#make long dataset by ED average rating
SC_FoodRating_likert_EDlong = reshape2::melt(SC_FoodRating_likert, id.vars = names(SC_FoodRating_likert)[c(1:84)])
SC_FoodRating_likert_EDlong$ED = SC_FoodRating_likert_EDlong$variable
SC_FoodRating_likert_EDlong$EDavg_rating = SC_FoodRating_likert_EDlong$value
SC_FoodRating_likert_EDlong = SC_FoodRating_likert_EDlong[c(1:84, 87:88)]

##add ED information to long dataset
SC_FoodRating_likert_long = merge(SC_FoodRating_likert_long, SC_FoodRating_foodED_long[c(1, 4:6)], by.x = "Food_Item", by.y = "Name")
SC_FoodRating_likert_long$EDgroup = factor(SC_FoodRating_likert_long$EDgroup)

# Analyses - individual foods ####
#### BarPlot: HEALTH ratings by food item
foodRating_health_mean = means.function.na(SC_FoodRating_likert_long.health, SC_FoodRating_likert_long.health$Likert_rating, SC_FoodRating_likert_long.health$Food_Item)
foodRating_health_se = se.function.na(SC_FoodRating_likert_long.health, SC_FoodRating_likert_long.health$Likert_rating, SC_FoodRating_likert_long.health$Food_Item)
foodRating_health_sd = sd.function.na(SC_FoodRating_likert_long.health, SC_FoodRating_likert_long.health$Likert_rating, SC_FoodRating_likert_long.health$Food_Item)
foodRating_byfood_health_barplot = bar_graph.se_food(foodRating_health_mean, foodRating_health_se, "Food Item", "Health Rating", 1.5, -0.5, 0)

#### BarPlot: TASTE ratings by food item
foodRating_taste_mean = means.function.na(SC_FoodRating_likert_long.taste, SC_FoodRating_likert_long.taste$Likert_rating, SC_FoodRating_likert_long.taste$Food_Item)
foodRating_taste_se = se.function.na(SC_FoodRating_likert_long.taste, SC_FoodRating_likert_long.taste$Likert_rating, SC_FoodRating_likert_long.taste$Food_Item)
foodRating_taste_sd = sd.function.na(SC_FoodRating_likert_long.taste, SC_FoodRating_likert_long.taste$Likert_rating, SC_FoodRating_likert_long.taste$Food_Item)
foodRating_byfood_taste_barplot = bar_graph.se_food(foodRating_taste_mean, foodRating_taste_se, "Food Item", "Taste Rating", 1.5, -0.5, 0)

#### BarPlot: LIKING ratings by food item
foodRating_liking_mean = means.function.na(SC_FoodRating_likert_long.liking, SC_FoodRating_likert_long.liking$Likert_rating, SC_FoodRating_likert_long.liking$Food_Item)
foodRating_liking_se = se.function.na(SC_FoodRating_likert_long.liking, SC_FoodRating_likert_long.liking$Likert_rating, SC_FoodRating_likert_long.liking$Food_Item)
foodRating_liking_sd = sd.function.na(SC_FoodRating_likert_long.liking, SC_FoodRating_likert_long.liking$Likert_rating, SC_FoodRating_likert_long.liking$Food_Item)
foodRating_byfood_liking_barplot = bar_graph.se_food(foodRating_liking_mean, foodRating_liking_se, "Food Item", "Liking Rating", 1.5, -0.5, 0)

#### Reg: Liking ~ Health ratings by food item
foodRating_likehealth_mod = lmer(Like ~ Health + (1|ParID), data = SC_FoodRating_likert_widebyrating)
foodRating_likehealth_sum = summary(foodRating_likehealth_mod)

#### Reg: Liking ~ Taste ratings by food item
foodRating_liketaste_mod = lmer(Like ~ Taste + (1|ParID), data = SC_FoodRating_likert_widebyrating)
foodRating_liketaste_sum = summary(foodRating_liketaste_mod)

#### Reg: Taste ~ Health ratings by food item
foodRating_tastehealth_mod = lmer(Like ~ Health + (1|ParID), data = SC_FoodRating_likert_widebyrating)
foodRating_tastehealth_sum = summary(foodRating_tastehealth_mod)


# Analyses - average rating across foods ####
foodRating_avg_vars = SC_FoodRating_likert_widebyrating_avg[c(4, 6:9)]
foodRating_avg_varnames = names(SC_FoodRating_likert_widebyrating_avg)[c(4, 6:9)]
foodRating_avg_cormat = cor.matrix(foodRating_avg_vars, foodRating_avg_varnames)
foodRating_avg_cormat_ps = cor.matrix_ps(foodRating_avg_vars, foodRating_avg_varnames)

#### ANOVA: Rating Value ~ Attribute x ED
foodRating_rating.ED_mod = lmer(EDavg_rating~rating*ED + (1|ParID), data = SC_FoodRating_likert_EDlong)
foodRating_rating.ED_ANOVA = anova(foodRating_rating.ED_mod)
foodRating_rating.ED_sig_stars = c("***", "*", "")
foodRating_rating.ED_tab = sig_stars_lmerTestAll.table(foodRating_rating.ED_ANOVA, foodRating_rating.ED_sig_stars)

foodRating_rating_MErating_emmeans = emmeans(foodRating_rating.ED_mod, pairwise ~ rating)
foodRating_rating_MEED_emmeans = emmeans(foodRating_rating.ED_mod, pairwise ~ ED)

#### ANOVAs: Rating Value ~ BMI percentile x ED
foodRating_health_BMIp.ED_mod = lmer(EDavg_rating~cBodyMass_p*ED + (1|ParID), data = SC_FoodRating_likert_EDlong[SC_FoodRating_likert_EDlong$rating == 'Health', ])
foodRating_health_BMIp.ED_ANOVA = anova(foodRating_health_BMIp.ED_mod)
foodRating_health_BMIp.ED_sig_stars = c("", "", "")
foodRating_health_BMIp.ED_tab = sig_stars_lmerTestAll.table(foodRating_health_BMIp.ED_ANOVA, foodRating_health_BMIp.ED_sig_stars)

foodRating_taste_BMIp.ED_mod = lmer(EDavg_rating~cBodyMass_p*ED + (1|ParID), data = SC_FoodRating_likert_EDlong[SC_FoodRating_likert_EDlong$rating == 'Taste', ])
foodRating_taste_BMIp.ED_ANOVA = anova(foodRating_taste_BMIp.ED_mod)
foodRating_taste_BMIp.ED_sig_stars = c("", ".", "")
foodRating_taste_BMIp.ED_tab = sig_stars_lmerTestAll.table(foodRating_taste_BMIp.ED_ANOVA, foodRating_taste_BMIp.ED_sig_stars)

foodRating_liking_BMIp.ED_mod = lmer(EDavg_rating~cBodyMass_p*ED + (1|ParID), data = SC_FoodRating_likert_EDlong[SC_FoodRating_likert_EDlong$rating == 'Like', ])
foodRating_liking_BMIp.ED_ANOVA = anova(foodRating_liking_BMIp.ED_mod)
foodRating_liking_BMIp.ED_sig_stars = c("", ".", "")
foodRating_liking_BMIp.ED_tab = sig_stars_lmerTestAll.table(foodRating_liking_BMIp.ED_ANOVA, foodRating_liking_BMIp.ED_sig_stars)

#### ANOVA: Rating Value ~ Age x ED
foodRating_health_Age.ED_mod = lmer(EDavg_rating~cAge_yr*ED + (1|ParID), data = SC_FoodRating_likert_EDlong[SC_FoodRating_likert_EDlong$rating == 'Health', ])
foodRating_health_Age.ED_ANOVA = anova(foodRating_health_Age.ED_mod)
foodRating_health_Age.ED_sig_stars = c("", "", "")
foodRating_health_Age.ED_tab = sig_stars_lmerTestAll.table(foodRating_health_Age.ED_ANOVA, foodRating_health_Age.ED_sig_stars)

foodRating_taste_Age.ED_mod = lmer(EDavg_rating~cAge_yr*ED + (1|ParID), data = SC_FoodRating_likert_EDlong[SC_FoodRating_likert_EDlong$rating == 'Taste', ])
foodRating_taste_Age.ED_ANOVA = anova(foodRating_taste_Age.ED_mod)
foodRating_taste_Age.ED_sig_stars = c(".", "", "")
foodRating_taste_Age.ED_tab = sig_stars_lmerTestAll.table(foodRating_taste_Age.ED_ANOVA, foodRating_taste_Age.ED_sig_stars)

foodRating_liking_Age.ED_mod = lmer(EDavg_rating~cAge_yr*ED + (1|ParID), data = SC_FoodRating_likert_EDlong[SC_FoodRating_likert_EDlong$rating == 'Like', ])
foodRating_liking_Age.ED_ANOVA = anova(foodRating_liking_Age.ED_mod)
foodRating_liking_Age.ED_sig_stars = c("", "", "")
foodRating_liking_Age.ED_tab = sig_stars_lmerTestAll.table(foodRating_liking_Age.ED_ANOVA, foodRating_liking_Age.ED_sig_stars)

#### ANOVA: Rating Value ~ Sex x ED
foodRating_health_Sex.ED_mod = lmer(EDavg_rating~sex*ED + (1|ParID), data = SC_FoodRating_likert_EDlong[SC_FoodRating_likert_EDlong$rating == 'Health', ])
foodRating_health_Sex.ED_ANOVA = anova(foodRating_health_Sex.ED_mod)
foodRating_health_Sex.ED_sig_stars = c("", "", "")
foodRating_health_Sex.ED_tab = sig_stars_lmerTestAll.table(foodRating_health_Sex.ED_ANOVA, foodRating_health_Sex.ED_sig_stars)

foodRating_taste_Sex.ED_mod = lmer(EDavg_rating~sex*ED + (1|ParID), data = SC_FoodRating_likert_EDlong[SC_FoodRating_likert_EDlong$rating == 'Taste', ])
foodRating_taste_Sex.ED_ANOVA = anova(foodRating_taste_Sex.ED_mod)
foodRating_taste_Sex.ED_sig_stars = c("", "***", ".")
foodRating_taste_Sex.ED_tab = sig_stars_lmerTestAll.table(foodRating_taste_Sex.ED_ANOVA, foodRating_taste_Sex.ED_sig_stars)

foodRating_liking_Sex.ED_mod = lmer(EDavg_rating~sex*ED + (1|ParID), data = SC_FoodRating_likert_EDlong[SC_FoodRating_likert_EDlong$rating == 'Like', ])
foodRating_liking_Sex.ED_ANOVA = anova(foodRating_liking_Sex.ED_mod)
foodRating_liking_Sex.ED_sig_stars = c("", "**", "")
foodRating_liking_Sex.ED_tab = sig_stars_lmerTestAll.table(foodRating_liking_Sex.ED_ANOVA, foodRating_liking_Sex.ED_sig_stars)

#### ####
#### ####

#####################################
####                            
####            MeanRT             ####
####                            
#####################################
#### CorMat: SCSR correlation matrx
meanRT_vars = MouseT_sumDat[c(11, 29, 21)]
meanRT_varames = names(MouseT_sumDat)[c(11, 29, 21)]
meanRT_cormat = cor.matrix(meanRT_vars, meanRT_varames)
meanRT_cormat_ps = cor.matrix_ps(meanRT_vars, meanRT_varames)

#### ttest: meanRT - Mouse and Sex
meanRT_mouse_sex_ttest = t.test(meanRT_mouse~sex, data = MouseT_sumDat)

#### ####
#### ####
#####################################
####                            
####            SCSR             ####
####                            
##################################### 
#Remove 164 - no SC trials - and 132 - health and taste ratings colinear
MouseT_sumDat_SCSR= MouseT_sumDat[MouseT_sumDat$ParID != 164 & MouseT_sumDat$ParID != 132, ]

#### HistPlot: SCSR
SCSR_histplot = ggplot(MouseT_sumDat_SCSR, aes(percSC_success)) +
  geom_histogram(binwidth=.05, color = 'black', fill = 'white') +
  ggtitle('Distribution of Self Control Success Ratio') +
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### CorMat: SCSR correlation matrx
SCSR_vars = MouseT_sumDat_SCSR[c(5, 11, 2, 29, 21)]
SCSR_varames = names(MouseT_sumDat_SCSR)[c(5, 11, 2, 29, 21)]
SCSR_cormat = cor.matrix(SCSR_vars, SCSR_varames)
SCSR_cormat_ps = cor.matrix_ps(SCSR_vars, SCSR_varames)

#### ttest: SCSR and Sex
SCSR_sex_ttest = t.test(percSC_success~sex, data = MouseT_sumDat_SCSR)

#### ####
#### ####
#####################################
####                            
####  All Trials: Group T-Tests by Attribute    ####
####                            
#####################################
# Load datasets ####
#run if have not compiled the following datasets:
#1)MouseT_sig_ttest_Tstamp_nodelete.csv
#source('3a_MouseTrack_angleRegression_Sullivan.R')

#Group t-test sig points
MouseT_sigTime_Group_Tstamp_nodelete = read.csv('Data/Databases/MouseT_sig_ttest_Tstamp_nodelete.csv', header = TRUE)

#### Table: sigToEnd_10 present
Group_lastsig10_tab = xtabs(~Group + Rating, data = MouseT_sigTime_Group_Tstamp_nodelete[MouseT_sigTime_Group_Tstamp_nodelete$sigToEnd_10 == 'Y', ])

#### Table: sigTime for health across approaches
Group_firstSigTP_health_Tstamp_nodelete = data.frame(matrix(c('All','HW', 'OB', 52, 50, 0), nrow = 3, ncol = 2, byrow = FALSE))
names(Group_firstSigTP_health_Tstamp_nodelete) = c('Group', 'Tstamp_nodelete')

#### ####
#### ####
#####################################
####                            
####  All Trials: Ind STPs ####
####                            
#####################################
# Load datasets ####
#run if have not compiled the following datasets:
#1)MouseT_regDat_Tstamp_nodelete.csv
#2)MouseT_ind_sigTimes_Tstamp_nodelete.csv
#source('3a_MouseTrack_angleRegression_Sullivan.R')

#Individual Regression Data
MouseT_indReg_Tstamp_nodelete = read.csv('Data/Databases/MouseT_regDat_Tstamp_nodelete.csv', header = TRUE)
MouseT_indReg_Tstamp_nodelete$cAge_yr = MouseT_indReg_Tstamp_nodelete$cAge_mo/12

#Individual Regression sig points
MouseT_ind_sigTimes_Tstamp_nodelete = read.csv('Data/Databases/MouseT_ind_sigTimes_Tstamp_nodelete.csv', header = TRUE)
MouseT_ind_sigTimes_Tstamp_nodelete$cAge_yr = MouseT_ind_sigTimes_Tstamp_nodelete$cAge_mo/12
MouseT_ind_sigTimes_Tstamp_nodelete$method = 'Tstamp_nodelete'

#reduce to just coefficients
MouseT_indReg_coef = MouseT_indReg_Tstamp_nodelete[MouseT_indReg_Tstamp_nodelete$measure == 'coef', ]

## make long database by time for IndReg
MouseT_indReg_long = reshape2::melt(MouseT_indReg_coef, id.vars = names(MouseT_indReg_coef[1:32]))

#make a timepoint variable
MouseT_indReg_long$TimePoint = as.numeric(gsub( "t", "", as.character(MouseT_indReg_long$variable)))

#rename outcome variable
MouseT_indReg_long$Coef = MouseT_indReg_long$value

#clean variables
MouseT_indReg_long = MouseT_indReg_long[c(1:32, 35:36)]

#get subsets for each rating
MouseT_indReg_long_health = MouseT_indReg_long[MouseT_indReg_long$rating == 'health', ]
MouseT_indReg_long_taste= MouseT_indReg_long[MouseT_indReg_long$rating == 'taste', ]
MouseT_indReg_long_liking = MouseT_indReg_long[MouseT_indReg_long$rating == 'liking', ]

## subset sigTime data by ratings and those with STPs
MouseT_ind_sigTimes_health = MouseT_ind_sigTimes_Tstamp_nodelete[MouseT_ind_sigTimes_Tstamp_nodelete$Rating == 'health' & MouseT_ind_sigTimes_Tstamp_nodelete$sigToEnd_10 == 'Y', ]
MouseT_ind_sigTimes_taste = MouseT_ind_sigTimes_Tstamp_nodelete[MouseT_ind_sigTimes_Tstamp_nodelete$Rating == 'taste' & MouseT_ind_sigTimes_Tstamp_nodelete$sigToEnd_10 == 'Y', ]
MouseT_ind_sigTimes_liking = MouseT_ind_sigTimes_Tstamp_nodelete[MouseT_ind_sigTimes_Tstamp_nodelete$Rating == 'liking' & MouseT_ind_sigTimes_Tstamp_nodelete$sigToEnd_10 == 'Y', ]

## Add sigtoend_10 info to individual regression estimates
#need to edit name to match between dsets
MouseT_indReg_long$Rating = MouseT_indReg_long$rating

#merge just sigtoend_10 between dsets
MouseT_indReg_long = merge(MouseT_indReg_long, MouseT_ind_sigTimes_Tstamp_nodelete[c(1, 31, 35)], by = c('ParID', 'Rating'))

## Make Wide data for sigTimes
#MouseT_ind_sigTimes_wideratings = dcast(MouseT_ind_sigTimes_Tstamp_nodelete[MouseT_ind_sigTimes_Tstamp_nodelete$sigToEnd_10 == 'Y', c(1:2, 5, 11:12, 17, 19, 25:26, 59:61, 80, 82)], 
  #                                      ParID + Hunger + percSC_success + meanRT_mouse + medRT_mouse + sex + cAge_group + cBodyMass_z + cBodyMass_p + FF_preTask + FF_postTask + cAge_yr ~ Rating, value.var = "lastSig_start", fun.aggregate = mean)

#####################################
####                            
####  All Trials: Ind SigTime - STP Present  ####   
####                            
#####################################
#### ANOVA: SigPres v Absent and SCSR
IndSigTime_STP.Rating_SCSR_mod = lm(percSC_success~sigToEnd_10*Rating, data = MouseT_ind_sigTimes_Tstamp_nodelete)
IndSigTime_STP.Rating_SCSR_anova = Anova(IndSigTime_STP.Rating_SCSR_mod, type = 3)
IndSigTime_STP.Rating_SCSR_sig_stars = c("***", "", "", "", "")
IndSigTime_STP.Rating_SCSR_tab = sig_stars.table(IndSigTime_STP.Rating_SCSR_anova, IndSigTime_STP.Rating_SCSR_sig_stars)

#### ANOVA: SigPres v Absent and Age
IndSigTime_STP.Rating_Age_mod = lm(cAge_yr~sigToEnd_10*Rating, data = MouseT_ind_sigTimes_Tstamp_nodelete)
IndSigTime_STP.Rating_Age_anova = Anova(IndSigTime_STP.Rating_Age_mod, type = 3)
IndSigTime_STP.Rating_Age_sig_stars = c("***", "", "", "", "")
IndSigTime_STP.Rating_Age_tab = sig_stars.table(IndSigTime_STP.Rating_Age_anova, IndSigTime_STP.Rating_Age_sig_stars)

#### ANOVA: SigPres v Absent and BMI percentile
IndSigTime_STP.Rating_BMIp_mod = lm(cBodyMass_p~sigToEnd_10*Rating, data = MouseT_ind_sigTimes_Tstamp_nodelete)
IndSigTime_STP.Rating_BMIp_anova = Anova(IndSigTime_STP.Rating_BMIp_mod, type = 3)
IndSigTime_STP.Rating_BMIp_sig_stars = c("***", "", "", "", "")
IndSigTime_STP.Rating_BMIp_tab = sig_stars.table(IndSigTime_STP.Rating_BMIp_anova, IndSigTime_STP.Rating_BMIp_sig_stars)

#### chi: SigPres v Absent sex
IndSigTime_STP.Rating_sex_tab = xtabs(~sex + sigToEnd_10 + Rating, data = MouseT_ind_sigTimes_Tstamp_nodelete)
IndSigTime_STP.Rating_sex_tab_nice = matrix(c(21, 10, 19, 12, 19, 12, 19, 15, 15, 19, 18, 16), ncol = 2, byrow = FALSE)
rownames(IndSigTime_STP.Rating_sex_tab_nice) = c('HealthSTP_yes', 'HealthSTP_no', 'TasteSTP_yes', 'TasteSTP_no', 'LikingSTP_yes', 'LikingSTP_no')
colnames(IndSigTime_STP.Rating_sex_tab_nice) = c('Boy', 'Girl')

IndSigTime_STP.Rating_sex_MHT = mantelhaen.test(IndSigTime_STP.Rating_sex_tab)


#### ANOVA: STP present x Hunger
IndSigTime_STP.Rating_Hunger_mod = lm(Hunger~sigToEnd_10*Rating, data = MouseT_ind_sigTimes_Tstamp_nodelete)
IndSigTime_STP.Rating_Hunger_anova = Anova(IndSigTime_STP.Rating_Hunger_mod, type = 3)
IndSigTime_STP.Rating_Hunger_sig_stars = c("***", "", "", "*", "")
IndSigTime_STP.Rating_Hunger_tab = sig_stars.table(IndSigTime_STP.Rating_Hunger_anova, IndSigTime_STP.Rating_Hunger_sig_stars)

IndSigTime_STP.Rating_Hunger_emmeans = emmeans(IndSigTime_STP.Rating_Hunger_mod, pairwise ~ sigToEnd_10 | Rating)

#check without outlier value
IndSigTime_STP.Rating_Hunger_mod_no159 = lm(Hunger~sigToEnd_10*Rating, data = MouseT_ind_sigTimes_Tstamp_nodelete[MouseT_ind_sigTimes_Tstamp_nodelete$ParID != 159, ])
IndSigTime_STP.Rating_Hunger_anova_no159 = Anova(IndSigTime_STP.Rating_Hunger_mod_no159, type = 3)
IndSigTime_STP.Rating_Hunger_sig_stars_no159 = c("***", "", "", "*", "")
IndSigTime_STP.Rating_Hunger_tab_no159 = sig_stars.table(IndSigTime_STP.Rating_Hunger_anova_no159, IndSigTime_STP.Rating_Hunger_sig_stars_no159)

IndSigTime_STP.Rating_Hunger_emmeans_no159 = emmeans(IndSigTime_STP.Rating_Hunger_mod_no159, pairwise ~ sigToEnd_10 | Rating)

#### ####
#### ####
#####################################
####                            
####  All Trials: Ind SigTime by Attribute ####
####                            
#####################################
#### ANOVA: SigTime ~ Rating
IndSigTime_Rating_nodelete_mod = lmer(lastSig_start~Rating + (1|ParID), data = MouseT_ind_sigTimes_Tstamp_nodelete[MouseT_ind_sigTimes_Tstamp_nodelete$sigToEnd_10 == 'Y', ])
IndSigTime_Rating_nodelete_ANVOA = anova(IndSigTime_Rating_nodelete_mod)
IndSigTime_Rating_nodelete_sig_stars = c("")
IndSigTime_Rating_nodelete_tab = sig_stars_lmerTestAll.table(IndSigTime_Rating_nodelete_ANVOA, IndSigTime_Rating_nodelete_sig_stars)

#### CoefPlot: Tstamp_NoDelete Coef by TimePoint and Rating
IndCoef_plot_allratings = ggplot(MouseT_indReg_long[MouseT_indReg_long$sigToEnd_10 == 'Y', ], aes(x=TimePoint, y=Coef, color=rating),
                                                 environment=environment ()) + scale_color_manual(values = c('darkorchid4', 'deepskyblue2', 'darkorange1')) +
  geom_smooth(method = 'loess', formula ='y ~ x', se=TRUE, fullrange=F, fill = 'lightgrey') +
  scale_y_continuous(name='beta Attribute Difference') +
  scale_x_continuous(name='Time Point') +
  geom_vline(xintercept=66.8, color = 'darkorchid4') +
  geom_vline(xintercept=67.4, color = 'darkorange1') +
  geom_vline(xintercept=66.5, color = 'deepskyblue2') +
  ggtitle('Rating Differences Predict Mouse Trajectory by Attribute') +
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### Table: individuals with sigTime by rating and approach
GroupCount_lastsig10_rating_tab = xtabs(~ Rating, data = MouseT_ind_sigTimes_Tstamp_nodelete[MouseT_ind_sigTimes_Tstamp_nodelete$sigToEnd_10 == 'Y', ])
GroupCount_lastsig10_rating_chi = chisq.test(GroupCount_lastsig10_rating_tab)

#### Table: Tstamp No Delete SigTime by Attribute
IndSigTime_Rating_mean = means.function.na(MouseT_ind_sigTimes_Tstamp_nodelete[MouseT_ind_sigTimes_Tstamp_nodelete$sigToEnd_10 == 'Y', ],
                                           MouseT_ind_sigTimes_Tstamp_nodelete[MouseT_ind_sigTimes_Tstamp_nodelete$sigToEnd_10 == 'Y', ]$lastSig_start,
                                           MouseT_ind_sigTimes_Tstamp_nodelete[MouseT_ind_sigTimes_Tstamp_nodelete$sigToEnd_10 == 'Y', ]$Rating)
IndSigTime_Rating_sd = sd.function.na(MouseT_ind_sigTimes_Tstamp_nodelete[MouseT_ind_sigTimes_Tstamp_nodelete$sigToEnd_10 == 'Y', ],
                                         MouseT_ind_sigTimes_Tstamp_nodelete[MouseT_ind_sigTimes_Tstamp_nodelete$sigToEnd_10 == 'Y', ]$lastSig_start,
                                         MouseT_ind_sigTimes_Tstamp_nodelete[MouseT_ind_sigTimes_Tstamp_nodelete$sigToEnd_10 == 'Y', ]$Rating)
IndSigTime_Rating_range = range.function.na(MouseT_ind_sigTimes_Tstamp_nodelete[MouseT_ind_sigTimes_Tstamp_nodelete$sigToEnd_10 == 'Y', ],
                                      MouseT_ind_sigTimes_Tstamp_nodelete[MouseT_ind_sigTimes_Tstamp_nodelete$sigToEnd_10 == 'Y', ]$lastSig_start,
                                      MouseT_ind_sigTimes_Tstamp_nodelete[MouseT_ind_sigTimes_Tstamp_nodelete$sigToEnd_10 == 'Y', ]$Rating)


#### ####
#### ####
#####################################
####                            
####  All Trials: TVEM plots  ####      
####                            
#####################################
# data org ####
#run if have not compiled the following datasets:
#1)TVEM_FinalMods_PlotData.csv
#source('4b_MouseTrack_angles_TVEMplotdata.R')
#Note: this requires that you have already formatted 
#dsets into format for TVEM (script 5a_MouseTrack_angles_TVEMformat.R)
#and have run the TVEM models in SAS

#load data
MouseT_TVEMplotdata = read.csv('Data/Databases/TVEM_FinalMods_PlotData.csv', header = TRUE)

#### All trials
MouseT_TVEMplotdata_alltrials = MouseT_TVEMplotdata[grepl("lk|htk", names(MouseT_TVEMplotdata)) & 
                                                      !grepl("intercept", names(MouseT_TVEMplotdata))]

MouseT_TVEMplotdata_alltrials_long = reshape2::melt(MouseT_TVEMplotdata_alltrials[c(1:2, 6, 11)], id.vars = names(MouseT_TVEMplotdata_alltrials)[1])

alltrials_coef_long = reshape2::melt(MouseT_TVEMplotdata_alltrials[c(1, 3, 7, 12)], id.vars = names(MouseT_TVEMplotdata_alltrials)[1])
alltrials_upper_long = reshape2::melt(MouseT_TVEMplotdata_alltrials[c(1, 4, 8, 13)], id.vars = names(MouseT_TVEMplotdata_alltrials)[1])

MouseT_TVEMplotdata_alltrials_long = data.frame(MouseT_TVEMplotdata_alltrials_long, alltrials_coef_long[3], alltrials_upper_long[3])
names(MouseT_TVEMplotdata_alltrials_long) = c("TimePoint", "Rating", "Lower95", "Coef", "Upper95")

#### All trials - Liking split by BMIpercentile Quartile
MouseT_TVEMplotdata_alltrials_likingBMIpQ = MouseT_TVEMplotdata[grepl("lbmic|lbmiq1|lbmiq4", names(MouseT_TVEMplotdata)) & 
                                                                  !grepl("intercept", names(MouseT_TVEMplotdata))]

MouseT_TVEMplotdata_alltrials_likingBMIpQ_long = reshape2::melt(MouseT_TVEMplotdata_alltrials_likingBMIpQ[c(1:2, 7, 12)], id.vars = names(MouseT_TVEMplotdata_alltrials_likingBMIpQ)[1])

alltrials_likingBMIpQ_coef_long = reshape2::melt(MouseT_TVEMplotdata_alltrials_likingBMIpQ[c(1, 3, 8, 13)], id.vars = names(MouseT_TVEMplotdata_alltrials_likingBMIpQ)[1])
alltrials_likingBMIpQ_upper_long = reshape2::melt(MouseT_TVEMplotdata_alltrials_likingBMIpQ[c(1, 4, 9, 14)], id.vars = names(MouseT_TVEMplotdata_alltrials_likingBMIpQ)[1])

MouseT_TVEMplotdata_alltrials_likingBMIpQ_long = data.frame(MouseT_TVEMplotdata_alltrials_likingBMIpQ_long, alltrials_likingBMIpQ_coef_long[3], alltrials_likingBMIpQ_upper_long[3])
names(MouseT_TVEMplotdata_alltrials_likingBMIpQ_long) = c("TimePoint", "BMIpQ", "Lower95", "Coef", "Upper95")

#### All trials - Liking split by SCSR
MouseT_TVEMplotdata_alltrials_likingSCSR = MouseT_TVEMplotdata[grepl("lsr1q|lsr4q|lsrc", names(MouseT_TVEMplotdata)) & 
                                                                 !grepl("intercept", names(MouseT_TVEMplotdata)) & 
                                                                 !grepl("fl|gl", names(MouseT_TVEMplotdata))]

MouseT_TVEMplotdata_alltrials_likingSCSR_long = reshape2::melt(MouseT_TVEMplotdata_alltrials_likingSCSR[c(1:2, 7, 12)], id.vars = names(MouseT_TVEMplotdata_alltrials_likingSCSR)[1])

alltrials_likingSCSR_coef_long = reshape2::melt(MouseT_TVEMplotdata_alltrials_likingSCSR[c(1, 3, 8, 13)], id.vars = names(MouseT_TVEMplotdata_alltrials_likingSCSR)[1])
alltrials_likingSCSR_upper_long = reshape2::melt(MouseT_TVEMplotdata_alltrials_likingSCSR[c(1, 4, 9, 14)], id.vars = names(MouseT_TVEMplotdata_alltrials_likingSCSR)[1])

MouseT_TVEMplotdata_alltrials_likingSCSR_long = data.frame(MouseT_TVEMplotdata_alltrials_likingSCSR_long[c(1:3)], alltrials_likingSCSR_coef_long[3], alltrials_likingSCSR_upper_long[3])

names(MouseT_TVEMplotdata_alltrials_likingSCSR_long) = c("TimePoint", "SCSR", "Lower95", "Coef", "Upper95")


#### All trials - Health split by SCSR
MouseT_TVEMplotdata_alltrials_healthtasteSCSR = MouseT_TVEMplotdata[grepl("htsr1q|htsrk4q|htsrc", names(MouseT_TVEMplotdata)) & 
                                                                      !grepl("intercept", names(MouseT_TVEMplotdata)) &
                                                                      !grepl("fht|ght", names(MouseT_TVEMplotdata))]

MouseT_TVEMplotdata_alltrials_healthtasteSCSR_long = reshape2::melt(MouseT_TVEMplotdata_alltrials_healthtasteSCSR[c(1:2, 6, 11, 15, 21, 24)], id.vars = names(MouseT_TVEMplotdata_alltrials_healthtasteSCSR)[1])

alltrials_healthtasteSCSR_coef_long = reshape2::melt(MouseT_TVEMplotdata_alltrials_healthtasteSCSR[c(1, 3, 7, 12, 16, 22, 25)], id.vars = names(MouseT_TVEMplotdata_alltrials_healthtasteSCSR)[1])
alltrials_healthtasteSCSR_upper_long = reshape2::melt(MouseT_TVEMplotdata_alltrials_healthtasteSCSR[c(1, 4, 8, 13, 17, 23, 26)], id.vars = names(MouseT_TVEMplotdata_alltrials_healthtasteSCSR)[1])

MouseT_TVEMplotdata_alltrials_healthtasteSCSR_long$Rating = ifelse(grepl('Health', MouseT_TVEMplotdata_alltrials_healthtasteSCSR_long$variable), 'Health', 'Taste')

MouseT_TVEMplotdata_alltrials_healthtasteSCSR_long = data.frame(MouseT_TVEMplotdata_alltrials_healthtasteSCSR_long[c(1:2, 4, 3)], alltrials_healthtasteSCSR_coef_long[3], alltrials_healthtasteSCSR_upper_long[3])

names(MouseT_TVEMplotdata_alltrials_healthtasteSCSR_long) = c("TimePoint", "SCSR", "Rating", "Lower95", "Coef", "Upper95")


# Plots ####
#### TVEMPlot: All trials by TimePoint and Rating
ribbon_data_allratings = MouseT_TVEMplotdata_alltrials_long[MouseT_TVEMplotdata_alltrials_long$Upper95 > 0 & MouseT_TVEMplotdata_alltrials_long$Lower95 > 0, ]
range_allratings = max(MouseT_TVEMplotdata_alltrials_long$Upper95) - min(MouseT_TVEMplotdata_alltrials_long$Lower95)

TVEM_plot_allratings = ggplot(MouseT_TVEMplotdata_alltrials_long, aes(x=TimePoint, y=Coef, color=Rating),
                                 environment=environment ()) + 
  scale_color_manual(values = c('darkorchid4', 'darkorange1', 'deepskyblue2')) +
  scale_y_continuous(name='Coef', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  ggtitle('All Trials: TVEM coefficients with 95% confidence bounds') +
  geom_line(data = MouseT_TVEMplotdata_alltrials_long, aes(x = TimePoint, y = Coef), linetype = 1, size = 1.5) +
  geom_line(data = MouseT_TVEMplotdata_alltrials_long, aes(x = TimePoint, y = Upper95), linetype = 4, size = 1.5) +
  geom_line(data = MouseT_TVEMplotdata_alltrials_long, aes(x = TimePoint, y = Lower95), linetype = 4, size = 1.5) +
  geom_ribbon(data = ribbon_data_allratings[ribbon_data_allratings$Rating == 'htk2c5_HealthDif_L', ], mapping = aes(ymin=min(MouseT_TVEMplotdata_alltrials_long$Lower95), ymax = min(MouseT_TVEMplotdata_alltrials_long$Lower95)+.025*range_allratings), fill = 'darkorchid4') +
  geom_ribbon(data = ribbon_data_allratings[ribbon_data_allratings$Rating == 'htk2c5_TasteDif_L', ], mapping = aes(ymin=min(MouseT_TVEMplotdata_alltrials_long$Lower95)+.025*range_allratings, ymax = min(MouseT_TVEMplotdata_alltrials_long$Lower95)+.05*range_allratings), fill = 'darkorange1') +
  geom_hline(yintercept = 0, color = 'black', linetype = "dashed") + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### TVEMPlot: Liking by BMI quartiles combind plot
shade_data_liking.BMIpQ = MouseT_TVEMplotdata[c('lbmi2c1cplot_TimePoint', 'lbmi2c1cplot_BMIp_LDif_int')]
shade_data_liking.BMIpQ$BMIpQ = NA
names(shade_data_liking.BMIpQ) = c('TimePoint', 'Coef', 'BMIpQ')

ribbon_data_liking.BMIpQ = MouseT_TVEMplotdata[MouseT_TVEMplotdata$lbmi2c1cplot_BMIp_LDif_int_U > 0 & MouseT_TVEMplotdata$lbmi2c1cplot_BMIp_LDif_int_L > 0, c('lbmi2c1cplot_TimePoint', 'lbmi2c1cplot_BMIp_LDif_int')]
ribbon_data_liking.BMIpQ$BMIpQ = NA
names(ribbon_data_liking.BMIpQ) = c('TimePoint', 'Coef', 'BMIpQ')

range_liking.BMIpQ = max(MouseT_TVEMplotdata_alltrials_likingBMIpQ_long$Coef/10) - min(MouseT_TVEMplotdata_alltrials_likingBMIpQ_long$Coef/10)+0.01

TVEM_plot_liking.BMIpQ = ggplot(shade_data_liking.BMIpQ, aes(x=TimePoint),
                                                   environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('All Trials Liking: TVEM coefficients with 95% confidence bounds by Weight Status') +
  geom_ribbon(data = ribbon_data_liking.BMIpQ, mapping = aes(ymin=min(MouseT_TVEMplotdata_alltrials_likingBMIpQ_long$Coef/10)-0.01, ymax = min(MouseT_TVEMplotdata_alltrials_likingBMIpQ_long$Coef/10)-0.01+.025*range_liking.BMIpQ), fill = 'deepskyblue2') +
  geom_ribbon(data = MouseT_TVEMplotdata, mapping = aes(ymin=lbmi2c1cplot_BMIp_LDif_int_L, ymax=lbmi2c1cplot_BMIp_LDif_int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_TVEMplotdata_alltrials_likingBMIpQ_long, aes(x = TimePoint, y = Coef/10, color=BMIpQ), linetype = 1, size = 1.5) +
  geom_line(data = shade_data_liking.BMIpQ, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~.*10, name = "Coef of Liking", breaks=pretty_breaks(n = 7)),
                     name='Coef of Liking x Weight Status Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c( 'deepskyblue2','mediumturquoise', 'blue4')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### TVEMPlot: Liking by SCSR quartiles combind plot
shade_data_liking.SCSR = MouseT_TVEMplotdata[c('lscsr2c1cplot_TimePoint', 'lscsr2c1cplot_SCSR_LDif_int')]
shade_data_liking.SCSR$SCSR = NA
names(shade_data_liking.SCSR) = c('TimePoint', 'Coef', 'SCSR')

ribbon_data_liking.SCSR = MouseT_TVEMplotdata[MouseT_TVEMplotdata$lscsr2c1cplot_SCSR_LDif_int_U < 0 & MouseT_TVEMplotdata$lscsr2c1cplot_SCSR_LDif_int_L < 0, c('lscsr2c1cplot_TimePoint', 'lscsr2c1cplot_SCSR_LDif_int')]
ribbon_data_liking.SCSR$SCSR = NA
names(ribbon_data_liking.SCSR) = c('TimePoint', 'Coef', 'SCSR')

range_liking.SCSR = max(MouseT_TVEMplotdata$lscsr2c1cplot_SCSR_LDif_int_U) - min(MouseT_TVEMplotdata$lscsr2c1cplot_SCSR_LDif_int_L)+0.5

TVEM_plot_liking.SCSR = ggplot(shade_data_liking.SCSR, aes(x=TimePoint),
                                                  environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('All Trials Liking: TVEM coefficients with 95% confidence bounds by SCSR') +
  geom_ribbon(data = ribbon_data_liking.SCSR, mapping = aes(ymin=min(MouseT_TVEMplotdata$lscsr2c1cplot_SCSR_LDif_int_L)-0.5, ymax = min(MouseT_TVEMplotdata$lscsr2c1cplot_SCSR_LDif_int_L)-0.5+.025*range_liking.SCSR), fill = 'deepskyblue2') +
  geom_ribbon(data = MouseT_TVEMplotdata, mapping = aes(ymin=lscsr2c1cplot_SCSR_LDif_int_L, ymax=lscsr2c1cplot_SCSR_LDif_int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_TVEMplotdata_alltrials_likingSCSR_long, aes(x = TimePoint, y = Coef*3, color=SCSR), linetype = 1, size = 1.5) +
  geom_line(data = shade_data_liking.SCSR, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~./3, name = "Coef of Liking", breaks=pretty_breaks(n = 7)),
                     name='Coef of Liking x SCSR Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c('mediumturquoise', 'blue4', 'deepskyblue2')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### TVEMPlot: Health by SCSR combind plot
MouseT_TVEMplotdata_alltrials_healthSCSR_long = MouseT_TVEMplotdata_alltrials_healthtasteSCSR_long[MouseT_TVEMplotdata_alltrials_healthtasteSCSR_long$Rating == 'Health', ]
MouseT_TVEMplotdata_alltrials_healthSCSR_long$Rating = factor(MouseT_TVEMplotdata_alltrials_healthSCSR_long$Rating)

shade_data_health.SCSR = MouseT_TVEMplotdata[c('htscsr2cc1ccplot_TimePoint', 'htscsr2cc1ccplot_SCSR_Hdif_int')]
shade_data_health.SCSR$SCSR = NA
names(shade_data_health.SCSR) = c('TimePoint', 'Coef', 'SCSR')

ribbon_data_health.SCSR = MouseT_TVEMplotdata[MouseT_TVEMplotdata$htscsr2cc1ccplot_SCSR_Hdif_int_U > 0 & MouseT_TVEMplotdata$htscsr2cc1ccplot_SCSR_Hdif_int_L > 0, c('htscsr2cc1ccplot_TimePoint', 'htscsr2cc1ccplot_SCSR_Hdif_int')]
ribbon_data_health.SCSR$SCSR = NA
names(ribbon_data_health.SCSR) = c('TimePoint', 'Coef', 'SCSR')

range_health.SCSR = max(MouseT_TVEMplotdata$htscsr2cc1ccplot_SCSR_Hdif_int_U) - min(MouseT_TVEMplotdata$htscsr2cc1ccplot_SCSR_Hdif_int_L)

TVEM_plot_health.SCSR = ggplot(shade_data_health.SCSR, aes(x=TimePoint),
                                                  environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('All Trials Health: TVEM coefficients with 95% confidence bounds by SCSR') +
  geom_ribbon(data = ribbon_data_health.SCSR, mapping = aes(ymin=min(MouseT_TVEMplotdata$htscsr2cc1ccplot_SCSR_Hdif_int_L)-0.1, ymax = min( MouseT_TVEMplotdata$htscsr2cc1ccplot_SCSR_Hdif_int_L)-0.1+.025*range_health.SCSR), fill = 'darkorchid4') +
  geom_ribbon(data = MouseT_TVEMplotdata, mapping = aes(ymin=htscsr2cc1ccplot_SCSR_Hdif_int_L, ymax = htscsr2cc1ccplot_SCSR_Hdif_int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_TVEMplotdata_alltrials_healthSCSR_long, aes(x = TimePoint, y = Coef*2, color=SCSR), linetype = 1, size = 1.5) +
  geom_line(data = shade_data_health.SCSR, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~./2, name = "Coef of Health", breaks=pretty_breaks(n = 7)),
                     name='Coef of Health x SCSR Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c('mediumturquoise', 'deepskyblue2', 'blue4')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### TVEMPlot: Taste by SCSR combind plot
MouseT_TVEMplotdata_alltrials_tasteSCSR_long = MouseT_TVEMplotdata_alltrials_healthtasteSCSR_long[MouseT_TVEMplotdata_alltrials_healthtasteSCSR_long$Rating == 'Taste', ]
MouseT_TVEMplotdata_alltrials_tasteSCSR_long$Rating = factor(MouseT_TVEMplotdata_alltrials_tasteSCSR_long$Rating)

shade_data_taste.SCSR = MouseT_TVEMplotdata[c('htscsr2cc1ccplot_TimePoint', 'htscsr2cc1ccplot_SCSR_Tdif_int')]
shade_data_taste.SCSR$SCSR = NA
names(shade_data_taste.SCSR) = c('TimePoint', 'Coef', 'SCSR')

ribbon_data_taste.SCSR = MouseT_TVEMplotdata[MouseT_TVEMplotdata$htscsr2cc1ccplot_SCSR_Tdif_int_U < 0 & MouseT_TVEMplotdata$htscsr2cc1ccplot_SCSR_Tdif_int_L < 0, c('htscsr2cc1ccplot_TimePoint', 'htscsr2cc1ccplot_SCSR_Tdif_int')]
ribbon_data_taste.SCSR$SCSR = NA
names(ribbon_data_taste.SCSR) = c('TimePoint', 'Coef', 'SCSR')

range_taste.SCSR = max(MouseT_TVEMplotdata$htscsr2cc1ccplot_SCSR_Tdif_int_U) - min(MouseT_TVEMplotdata$htscsr2cc1ccplot_SCSR_Tdif_int_L)-1

TVEM_plot_taste.SCSR = ggplot(shade_data_taste.SCSR, aes(x=TimePoint),
                                                 environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('All Trials Taste: TVEM coefficients with 95% confidence bounds by SCSR') +
  geom_ribbon(data = ribbon_data_taste.SCSR, mapping = aes(ymin=min(MouseT_TVEMplotdata$htscsr2cc1ccplot_SCSR_Tdif_int_L)-1, ymax = min( MouseT_TVEMplotdata$htscsr2cc1ccplot_SCSR_Tdif_int_L)-1+.025*range_taste.SCSR), fill = 'darkorange1') +
  geom_ribbon(data = MouseT_TVEMplotdata, mapping = aes(ymin=htscsr2cc1ccplot_SCSR_Tdif_int_L, ymax = htscsr2cc1ccplot_SCSR_Tdif_int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_TVEMplotdata_alltrials_tasteSCSR_long, aes(x = TimePoint, y = Coef*3, color=SCSR), linetype = 1, size = 1.5) +
  geom_line(data = shade_data_taste.SCSR, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~./3, name = "Coef of Taste", breaks=pretty_breaks(n = 7)),
                     name='Coef of Taste x SCSR Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c('mediumturquoise', 'deepskyblue2', 'blue4')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### ####
#### ####
#####################################
####                            
####  All Trials: TVEM plots  ####   
####  nSC controlled  ####   
####                            
#####################################
# data org ####
#run if have not compiled the following datasets:
#1)TVEM_FinalMods_PlotData.csv
#source('4c_MouseTrack_angles_nnSCcontrolled_TVEMplotdata.R')
#Note: this requires that you have already formatted 
#dsets into format for TVEM (script 5a_MouseTrack_angles_TVEMformat.R)
#and have run the TVEM models in SAS

#load data
MouseT_nSCcont_TVEMplotdata = read.csv('Data/Databases/TVEM_FinalMods_nSCcontrolled_PlotData.csv', header = TRUE)

#### All trials
MouseT_nSCcont_TVEMplotdata_alltrials = MouseT_nSCcont_TVEMplotdata[grepl("lk|htk", names(MouseT_nSCcont_TVEMplotdata)) & 
                                                      !grepl("intercept", names(MouseT_nSCcont_TVEMplotdata))]

MouseT_nSCcont_TVEMplotdata_alltrials_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_alltrials[c(1, 6, 10, 19)], id.vars = names(MouseT_nSCcont_TVEMplotdata_alltrials)[1])

alltrials_coef_nSCcont_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_alltrials[c(1, 7, 11, 20)], id.vars = names(MouseT_nSCcont_TVEMplotdata_alltrials)[1])
alltrials_upper_nSCcont_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_alltrials[c(1, 8, 12, 21)], id.vars = names(MouseT_nSCcont_TVEMplotdata_alltrials)[1])

MouseT_nSCcont_TVEMplotdata_alltrials_long = data.frame(MouseT_nSCcont_TVEMplotdata_alltrials_long, alltrials_coef_nSCcont_long[3], alltrials_upper_nSCcont_long[3])
names(MouseT_nSCcont_TVEMplotdata_alltrials_long) = c("TimePoint", "Rating", "Lower95", "Coef", "Upper95")

#### All trials - Liking split by BMIpercentile Quartile
MouseT_nSCcont_TVEMplotdata_alltrials_likingBMIpQ = MouseT_nSCcont_TVEMplotdata[grepl("lbmic|lbmiq1|lbmiq4", names(MouseT_nSCcont_TVEMplotdata)) & 
                                                                  !grepl("intercept", names(MouseT_nSCcont_TVEMplotdata))]

MouseT_nSCcont_TVEMplotdata_alltrials_likingBMIpQ_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_alltrials_likingBMIpQ[c(1, 6, 15, 24)], id.vars = names(MouseT_nSCcont_TVEMplotdata_alltrials_likingBMIpQ)[1])

alltrials_likingBMIpQ_nSCcont_coef_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_alltrials_likingBMIpQ[c(1, 7, 16, 25)], id.vars = names(MouseT_nSCcont_TVEMplotdata_alltrials_likingBMIpQ)[1])
alltrials_likingBMIpQ_nSCcont_upper_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_alltrials_likingBMIpQ[c(1, 8, 17, 26)], id.vars = names(MouseT_nSCcont_TVEMplotdata_alltrials_likingBMIpQ)[1])

MouseT_nSCcont_TVEMplotdata_alltrials_likingBMIpQ_long = data.frame(MouseT_nSCcont_TVEMplotdata_alltrials_likingBMIpQ_long, alltrials_likingBMIpQ_nSCcont_coef_long[3], alltrials_likingBMIpQ_nSCcont_upper_long[3])
names(MouseT_nSCcont_TVEMplotdata_alltrials_likingBMIpQ_long) = c("TimePoint", "BMIpQ", "Lower95", "Coef", "Upper95")

#### All trials - Liking split by SCSR
MouseT_nSCcont_TVEMplotdata_alltrials_likingSCSR = MouseT_nSCcont_TVEMplotdata[grepl("lsr1q|lsr4q|lsrc", names(MouseT_nSCcont_TVEMplotdata)) & 
                                                                 !grepl("intercept", names(MouseT_nSCcont_TVEMplotdata)) & 
                                                                 !grepl("fl|gl", names(MouseT_nSCcont_TVEMplotdata))]

MouseT_nSCcont_TVEMplotdata_alltrials_likingSCSR_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_alltrials_likingSCSR[c(1, 6, 15, 24)], id.vars = names(MouseT_nSCcont_TVEMplotdata_alltrials_likingSCSR)[1])

alltrials_likingSCSR_nSCcont_coef_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_alltrials_likingSCSR[c(1, 7, 16, 25)], id.vars = names(MouseT_nSCcont_TVEMplotdata_alltrials_likingSCSR)[1])
alltrials_likingSCSR_nSCcont_upper_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_alltrials_likingSCSR[c(1, 8, 17, 26)], id.vars = names(MouseT_nSCcont_TVEMplotdata_alltrials_likingSCSR)[1])

MouseT_nSCcont_TVEMplotdata_alltrials_likingSCSR_long = data.frame(MouseT_nSCcont_TVEMplotdata_alltrials_likingSCSR_long[c(1:3)], alltrials_likingSCSR_nSCcont_coef_long[3], alltrials_likingSCSR_nSCcont_upper_long[3])

names(MouseT_nSCcont_TVEMplotdata_alltrials_likingSCSR_long) = c("TimePoint", "SCSR", "Lower95", "Coef", "Upper95")


#### All trials - Health split by SCSR
MouseT_nSCcont_TVEMplotdata_alltrials_healthtasteSCSR = MouseT_nSCcont_TVEMplotdata[grepl("htsr1q|htsrk4q|htsrc", names(MouseT_nSCcont_TVEMplotdata)) & 
                                                                      !grepl("intercept", names(MouseT_nSCcont_TVEMplotdata)) &
                                                                      !grepl("fht|ght", names(MouseT_nSCcont_TVEMplotdata))]

MouseT_nSCcont_TVEMplotdata_alltrials_healthtasteSCSR_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_alltrials_healthtasteSCSR[c(1, 6, 10, 19, 23, 32, 36)], id.vars = names(MouseT_nSCcont_TVEMplotdata_alltrials_healthtasteSCSR)[1])

alltrials_healthtasteSCSR_nSCcont_coef_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_alltrials_healthtasteSCSR[c(1, 7, 11, 20, 24, 33, 37)], id.vars = names(MouseT_nSCcont_TVEMplotdata_alltrials_healthtasteSCSR)[1])
alltrials_healthtasteSCSR_nSCcont_upper_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_alltrials_healthtasteSCSR[c(1, 8, 12, 21, 25, 34, 38)], id.vars = names(MouseT_nSCcont_TVEMplotdata_alltrials_healthtasteSCSR)[1])

MouseT_nSCcont_TVEMplotdata_alltrials_healthtasteSCSR_long$Rating = ifelse(grepl('Health', MouseT_nSCcont_TVEMplotdata_alltrials_healthtasteSCSR_long$variable), 'Health', 'Taste')

MouseT_nSCcont_TVEMplotdata_alltrials_healthtasteSCSR_long = data.frame(MouseT_nSCcont_TVEMplotdata_alltrials_healthtasteSCSR_long[c(1:2, 4, 3)], alltrials_healthtasteSCSR_nSCcont_coef_long[3], alltrials_healthtasteSCSR_nSCcont_upper_long[3])

names(MouseT_nSCcont_TVEMplotdata_alltrials_healthtasteSCSR_long) = c("TimePoint", "SCSR", "Rating", "Lower95", "Coef", "Upper95")


# Plots ####
#### TVEMPlot: All trials by TimePoint and Rating
ribbon_nSCcont_data_allratings = MouseT_nSCcont_TVEMplotdata_alltrials_long[MouseT_nSCcont_TVEMplotdata_alltrials_long$Upper95 > 0 & MouseT_nSCcont_TVEMplotdata_alltrials_long$Lower95 > 0, ]
range_nSCcont_allratings = max(MouseT_nSCcont_TVEMplotdata_alltrials_long$Upper95) - min(MouseT_nSCcont_TVEMplotdata_alltrials_long$Lower95)

TVEM_plot_nSCcont_allratings = ggplot(MouseT_nSCcont_TVEMplotdata_alltrials_long, aes(x=TimePoint, y=Coef, color=Rating),
                              environment=environment ()) + 
  scale_color_manual(values = c('darkorchid4', 'darkorange1', 'deepskyblue2')) +
  scale_y_continuous(name='Coef', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  ggtitle('All Trials: TVEM coefficients with 95% confidence bounds') +
  geom_line(data = MouseT_nSCcont_TVEMplotdata_alltrials_long, aes(x = TimePoint, y = Coef), linetype = 1, size = 1.5) +
  geom_line(data = MouseT_nSCcont_TVEMplotdata_alltrials_long, aes(x = TimePoint, y = Upper95), linetype = 4, size = 1.5) +
  geom_line(data = MouseT_nSCcont_TVEMplotdata_alltrials_long, aes(x = TimePoint, y = Lower95), linetype = 4, size = 1.5) +
  geom_ribbon(data = ribbon_nSCcont_data_allratings[ribbon_nSCcont_data_allratings$Rating == 'htk2c5_HealthDif_L', ], mapping = aes(ymin=min(MouseT_nSCcont_TVEMplotdata_alltrials_long$Lower95), ymax = min(MouseT_nSCcont_TVEMplotdata_alltrials_long$Lower95)+.025*range_nSCcont_allratings), fill = 'darkorchid4') +
  geom_ribbon(data = ribbon_nSCcont_data_allratings[ribbon_nSCcont_data_allratings$Rating == 'htk2c5_TasteDif_L', ], mapping = aes(ymin=min(MouseT_nSCcont_TVEMplotdata_alltrials_long$Lower95)+.025*range_nSCcont_allratings, ymax = min(MouseT_nSCcont_TVEMplotdata_alltrials_long$Lower95)+.05*range_nSCcont_allratings), fill = 'darkorange1') +
  geom_hline(yintercept = 0, color = 'black', linetype = "dashed") + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### TVEMPlot: Liking by BMI quartiles combind plot
shade_nSCcont_data_liking.BMIpQ = MouseT_nSCcont_TVEMplotdata[c('lbmi2c1cplot_TimePoint', 'lbmi2c1cplot_BMIp_LDif_int')]
shade_nSCcont_data_liking.BMIpQ$BMIpQ = NA
names(shade_nSCcont_data_liking.BMIpQ) = c('TimePoint', 'Coef', 'BMIpQ')

ribbon_nSCcont_data_liking.BMIpQ = MouseT_nSCcont_TVEMplotdata[MouseT_nSCcont_TVEMplotdata$lbmi2c1cplot_BMIp_LDif_int_U > 0 & MouseT_nSCcont_TVEMplotdata$lbmi2c1cplot_BMIp_LDif_int_L > 0, c('lbmi2c1cplot_TimePoint', 'lbmi2c1cplot_BMIp_LDif_int')]
ribbon_nSCcont_data_liking.BMIpQ$BMIpQ = NA
names(ribbon_nSCcont_data_liking.BMIpQ) = c('TimePoint', 'Coef', 'BMIpQ')

range_nSCcont_liking.BMIpQ = max(MouseT_nSCcont_TVEMplotdata_alltrials_likingBMIpQ_long$Coef/10) - min(MouseT_nSCcont_TVEMplotdata_alltrials_likingBMIpQ_long$Coef/10)+0.01

TVEM_plot_nSCcont_liking.BMIpQ = ggplot(shade_nSCcont_data_liking.BMIpQ, aes(x=TimePoint),
                                environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('All Trials Liking: TVEM coefficients with 95% confidence bounds by Weight Status') +
  geom_ribbon(data = ribbon_nSCcont_data_liking.BMIpQ, mapping = aes(ymin=min(MouseT_nSCcont_TVEMplotdata_alltrials_likingBMIpQ_long$Coef/10)-0.01, ymax = min(MouseT_nSCcont_TVEMplotdata_alltrials_likingBMIpQ_long$Coef/10)-0.01+.025*range_nSCcont_liking.BMIpQ), fill = 'deepskyblue2') +
  geom_ribbon(data = MouseT_nSCcont_TVEMplotdata, mapping = aes(ymin=lbmi2c1cplot_BMIp_LDif_int_L, ymax=lbmi2c1cplot_BMIp_LDif_int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_nSCcont_TVEMplotdata_alltrials_likingBMIpQ_long, aes(x = TimePoint, y = Coef/10, color=BMIpQ), linetype = 1, size = 1.5) +
  geom_line(data = shade_nSCcont_data_liking.BMIpQ, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~.*10, name = "Coef of Liking", breaks=pretty_breaks(n = 7)),
                     name='Coef of Liking x Weight Status Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c( 'deepskyblue2','mediumturquoise', 'blue4')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### TVEMPlot: Liking by SCSR quartiles combind plot
shade_nSCcont_data_liking.SCSR = MouseT_nSCcont_TVEMplotdata[c('lscsr2c1cplot_TimePoint', 'lscsr2c1cplot_SCSR_LDif_int')]
shade_nSCcont_data_liking.SCSR$SCSR = NA
names(shade_nSCcont_data_liking.SCSR) = c('TimePoint', 'Coef', 'SCSR')

ribbon_nSCcont_data_liking.SCSR = MouseT_nSCcont_TVEMplotdata[MouseT_nSCcont_TVEMplotdata$lscsr2c1cplot_SCSR_LDif_int_U < 0 & MouseT_nSCcont_TVEMplotdata$lscsr2c1cplot_SCSR_LDif_int_L < 0, c('lscsr2c1cplot_TimePoint', 'lscsr2c1cplot_SCSR_LDif_int')]
ribbon_nSCcont_data_liking.SCSR$SCSR = NA
names(ribbon_nSCcont_data_liking.SCSR) = c('TimePoint', 'Coef', 'SCSR')

range_nSCcont_liking.SCSR = max(MouseT_nSCcont_TVEMplotdata$lscsr2c1cplot_SCSR_LDif_int_U) - min(MouseT_nSCcont_TVEMplotdata$lscsr2c1cplot_SCSR_LDif_int_L)+0.5

TVEM_plot_nSCcont_liking.SCSR = ggplot(shade_nSCcont_data_liking.SCSR, aes(x=TimePoint),
                               environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('All Trials Liking: TVEM coefficients with 95% confidence bounds by SCSR') +
  geom_ribbon(data = ribbon_nSCcont_data_liking.SCSR, mapping = aes(ymin=min(MouseT_nSCcont_TVEMplotdata$lscsr2c1cplot_SCSR_LDif_int_L)-0.5, ymax = min(MouseT_nSCcont_TVEMplotdata$lscsr2c1cplot_SCSR_LDif_int_L)-0.5+.025*range_nSCcont_liking.SCSR), fill = 'deepskyblue2') +
  geom_ribbon(data = MouseT_nSCcont_TVEMplotdata, mapping = aes(ymin=lscsr2c1cplot_SCSR_LDif_int_L, ymax=lscsr2c1cplot_SCSR_LDif_int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_nSCcont_TVEMplotdata_alltrials_likingSCSR_long, aes(x = TimePoint, y = Coef*3, color=SCSR), linetype = 1, size = 1.5) +
  geom_line(data = shade_nSCcont_data_liking.SCSR, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~./3, name = "Coef of Liking", breaks=pretty_breaks(n = 7)),
                     name='Coef of Liking x SCSR Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c('mediumturquoise', 'blue4', 'deepskyblue2')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### TVEMPlot: Health by SCSR combind plot
MouseT_nSCcont_TVEMplotdata_alltrials_healthSCSR_long = MouseT_nSCcont_TVEMplotdata_alltrials_healthtasteSCSR_long[MouseT_nSCcont_TVEMplotdata_alltrials_healthtasteSCSR_long$Rating == 'Health', ]
MouseT_nSCcont_TVEMplotdata_alltrials_healthSCSR_long$Rating = factor(MouseT_nSCcont_TVEMplotdata_alltrials_healthSCSR_long$Rating)

shade_nSCcont_data_health.SCSR = MouseT_nSCcont_TVEMplotdata[c('htsr2cc1ccplot_TimePoint', 'htsr2cc1ccplot_SCSR_Hdif_int')]
shade_nSCcont_data_health.SCSR$SCSR = NA
names(shade_nSCcont_data_health.SCSR) = c('TimePoint', 'Coef', 'SCSR')

ribbon_nSCcont_data_health.SCSR = MouseT_nSCcont_TVEMplotdata[MouseT_nSCcont_TVEMplotdata$htsr2cc1ccplot_SCSR_Hdif_int_U > 0 & MouseT_nSCcont_TVEMplotdata$htsr2cc1ccplot_SCSR_Hdif_int_L > 0, c('htsr2cc1ccplot_TimePoint', 'htsr2cc1ccplot_SCSR_Hdif_int')]
ribbon_nSCcont_data_health.SCSR$SCSR = NA
names(ribbon_nSCcont_data_health.SCSR) = c('TimePoint', 'Coef', 'SCSR')

range_nSCcont_health.SCSR = max(MouseT_nSCcont_TVEMplotdata$htsr2cc1ccplot_SCSR_Hdif_int_U) - min(MouseT_nSCcont_TVEMplotdata$htsr2cc1ccplot_SCSR_Hdif_int_L)

TVEM_plot_nSCcont_health.SCSR = ggplot(shade_nSCcont_data_health.SCSR, aes(x=TimePoint),
                               environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('All Trials Health: TVEM coefficients with 95% confidence bounds by SCSR') +
  geom_ribbon(data = ribbon_nSCcont_data_health.SCSR, mapping = aes(ymin=min(MouseT_nSCcont_TVEMplotdata$htsr2cc1ccplot_SCSR_Hdif_int_L)-0.1, ymax = min( MouseT_nSCcont_TVEMplotdata$htsr2cc1ccplot_SCSR_Hdif_int_L)-0.1+.025*range_nSCcont_health.SCSR), fill = 'darkorchid4') +
  geom_ribbon(data = MouseT_nSCcont_TVEMplotdata, mapping = aes(ymin=htsr2cc1ccplot_SCSR_Hdif_int_L, ymax = htsr2cc1ccplot_SCSR_Hdif_int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_nSCcont_TVEMplotdata_alltrials_healthSCSR_long, aes(x = TimePoint, y = Coef*2, color=SCSR), linetype = 1, size = 1.5) +
  geom_line(data = shade_nSCcont_data_health.SCSR, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~./2, name = "Coef of Health", breaks=pretty_breaks(n = 7)),
                     name='Coef of Health x SCSR Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c('mediumturquoise', 'deepskyblue2', 'blue4')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### TVEMPlot: Taste by SCSR combind plot
MouseT_nSCcont_TVEMplotdata_alltrials_tasteSCSR_long = MouseT_nSCcont_TVEMplotdata_alltrials_healthtasteSCSR_long[MouseT_nSCcont_TVEMplotdata_alltrials_healthtasteSCSR_long$Rating == 'Taste', ]
MouseT_nSCcont_TVEMplotdata_alltrials_tasteSCSR_long$Rating = factor(MouseT_nSCcont_TVEMplotdata_alltrials_tasteSCSR_long$Rating)

shade_nSCcont_data_taste.SCSR = MouseT_nSCcont_TVEMplotdata[c('htsr2cc1ccplot_TimePoint', 'htsr2cc1ccplot_SCSR_Tdif_int')]
shade_nSCcont_data_taste.SCSR$SCSR = NA
names(shade_nSCcont_data_taste.SCSR) = c('TimePoint', 'Coef', 'SCSR')

ribbon_nSCcont_data_taste.SCSR = MouseT_nSCcont_TVEMplotdata[MouseT_nSCcont_TVEMplotdata$htsr2cc1ccplot_SCSR_Tdif_int_U < 0 & MouseT_nSCcont_TVEMplotdata$htsr2cc1ccplot_SCSR_Tdif_int_L < 0, c('htsr2cc1ccplot_TimePoint', 'htsr2cc1ccplot_SCSR_Tdif_int')]
ribbon_nSCcont_data_taste.SCSR$SCSR = NA
names(ribbon_nSCcont_data_taste.SCSR) = c('TimePoint', 'Coef', 'SCSR')

range_nSCcont_taste.SCSR = max(MouseT_nSCcont_TVEMplotdata$htsr2cc1ccplot_SCSR_Tdif_int_U) - min(MouseT_nSCcont_TVEMplotdata$htsr2cc1ccplot_SCSR_Tdif_int_L)-1

TVEM_plot_nSCcont_taste.SCSR = ggplot(shade_nSCcont_data_taste.SCSR, aes(x=TimePoint),
                              environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('All Trials Taste: TVEM coefficients with 95% confidence bounds by SCSR') +
  geom_ribbon(data = ribbon_nSCcont_data_taste.SCSR, mapping = aes(ymin=min(MouseT_nSCcont_TVEMplotdata$htsr2cc1ccplot_SCSR_Tdif_int_L)-1, ymax = min( MouseT_nSCcont_TVEMplotdata$htsr2cc1ccplot_SCSR_Tdif_int_L)-1+.025*range_nSCcont_taste.SCSR), fill = 'darkorange1') +
  geom_ribbon(data = MouseT_nSCcont_TVEMplotdata, mapping = aes(ymin=htsr2cc1ccplot_SCSR_Tdif_int_L, ymax = htsr2cc1ccplot_SCSR_Tdif_int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_nSCcont_TVEMplotdata_alltrials_tasteSCSR_long, aes(x = TimePoint, y = Coef*3, color=SCSR), linetype = 1, size = 1.5) +
  geom_line(data = shade_nSCcont_data_taste.SCSR, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~./3, name = "Coef of Taste", breaks=pretty_breaks(n = 7)),
                     name='Coef of Taste x SCSR Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c('mediumturquoise', 'deepskyblue2', 'blue4')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### ####
#### ####
#####################################
####                            
####  SC Trials: Group T-Tests by Attribute    #### 
####                            
#####################################
# Load datasets ####
#run if have not compiled the following datasets for SC, notSC, SC good, and SCfail:
#1)MouseT_SCgood_sigTime_Group_Tstamp_nodelete.csv
#2)MouseT_SCfail_sigTime_Group_Tstamp_nodelete.csv
#source('3b_MouseTrack_angleRegression_SCtrials.R')
#Group t-test sig points
MouseT_SCgood_sigTime_Group = read.csv('Data/Databases/MouseT_SCgood_sig_ttest_Tstamp_nodelete.csv', header = TRUE)
MouseT_SCfail_sigTime_Group = read.csv('Data/Databases/MouseT_SCfail_sig_ttest_Tstamp_nodelete.csv', header = TRUE)

#stack to combine into 1 dset
MouseT_SCoutcome_sigTime_Group = rbind(MouseT_SCgood_sigTime_Group, MouseT_SCfail_sigTime_Group)

#### Table: sigToEnd_10 present
SC_Group_lastsig10_nodelete_tab = xtabs(~TrialType + Rating, data = MouseT_SCoutcome_sigTime_Group[MouseT_SCoutcome_sigTime_Group$sigToEnd_10 == 'Y' & MouseT_SCoutcome_sigTime_Group$Group == 'All', ])

#### Table: sigTime across SC trial choice and rating
SC_Group_firstSigTP_SCchoice.Rating = data.frame(matrix(c('SCgood','SCfail', 55, 42, 34, 56, 51, 39), nrow = 2, ncol = 4, byrow = FALSE))
names(SC_Group_firstSigTP_SCchoice.Rating) = c('TrialType', 'health', 'taste', 'liking')

#### ####
#### ####
#####################################
####                            
####  SC Trials: Ind SigTime - SigTime Present  ####   
####                            
#####################################
# Load datasets ####
#run if have not compiled the following datasets for SC, notSC, SC good, and SCfail:
#1)MouseT_SCgood_regDat_Tstamp_nodelete.csv
#2)MouseT_SCfail_regDat_Tstamp_nodelete.csv
#3)MouseT_SCoutcome_ind_sigTimes_Tstamp_nodelete.csv
#source('3b_MouseTrack_angleRegression_SCtrials.R')
#Individual Regression Data
MouseT_SCgood_indReg = read.csv('Data/Databases/MouseT_SCgood_regDat_Tstamp_nodelete.csv', header = TRUE)
MouseT_SCgood_indReg$cAge_yr = MouseT_SCgood_indReg$cAge_mo/12

MouseT_SCfail_indReg= read.csv('Data/Databases/MouseT_SCfail_regDat_Tstamp_nodelete.csv', header = TRUE)
MouseT_SCfail_indReg$cAge_yr = MouseT_SCfail_indReg$cAge_mo/12

#Individual Regression sig points
MouseT_SCoutcome_ind_sigTimes = read.csv('Data/Databases/MouseT_SCoutcome_ind_sigTimes_Tstamp_nodelete.csv', header = TRUE)
MouseT_SCoutcome_ind_sigTimes$cAge_yr = MouseT_SCoutcome_ind_sigTimes$cAge_mo/12

## add label for SC trial choice
MouseT_SCgood_indReg$Choice = 'SCgood'
MouseT_SCfail_indReg$Choice = 'SCfail'

#compile databases-reduce to just coefficients
MouseT_SC_indReg_coefs_all= rbind(MouseT_SCgood_indReg[MouseT_SCgood_indReg$measure == 'coef', ],
                                  MouseT_SCfail_indReg[MouseT_SCfail_indReg$measure == 'coef', ])

## Add sigtoend_10 info to Tstamp_nodelete
MouseT_SC_indReg_coefs_all$Rating = MouseT_SC_indReg_coefs_all$rating
MouseT_SC_indReg_coefs_all = merge(MouseT_SC_indReg_coefs_all, MouseT_SCoutcome_ind_sigTimes[c(1, 31, 35)], by = c('ParID', 'Rating'))

# Reduce to those with 15 plus trials
MouseT_SC_indReg_coefs = MouseT_SC_indReg_coefs_all[MouseT_SC_indReg_coefs_all$t2 != 'less15Trials', ]

# Make numeric
MouseT_SC_indReg_coefs[34:134] = sapply(MouseT_SC_indReg_coefs[34:134], as.character)
MouseT_SC_indReg_coefs[34:134] = sapply(MouseT_SC_indReg_coefs[34:134], as.numeric)

## Make long data
MouseT_SC_indReg_coefs_long = reshape2::melt(MouseT_SC_indReg_coefs,
                                             id.vars = names(MouseT_SC_indReg_coefs[c(1:33, 135:137)]))
#make a timepoint variable
MouseT_SC_indReg_coefs_long$TimePoint = as.numeric(gsub( "t", "", as.character(MouseT_SC_indReg_coefs_long$variable)))

#rename outcome variable
MouseT_SC_indReg_coefs_long$Coef = MouseT_SC_indReg_coefs_long$value

#clean variables
MouseT_SC_indReg_coefs_long = MouseT_SC_indReg_coefs_long[c(1:36, 39:40)]

## get subsets for each coefficient
MouseT_SC_indReg_long_health = MouseT_SC_indReg_coefs_long[MouseT_SC_indReg_coefs_long$Rating == 'health', ]
MouseT_SC_indReg_long_taste= MouseT_SC_indReg_coefs_long[MouseT_SC_indReg_coefs_long$Rating == 'taste', ]
MouseT_SC_indReg_long_liking = MouseT_SC_indReg_coefs_long[MouseT_SC_indReg_coefs_long$Rating == 'liking', ]

MouseT_SCgood_indReg_long = MouseT_SC_indReg_coefs_long[MouseT_SC_indReg_coefs_long$Choice == 'SCgood', ]
MouseT_SCfail_indReg_long = MouseT_SC_indReg_coefs_long[MouseT_SC_indReg_coefs_long$Choice == 'SCfail', ]
MouseT_SCoutcome_indReg_long = MouseT_SC_indReg_coefs_long[MouseT_SC_indReg_coefs_long$Choice == 'SCgood'|
                                                             MouseT_SC_indReg_coefs_long$Choice == 'SCfail', ]

MouseT_SCoutcome_ind_sigTimes_health = MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$Rating == 'health', ]
MouseT_SCoutcome_ind_sigTimes_taste= MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$Rating == 'taste', ]
MouseT_SCoutcome_ind_sigTimes_liking = MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$Rating == 'liking', ]

# ANOVAs ####
#### ANOVA SigPres v Absent and SCSR
IndSigTime_STP.Rating_SCSR_SCgood_mod = lm(percSC_success~sigToEnd_10*Rating, data = MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$TrialType == 'SCgood', ])
IndSigTime_STP.Rating_SCSR_SCgood_anova = Anova(IndSigTime_STP.Rating_SCSR_SCgood_mod, type = 3)
IndSigTime_STP.Rating_SCSR_SCgood_sig_stars = c("***", "", "", "", "")
IndSigTime_STP.Rating_SCSR_SCgood_tab = sig_stars.table(IndSigTime_STP.Rating_SCSR_SCgood_anova, IndSigTime_STP.Rating_SCSR_SCgood_sig_stars)

IndSigTime_STP.Rating_SCSR_SCfail_mod = lm(percSC_success~sigToEnd_10*Rating, data = MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$TrialType == 'SCfail', ])
IndSigTime_STP.Rating_SCSR_SCfail_anova = Anova(IndSigTime_STP.Rating_SCSR_SCfail_mod, type = 3)
IndSigTime_STP.Rating_SCSR_SCfail_sig_stars = c("***", "", "", "", "")
IndSigTime_STP.Rating_SCSR_SCfail_tab = sig_stars.table(IndSigTime_STP.Rating_SCSR_SCfail_anova, IndSigTime_STP.Rating_SCSR_SCfail_sig_stars)

#### ANOVA SigPres v Absent and Age
IndSigTime_STP.Rating_Age_SCgood_mod = lm(cAge_yr~sigToEnd_10*Rating, data = MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$TrialType == 'SCgood', ])
IndSigTime_STP.Rating_Age_SCgood_anova = Anova(IndSigTime_STP.Rating_Age_SCgood_mod, type = 3)
IndSigTime_STP.Rating_Age_SCgood_sig_stars = c("***", "", "", "", "")
IndSigTime_STP.Rating_Age_SCgood_tab = sig_stars.table(IndSigTime_STP.Rating_Age_SCgood_anova, IndSigTime_STP.Rating_Age_SCgood_sig_stars)

IndSigTime_STP.Rating_Age_SCfail_mod = lm(cAge_yr~sigToEnd_10*Rating, data = MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$TrialType == 'SCfail', ])
IndSigTime_STP.Rating_Age_SCfail_anova = Anova(IndSigTime_STP.Rating_Age_SCfail_mod, type = 3)
IndSigTime_STP.Rating_Age_SCfail_sig_stars = c("***", "", "", "", "")
IndSigTime_STP.Rating_Age_SCfail_tab = sig_stars.table(IndSigTime_STP.Rating_Age_SCfail_anova, IndSigTime_STP.Rating_Age_SCfail_sig_stars)


#### ANOVA SigPres v Absent and BMI percentile
IndSigTime_STP.Rating_BMIp_SCgood_mod = lm(cBodyMass_p~sigToEnd_10*Rating, data = MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$TrialType == 'SCgood', ])
IndSigTime_STP.Rating_BMIp_SCgood_anova = Anova(IndSigTime_STP.Rating_BMIp_SCgood_mod, type = 3)
IndSigTime_STP.Rating_BMIp_SCgood_sig_stars = c("***", "", "", "", "")
IndSigTime_STP.Rating_BMIp_SCgood_tab = sig_stars.table(IndSigTime_STP.Rating_BMIp_SCgood_anova, IndSigTime_STP.Rating_BMIp_SCgood_sig_stars)

IndSigTime_STP.Rating_BMIp_SCfail_mod = lm(cBodyMass_p~sigToEnd_10*Rating, data = MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$TrialType == 'SCfail', ])
IndSigTime_STP.Rating_BMIp_SCfail_anova = Anova(IndSigTime_STP.Rating_BMIp_SCfail_mod, type = 3)
IndSigTime_STP.Rating_BMIp_SCfail_sig_stars = c("***", "", "", "", "")
IndSigTime_STP.Rating_BMIp_SCfail_tab = sig_stars.table(IndSigTime_STP.Rating_BMIp_SCfail_anova, IndSigTime_STP.Rating_BMIp_SCfail_sig_stars)

#### ANOVA: SigPres v Absent and Hunger
IndSigTime_STP.Rating_Hunger_SCgood_mod = lm(Hunger~sigToEnd_10*Rating, data = MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$TrialType == 'SCgood', ])
IndSigTime_STP.Rating_Hunger_SCgood_anova = Anova(IndSigTime_STP.Rating_Hunger_SCgood_mod, type = 3)
IndSigTime_STP.Rating_Hunger_SCgood_sig_stars = c("***", "", "", "", "")
IndSigTime_STP.Rating_Hunger_SCgood_tab = sig_stars.table(IndSigTime_STP.Rating_Hunger_SCgood_anova, IndSigTime_STP.Rating_Hunger_SCgood_sig_stars)

IndSigTime_STP.Rating_Hunger_SCfail_mod = lm(Hunger~sigToEnd_10*Rating, data = MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$TrialType == 'SCfail', ])
IndSigTime_STP.Rating_Hunger_SCfail_anova = Anova(IndSigTime_STP.Rating_Hunger_SCfail_mod, type = 3)
IndSigTime_STP.Rating_Hunger_SCfail_sig_stars = c("***", "", "", "", "")
IndSigTime_STP.Rating_Hunger_SCfail_tab = sig_stars.table(IndSigTime_STP.Rating_Hunger_SCfail_anova, IndSigTime_STP.Rating_Hunger_SCfail_sig_stars)

#### chi: SigPres v Absent sex
IndSigTimeSCgood_sex.rating_tab = xtabs(~sex + sigToEnd_10 + Rating, data = MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$TrialType == 'SCgood', ])
IndSigTimeSCfail_sex.rating_tab = xtabs(~sex + sigToEnd_10 + Rating, data = MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$TrialType == 'SCfail', ])

IndSigTimeSCgood_sex.rating_tab_nice = matrix(c(27, 4, 23, 8, 23, 8, 26, 8, 23, 11, 26, 8), ncol = 2, byrow = FALSE)
rownames(IndSigTimeSCgood_sex.rating_tab_nice) = c('HealthSTP_yes', 'HealthSTP_no', 'TasteSTP_yes', 'TasteSTP_no', 'LikingSTP_yes', 'LikingSTP_no')
colnames(IndSigTimeSCgood_sex.rating_tab_nice) = c('Boy', 'Girl')

IndSigTimeSCfail_sex.rating_tab_nice = matrix(c(23, 8, 22, 9, 24, 7, 25, 9, 28, 6, 27, 7), ncol = 2, byrow = FALSE)
rownames(IndSigTimeSCfail_sex.rating_tab_nice) = c('HealthSTP_yes', 'HealthSTP_no', 'TasteSTP_yes', 'TasteSTP_no', 'LikingSTP_yes', 'LikingSTP_no')
colnames(IndSigTimeSCfail_sex.rating_tab_nice) = c('Boy', 'Girl')


IndSigTimeSCgood_sex.rating_MHT = mantelhaen.test(IndSigTimeSCgood_sex.rating_tab)
IndSigTimeSCfail_sex.rating_MHT = mantelhaen.test(IndSigTimeSCfail_sex.rating_tab)

#### ####
#### ####
#####################################
####                            
####   SC Trials: Ind SigTime by Attribute and TrialType  ####    
####                            
#####################################

#### Descriptive: Number of Self Control Trials
nSCtrials_describe = describe(MouseT_sumDat_SCSR$nSC_trials)
row.names(nSCtrials_describe) = 'nSC_trials'

#### Cor: nSCtrials and BMI percentile
nSCtrials_cBMIp_cor = cor.test(MouseT_sumDat_SCSR$cBodyMass_p, MouseT_sumDat_SCSR$nSC_trials)

#### ttest: nSCtrials and Sex
nSCtrials_sex_ttest = t.test(nSC_trials~sex, data = MouseT_sumDat_SCSR)

#### Cor: nSCtrials and Age
nSCtrials_Age_cor = cor.test(MouseT_sumDat_SCSR$cAge_yr, MouseT_sumDat_SCSR$nSC_trials)

#### Cor: nSCtrials ~ SCSR
nSCtrials_SCSR_cor = cor.test(MouseT_sumDat_SCSR$percSC_success, MouseT_sumDat_SCSR$nSC_trials)

#### CoefPlot: SC trials Coef by TimePoint and Rating and trial type
IndCoef_plot_SCtrials_allratings = ggplot(MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$sigToEnd_10 == 'Y', ], aes(x=TimePoint),
                                          environment=environment ()) + 
  scale_color_manual(values = c('darkorchid4', 'deepskyblue2', 'darkorange1')) +
  geom_smooth(data = MouseT_SCgood_indReg_long[MouseT_SCgood_indReg_long$sigToEnd_10 == 'Y', ], 
              aes(x=TimePoint, y=Coef, color=Rating), method = 'loess', formula ='y ~ x', se=TRUE, fullrange=F, size = 1) +
  geom_smooth(data = MouseT_SCfail_indReg_long[MouseT_SCfail_indReg_long$sigToEnd_10 == 'Y', ], 
              aes(x=TimePoint, y=Coef, color=Rating), method = 'loess', formula ='y ~ x', se=TRUE, fullrange=F, size = 1, linetype = 'dashed') +
  scale_y_continuous(name='beta Rating Dif') +
  scale_x_continuous(name='Time Point') +
  ggtitle('Mouse Trajectory by Rating Difference (R-L) Across Time Points') +
  geom_vline(xintercept=70.8, color = 'darkorchid4') +
  geom_vline(xintercept=71.2, color = 'darkorange1') +
  geom_vline(xintercept=55.7, color = 'deepskyblue2') +
  geom_vline(xintercept=70.0, color = 'darkorchid4', linetype = "dashed") +
  geom_vline(xintercept=71.7, color = 'darkorange1', linetype = "dashed") +
  geom_vline(xintercept=59.1, color = 'deepskyblue2', linetype = "dashed") +
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### Table: individuals with sigTime by rating and SC Choice
GroupCount_lastsig10_SCchoice.rating_tab = xtabs(~TrialType + Rating, data = MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$sigToEnd_10 == 'Y', ])
GroupCount_lastsig10_SCchoice.rating_chi = chisq.test(GroupCount_lastsig10_SCchoice.rating_tab)

#### Table: mean SigTime by Rating and SC Choice
IndSigTime_SCchoice.Rating_nodelete_dset = data.frame(MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$sigToEnd_10 == 'Y', ]$Rating, MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$sigToEnd_10 == 'Y', ]$TrialType)
IndSigTime_SCchoice.Rating_nodelete_mean = data.frame(t(means.function.na(MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$sigToEnd_10 == 'Y', ], MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$sigToEnd_10 == 'Y', ]$lastSig_start, IndSigTime_SCchoice.Rating_nodelete_dset)))
IndSigTime_SCchoice.Rating_nodelete_sd = data.frame(t(sd.function.na(MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$sigToEnd_10 == 'Y', ], MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$sigToEnd_10 == 'Y', ]$lastSig_start, IndSigTime_SCchoice.Rating_nodelete_dset)))
IndSigTime_SCchoice.Rating_nodelete_range = data.frame(t(range.function.na(MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$sigToEnd_10 == 'Y', ], MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$sigToEnd_10 == 'Y', ]$lastSig_start, IndSigTime_SCchoice.Rating_nodelete_dset)))

## average number of trials for each model
#get number of good/fail trials for each participant
MouseT_sumDat_SCSR$nSC_goodTrials = MouseT_sumDat_SCSR$nSC_trials*MouseT_sumDat_SCSR$percSC_success
MouseT_sumDat_SCSR$nSC_failTrials = MouseT_sumDat_SCSR$nSC_trials - MouseT_sumDat_SCSR$nSC_goodTrials

#merge with existing ind reg dataset 
MouseT_SCoutcome_ind_sigTimes_ntrials = merge(MouseT_SCoutcome_ind_sigTimes, MouseT_sumDat_SCSR[c('ParID', 'nSC_goodTrials', 'nSC_failTrials')], by = 'ParID')

IndSigTime_Rating_nodelete_dset_nSCgood_means = means.function.na(MouseT_SCoutcome_ind_sigTimes_ntrials[MouseT_SCoutcome_ind_sigTimes_ntrials$nSC_goodTrials >= 15 & MouseT_SCoutcome_ind_sigTimes_ntrials$sigToEnd_10 == 'Y' & MouseT_SCoutcome_ind_sigTimes_ntrials$TrialType == 'SCgood', ],
                                        MouseT_SCoutcome_ind_sigTimes_ntrials[MouseT_SCoutcome_ind_sigTimes_ntrials$nSC_goodTrials >= 15 & MouseT_SCoutcome_ind_sigTimes_ntrials$sigToEnd_10 == 'Y' & MouseT_SCoutcome_ind_sigTimes_ntrials$TrialType == 'SCgood', ]$nSC_goodTrials,
                                        MouseT_SCoutcome_ind_sigTimes_ntrials[MouseT_SCoutcome_ind_sigTimes_ntrials$nSC_goodTrials >= 15 & MouseT_SCoutcome_ind_sigTimes_ntrials$sigToEnd_10 == 'Y' & MouseT_SCoutcome_ind_sigTimes_ntrials$TrialType == 'SCgood', ]$Rating)

IndSigTime_Rating_nodelete_dset_nSCfail_means = means.function.na(MouseT_SCoutcome_ind_sigTimes_ntrials[MouseT_SCoutcome_ind_sigTimes_ntrials$nSC_failTrials >= 15 & MouseT_SCoutcome_ind_sigTimes_ntrials$sigToEnd_10 == 'Y' & MouseT_SCoutcome_ind_sigTimes_ntrials$TrialType == 'SCfail', ],
                                        MouseT_SCoutcome_ind_sigTimes_ntrials[MouseT_SCoutcome_ind_sigTimes_ntrials$nSC_failTrials >= 15 & MouseT_SCoutcome_ind_sigTimes_ntrials$sigToEnd_10 == 'Y' & MouseT_SCoutcome_ind_sigTimes_ntrials$TrialType == 'SCfail', ]$nSC_failTrials,
                                        MouseT_SCoutcome_ind_sigTimes_ntrials[MouseT_SCoutcome_ind_sigTimes_ntrials$nSC_failTrials >= 15 & MouseT_SCoutcome_ind_sigTimes_ntrials$sigToEnd_10 == 'Y' & MouseT_SCoutcome_ind_sigTimes_ntrials$TrialType == 'SCfail', ]$Rating)

#### ANOVA: SigTime ~ Rating*SC Choice
IndSigTime_Rating.SCchoice_nodelete_mod = lmer(lastSig_start~Rating*TrialType + (1|ParID), data = MouseT_SCoutcome_ind_sigTimes[MouseT_SCoutcome_ind_sigTimes$sigToEnd_10 == 'Y', ])
IndSigTime_Rating.SCchoice_nodelete_ANVOA = anova(IndSigTime_Rating.SCchoice_nodelete_mod)
IndSigTime_Rating.SCchoice_nodelete_sig_stars = c("***", "", "")
IndSigTime_Rating.SCchoice_nodelete_tab = sig_stars_lmerTestAll.table(IndSigTime_Rating.SCchoice_nodelete_ANVOA, IndSigTime_Rating.SCchoice_nodelete_sig_stars)

IndSigTime_Rating.SCchoice_nodelete_emmeans = emmeans(IndSigTime_Rating.SCchoice_nodelete_mod, pairwise ~ Rating )

#### ####
#### ####
#####################################
####                            
####  SC Trials: TVEM plots  ####     
####                            
#####################################
# data org ####
#### SC trials
MouseT_TVEMplotdata_SCtrials = MouseT_TVEMplotdata[grepl("gl2|ght2|flc|fht2", names(MouseT_TVEMplotdata)) & 
                                                     !grepl("intercept", names(MouseT_TVEMplotdata))]

MouseT_TVEMplotdata_SCtrials_long = reshape2::melt(MouseT_TVEMplotdata_SCtrials[c(1:2, 6, 11, 16, 20, 25)], id.vars = names(MouseT_TVEMplotdata_SCtrials)[1])

SCtrials_coef_long = reshape2::melt(MouseT_TVEMplotdata_SCtrials[c(1, 3, 7, 12, 17, 21, 26)], id.vars = names(MouseT_TVEMplotdata_SCtrials)[1])
SCtrials_upper_long = reshape2::melt(MouseT_TVEMplotdata_SCtrials[c(1, 4, 8, 13, 18, 22, 27)], id.vars = names(MouseT_TVEMplotdata_SCtrials)[1])

MouseT_TVEMplotdata_SCtrials_long = data.frame(MouseT_TVEMplotdata_SCtrials_long, SCtrials_coef_long[3], SCtrials_upper_long[3])
names(MouseT_TVEMplotdata_SCtrials_long) = c("TimePoint", "Rating", "Lower95", "Coef", "Upper95")

MouseT_TVEMplotdata_SCtrials_long$SCoutcome = ifelse(grepl("gh|gl", MouseT_TVEMplotdata_SCtrials_long$Rating), "SCgood", "SCfail")

#### SC outcome
MouseT_TVEMplotdata_SCoutcome = MouseT_TVEMplotdata[grepl("lout2|htout2|loutc|htout2", names(MouseT_TVEMplotdata)) & 
                                                     !grepl("intercept", names(MouseT_TVEMplotdata))]

MouseT_TVEMplotdata_SCoutcome_long = reshape2::melt(MouseT_TVEMplotdata_SCoutcome[c(1, 14, 18, 31)], id.vars = names(MouseT_TVEMplotdata_SCoutcome)[1])

SCoutcome_coef_long = reshape2::melt(MouseT_TVEMplotdata_SCoutcome[c(1, 15, 19, 32)], id.vars = names(MouseT_TVEMplotdata_SCoutcome)[1])
SCoutcome_upper_long = reshape2::melt(MouseT_TVEMplotdata_SCoutcome[c(1, 16, 20, 33)], id.vars = names(MouseT_TVEMplotdata_SCoutcome)[1])

MouseT_TVEMplotdata_SCoutcome_long = data.frame(MouseT_TVEMplotdata_SCoutcome_long, SCoutcome_coef_long[3], SCoutcome_upper_long[3])
names(MouseT_TVEMplotdata_SCoutcome_long) = c("TimePoint", "Rating", "Lower95", "Coef", "Upper95")

MouseT_TVEMplotdata_SCoutcome_long$SCoutcome = ifelse(grepl("gh|gl", MouseT_TVEMplotdata_SCoutcome_long$Rating), "SCgood", "SCfail")

#### SC good - Taste split by BMI percentile Quartile
MouseT_TVEMplotdata_SCgood_taste.BMIpQ=MouseT_TVEMplotdata[grepl("ghtbmiq1|ghtbmic|ghtbmiq4", names(MouseT_TVEMplotdata)) & 
                                                               !grepl("intercept", names(MouseT_TVEMplotdata))]

MouseT_TVEMplotdata_SCgood_taste.BMIpQ_long = reshape2::melt(MouseT_TVEMplotdata_SCgood_taste.BMIpQ[c(1, 6, 15, 24)], id.vars = names(MouseT_TVEMplotdata_SCgood_taste.BMIpQ)[1])

SCgood_taste.BMIpQ_coef_long = reshape2::melt(MouseT_TVEMplotdata_SCgood_taste.BMIpQ[c(1, 7, 16, 25)], id.vars = names(MouseT_TVEMplotdata_SCgood_taste.BMIpQ)[1])
SCgood_taste.BMIpQ_upper_long = reshape2::melt(MouseT_TVEMplotdata_SCgood_taste.BMIpQ[c(1, 8, 17, 26)], id.vars = names(MouseT_TVEMplotdata_SCgood_taste.BMIpQ)[1])

MouseT_TVEMplotdata_SCgood_taste.BMIpQ_long = data.frame(MouseT_TVEMplotdata_SCgood_taste.BMIpQ_long, SCgood_taste.BMIpQ_coef_long[3], SCgood_taste.BMIpQ_upper_long[3])
names(MouseT_TVEMplotdata_SCgood_taste.BMIpQ_long) = c("TimePoint", "BMIpQ", "Lower95", "Coef", "Upper95")

#### SC fail - Liking split by Age Quartile
MouseT_TVEMplotdata_SCfail_liking.Age=MouseT_TVEMplotdata[grepl("flagecc|flageq1|flageq4", names(MouseT_TVEMplotdata)) & 
                                                             !grepl("intercept", names(MouseT_TVEMplotdata))]

MouseT_TVEMplotdata_SCfail_liking.Age_long = reshape2::melt(MouseT_TVEMplotdata_SCfail_liking.Age[c(1:2, 7, 12)], id.vars = names(MouseT_TVEMplotdata_SCfail_liking.Age)[1])

SCfail_liking.Age_coef_long = reshape2::melt(MouseT_TVEMplotdata_SCfail_liking.Age[c(1, 3, 8, 13)], id.vars = names(MouseT_TVEMplotdata_SCfail_liking.Age)[1])
SCfail_liking.Age_upper_long = reshape2::melt(MouseT_TVEMplotdata_SCfail_liking.Age[c(1, 4, 9, 14)], id.vars = names(MouseT_TVEMplotdata_SCfail_liking.Age)[1])

MouseT_TVEMplotdata_SCfail_liking.Age_long = data.frame(MouseT_TVEMplotdata_SCfail_liking.Age_long, SCfail_liking.Age_coef_long[3], SCfail_liking.Age_upper_long[3])
names(MouseT_TVEMplotdata_SCfail_liking.Age_long) = c("TimePoint", "AgeGroup", "Lower95", "Coef", "Upper95")

#### SC fail - Taste split by Age
MouseT_TVEMplotdata_SCfail_taste.Age=MouseT_TVEMplotdata[grepl("fhtagec|fhtageq1|fhtageq4", names(MouseT_TVEMplotdata)) & 
                                                                    !grepl("intercept", names(MouseT_TVEMplotdata))]
MouseT_TVEMplotdata_SCfail_taste.Age_long = reshape2::melt(MouseT_TVEMplotdata_SCfail_taste.Age[c(1, 6, 15, 24)], id.vars = names(MouseT_TVEMplotdata_SCfail_taste.Age)[1])

SCfail_taste.Age_coef_long = reshape2::melt(MouseT_TVEMplotdata_SCfail_taste.Age[c(1, 7, 16, 25)], id.vars = names(MouseT_TVEMplotdata_SCfail_taste.Age)[1])
SCfail_taste.Age_upper_long = reshape2::melt(MouseT_TVEMplotdata_SCfail_taste.Age[c(1, 8, 17, 26)], id.vars = names(MouseT_TVEMplotdata_SCfail_taste.Age)[1])

MouseT_TVEMplotdata_SCfail_taste.Age_long = data.frame(MouseT_TVEMplotdata_SCfail_taste.Age_long, SCfail_taste.Age_coef_long[3], SCfail_taste.Age_upper_long[3])
names(MouseT_TVEMplotdata_SCfail_taste.Age_long) = c("TimePoint", "AgeGroup", "Lower95", "Coef", "Upper95")

#### SC good - Liking split by SCSR Quartile
MouseT_TVEMplotdata_SCgood_liking.SCSR=MouseT_TVEMplotdata[grepl("glsrc|glsr1q|glsr4q", names(MouseT_TVEMplotdata)) & 
                                                            !grepl("intercept", names(MouseT_TVEMplotdata))]

MouseT_TVEMplotdata_SCgood_liking.SCSR_long = reshape2::melt(MouseT_TVEMplotdata_SCgood_liking.SCSR[c(1:2, 7, 12)], id.vars = names(MouseT_TVEMplotdata_SCgood_liking.SCSR)[1])

SCgood_liking.SCSR_coef_long = reshape2::melt(MouseT_TVEMplotdata_SCgood_liking.SCSR[c(1, 3, 8, 13)], id.vars = names(MouseT_TVEMplotdata_SCgood_liking.SCSR)[1])
SCgood_liking.SCSR_upper_long = reshape2::melt(MouseT_TVEMplotdata_SCgood_liking.SCSR[c(1, 4, 9, 14)], id.vars = names(MouseT_TVEMplotdata_SCgood_liking.SCSR)[1])

MouseT_TVEMplotdata_SCgood_liking.SCSR_long = data.frame(MouseT_TVEMplotdata_SCgood_liking.SCSR_long, SCgood_liking.SCSR_coef_long[3], SCgood_liking.SCSR_upper_long[3])
names(MouseT_TVEMplotdata_SCgood_liking.SCSR_long) = c("TimePoint", "SCSR", "Lower95", "Coef", "Upper95")


#### SC fail - Liking split by SCSR Quartile
MouseT_TVEMplotdata_SCfail_liking.SCSR=MouseT_TVEMplotdata[grepl("flsrc|flsr1q|flsr4q", names(MouseT_TVEMplotdata)) & 
                                                             !grepl("intercept", names(MouseT_TVEMplotdata))]

MouseT_TVEMplotdata_SCfail_liking.SCSR_long = reshape2::melt(MouseT_TVEMplotdata_SCfail_liking.SCSR[c(1:2, 7, 12)], id.vars = names(MouseT_TVEMplotdata_SCfail_liking.SCSR)[1])

SCfail_liking.SCSR_coef_long = reshape2::melt(MouseT_TVEMplotdata_SCfail_liking.SCSR[c(1, 3, 8, 13)], id.vars = names(MouseT_TVEMplotdata_SCfail_liking.SCSR)[1])
SCfail_liking.SCSR_upper_long = reshape2::melt(MouseT_TVEMplotdata_SCfail_liking.SCSR[c(1, 4, 9, 14)], id.vars = names(MouseT_TVEMplotdata_SCfail_liking.SCSR)[1])

MouseT_TVEMplotdata_SCfail_liking.SCSR_long = data.frame(MouseT_TVEMplotdata_SCfail_liking.SCSR_long, SCfail_liking.SCSR_coef_long[3], SCfail_liking.SCSR_upper_long[3])
names(MouseT_TVEMplotdata_SCfail_liking.SCSR_long) = c("TimePoint", "SCSR", "Lower95", "Coef", "Upper95")


#### SC fail - Health split by SCSR
MouseT_TVEMplotdata_SCfail_healthtaste.SCSR=MouseT_TVEMplotdata[grepl("fhtsrc|fhtsr1q|fhtsr4q", names(MouseT_TVEMplotdata)) & 
                                                                    !grepl("intercept", names(MouseT_TVEMplotdata))]

MouseT_TVEMplotdata_SCfail_health.SCSR_long = reshape2::melt(MouseT_TVEMplotdata_SCfail_healthtaste.SCSR[c(1:2, 11, 20)], id.vars = names(MouseT_TVEMplotdata_SCfail_healthtaste.SCSR)[1])

SCfail_health.SCSR_coef_long = reshape2::melt(MouseT_TVEMplotdata_SCfail_healthtaste.SCSR[c(1, 3, 12, 21)], id.vars = names(MouseT_TVEMplotdata_SCfail_healthtaste.SCSR)[1])
SCfail_health.SCSR_upper_long = reshape2::melt(MouseT_TVEMplotdata_SCfail_healthtaste.SCSR[c(1, 4, 13, 22)], id.vars = names(MouseT_TVEMplotdata_SCfail_healthtaste.SCSR)[1])

MouseT_TVEMplotdata_SCfail_health.SCSR_long = data.frame(MouseT_TVEMplotdata_SCfail_health.SCSR_long, SCfail_health.SCSR_coef_long[3], SCfail_health.SCSR_upper_long[3])
names(MouseT_TVEMplotdata_SCfail_health.SCSR_long) = c("TimePoint", "SCSR", "Lower95", "Coef", "Upper95")

#### SC fail - Taste split by SCSR
MouseT_TVEMplotdata_SCfail_taste.SCSR_long = reshape2::melt(MouseT_TVEMplotdata_SCfail_healthtaste.SCSR[c(1, 6, 15, 24)], id.vars = names(MouseT_TVEMplotdata_SCfail_healthtaste.SCSR)[1])

SCfail_taste.SCSR_coef_long = reshape2::melt(MouseT_TVEMplotdata_SCfail_healthtaste.SCSR[c(1, 7, 16, 25)], id.vars = names(MouseT_TVEMplotdata_SCfail_healthtaste.SCSR)[1])
SCfail_taste.SCSR_upper_long = reshape2::melt(MouseT_TVEMplotdata_SCfail_healthtaste.SCSR[c(1, 8, 17, 26)], id.vars = names(MouseT_TVEMplotdata_SCfail_healthtaste.SCSR)[1])

MouseT_TVEMplotdata_SCfail_taste.SCSR_long = data.frame(MouseT_TVEMplotdata_SCfail_taste.SCSR_long, SCfail_taste.SCSR_coef_long[3], SCfail_taste.SCSR_upper_long[3])
names(MouseT_TVEMplotdata_SCfail_taste.SCSR_long) = c("TimePoint", "SCSR", "Lower95", "Coef", "Upper95")


# Plots ####
#### TVEMPlot: SC outcome by TimePoint and Rating
ribbon_data_SCoutcome = MouseT_TVEMplotdata_SCoutcome_long[(MouseT_TVEMplotdata_SCoutcome_long$Lower95 > 0 & MouseT_TVEMplotdata_SCoutcome_long$Upper95 > 0) | 
                                                                (MouseT_TVEMplotdata_SCoutcome_long$Lower95 < 0 & MouseT_TVEMplotdata_SCoutcome_long$Upper95 < 0), ]

SCoutcome_range_allratings = max(MouseT_TVEMplotdata_SCtrials_long$Upper95) - min(MouseT_TVEMplotdata_SCtrials_long$Lower95) - 2

SCoutcome_TVEM_plot_allratings = ggplot(MouseT_TVEMplotdata_SCtrials_long, aes(x=TimePoint, group = Rating),
                                        environment=environment ()) + 
  scale_color_manual(values = c('darkorchid4', 'darkorange1', 'deepskyblue2', 'darkorchid4', 'darkorange1', 'deepskyblue2')) +
  scale_y_continuous(name='Coef', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  ggtitle('SC Fail Trials: TVEM coefficients with 95% confidence bounds') +
  geom_ribbon(data = MouseT_TVEMplotdata_SCtrials_long, mapping = aes(ymin=Lower95, ymax = Upper95), fill = 'lightgrey', alpha = 0.7) +
  geom_line(data = MouseT_TVEMplotdata_SCtrials_long[MouseT_TVEMplotdata_SCtrials_long$SCoutcome == 'SCgood', ], aes(x = TimePoint, y = Coef, color = Rating), linetype = 1, size = 1.5) +
  geom_line(data = MouseT_TVEMplotdata_SCtrials_long[MouseT_TVEMplotdata_SCtrials_long$SCoutcome == 'SCfail', ], aes(x = TimePoint, y = Coef, color = Rating), linetype = "dashed", size = 1.5) +
  geom_ribbon(data = ribbon_data_SCoutcome[ribbon_data_SCoutcome$Rating == 'htout211c11plot_TT_HDif_Int_L', ], mapping = aes(ymin=min(MouseT_TVEMplotdata_SCtrials_long$Lower95)-2, ymax = min(MouseT_TVEMplotdata_SCtrials_long$Lower95)-2+.025*SCoutcome_range_allratings), fill = 'darkorchid4') +
  geom_ribbon(data = ribbon_data_SCoutcome[ribbon_data_SCoutcome$Rating == 'htout211c11plot_TT_TDif_Int_L', ], mapping = aes(ymin=min(MouseT_TVEMplotdata_SCtrials_long$Lower95)-2+0.025*SCoutcome_range_allratings, ymax = min(MouseT_TVEMplotdata_SCtrials_long$Lower95)-2+.05*SCoutcome_range_allratings), fill = 'darkorange1') +
  geom_ribbon(data = ribbon_data_SCoutcome[ribbon_data_SCoutcome$Rating == 'lout2cc1plot_TT_LDif_Int_L' & ribbon_data_SCoutcome$TimePoint < 9, ], mapping = aes(ymin=min(MouseT_TVEMplotdata_SCtrials_long$Lower95)-2+.05*SCoutcome_range_allratings, ymax = min(MouseT_TVEMplotdata_SCtrials_long$Lower95)-2+.075*SCoutcome_range_allratings), fill = 'deepskyblue2') +
  geom_ribbon(data = ribbon_data_SCoutcome[ribbon_data_SCoutcome$Rating == 'lout2cc1plot_TT_LDif_Int_L' & ribbon_data_SCoutcome$TimePoint > 9, ], mapping = aes(ymin=min(MouseT_TVEMplotdata_SCtrials_long$Lower95)-2+.05*SCoutcome_range_allratings, ymax = min(MouseT_TVEMplotdata_SCtrials_long$Lower95)-2+.075*SCoutcome_range_allratings), fill = 'deepskyblue2') +
  geom_hline(yintercept = 0, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())


#### TVEMPlot: SC good Taste by BMI percentile quartiles combind plot
SCgood_shade_data_taste.BMIpQ = MouseT_TVEMplotdata[c('ghtbmi21ccccplotdata.sas7bdat_TimePoint', 'ghtbmi21ccccplotdata.sas7bdat_BMIp_TDif_int')]
SCgood_shade_data_taste.BMIpQ$BMIpQ = NA
names(SCgood_shade_data_taste.BMIpQ) = c('TimePoint', 'Coef', 'BMIpQ')

SCgood_ribbon_data_taste.BMIpQ = MouseT_TVEMplotdata[MouseT_TVEMplotdata$ghtbmi21ccccplotdata.sas7bdat_BMIp_TDif_int_U < 0 & MouseT_TVEMplotdata$ghtbmi21ccccplotdata.sas7bdat_BMIp_TDif_int_L < 0, c('ghtbmi21ccccplotdata.sas7bdat_TimePoint', 'ghtbmi21ccccplotdata.sas7bdat_BMIp_TDif_int')]
SCgood_ribbon_data_taste.BMIpQ$BMIpQ = NA
names(SCgood_ribbon_data_taste.BMIpQ) = c('TimePoint', 'Coef', 'BMIpQ')

SCgood_range_taste.BMIpQ = max(MouseT_TVEMplotdata$ghtbmi21ccccplotdata.sas7bdat_BMIp_TDif_int_U) - min(MouseT_TVEMplotdata$ghtbmi21ccccplotdata.sas7bdat_BMIp_TDif_int_L)+0.02

SCgood_TVEM_plot_taste.BMIpQ = ggplot(SCgood_shade_data_taste.BMIpQ, aes(x=TimePoint),
                                         environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('SC Good Trials Taste: TVEM coefficients with 95% confidence bounds by BMI percentile Quartile') +
  geom_ribbon(data = SCgood_ribbon_data_taste.BMIpQ, mapping = aes(ymin=min(MouseT_TVEMplotdata$ghtbmi21ccccplotdata.sas7bdat_BMIp_TDif_int_L)-0.02, ymax = min(MouseT_TVEMplotdata$ghtbmi21ccccplotdata.sas7bdat_BMIp_TDif_int_L)-0.02+.025*SCgood_range_taste.BMIpQ), fill = 'darkorange1') +
  geom_ribbon(data = MouseT_TVEMplotdata, mapping = aes(ymin=ghtbmi21ccccplotdata.sas7bdat_BMIp_TDif_int_L, ymax = ghtbmi21ccccplotdata.sas7bdat_BMIp_TDif_int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_TVEMplotdata_SCgood_taste.BMIpQ_long, aes(x = TimePoint, y = Coef/100, color=BMIpQ), linetype = 1, size = 1.5) +
  geom_line(data = SCgood_shade_data_taste.BMIpQ, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~.*100, name = "Coef of Taste", breaks=pretty_breaks(n = 7)),
                     name='Coef of Taste x BMI percentile Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c('deepskyblue2', 'mediumturquoise', 'blue4')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())


#### TVEMPlot: SC good Liking by SCSR combind plot
SCgood_shade_data_liking.SCSR = MouseT_TVEMplotdata[c('glsrk215cplot_TimePoint', 'glsrk215cplot_SCSR_LDif_int')]
SCgood_shade_data_liking.SCSR$SCSR = NA
names(SCgood_shade_data_liking.SCSR) = c('TimePoint', 'Coef', 'SCSR')

SCgood_ribbon_data_liking.SCSR = MouseT_TVEMplotdata[MouseT_TVEMplotdata$glsrk215cplot_SCSR_LDif_int_U < 0 & MouseT_TVEMplotdata$glsrk215cplot_SCSR_LDif_int_L < 0, c('glsrk215cplot_TimePoint', 'glsrk215cplot_SCSR_LDif_int')]
SCgood_ribbon_data_liking.SCSR$SCSR = NA
names(SCgood_ribbon_data_liking.SCSR) = c('TimePoint', 'Coef', 'SCSR')

SCgood_range_liking.SCSR = max(MouseT_TVEMplotdata$flsrkc343plot_SCSR_LDif_int_U) - min(MouseT_TVEMplotdata$flsrkc343plot_SCSR_LDif_int_L)+1.5

SCgood_TVEM_plot_liking.SCSR = ggplot(SCgood_shade_data_liking.SCSR, aes(x=TimePoint),
                                                         environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('SC good Trials Liking: TVEM coefficients with 95% confidence bounds by SCSR') +
  geom_ribbon(data = SCgood_ribbon_data_liking.SCSR, mapping = aes(ymin=min(MouseT_TVEMplotdata$glsrk215cplot_SCSR_LDif_int_L)-1.5, ymax = min(MouseT_TVEMplotdata$glsrk215cplot_SCSR_LDif_int_L)-1.5+.025*SCgood_range_liking.SCSR), fill = 'deepskyblue2') +
  geom_ribbon(data = MouseT_TVEMplotdata, mapping = aes(ymin=glsrk215cplot_SCSR_LDif_int_L, ymax = glsrk215cplot_SCSR_LDif_int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_TVEMplotdata_SCgood_liking.SCSR_long, aes(x = TimePoint, y = Coef, color=SCSR), linetype = 1, size = 1.5) +
  geom_line(data = SCgood_shade_data_liking.SCSR, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~., name = "Coef of Liking", breaks=pretty_breaks(n = 7)),
                     name='Coef of Liking x Sex Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c('mediumturquoise', 'blue4', 'deepskyblue2')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### TVEMPlot: SC fail Liking by SCSR combind plot
SCfail_shade_data_liking.SCSR = MouseT_TVEMplotdata[c('flsrkc343plot_TimePoint', 'flsrkc343plot_SCSR_LDif_int')]
SCfail_shade_data_liking.SCSR$SCSR = NA
names(SCfail_shade_data_liking.SCSR) = c('TimePoint', 'Coef', 'SCSR')

SCfail_ribbon_data_liking.SCSR = MouseT_TVEMplotdata[MouseT_TVEMplotdata$flsrkc343plot_SCSR_LDif_int_U > 0 & MouseT_TVEMplotdata$flsrkc343plot_SCSR_LDif_int_L > 0, c('flsrkc343plot_TimePoint', 'flsrkc343plot_SCSR_LDif_int')]
SCfail_ribbon_data_liking.SCSR$SCSRp = NA
names(SCfail_ribbon_data_liking.SCSR) = c('TimePoint', 'Coef', 'SCSR')

SCfail_range_liking.SCSR = max(MouseT_TVEMplotdata$flsrkc343plot_SCSR_LDif_int_U) - min(MouseT_TVEMplotdata$flsrkc343plot_SCSR_LDif_int_L)

SCfail_TVEM_plot_liking.SCSR = ggplot(SCfail_shade_data_liking.SCSR, aes(x=TimePoint),
                                                         environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('SC fail Trials Liking: TVEM coefficients with 95% confidence bounds by SCSR') +
  geom_ribbon(data = SCfail_ribbon_data_liking.SCSR, mapping = aes(ymin=min(MouseT_TVEMplotdata$flsrkc343plot_SCSR_LDif_int_L), ymax = min(MouseT_TVEMplotdata$flsrkc343plot_SCSR_LDif_int_L)+.025*SCfail_range_liking.SCSR), fill = 'deepskyblue2') +
  geom_ribbon(data = MouseT_TVEMplotdata, mapping = aes(ymin=flsrkc343plot_SCSR_LDif_int_L, ymax = flsrkc343plot_SCSR_LDif_int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_TVEMplotdata_SCfail_liking.SCSR_long, aes(x = TimePoint, y = Coef, color=SCSR), linetype = 1, size = 1.5) +
  geom_line(data = SCfail_shade_data_liking.SCSR, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~., name = "Coef of Liking", breaks=pretty_breaks(n = 7)),
                     name='Coef of Liking x Sex Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c('mediumturquoise','blue4', 'deepskyblue2')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### TVEMPlot: SC fail Liking by Age combind plot
SCfail_shade_data_liking.Age = MouseT_TVEMplotdata[c('flagec321plot_TimePoint', 'flagec321plot_age_LDif_int')]
SCfail_shade_data_liking.Age$AgeGroup = NA
names(SCfail_shade_data_liking.Age) = c('TimePoint', 'Coef', 'AgeGroup')

SCfail_ribbon_data_liking.Age = MouseT_TVEMplotdata[MouseT_TVEMplotdata$flagec321plot_age_LDif_int_U > 0 & MouseT_TVEMplotdata$flagec321plot_age_LDif_int_L > 0, c('flagec321plot_TimePoint', 'flagec321plot_age_LDif_int')]
SCfail_ribbon_data_liking.Age$AgeGroup = NA
names(SCfail_ribbon_data_liking.Age) = c('TimePoint', 'Coef', 'AgeGroup')

SCfail_range_liking.Age = max(MouseT_TVEMplotdata$flagec321plot_age_LDif_int_U) - min(MouseT_TVEMplotdata$flagec321plot_age_LDif_int_L)

SCfail_TVEM_plot_liking.Age = ggplot(SCfail_shade_data_liking.Age, aes(x=TimePoint),
                                        environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('SC fail Trials Liking: TVEM coefficients with 95% confidence bounds by Age') +
  geom_ribbon(data = SCfail_ribbon_data_liking.Age, mapping = aes(ymin=min(MouseT_TVEMplotdata$flagec321plot_age_LDif_int_L), ymax = min(MouseT_TVEMplotdata$flagec321plot_age_LDif_int_L)+.025*SCfail_range_liking.Age), fill = 'deepskyblue2') +
  geom_ribbon(data = MouseT_TVEMplotdata, mapping = aes(ymin=flagec321plot_age_LDif_int_L, ymax = flagec321plot_age_LDif_int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_TVEMplotdata_SCfail_liking.Age_long, aes(x = TimePoint, y = Coef/10, color=AgeGroup), linetype = 1, size = 1.5) +
  geom_line(data = SCfail_shade_data_liking.Age, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~.*10, name = "Coef of Liking", breaks=pretty_breaks(n = 7)),
                     name='Coef of Liking x Sex Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c('deepskyblue2','mediumturquoise', 'blue4')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### TVEMPlot: SC fail Taste by Age combind plot
SCfail_shade_data_taste.Age = MouseT_TVEMplotdata[c('fhtage213cc1plotdata.sas7bdat_TimePoint', 'fhtage213cc1plotdata.sas7bdat_age_TDif_Int')]
SCfail_shade_data_taste.Age$AgeGroup = NA
names(SCfail_shade_data_taste.Age) = c('TimePoint', 'Coef', 'AgeGroup')

SCfail_ribbon_data_taste.Age = MouseT_TVEMplotdata[MouseT_TVEMplotdata$fhtage213cc1plotdata.sas7bdat_age_TDif_Int_U > 0 & MouseT_TVEMplotdata$fhtage213cc1plotdata.sas7bdat_age_TDif_Int_L > 0, c('fhtage213cc1plotdata.sas7bdat_TimePoint', 'fhtage213cc1plotdata.sas7bdat_age_TDif_Int')]
SCfail_ribbon_data_taste.Age$AgeGroup = NA
names(SCfail_ribbon_data_taste.Age) = c('TimePoint', 'Coef', 'AgeGroup')

SCfail_range_taste.Age = max(MouseT_TVEMplotdata$fhtage213cc1plotdata.sas7bdat_age_TDif_Int_U) - min(MouseT_TVEMplotdata$fhtage213cc1plotdata.sas7bdat_age_TDif_Int_L)+0.5

SCfail_TVEM_plot_taste.Age = ggplot(SCfail_shade_data_taste.Age, aes(x=TimePoint),
                                       environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('SC fail Trials Taste: TVEM coefficients with 95% confidence bounds by Age') +
  geom_ribbon(data = SCfail_ribbon_data_taste.Age, mapping = aes(ymin=min(MouseT_TVEMplotdata$fhtage213cc1plotdata.sas7bdat_age_TDif_Int_L)-0.5, ymax = min(MouseT_TVEMplotdata$fhtage213cc1plotdata.sas7bdat_age_TDif_Int_L)-0.5+.025*SCfail_range_taste.Age), fill = 'darkorange1') +
  geom_ribbon(data = MouseT_TVEMplotdata, mapping = aes(ymin=fhtage213cc1plotdata.sas7bdat_age_TDif_Int_L, ymax = fhtage213cc1plotdata.sas7bdat_age_TDif_Int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_TVEMplotdata_SCfail_taste.Age_long, aes(x = TimePoint, y = Coef/10, color=AgeGroup), linetype = 1, size = 1.5) +
  geom_line(data = SCfail_shade_data_taste.Age, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~.*10, name = "Coef of Taste", breaks=pretty_breaks(n = 7)),
                     name='Coef of Taste x Age Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c('deepskyblue2', 'mediumturquoise', 'blue4')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### TVEMPlot: SC fail Taste by SCSR combind plot
SCfail_shade_data_taste.SCSR = MouseT_TVEMplotdata[c('fhtsr213431plot_TimePoint', 'fhtsr213431plot_SCSR_TDif_Int')]
SCfail_shade_data_taste.SCSR$SCSR = NA
names(SCfail_shade_data_taste.SCSR) = c('TimePoint', 'Coef', 'SCSR')

SCfail_ribbon_data_taste.SCSR = MouseT_TVEMplotdata[MouseT_TVEMplotdata$fhtsr213431plot_SCSR_TDif_Int_U > 0 & MouseT_TVEMplotdata$fhtsr213431plot_SCSR_TDif_Int_L > 0, c('fhtsr213431plot_TimePoint', 'fhtsr213431plot_SCSR_TDif_Int')]
SCfail_ribbon_data_taste.SCSR$SCSR = NA
names(SCfail_ribbon_data_taste.SCSR) = c('TimePoint', 'Coef', 'SCSR')

SCfail_range_taste.SCSR = max(MouseT_TVEMplotdata$fhtsr213431plot_SCSR_TDif_Int_U) - min(MouseT_TVEMplotdata$fhtsr213431plot_SCSR_TDif_Int_L)+0.05

SCfail_TVEM_plot_taste.SCSR = ggplot(SCfail_shade_data_taste.SCSR, aes(x=TimePoint),
                                                        environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('SC Fail Trials Taste: TVEM coefficients with 95% confidence bounds by SCSR') +
  geom_ribbon(data = SCfail_ribbon_data_taste.SCSR, mapping = aes(ymin=min(MouseT_TVEMplotdata$fhtsr213431plot_SCSR_TDif_Int_L)-0.05, ymax = min(MouseT_TVEMplotdata$fhtsr213431plot_SCSR_TDif_Int_L)-0.52+.025*SCfail_range_taste.SCSR), fill = 'darkorange1') +
  geom_ribbon(data = MouseT_TVEMplotdata, mapping = aes(ymin=fhtsr213431plot_SCSR_TDif_Int_L, ymax = fhtsr213431plot_SCSR_TDif_Int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_TVEMplotdata_SCfail_taste.SCSR_long, aes(x = TimePoint, y = Coef, color=SCSR), linetype = 1, size = 1.5) +
  geom_line(data = SCfail_shade_data_taste.SCSR, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~., name = "Coef of Taste", breaks=pretty_breaks(n = 7)),
                     name='Coef of Taste x SCSR Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c('mediumturquoise', 'blue4', 'deepskyblue2')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())


#### TVEMPlot: SC fail Health by SCSR combind plot
SCfail_shade_data_health.SCSR = MouseT_TVEMplotdata[c('fhtsr213431plot_TimePoint', 'fhtsr213431plot_SCSR_HDif_Int')]
SCfail_shade_data_health.SCSR$SCSR = NA
names(SCfail_shade_data_health.SCSR) = c('TimePoint', 'Coef', 'SCSR')

SCfail_ribbon_data_health.SCSR = MouseT_TVEMplotdata[MouseT_TVEMplotdata$fhtsr213431plot_SCSR_HDif_Int_U > 0 & MouseT_TVEMplotdata$fhtsr213431plot_SCSR_HDif_Int_L > 0, c('fhtsr213431plot_TimePoint', 'fhtsr213431plot_SCSR_HDif_Int')]
SCfail_ribbon_data_health.SCSR$SCSR = NA
names(SCfail_ribbon_data_health.SCSR) = c('TimePoint', 'Coef', 'SCSR')

SCfail_range_health.SCSR = max(MouseT_TVEMplotdata$fhtsr213431plot_SCSR_HDif_Int_U) - min(MouseT_TVEMplotdata$fhtsr213431plot_SCSR_HDif_Int_L)+5

SCfail_TVEM_plot_health.SCSR = ggplot(SCfail_shade_data_health.SCSR, aes(x=TimePoint),
                                                         environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('SC Fail Trials Health: TVEM coefficients with 95% confidence bounds by SCSR') +
  geom_ribbon(data = SCfail_ribbon_data_health.SCSR, mapping = aes(ymin=min(MouseT_TVEMplotdata$fhtsr213431plot_SCSR_HDif_Int_L)-5, ymax = min(MouseT_TVEMplotdata$fhtsr213431plot_SCSR_HDif_Int_L)-5+.025*SCfail_range_health.SCSR), fill = 'darkorchid4') +
  geom_ribbon(data = MouseT_TVEMplotdata, mapping = aes(ymin=fhtsr213431plot_SCSR_HDif_Int_L, ymax = fhtsr213431plot_SCSR_HDif_Int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_TVEMplotdata_SCfail_health.SCSR_long, aes(x = TimePoint, y = Coef, color=SCSR), linetype = 1, size = 1.5) +
  geom_line(data = SCfail_shade_data_health.SCSR, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~., name = "Coef of Health", breaks=pretty_breaks(n = 7)),
                     name='Coef of Health x SCSR Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c('mediumturquoise', 'blue4', 'deepskyblue2')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### ####
#### ####
#####################################
####                            
####  SC Trials: TVEM plots  ####   
####  nSC controlled  ####  
####                            
#####################################
# data org ####
#### SC trials
MouseT_nSCcont_TVEMplotdata_SCtrials = MouseT_nSCcont_TVEMplotdata[grepl("gl2|ght2|flc|fht2", names(MouseT_nSCcont_TVEMplotdata)) & 
                                                     !grepl("intercept", names(MouseT_nSCcont_TVEMplotdata))]

MouseT_nSCcont_TVEMplotdata_SCtrials_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCtrials[c(1:2, 6, 11, 16, 20, 25)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCtrials)[1])

SCtrials_nSCcont_coef_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCtrials[c(1, 3, 7, 12, 17, 21, 26)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCtrials)[1])
SCtrials_nSCcont_upper_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCtrials[c(1, 4, 8, 13, 18, 22, 27)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCtrials)[1])

MouseT_nSCcont_TVEMplotdata_SCtrials_long = data.frame(MouseT_nSCcont_TVEMplotdata_SCtrials_long, SCtrials_nSCcont_coef_long[3], SCtrials_nSCcont_upper_long[3])
names(MouseT_nSCcont_TVEMplotdata_SCtrials_long) = c("TimePoint", "Rating", "Lower95", "Coef", "Upper95")

MouseT_nSCcont_TVEMplotdata_SCtrials_long$SCoutcome = ifelse(grepl("gh|gl", MouseT_nSCcont_TVEMplotdata_SCtrials_long$Rating), "SCgood", "SCfail")

#### SC outcome
MouseT_nSCcont_TVEMplotdata_SCoutcome = MouseT_nSCcont_TVEMplotdata[grepl("lout2|htout2|loutc|htout2", names(MouseT_nSCcont_TVEMplotdata)) & 
                                                      !grepl("intercept", names(MouseT_nSCcont_TVEMplotdata))]

MouseT_nSCcont_TVEMplotdata_SCoutcome_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCoutcome[c(1, 18, 22, 39)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCoutcome)[1])

SCoutcome_nSCcont_coef_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCoutcome[c(1, 19, 23, 40)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCoutcome)[1])
SCoutcome_nSCcont_upper_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCoutcome[c(1, 20, 24, 41)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCoutcome)[1])

MouseT_nSCcont_TVEMplotdata_SCoutcome_long = data.frame(MouseT_nSCcont_TVEMplotdata_SCoutcome_long, SCoutcome_nSCcont_coef_long[3], SCoutcome_nSCcont_upper_long[3])
names(MouseT_nSCcont_TVEMplotdata_SCoutcome_long) = c("TimePoint", "Rating", "Lower95", "Coef", "Upper95")

MouseT_nSCcont_TVEMplotdata_SCoutcome_long$SCoutcome = ifelse(grepl("gh|gl", MouseT_nSCcont_TVEMplotdata_SCoutcome_long$Rating), "SCgood", "SCfail")

#### SC good - Taste split by BMI percentile Quartile
MouseT_nSCcont_TVEMplotdata_SCgood_taste.BMIpQ=MouseT_nSCcont_TVEMplotdata[grepl("ghtbmiq1|ghtbmic|ghtbmiq4", names(MouseT_nSCcont_TVEMplotdata)) & 
                                                             !grepl("intercept", names(MouseT_nSCcont_TVEMplotdata))]

MouseT_nSCcont_TVEMplotdata_SCgood_taste.BMIpQ_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCgood_taste.BMIpQ[c(1, 6, 15, 24)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCgood_taste.BMIpQ)[1])

SCgood_taste.BMIpQ_nSCcont_coef_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCgood_taste.BMIpQ[c(1, 7, 16, 25)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCgood_taste.BMIpQ)[1])
SCgood_taste.BMIpQ_nSCcont_upper_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCgood_taste.BMIpQ[c(1, 8, 17, 26)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCgood_taste.BMIpQ)[1])

MouseT_nSCcont_TVEMplotdata_SCgood_taste.BMIpQ_long = data.frame(MouseT_nSCcont_TVEMplotdata_SCgood_taste.BMIpQ_long, SCgood_taste.BMIpQ_nSCcont_coef_long[3], SCgood_taste.BMIpQ_nSCcont_upper_long[3])
names(MouseT_nSCcont_TVEMplotdata_SCgood_taste.BMIpQ_long) = c("TimePoint", "BMIpQ", "Lower95", "Coef", "Upper95")

#### SC fail - Liking split by Age Quartile
MouseT_nSCcont_TVEMplotdata_SCfail_liking.Age=MouseT_nSCcont_TVEMplotdata[grepl("flagecc|flageq1|flageq4", names(MouseT_nSCcont_TVEMplotdata)) & 
                                                            !grepl("intercept", names(MouseT_nSCcont_TVEMplotdata))]

MouseT_nSCcont_TVEMplotdata_SCfail_liking.Age_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCfail_liking.Age[c(1:2, 7, 12)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCfail_liking.Age)[1])

SCfail_liking.Age_nSCcont_coef_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCfail_liking.Age[c(1, 3, 8, 13)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCfail_liking.Age)[1])
SCfail_liking.Age_nSCcont_upper_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCfail_liking.Age[c(1, 4, 9, 14)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCfail_liking.Age)[1])

MouseT_nSCcont_TVEMplotdata_SCfail_liking.Age_long = data.frame(MouseT_nSCcont_TVEMplotdata_SCfail_liking.Age_long, SCfail_liking.Age_nSCcont_coef_long[3], SCfail_liking.Age_nSCcont_upper_long[3])
names(MouseT_nSCcont_TVEMplotdata_SCfail_liking.Age_long) = c("TimePoint", "AgeGroup", "Lower95", "Coef", "Upper95")

#### SC fail - Taste split by Age
MouseT_nSCcont_TVEMplotdata_SCfail_taste.Age=MouseT_nSCcont_TVEMplotdata[grepl("fhtagec|fhtageq1|fhtageq4", names(MouseT_nSCcont_TVEMplotdata)) & 
                                                           !grepl("intercept", names(MouseT_nSCcont_TVEMplotdata))]
MouseT_nSCcont_TVEMplotdata_SCfail_taste.Age_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCfail_taste.Age[c(1, 6, 15, 24)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCfail_taste.Age)[1])

SCfail_taste.Age_nSCcont_coef_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCfail_taste.Age[c(1, 7, 16, 25)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCfail_taste.Age)[1])
SCfail_taste.Age_nSCcont_upper_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCfail_taste.Age[c(1, 8, 17, 26)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCfail_taste.Age)[1])

MouseT_nSCcont_TVEMplotdata_SCfail_taste.Age_long = data.frame(MouseT_nSCcont_TVEMplotdata_SCfail_taste.Age_long, SCfail_taste.Age_nSCcont_coef_long[3], SCfail_taste.Age_nSCcont_upper_long[3])
names(MouseT_nSCcont_TVEMplotdata_SCfail_taste.Age_long) = c("TimePoint", "AgeGroup", "Lower95", "Coef", "Upper95")

#### SC good - Liking split by SCSR Quartile
MouseT_nSCcont_TVEMplotdata_SCgood_liking.SCSR=MouseT_nSCcont_TVEMplotdata[grepl("glsrc|glsr1q|glsr4q", names(MouseT_nSCcont_TVEMplotdata)) & 
                                                             !grepl("intercept", names(MouseT_nSCcont_TVEMplotdata))]

MouseT_nSCcont_TVEMplotdata_SCgood_liking.SCSR_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCgood_liking.SCSR[c(1:2, 7, 12)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCgood_liking.SCSR)[1])

SCgood_liking.SCSR_nSCcont_coef_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCgood_liking.SCSR[c(1, 3, 8, 13)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCgood_liking.SCSR)[1])
SCgood_liking.SCSR_nSCcont_upper_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCgood_liking.SCSR[c(1, 4, 9, 14)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCgood_liking.SCSR)[1])

MouseT_nSCcont_TVEMplotdata_SCgood_liking.SCSR_long = data.frame(MouseT_nSCcont_TVEMplotdata_SCgood_liking.SCSR_long, SCgood_liking.SCSR_nSCcont_coef_long[3], SCgood_liking.SCSR_nSCcont_upper_long[3])
names(MouseT_nSCcont_TVEMplotdata_SCgood_liking.SCSR_long) = c("TimePoint", "SCSR", "Lower95", "Coef", "Upper95")


#### SC fail - Liking split by SCSR Quartile
MouseT_nSCcont_TVEMplotdata_SCfail_liking.SCSR=MouseT_nSCcont_TVEMplotdata[grepl("flsrc|flsr1q|flsr4q", names(MouseT_nSCcont_TVEMplotdata)) & 
                                                             !grepl("intercept", names(MouseT_nSCcont_TVEMplotdata))]

MouseT_nSCcont_TVEMplotdata_SCfail_liking.SCSR_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCfail_liking.SCSR[c(1:2, 7, 12)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCfail_liking.SCSR)[1])

SCfail_liking.SCSR_nSCcont_coef_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCfail_liking.SCSR[c(1, 3, 8, 13)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCfail_liking.SCSR)[1])
SCfail_liking.SCSR_nSCcont_upper_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCfail_liking.SCSR[c(1, 4, 9, 14)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCfail_liking.SCSR)[1])

MouseT_nSCcont_TVEMplotdata_SCfail_liking.SCSR_long = data.frame(MouseT_nSCcont_TVEMplotdata_SCfail_liking.SCSR_long, SCfail_liking.SCSR_nSCcont_coef_long[3], SCfail_liking.SCSR_nSCcont_upper_long[3])
names(MouseT_nSCcont_TVEMplotdata_SCfail_liking.SCSR_long) = c("TimePoint", "SCSR", "Lower95", "Coef", "Upper95")


#### SC fail - Health split by SCSR
MouseT_nSCcont_TVEMplotdata_SCfail_healthtaste.SCSR=MouseT_nSCcont_TVEMplotdata[grepl("fhtsrc|fhtsr1q|fhtsr4q", names(MouseT_nSCcont_TVEMplotdata)) & 
                                                                  !grepl("intercept", names(MouseT_nSCcont_TVEMplotdata))]

MouseT_nSCcont_TVEMplotdata_SCfail_health.SCSR_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCfail_healthtaste.SCSR[c(1:2, 11, 20)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCfail_healthtaste.SCSR)[1])

SCfail_health.SCSR_nSCcont_coef_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCfail_healthtaste.SCSR[c(1, 3, 12, 21)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCfail_healthtaste.SCSR)[1])
SCfail_health.SCSR_nSCcont_upper_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCfail_healthtaste.SCSR[c(1, 4, 13, 22)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCfail_healthtaste.SCSR)[1])

MouseT_nSCcont_TVEMplotdata_SCfail_health.SCSR_long = data.frame(MouseT_nSCcont_TVEMplotdata_SCfail_health.SCSR_long, SCfail_health.SCSR_nSCcont_coef_long[3], SCfail_health.SCSR_nSCcont_upper_long[3])
names(MouseT_nSCcont_TVEMplotdata_SCfail_health.SCSR_long) = c("TimePoint", "SCSR", "Lower95", "Coef", "Upper95")

#### SC fail - Taste split by SCSR
MouseT_nSCcont_TVEMplotdata_SCfail_taste.SCSR_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCfail_healthtaste.SCSR[c(1, 6, 15, 24)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCfail_healthtaste.SCSR)[1])

SCfail_taste.SCSR_nSCcont_coef_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCfail_healthtaste.SCSR[c(1, 7, 16, 25)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCfail_healthtaste.SCSR)[1])
SCfail_taste.SCSR_nSCcont_upper_long = reshape2::melt(MouseT_nSCcont_TVEMplotdata_SCfail_healthtaste.SCSR[c(1, 8, 17, 26)], id.vars = names(MouseT_nSCcont_TVEMplotdata_SCfail_healthtaste.SCSR)[1])

MouseT_nSCcont_TVEMplotdata_SCfail_taste.SCSR_long = data.frame(MouseT_nSCcont_TVEMplotdata_SCfail_taste.SCSR_long, SCfail_taste.SCSR_nSCcont_coef_long[3], SCfail_taste.SCSR_nSCcont_upper_long[3])
names(MouseT_nSCcont_TVEMplotdata_SCfail_taste.SCSR_long) = c("TimePoint", "SCSR", "Lower95", "Coef", "Upper95")


# Plots ####
#### TVEMPlot: SC outcome by TimePoint and Rating
ribbon_nSCcont_data_SCoutcome = MouseT_nSCcont_TVEMplotdata_SCoutcome_long[(MouseT_nSCcont_TVEMplotdata_SCoutcome_long$Lower95 > 0 & MouseT_nSCcont_TVEMplotdata_SCoutcome_long$Upper95 > 0) | 
                                                             (MouseT_nSCcont_TVEMplotdata_SCoutcome_long$Lower95 < 0 & MouseT_nSCcont_TVEMplotdata_SCoutcome_long$Upper95 < 0), ]

SCoutcome_range_nSCcont_allratings = max(MouseT_nSCcont_TVEMplotdata_SCtrials_long$Upper95) - min(MouseT_nSCcont_TVEMplotdata_SCtrials_long$Lower95) - 2

SCoutcome_TVEM_plot_nSCcont_allratings = ggplot(MouseT_nSCcont_TVEMplotdata_SCtrials_long, aes(x=TimePoint, group = Rating),
                                        environment=environment ()) + 
  scale_color_manual(values = c('darkorchid4', 'darkorange1', 'deepskyblue2', 'darkorchid4', 'darkorange1', 'deepskyblue2')) +
  scale_y_continuous(name='Coef', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  ggtitle('SC Fail Trials: TVEM coefficients with 95% confidence bounds') +
  geom_ribbon(data = MouseT_nSCcont_TVEMplotdata_SCtrials_long, mapping = aes(ymin=Lower95, ymax = Upper95), fill = 'lightgrey', alpha = 0.7) +
  geom_line(data = MouseT_nSCcont_TVEMplotdata_SCtrials_long[MouseT_nSCcont_TVEMplotdata_SCtrials_long$SCoutcome == 'SCgood', ], aes(x = TimePoint, y = Coef, color = Rating), linetype = 1, size = 1.5) +
  geom_line(data = MouseT_nSCcont_TVEMplotdata_SCtrials_long[MouseT_nSCcont_TVEMplotdata_SCtrials_long$SCoutcome == 'SCfail', ], aes(x = TimePoint, y = Coef, color = Rating), linetype = "dashed", size = 1.5) +
  geom_ribbon(data = ribbon_nSCcont_data_SCoutcome[ribbon_nSCcont_data_SCoutcome$Rating == 'htout211c11plot_TT_HDif_Int_L', ], mapping = aes(ymin=min(MouseT_nSCcont_TVEMplotdata_SCtrials_long$Lower95)-2, ymax = min(MouseT_nSCcont_TVEMplotdata_SCtrials_long$Lower95)-2+.025*SCoutcome_range_nSCcont_allratings), fill = 'darkorchid4') +
  geom_ribbon(data = ribbon_nSCcont_data_SCoutcome[ribbon_nSCcont_data_SCoutcome$Rating == 'htout211c11plot_TT_TDif_Int_L', ], mapping = aes(ymin=min(MouseT_nSCcont_TVEMplotdata_SCtrials_long$Lower95)-2+0.025*SCoutcome_range_nSCcont_allratings, ymax = min(MouseT_nSCcont_TVEMplotdata_SCtrials_long$Lower95)-2+.05*SCoutcome_range_nSCcont_allratings), fill = 'darkorange1') +
  geom_ribbon(data = ribbon_nSCcont_data_SCoutcome[ribbon_nSCcont_data_SCoutcome$Rating == 'lout2cc1plot_TT_LDif_Int_L' & ribbon_nSCcont_data_SCoutcome$TimePoint < 9, ], mapping = aes(ymin=min(MouseT_nSCcont_TVEMplotdata_SCtrials_long$Lower95)-2+.05*SCoutcome_range_nSCcont_allratings, ymax = min(MouseT_nSCcont_TVEMplotdata_SCtrials_long$Lower95)-2+.075*SCoutcome_range_nSCcont_allratings), fill = 'deepskyblue2') +
  geom_ribbon(data = ribbon_nSCcont_data_SCoutcome[ribbon_nSCcont_data_SCoutcome$Rating == 'lout2cc1plot_TT_LDif_Int_L' & ribbon_nSCcont_data_SCoutcome$TimePoint > 9, ], mapping = aes(ymin=min(MouseT_nSCcont_TVEMplotdata_SCtrials_long$Lower95)-2+.05*SCoutcome_range_nSCcont_allratings, ymax = min(MouseT_nSCcont_TVEMplotdata_SCtrials_long$Lower95)-2+.075*SCoutcome_range_nSCcont_allratings), fill = 'deepskyblue2') +
  geom_hline(yintercept = 0, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())


#### TVEMPlot: SC good Taste by BMI percentile quartiles combind plot
SCgood_shade_nSCcont_data_taste.BMIpQ = MouseT_nSCcont_TVEMplotdata[c('ghtbmi21ccccplotdata.sas7bdat_TimePoint', 'ghtbmi21ccccplotdata.sas7bdat_BMIp_TDif_int')]
SCgood_shade_nSCcont_data_taste.BMIpQ$BMIpQ = NA
names(SCgood_shade_nSCcont_data_taste.BMIpQ) = c('TimePoint', 'Coef', 'BMIpQ')

SCgood_ribbon_nSCcont_data_taste.BMIpQ = MouseT_nSCcont_TVEMplotdata[MouseT_nSCcont_TVEMplotdata$ghtbmi21ccccplotdata.sas7bdat_BMIp_TDif_int_U < 0 & MouseT_nSCcont_TVEMplotdata$ghtbmi21ccccplotdata.sas7bdat_BMIp_TDif_int_L < 0, c('ghtbmi21ccccplotdata.sas7bdat_TimePoint', 'ghtbmi21ccccplotdata.sas7bdat_BMIp_TDif_int')]
SCgood_ribbon_nSCcont_data_taste.BMIpQ$BMIpQ = NA
names(SCgood_ribbon_nSCcont_data_taste.BMIpQ) = c('TimePoint', 'Coef', 'BMIpQ')

SCgood_range_nSCcont_taste.BMIpQ = max(MouseT_nSCcont_TVEMplotdata$ghtbmi21ccccplotdata.sas7bdat_BMIp_TDif_int_U) - min(MouseT_nSCcont_TVEMplotdata$ghtbmi21ccccplotdata.sas7bdat_BMIp_TDif_int_L)+0.02

SCgood_TVEM_plot_nSCcont_taste.BMIpQ = ggplot(SCgood_shade_nSCcont_data_taste.BMIpQ, aes(x=TimePoint),
                                      environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('SC Good Trials Taste: TVEM coefficients with 95% confidence bounds by BMI percentile Quartile') +
  geom_ribbon(data = SCgood_ribbon_nSCcont_data_taste.BMIpQ, mapping = aes(ymin=min(MouseT_nSCcont_TVEMplotdata$ghtbmi21ccccplotdata.sas7bdat_BMIp_TDif_int_L)-0.02, ymax = min(MouseT_nSCcont_TVEMplotdata$ghtbmi21ccccplotdata.sas7bdat_BMIp_TDif_int_L)-0.02+.025*SCgood_range_nSCcont_taste.BMIpQ), fill = 'darkorange1') +
  geom_ribbon(data = MouseT_nSCcont_TVEMplotdata, mapping = aes(ymin=ghtbmi21ccccplotdata.sas7bdat_BMIp_TDif_int_L, ymax = ghtbmi21ccccplotdata.sas7bdat_BMIp_TDif_int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_nSCcont_TVEMplotdata_SCgood_taste.BMIpQ_long, aes(x = TimePoint, y = Coef/100, color=BMIpQ), linetype = 1, size = 1.5) +
  geom_line(data = SCgood_shade_nSCcont_data_taste.BMIpQ, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~.*100, name = "Coef of Taste", breaks=pretty_breaks(n = 7)),
                     name='Coef of Taste x BMI percentile Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c('deepskyblue2', 'mediumturquoise', 'blue4')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())


#### TVEMPlot: SC good Liking by SCSR combind plot
SCgood_shade_nSCcont_data_liking.SCSR = MouseT_nSCcont_TVEMplotdata[c('glsrk215cplot_TimePoint', 'glsrk215cplot_SCSR_LDif_int')]
SCgood_shade_nSCcont_data_liking.SCSR$SCSR = NA
names(SCgood_shade_nSCcont_data_liking.SCSR) = c('TimePoint', 'Coef', 'SCSR')

SCgood_ribbon_nSCcont_data_liking.SCSR = MouseT_nSCcont_TVEMplotdata[MouseT_nSCcont_TVEMplotdata$glsrk215cplot_SCSR_LDif_int_U < 0 & MouseT_nSCcont_TVEMplotdata$glsrk215cplot_SCSR_LDif_int_L < 0, c('glsrk215cplot_TimePoint', 'glsrk215cplot_SCSR_LDif_int')]
SCgood_ribbon_nSCcont_data_liking.SCSR$SCSR = NA
names(SCgood_ribbon_nSCcont_data_liking.SCSR) = c('TimePoint', 'Coef', 'SCSR')

SCgood_range_nSCcont_liking.SCSR = max(MouseT_nSCcont_TVEMplotdata$flsrkc343plot_SCSR_LDif_int_U) - min(MouseT_nSCcont_TVEMplotdata$flsrkc343plot_SCSR_LDif_int_L)+1.5

SCgood_TVEM_plot_nSCcont_liking.SCSR = ggplot(SCgood_shade_nSCcont_data_liking.SCSR, aes(x=TimePoint),
                                      environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('SC good Trials Liking: TVEM coefficients with 95% confidence bounds by SCSR') +
  geom_ribbon(data = SCgood_ribbon_nSCcont_data_liking.SCSR, mapping = aes(ymin=min(MouseT_nSCcont_TVEMplotdata$glsrk215cplot_SCSR_LDif_int_L)-1.5, ymax = min(MouseT_nSCcont_TVEMplotdata$glsrk215cplot_SCSR_LDif_int_L)-1.5+.025*SCgood_range_nSCcont_liking.SCSR), fill = 'deepskyblue2') +
  geom_ribbon(data = MouseT_nSCcont_TVEMplotdata, mapping = aes(ymin=glsrk215cplot_SCSR_LDif_int_L, ymax = glsrk215cplot_SCSR_LDif_int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_nSCcont_TVEMplotdata_SCgood_liking.SCSR_long, aes(x = TimePoint, y = Coef, color=SCSR), linetype = 1, size = 1.5) +
  geom_line(data = SCgood_shade_nSCcont_data_liking.SCSR, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~., name = "Coef of Liking", breaks=pretty_breaks(n = 7)),
                     name='Coef of Liking x Sex Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c('mediumturquoise', 'blue4', 'deepskyblue2')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### TVEMPlot: SC fail Liking by SCSR combind plot
SCfail_shade_nSCcont_data_liking.SCSR = MouseT_nSCcont_TVEMplotdata[c('flsrkc343plot_TimePoint', 'flsrkc343plot_SCSR_LDif_int')]
SCfail_shade_nSCcont_data_liking.SCSR$SCSR = NA
names(SCfail_shade_nSCcont_data_liking.SCSR) = c('TimePoint', 'Coef', 'SCSR')

SCfail_ribbon_nSCcont_data_liking.SCSR = MouseT_nSCcont_TVEMplotdata[MouseT_nSCcont_TVEMplotdata$flsrkc343plot_SCSR_LDif_int_U > 0 & MouseT_nSCcont_TVEMplotdata$flsrkc343plot_SCSR_LDif_int_L > 0, c('flsrkc343plot_TimePoint', 'flsrkc343plot_SCSR_LDif_int')]
SCfail_ribbon_nSCcont_data_liking.SCSR$SCSRp = NA
names(SCfail_ribbon_nSCcont_data_liking.SCSR) = c('TimePoint', 'Coef', 'SCSR')

SCfail_range_nSCcont_liking.SCSR = max(MouseT_nSCcont_TVEMplotdata$flsrkc343plot_SCSR_LDif_int_U) - min(MouseT_nSCcont_TVEMplotdata$flsrkc343plot_SCSR_LDif_int_L)

SCfail_TVEM_plot_nSCcont_liking.SCSR = ggplot(SCfail_shade_nSCcont_data_liking.SCSR, aes(x=TimePoint),
                                      environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('SC fail Trials Liking: TVEM coefficients with 95% confidence bounds by SCSR') +
  geom_ribbon(data = SCfail_ribbon_nSCcont_data_liking.SCSR, mapping = aes(ymin=min(MouseT_nSCcont_TVEMplotdata$flsrkc343plot_SCSR_LDif_int_L), ymax = min(MouseT_nSCcont_TVEMplotdata$flsrkc343plot_SCSR_LDif_int_L)+.025*SCfail_range_nSCcont_liking.SCSR), fill = 'deepskyblue2') +
  geom_ribbon(data = MouseT_nSCcont_TVEMplotdata, mapping = aes(ymin=flsrkc343plot_SCSR_LDif_int_L, ymax = flsrkc343plot_SCSR_LDif_int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_nSCcont_TVEMplotdata_SCfail_liking.SCSR_long, aes(x = TimePoint, y = Coef, color=SCSR), linetype = 1, size = 1.5) +
  geom_line(data = SCfail_shade_nSCcont_data_liking.SCSR, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~., name = "Coef of Liking", breaks=pretty_breaks(n = 7)),
                     name='Coef of Liking x Sex Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c('mediumturquoise','blue4', 'deepskyblue2')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### TVEMPlot: SC fail Liking by Age combind plot
SCfail_shade_nSCcont_data_liking.Age = MouseT_nSCcont_TVEMplotdata[c('flagec321plot_TimePoint', 'flagec321plot_age_LDif_int')]
SCfail_shade_nSCcont_data_liking.Age$AgeGroup = NA
names(SCfail_shade_nSCcont_data_liking.Age) = c('TimePoint', 'Coef', 'AgeGroup')

SCfail_ribbon_nSCcont_data_liking.Age = MouseT_nSCcont_TVEMplotdata[MouseT_nSCcont_TVEMplotdata$flagec321plot_age_LDif_int_U > 0 & MouseT_nSCcont_TVEMplotdata$flagec321plot_age_LDif_int_L > 0, c('flagec321plot_TimePoint', 'flagec321plot_age_LDif_int')]
SCfail_ribbon_nSCcont_data_liking.Age$AgeGroup = NA
names(SCfail_ribbon_nSCcont_data_liking.Age) = c('TimePoint', 'Coef', 'AgeGroup')

SCfail_range_nSCcont_liking.Age = max(MouseT_nSCcont_TVEMplotdata$flagec321plot_age_LDif_int_U) - min(MouseT_nSCcont_TVEMplotdata$flagec321plot_age_LDif_int_L)

SCfail_TVEM_plot_nSCcont_liking.Age = ggplot(SCfail_shade_nSCcont_data_liking.Age, aes(x=TimePoint),
                                     environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('SC fail Trials Liking: TVEM coefficients with 95% confidence bounds by Age') +
  geom_ribbon(data = SCfail_ribbon_nSCcont_data_liking.Age, mapping = aes(ymin=min(MouseT_nSCcont_TVEMplotdata$flagec321plot_age_LDif_int_L), ymax = min(MouseT_nSCcont_TVEMplotdata$flagec321plot_age_LDif_int_L)+.025*SCfail_range_nSCcont_liking.Age), fill = 'deepskyblue2') +
  geom_ribbon(data = MouseT_nSCcont_TVEMplotdata, mapping = aes(ymin=flagec321plot_age_LDif_int_L, ymax = flagec321plot_age_LDif_int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_nSCcont_TVEMplotdata_SCfail_liking.Age_long, aes(x = TimePoint, y = Coef/10, color=AgeGroup), linetype = 1, size = 1.5) +
  geom_line(data = SCfail_shade_nSCcont_data_liking.Age, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~.*10, name = "Coef of Liking", breaks=pretty_breaks(n = 7)),
                     name='Coef of Liking x Sex Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c('deepskyblue2','mediumturquoise', 'blue4')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### TVEMPlot: SC fail Taste by Age combind plot
SCfail_shade_nSCcont_data_taste.Age = MouseT_nSCcont_TVEMplotdata[c('fhtage213cc1plotdata.sas7bdat_TimePoint', 'fhtage213cc1plotdata.sas7bdat_age_TDif_Int')]
SCfail_shade_nSCcont_data_taste.Age$AgeGroup = NA
names(SCfail_shade_nSCcont_data_taste.Age) = c('TimePoint', 'Coef', 'AgeGroup')

SCfail_ribbon_nSCcont_data_taste.Age = MouseT_nSCcont_TVEMplotdata[MouseT_nSCcont_TVEMplotdata$fhtage213cc1plotdata.sas7bdat_age_TDif_Int_U > 0 & MouseT_nSCcont_TVEMplotdata$fhtage213cc1plotdata.sas7bdat_age_TDif_Int_L > 0, c('fhtage213cc1plotdata.sas7bdat_TimePoint', 'fhtage213cc1plotdata.sas7bdat_age_TDif_Int')]
SCfail_ribbon_nSCcont_data_taste.Age$AgeGroup = NA
names(SCfail_ribbon_nSCcont_data_taste.Age) = c('TimePoint', 'Coef', 'AgeGroup')

SCfail_range_nSCcont_taste.Age = max(MouseT_nSCcont_TVEMplotdata$fhtage213cc1plotdata.sas7bdat_age_TDif_Int_U) - min(MouseT_nSCcont_TVEMplotdata$fhtage213cc1plotdata.sas7bdat_age_TDif_Int_L)+0.5

SCfail_TVEM_plot_nSCcont_taste.Age = ggplot(SCfail_shade_nSCcont_data_taste.Age, aes(x=TimePoint),
                                    environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('SC fail Trials Taste: TVEM coefficients with 95% confidence bounds by Age') +
  geom_ribbon(data = SCfail_ribbon_nSCcont_data_taste.Age, mapping = aes(ymin=min(MouseT_nSCcont_TVEMplotdata$fhtage213cc1plotdata.sas7bdat_age_TDif_Int_L)-0.5, ymax = min(MouseT_nSCcont_TVEMplotdata$fhtage213cc1plotdata.sas7bdat_age_TDif_Int_L)-0.5+.025*SCfail_range_nSCcont_taste.Age), fill = 'darkorange1') +
  geom_ribbon(data = MouseT_nSCcont_TVEMplotdata, mapping = aes(ymin=fhtage213cc1plotdata.sas7bdat_age_TDif_Int_L, ymax = fhtage213cc1plotdata.sas7bdat_age_TDif_Int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_nSCcont_TVEMplotdata_SCfail_taste.Age_long, aes(x = TimePoint, y = Coef/10, color=AgeGroup), linetype = 1, size = 1.5) +
  geom_line(data = SCfail_shade_nSCcont_data_taste.Age, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~.*10, name = "Coef of Taste", breaks=pretty_breaks(n = 7)),
                     name='Coef of Taste x Age Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c('deepskyblue2', 'mediumturquoise', 'blue4')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())

#### TVEMPlot: SC fail Taste by SCSR combind plot
SCfail_shade_nSCcont_data_taste.SCSR = MouseT_nSCcont_TVEMplotdata[c('fhtsr213431plot_TimePoint', 'fhtsr213431plot_SCSR_TDif_Int')]
SCfail_shade_nSCcont_data_taste.SCSR$SCSR = NA
names(SCfail_shade_nSCcont_data_taste.SCSR) = c('TimePoint', 'Coef', 'SCSR')

SCfail_ribbon_nSCcont_data_taste.SCSR = MouseT_nSCcont_TVEMplotdata[MouseT_nSCcont_TVEMplotdata$fhtsr213431plot_SCSR_TDif_Int_U > 0 & MouseT_nSCcont_TVEMplotdata$fhtsr213431plot_SCSR_TDif_Int_L > 0, c('fhtsr213431plot_TimePoint', 'fhtsr213431plot_SCSR_TDif_Int')]
SCfail_ribbon_nSCcont_data_taste.SCSR$SCSR = NA
names(SCfail_ribbon_nSCcont_data_taste.SCSR) = c('TimePoint', 'Coef', 'SCSR')

SCfail_range_nSCcont_taste.SCSR = max(MouseT_nSCcont_TVEMplotdata$fhtsr213431plot_SCSR_TDif_Int_U) - min(MouseT_nSCcont_TVEMplotdata$fhtsr213431plot_SCSR_TDif_Int_L)+0.05

SCfail_TVEM_plot_nSCcont_taste.SCSR = ggplot(SCfail_shade_nSCcont_data_taste.SCSR, aes(x=TimePoint),
                                     environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('SC Fail Trials Taste: TVEM coefficients with 95% confidence bounds by SCSR') +
  geom_ribbon(data = SCfail_ribbon_nSCcont_data_taste.SCSR, mapping = aes(ymin=min(MouseT_nSCcont_TVEMplotdata$fhtsr213431plot_SCSR_TDif_Int_L)-0.05, ymax = min(MouseT_nSCcont_TVEMplotdata$fhtsr213431plot_SCSR_TDif_Int_L)-0.52+.025*SCfail_range_nSCcont_taste.SCSR), fill = 'darkorange1') +
  geom_ribbon(data = MouseT_nSCcont_TVEMplotdata, mapping = aes(ymin=fhtsr213431plot_SCSR_TDif_Int_L, ymax = fhtsr213431plot_SCSR_TDif_Int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_nSCcont_TVEMplotdata_SCfail_taste.SCSR_long, aes(x = TimePoint, y = Coef, color=SCSR), linetype = 1, size = 1.5) +
  geom_line(data = SCfail_shade_nSCcont_data_taste.SCSR, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~., name = "Coef of Taste", breaks=pretty_breaks(n = 7)),
                     name='Coef of Taste x SCSR Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c('mediumturquoise', 'blue4', 'deepskyblue2')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())


#### TVEMPlot: SC fail Health by SCSR combind plot
SCfail_shade_nSCcont_data_health.SCSR = MouseT_nSCcont_TVEMplotdata[c('fhtsr213431plot_TimePoint', 'fhtsr213431plot_SCSR_HDif_Int')]
SCfail_shade_nSCcont_data_health.SCSR$SCSR = NA
names(SCfail_shade_nSCcont_data_health.SCSR) = c('TimePoint', 'Coef', 'SCSR')

SCfail_ribbon_nSCcont_data_health.SCSR = MouseT_nSCcont_TVEMplotdata[MouseT_nSCcont_TVEMplotdata$fhtsr213431plot_SCSR_HDif_Int_U > 0 & MouseT_nSCcont_TVEMplotdata$fhtsr213431plot_SCSR_HDif_Int_L > 0, c('fhtsr213431plot_TimePoint', 'fhtsr213431plot_SCSR_HDif_Int')]
SCfail_ribbon_nSCcont_data_health.SCSR$SCSR = NA
names(SCfail_ribbon_nSCcont_data_health.SCSR) = c('TimePoint', 'Coef', 'SCSR')

SCfail_range_nSCcont_health.SCSR = max(MouseT_nSCcont_TVEMplotdata$fhtsr213431plot_SCSR_HDif_Int_U) - min(MouseT_nSCcont_TVEMplotdata$fhtsr213431plot_SCSR_HDif_Int_L)+5

SCfail_TVEM_plot_nSCcont_health.SCSR = ggplot(SCfail_shade_nSCcont_data_health.SCSR, aes(x=TimePoint),
                                      environment=environment ()) + 
  geom_hline(yintercept = 0, linetype=1, color = 'gray') + 
  ggtitle('SC Fail Trials Health: TVEM coefficients with 95% confidence bounds by SCSR') +
  geom_ribbon(data = SCfail_ribbon_nSCcont_data_health.SCSR, mapping = aes(ymin=min(MouseT_nSCcont_TVEMplotdata$fhtsr213431plot_SCSR_HDif_Int_L)-5, ymax = min(MouseT_nSCcont_TVEMplotdata$fhtsr213431plot_SCSR_HDif_Int_L)-5+.025*SCfail_range_nSCcont_health.SCSR), fill = 'darkorchid4') +
  geom_ribbon(data = MouseT_nSCcont_TVEMplotdata, mapping = aes(ymin=fhtsr213431plot_SCSR_HDif_Int_L, ymax = fhtsr213431plot_SCSR_HDif_Int_U), fill = 'lightgrey') +
  geom_line(data = MouseT_nSCcont_TVEMplotdata_SCfail_health.SCSR_long, aes(x = TimePoint, y = Coef, color=SCSR), linetype = 1, size = 1.5) +
  geom_line(data = SCfail_shade_nSCcont_data_health.SCSR, aes(x = TimePoint, y = Coef), linetype = "dashed", size = 1.5) +
  scale_y_continuous(sec.axis = sec_axis(~., name = "Coef of Health", breaks=pretty_breaks(n = 7)),
                     name='Coef of Health x SCSR Interaction', breaks=pretty_breaks(n = 7), expand = expand_scale(mult = c(.01, 0.01))) +
  scale_x_continuous(name='Time Point', breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_color_manual(values = c('mediumturquoise', 'blue4', 'deepskyblue2')) +
  geom_hline(yintercept = 0, linetype=1, color = 'black') + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        panel.background = element_blank())
