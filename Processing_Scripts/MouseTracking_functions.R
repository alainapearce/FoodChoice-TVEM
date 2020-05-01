# This list of functions is a subset of functions written by Alaina 
# Pearce in 2019. This function list is being used for 
# the purpose of processing the DMK SC_mouse tracking food choice
# task.
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

#####################################
####                             ####
####   Time Point Regressions    ####
####                             ####
#####################################
#The below function caluclates the impact of the difference in liking and 
#taste and health on mouse angle trajectory as caluclated by Sullivan, 
#with interpolation based on actual time stamps, and with interpolation 
#based on actual time stamps without excluding downward
#angles. The regression is calculated based on the input of which trials:
#all: all trials
#SC: self-control trials
#notSC: non self-control trials
#SCgood: sucessful self-control trials
#SCfail: unsucessful self-control trials
#SCoutcome: self-control trials with model controlling for trial sucess
MouseTracking_reg_par = function(dsetname, trials){
  
  #load dset
  dat = read.csv(paste('Data/ProcessedData/', dsetname, sep = ''))
  dat[[136]] = ifelse(dat[[29]] == 'Y' | dat[[31]] == 'Y' | dat[[33]] == 'Y', 'Y', 'N')
  names(dat) = c(names(dat)[1:135], "exclude")
  
  #all possible angle calculations from Matlab code:
  #angle_ES_LinInt_choiceD_downEx_dat: timepoints based on assumed equal distance (linspace 1 to 100); exclude downward angle movements-yi > yi+1
  #angle_LinInt_choiceD_downEx_dat: timepoints based on recorded time (linspace TimeStamp(1) to TimeStamp(end)); exclude downward angle movements-yi > yi+1
  #angle_LinInt_choiceD_dat: timepoints based on recorded time (linspace TimeStamp(1) to TimeStamp(end))
  angles = c('angle_LinInt_choiceD_dat')
  
  #create an empty dataset
  res_dat = matrix(NA, ncol = 105, nrow = 9*length(angles))
  
  #label rows for the angles
  res_dat[, 1] = c(rep('Tstamp_nodelete', 9))
  
  #label the model term
  res_dat[, 2] = c(rep('liking', 3), rep('taste', 3), rep('health', 3))
  
  #label the otucome for each model term
  measure = c('coef', 'pvalue', 'sig_ind')
  res_dat[, 3] = c(rep(measure, 3))
  
  #label that all are one tail tests
  res_dat[, 4] = c(rep('onetail', 9))
  
  for(a in 1:length(angles)){
    #subset data
    dat_sub = dat[dat[[34]] == angles[a], ]
      
    #which trials/version of regression
    #all
    if (trials == "all"){
      dat_sub = dat_sub[dat_sub[[136]] != 'Y', ]
      #SC = Self-control trials; SCoutcome = SC trials controlling for outcome
    } else if (trials == "SC" | trials == "SCoutcome"){
      dat_sub = dat_sub[dat_sub[[136]] != 'Y' & dat_sub[[12]] == 'Y', ]
      #Non self-control trials
    } else if (trials == "notSC"){
      dat_sub = dat_sub[dat_sub[[136]] != 'Y' & dat_sub[[12]] == 'N', ]
      #Successful self-control trials
    } else if (trials == "SCgood"){
      dat_sub = dat_sub[dat_sub[[136]] != 'Y' & dat_sub[[12]] == 'Y' & dat_sub[[13]] == 'Y', ]
      #Unsuccessful self-control trials
    } else if (trials == "SCfail"){
      dat_sub = dat_sub[dat_sub[[136]] != 'Y' & dat_sub[[12]] == 'Y' & dat_sub[[13]] != 'Y', ]
    }
    
    #if greater than/equal 15 trials points
    if(nrow(dat_sub) >= 15){
      
      #make temporary results dataset
      temp_res = matrix(NA, ncol = 105, nrow = 9)
    
      #loop through timepoints
      for(t in 2:101){
        #timepoint data column-t1 is column 35 so start at t2 (t1 has 0 angle because at origin)
        datcol = t + 34
        
        if(trials != "SCoutcome"){
          #like dif model: angle ~ LikeDif
          mod_sum_like = summary(lm(dat_sub[[datcol]]~dat_sub[[9]], data = dat_sub))
          
          #liking
          if(nrow(mod_sum_like$coefficients) != 2){
            temp_res[1, t+4] = NA
            temp_res[2, t+4] = NA
            temp_res[3, t+4] = 0
          } else {
            #beta coefficient
            temp_res[1, t+4] = mod_sum_like$coefficients[2,1]
            #p value
            temp_res[2, t+4] = mod_sum_like$coefficients[2,4]
            #significant time point-one-sided pvalue
            temp_res[3, t+4] = ifelse((temp_res[2, t+4]/2) <= 0.05, 1, 0)
          }
          
          #taste/health: angle ~ TasteDif + HealthDif
          mod_sum_tastehealth = summary(lm(dat_sub[[datcol]]~dat_sub[[10]] + dat_sub[[11]], data = dat_sub))
          
          #taste
          if(nrow(mod_sum_tastehealth$coefficients) != 3){
            #health
            temp_res[4, t+4] = NA
            temp_res[5, t+4] = NA
            temp_res[6, t+4] = 0
            
            #taste
            temp_res[7, t+4] = NA
            temp_res[8, t+4] = NA
            temp_res[9, t+4] = 0
          } else {
            #taste
            temp_res[4, t+4] = mod_sum_tastehealth$coefficients[2,1]
            temp_res[5, t+4] = mod_sum_tastehealth$coefficients[2,4]
            temp_res[6, t+4] = ifelse((temp_res[5, t+4]/2) <= 0.05, 1, 0)
            
            #health
            temp_res[7, t+4] = mod_sum_tastehealth$coefficients[3,1]
            temp_res[8, t+4] = mod_sum_tastehealth$coefficients[3,4]
            temp_res[9, t+4] = ifelse((temp_res[8, t+4]/2) <= 0.05, 1, 0)
          }
          
        } else if(trials == "SCoutcome"){
          #like dif: angle ~ Success (Y/N) + Like dif
          mod_sum_like = summary(lm(dat_sub[[datcol]]~dat_sub[[13]] + dat_sub[[9]], data = dat_sub))
          
          #liking
          if(nrow(mod_sum_like$coefficients) != 3){
            temp_res[1, t+4] = NA
            temp_res[2, t+4] = NA
            temp_res[3, t+4] = 0
          } else {
            #beta coefficient
            temp_res[1, t+4] = mod_sum_like$coefficients[3,1]
            #p value
            temp_res[2, t+4] = mod_sum_like$coefficients[3,4]
            #significant time point-one-sided pvalue
            temp_res[3, t+4] = ifelse((temp_res[2, t+4]/2) <= 0.05, 1, 0)
          }
          
          #taste/health: #like dif: angle ~ Success (Y/N) + TasteDif + LikeDif
          mod_sum_tastehealth = summary(lm(dat_sub[[datcol]]~dat_sub[[13]] + dat_sub[[10]] + dat_sub[[11]], data = dat_sub))
          
          if(nrow(mod_sum_tastehealth$coefficients) != 4){
            #taste
            temp_res[4, t+4] = NA
            temp_res[5, t+4] = NA
            temp_res[6, t+4] = 0
            
            #health
            temp_res[7, t+4] = NA
            temp_res[8, t+4] = NA
            temp_res[9, t+4] = 0
          } else {
            #taste
            temp_res[4, t+4] = mod_sum_tastehealth$coefficients[3,1]
            temp_res[5, t+4] = mod_sum_tastehealth$coefficients[3,4]
            temp_res[6, t+4] = ifelse((temp_res[5, t+4]/2) <= 0.05, 1, 0)
            
            #health
            temp_res[7, t+4] = mod_sum_tastehealth$coefficients[4,1]
            temp_res[8, t+4] = mod_sum_tastehealth$coefficients[4,4]
            temp_res[9, t+4] = ifelse((temp_res[8, t+4]/2) <= 0.05, 1, 0)
          }
        }
      }
    } else{
    #create an empty dataset
    temp_res = matrix('less15Trials', ncol = 105, nrow = 9)
    } 
    
    #get rows for angle
    num1 = a*9 - 8
    num2 = a*9
    
    #add results to dataset
    res_dat[num1:num2, 6:105] = temp_res[, 6:105]
  }
  
  return(res_dat)
}

#####################################
####                             ####
####     Group Path T-test       ####
####                             ####
#####################################
#The below function caluclates a t-test at each time point to test, on average, if the set of
#coefficients from the individual regressions are significantly different from zero. The regressions 
#regressions tested if liking or health and taste can predict the mouse angle trajectory 
#as caluclated by Sullivan, with interpolation based on actual time stamps,
#and with interpolation based on actual time stamps without excluding downward
#angles. The method of angle calculation will be based on the dataset provided--need to subset
#to just one method.
#
#The t-tests will be calculated for the entire sample, just those with healthy weight, and 
#just those with obesity
#
#beta
#sign: with sign from slope coef
#absValue: absolute value of beta

MouseTracking_ttest_coef = function(dset, beta_option){
  #make empty dset with nrow = number of rows/groups listed below
  #and ncol = number of time steps and group name
  coef_ttests = data.frame(matrix(data = NA, ncol = 102, nrow = 27))
  
  #set column names 
  names(coef_ttests) = c("Group", names(dset)[c(33:133)])
  
  #names of all the columns/groups to be tested for each coefficient
  coef_ttests$Group = c("All_coef_liking", "All_p_liking", "All_pInd_liking",  
                         "OB_coef_liking", "OB_p_liking", "OB_pInd_liking", 
                         "HW_coef_liking", "HW_p_liking", "HW_pInd_liking",
                         "All_coef_taste", "All_p_taste", "All_pInd_taste",  
                         "OB_coef_taste", "OB_p_taste", "OB_pInd_taste", 
                         "HW_coef_taste", "HW_p_taste", "HW_pInd_taste",
                         "All_coef_health", "All_p_health", "All_pInd_health",  
                         "OB_coef_health", "OB_p_health", "OB_pInd_health", 
                         "HW_coef_health", "HW_p_health", "HW_pInd_health")
  
  #list the coefficients/ratings estimated in the regressions
  ratings = c('liking', 'taste', 'health')
  
  #create list of start values for rows for each rating/coefficient
  #(i.e., the first row for liking, taste, health)
  row_start = matrix(c(1, 10, 19), ncol = 1)
  
  #for each rating
  for(res in 1:3){
    
    resrow_start = row_start[res]
    
    #reduce dataset to the rows for the current rating and for just coefficient estimates
    dataset = dset[dset[[30]] == ratings[res] & dset[[31]] == 'coef', ]
    
    #make sure time point coefficient columns are read as numeric
    dataset[33:133] = sapply(dataset[33:133], as.numeric)
    
    #loop through each group for sullivan
    for(g in 1:3){
      #row start for current group (i.e., if g = 1, 1*3-2 = 1; if g = 2, 2*3-2 = 4, etc...)
      resrow = g*3-2
      
      #get row for current estimate in the entire sample
      row1 = resrow_start+resrow-1
      
      #subset datset depending on the subgroup of participants
      if(g == 1){
        dset_gsub = dataset
      } else if(g == 2){
        dset_gsub = dataset[dataset[[28]] == "OWOB", ]
      } else if(g == 3){
        dset_gsub = dataset[dataset[[28]] == "HW", ]
      }
      
      #loop through timepoints
      for(t in 2:101){
        datcol = t + 32
        coefcol = t + 1
        
        #t-test to see if absolute valuedifferent from zero 
        if(beta_option == 'sign'){
          test = t.test(dset_gsub[[datcol]], mu=0)
        } else if(beta_option == 'absValue'){
          test = t.test(abs(dset_gsub[[datcol]]), mu=0)
        }
        
        #average coefficient
        coef_ttests[row1, coefcol] = mean(dset_gsub[[datcol]], na.rm = TRUE)
        
        #pvalue for t.test
        coef_ttests[resrow_start + resrow, coefcol] = test$p.value
        
        #one-sided pvalue sig test
        coef_ttests[resrow_start + resrow + 1, coefcol] = ifelse((test$p.value/2) <= 0.05, 1, 0)
      }
    }  
  }
    return(coef_ttests)
}
  
  
#####################################
####                             ####
####      Ttest sig point        ####
####                             ####
#####################################
#The below function find significant points with at least 10 significant timepoints in a row.
#Significance is based on the group t-tests at each timepoint for the coefficients from the
#regressions that tested if liking or health and taste can predict the mouse angle trajectory 
#as caluclated by Sullivan, with interpolation based on actual time stamps,
#and with interpolation based on actual time stamps without excluding downward
#angles. The method of angle calculation will be based on the dataset provided--need to subset
#to just one method.
#
#The significant time point will be calculated for the entire sample, just those with 
#healthy weight, and just those with obesity
coeff_lastsig_ttest = function(dat, TrialType){
  
  #make empty database
  last_sig_coeff = data.frame(matrix(NA, nrow = 9, ncol = 18))
  
  #add names
  names(last_sig_coeff) = c('Rating', 'Group', 'TrialType', 'lastSig', 'lastSig_start', 'sigToEnd', 'sigToEnd_10', 'lastSig_10', 'length_lastSig10', '2ndSig10_last', '2ndSig10_start', 'length_2ndSig10','3rdSig10_last', '3rdSig10_start', 'length_3rdSig10','4thSig10_last', '4thSig10_start', 'length_4thSig10')
  
  #fill in label for the for trial type
  last_sig_coeff$TrialType = c(rep(TrialType, 9) )
  
  #fill in the ratings
  last_sig_coeff$Rating = c(rep('liking', 3), rep('taste', 3), rep('health', 3))
  
  #fill in the groups
  groups = c('All', 'OB', 'HW')
  last_sig_coeff$Group = c(rep(groups, 3))
  
  #get starting point in dat from the MouseTracking_ttest_coef function above
  row_start_coef = matrix(c(1, 10, 19), ncol = 1)
  
  #get starting point in dat for the last_sig_coeff
  ls_start = matrix(c(1, 4, 7), ncol = 1)
  
  datrow = 0
  
  #for each rating
  for(r in 1:3){
    
    #starting rows for each rating from the dat from the MouseTracking_ttest_coef function above
    resrow_start = row_start_coef[r] 
    
    #data row for last_sig_coeff
    lsrow_start = ls_start[r]
    
    for(g in 1:3){
      #set up row number for group
      resrow = g*3-2
      
      #get overall start in MouseTracking_ttest_coef dat dataset
      datrow = resrow_start + resrow + 1
      
      #get overall start in last_sig_coeff
      ls_row = lsrow_start + g - 1
      
      #make sure all time point columns are numeric
      dat[2:102] = sapply(dat[2:102], as.numeric)
      
      #get the length of the time points
      #get the reverse order of the time points and match the value to 1; 
      #if the last time point is significant, then the match will be at value 1
      #because we revesered the order of the time points
      #subtract the match point from the total number of points and add 1 so that if
      #the last time point is significant you get 101 - 1 + 1 = 101 for your last sig point
      lastsig = length(dat[datrow, 2:102]) - match(1, rev(dat[datrow, 2:102])) + 1
      
      #if the last sig point is not NA
      if(!is.na(lastsig)){
        
        #save last sig point
        last_sig_coeff[ls_row, 5] = lastsig
        
        #get a data list that is from the first time point to the last sig point 
        #and reverse the order so you start at the sig point. Need to add 1 because dataset 
        #has the Group variable as the first collumn so the time point collumns are time
        #point + 1
        revdat = rev(dat[datrow, 2:(lastsig+1)])
        
        #loop through the reversed data to find where the significance first started
        for(m in 1:length(revdat)){
          #if you go through the whole set (m = total length)
          if(m == length(revdat)){
            #set first sig point to 1 and save to data
            firstsig = lastsig - m + 1
            last_sig_coeff[ls_row, 6] = firstsig
            break
          } #else if the value at m is not equal to the previous one then found the end
          else if(is.na(revdat[m + 1])){
            #set first sig to the value at m; since m + 1 == NA it means m = 1 at t2 (end of sig)
            firstsig = lastsig - m
            last_sig_coeff[ls_row, 6] = firstsig
            break
          }
          else if(revdat[m] != revdat[m + 1]){
            #set first sig to the value before m; since  m != m + 1 it means m = 0 (end of sig)
            firstsig = lastsig - m + 1
            last_sig_coeff[ls_row, 6] = firstsig
            break
          }
        }
        
        #if the last sig was at the end of the timepoints
        if(lastsig == 101){
          #set that indicator
          last_sig_coeff[ls_row, 7] = 'Y'
          #if the start of the significance was at 90 or early, it meets the cutoff
          if(firstsig < 91){
            last_sig_coeff[ls_row, 8] = 'Y'
          } #if not, not enough values in a row
          else if(firstsig > 90){
            last_sig_coeff[ls_row, 8] = 'N'
          }
        } else if(lastsig != 101){
          last_sig_coeff[ls_row, 7] = 'N'
          last_sig_coeff[ls_row, 8] = 'N'
        }
        
        #if there is at least 10 sig points
        if(lastsig - firstsig + 1 >= 10){
          last_sig_coeff[ls_row, 9] = 'Y'
          last_sig_coeff[ls_row, 10] = lastsig - firstsig + 1
        } else if(lastsig - firstsig + 1 < 10){
          last_sig_coeff[ls_row, 9] = 'N'
        }
        
        #set a new end to continue checking for other significance points
        newend = firstsig - 1
        
        #make new dataset cutting off already found significant time points
        #could be only have 1 timepoint left so check by seeing if newend = 2.
        #check to see how many unique values are left
        if(newend == 2){
          dat2 = dat[, 2]
          nunique = length(unique(dat2))
        }else{
          dat2 = dat[, 2:newend]
          nunique = length(unique(t(dat2[datrow, ])))
        }
        
        nrep = 0
        #if there are 3 unique values (i.e., NA, 0, and 1), means there are still significant 
        #time poitns. if not, no more significant time points exist
        while(nunique == 3){
          #do same match procedure as above to find last sig point
          lastsig2 = length(dat2[datrow, ]) - match(1, rev(dat2[datrow, ])) + 1
          revdat = rev(dat2[datrow, 1:lastsig2])
          
          #same checking for first sig point as above
          for(m in 1:length(revdat)){
            if(m == (length(revdat) -1)){
              firstsig2 = lastsig2 - m + 1
              break
            } else if(revdat[m] != revdat[m + 1]){
              firstsig2 = lastsig2 - m + 1
              break
            }
          }
          
          #same checking for length criteria as above
          if(lastsig2 - firstsig2 + 1 >= 10){
            nrep = nrep + 1
            col1 = 8 + 3*nrep
            col2 = 9 + 3*nrep
            col3 = 10 + 3*nrep
            last_sig_coeff[ls_row, col1] = lastsig2
            last_sig_coeff[ls_row, col2] = firstsig2
            last_sig_coeff[ls_row, col3] = lastsig2 - firstsig2 + 1
          }
          
          #reset removing newly found sig points
          newend = firstsig2 - 1
          
          #if newend = 1, means at first timepoint, which is NA becaue was at 0,0 so stop loop
          if(newend == 1){
            nunique = 0
          } else {
            dat2 = dat2[, 1:newend]
            nunique = length(unique(t(dat2[datrow, ])))
          }
        }
        
      } else if(is.na(lastsig)){
        last_sig_coeff[ls_row, 5:6] = NA
        last_sig_coeff[ls_row, 7:9] = "N"
      }
    }
  }
  return(last_sig_coeff)
}

#####################################
####                             ####
####      Ind Path sigTimes      ####
####                             ####
#####################################
#The below function caluclates a t-test at each time point to test, on average, if the set of
#coefficients from the individual regressions are significantly different from zero. The regressions 
#regressions tested if liking or health and taste can predict the mouse angle trajectory 
#as caluclated by Sullivan, with interpolation based on actual time stamps,
#and with interpolation based on actual time stamps without excluding downward
#angles. The method of angle calculation will be based on the dataset provided--need to subset
#to just one method.
#
#The t-tests will be calculated for the entire sample, just those with healthy weight, and 
#just those with obesity

MouseTracking_ind_sigTimes = function(dat){
  
  #get indicator for individual IDs
  sub_dat = dat[which(dat[[31]]=='sig_ind'), ]
  IDs = unique(sub_dat[[1]])
  
  #ratings
  ratings = c('liking', 'taste', 'health')
  
  #loop through IDs to duplicate rows as needed
  for(r in 1:length(IDs)){
    #get indicator for rows that match the IDs
    sub_dat_ID = dat[[1]] == IDs[r]
    
    #get data that matches IDs and the main vars
    ID_dat = dat[sub_dat_ID, c(1:29,32)]
    
    #get the dataset started if first ID, otherwise add to end with rbind (row bind)
    if (r == 1){
      #get the first row of the ID_dat and repeat 3 tiems, add ratings info, and then empty columns to fill
      last_sig_coeff_SC = cbind(rep(ID_dat[1, ], each = 3), matrix(c('liking', 'taste', 'health'), nrow = 3, ncol = 1), matrix(NA, ncol = 15, nrow = 3))
    } else{
      #get the first row of the ID_dat and repeat 3 tiems, add ratings info, and then empty columns to fill
      #then rbind them to the existing data
      last_sig_coeff_SC = rbind(last_sig_coeff_SC, cbind(rep(ID_dat[1, ], each = 3), matrix(c('liking', 'taste', 'health'), nrow = 3, ncol = 1), matrix(NA, ncol = 15, nrow = 3)))
    }
  }
  
  #add names 
  names(last_sig_coeff_SC) = c(names(sub_dat)[c(1:29,32)], 'Rating', 'lastSig', 'lastSig_start', 'sigToEnd', 'sigToEnd_10', 'lastSig_10', 'length_lastSig10', '2ndSig10_last', '2ndSig10_start', 'length_2ndSig10','3rdSig10_last', '3rdSig10_start', 'length_3rdSig10','4thSig10_last', '4thSig10_start', 'length_4thSig10')
  
  #make long format
  dat_long = reshape2::melt(sub_dat[c(1, 30, 33:133)], id.vars = names(sub_dat[c(1, 30)]))
  #relabe with better name
  dat_long$sig_ind =  dat_long$value
  #reduce data
  dat_long = dat_long[c(1:2, 5)]
  
  #set counter to 0
  datrow = 0
  
  #loop through participants
  for(p in 1:(length(IDs))){
    
    #loop through ratings
    for(r in 1:3){
      
      #subset data to current rating
      par_dat = sub_dat[sub_dat[[30]] == ratings[r], ]
      par_dat_long = dat_long[dat_long[[2]]== ratings[r], ]
      
      #add to counter
      datrow = datrow + 1
      
      #get the data for the current participant ID
      par_dat_ind = par_dat[par_dat[[1]] == IDs[p], ]
      par_dat_long_ind = par_dat_long[par_dat_long[[1]] == IDs[p], ]
      
      #get the length of the time points
      #get the reverse order of the time points and match the value to 1; 
      #if the last time point is significant, then the match will be at value 1
      #because we revesered the order of the time points
      #subtract the match point from the total number of points and add 1 so that if
      #the last time point is significant you get 101 - 1 + 1 = 101 for your last sig point
      lastsig = length(par_dat_long_ind[[3]]) - match(1, rev(par_dat_long_ind[[3]])) + 1
      
      #if the last sig point is not NA
      if(!is.na(lastsig)){
        #save last sig point
        last_sig_coeff_SC[datrow, 32] = lastsig
        
        #get a data list that is from the first time point to the last sig point 
        #and reverse the order so you start at the sig point. Need to add 1 because dataset 
        #has the Group variable as the first collumn so the time point collumns are time
        #point + 1
        revdat = rev(par_dat_long_ind[1:lastsig, 3])
        
        #loop through the reversed data to find where the significance first started
        for(m in 1:length(revdat)){
          #if you go through the whole set (m = total length)
          if(m == (length(revdat) -1)){
            firstsig = lastsig - m + 1
            last_sig_coeff_SC[datrow, 33] = firstsig
            break
          } else if (is.na(revdat[m + 1])){
            firstsig = lastsig - m
            last_sig_coeff_SC[datrow, 33] = firstsig
          }
          #else if the value at m is not equal to the previous one then found the end
          else if(revdat[m] != revdat[m + 1]){
            #set first sig to the value before m; since  m != m + 1 it means m = 0 (end of sig)
            firstsig = lastsig - m + 1
            last_sig_coeff_SC[datrow, 33] = firstsig
            break
          }
        }
        
        #if the last sig was at the end of the timepoints
        if(lastsig == 101){
          #set that indicator
          last_sig_coeff_SC[datrow, 34] = 'Y'
          
          #if the start of the significance was at 90 or early, it meets the cutoff
          if(firstsig < 91){
            last_sig_coeff_SC[datrow, 35] = 'Y'
          } else if(firstsig > 90){
            last_sig_coeff_SC[datrow, 35] = 'N'
          }
        } #if not, not enough values in a row
        else if(lastsig != 101){
          last_sig_coeff_SC[datrow, 34] = 'N'
          last_sig_coeff_SC[datrow, 35] = 'N'
        }
        
        #if there is at least 10 sig points
        if(lastsig - firstsig + 1 >= 10){
          last_sig_coeff_SC[datrow, 36] = 'Y'
          last_sig_coeff_SC[datrow, 37] = lastsig - firstsig + 1
        } else if(lastsig - firstsig + 1 < 10){
          last_sig_coeff_SC[datrow, 36] = 'N'
          last_sig_coeff_SC[datrow, 37] = lastsig - firstsig + 1
        }
        
        #set a new end to continue checking for other significance points
        #make new dataset cutting off already found significant time points
        #could be only have 1 timepoint left so check by seeing if newend = 2.
        #check to see how many unique values are left
        
        newend = firstsig - 1
        
        if(newend == 1){
          par_dat_long2 = par_dat_long_ind[1, ]
          nunique = length(unique(par_dat_long2[[3]]))
        }else{
          par_dat_long2 = par_dat_long_ind[1:newend, ]
          nunique = length(unique(par_dat_long2[[3]]))
        }
        
        nrep = 0
        #if there are 3 unique values (i.e., NA, 0, and 1), means there are still significant 
        #time poitns. if not, no more significant time points exist
        while(nunique == 3){
          #do same match procedure as above to find last sig point
          lastsig2 = length(par_dat_long2[[3]]) - match(1, rev(par_dat_long2[[3]])) + 1
          revdat = rev(par_dat_long2[1:lastsig2, 3])
          
          #same checking for first sig point as above
          for(m in 1:length(revdat)){
            if(m == (length(revdat) -1)){
              firstsig2 = lastsig2 - m + 1
              break
            } else if(is.na(revdat[m + 1])){
              firstsig2 = lastsig2 - m + 1
              break
            }
          }
            
          #same checking for length criteria as above
          if(lastsig2 - firstsig2 + 1 >= 10){
            nrep = nrep + 1
            col1 = 35 + 3*nrep
            col2 = 36 + 3*nrep
            col3 = 37 + 3*nrep
            last_sig_coeff_SC[datrow, col1] = lastsig2
            last_sig_coeff_SC[datrow, col2] = firstsig2
            last_sig_coeff_SC[datrow, col3] = lastsig2 - firstsig2 + 1
          }
          
          #reset removing newly found sig points
          newend = firstsig2 - 1
          
          #if newend = 1, means at first timepoint, which is NA becaue was at 0,0 so stop loop
          if(newend == 1){
            nunique = 0
          } else {
            par_dat_long2 = par_dat_long2[1:newend, ]
            nunique = length(unique(par_dat_long2[[3]]))
          }
        }
      } else if(is.na(lastsig)){
        last_sig_coeff_SC[datrow, 32:33] = NA
        last_sig_coeff_SC[datrow, 34:36] = "N"
      }
        
    }
  }
  
  return(last_sig_coeff_SC)
}

#####################################
####                             ####
####   TVEM Format Angle Dat     ####
####                             ####
#####################################
#The below function compiles long format data for 
#angles so that can be used in SAS TVEM macro
#The data is compiled based on the input of which trials:
#all: all trials
#SC: self-control trials
#notSC: non self-control trials
#SCgood: sucessful self-control trials
#SCfail: unsucessful self-control trials
#SCoutcome: self-control trials with model controlling for trial sucess
#The data is compiled based on the input of which approach:
#All: all appraochs in long format
#Sullivan: angle_ES_LinInt_choiceD_downEx_dat
#Tstamp: angle_LinInt_choiceD_downEx_dat
#Tstamp_nodelete: angle_LinInt_choiceD_dat

MouseTracking_Angles_TVEMformat_par = function(dsetname, trials, approach){
  
  #load dset
  dat = read.csv(paste('Data/ProcessedData/', dsetname, sep = ''))
  dat[[136]] = ifelse(dat[[29]] == 'Y' | dat[[31]] == 'Y' | dat[[33]] == 'Y', 'Y', 'N')
  names(dat) = c(names(dat)[1:135], "exclude")
  
  #angle calculations from Matlab code:
  #angle_ES_LinInt_choiceD_downEx_dat: timepoints based on assumed equal distance (linspace 1 to 100); exclude downward angle movements-yi > yi+1
  #angle_LinInt_choiceD_downEx_dat: timepoints based on recorded time (linspace TimeStamp(1) to TimeStamp(end)); exclude downward angle movements-yi > yi+1
  #angle_LinInt_choiceD_dat: timepoints based on recorded time (linspace TimeStamp(1) to TimeStamp(end))
  if(approach == 'all'){
    dat_angles = dat[dat[[34]] != 'angle_ES_LinInt_choiceD_dat', ]
    dat_angles[[34]] = ifelse(dat_angles[[34]] == 'angle_ES_LinInt_choiceD_downEx_dat', 'Sullivan', ifelse(
      dat_angles[[34]] == 'angle_LinInt_choiceD_dat', 'Tstamp', 'Tstamp_nodelete'))
    dat_angles[[34]] = factor(dat_angles[[34]], levels = c('Sullivan', 'Tstamp', 'Tstamp_nodelete'))
  } else if (approach == 'Sullivan'){
    dat_angles = dat[dat[[34]] == 'angle_ES_LinInt_choiceD_downEx_dat', ]
    dat_angles[[34]] = 'Sullivan'
  } else if (approach == 'Tstamp'){
    dat_angles = dat[dat[[34]] == 'angle_LinInt_choiceD_dat', ]
    dat_angles[[34]] = 'Tstamp'
  } else if (approach == 'Tstamp_nodelete'){
    dat_angles = dat[dat[[34]] == 'angle_LinInt_choiceD_downEx_dat', ]
    dat_angles[[34]] = 'Tstamp_nodelete'
  }
  
  #Trial type (e.g., SC) and exclusions
  if (trials == "all"){
    dat_sub = dat_angles[dat_angles[[136]] != 'Y', ]
    #SC = Self-control trials; SCoutcome = SC trials controlling for outcome
  } else if (trials == "SC" | trials == "SCoutcome"){
    dat_sub = dat_angles[dat_angles[[136]] != 'Y' & dat_angles[[12]] == 'Y', ]
    #Non self-control trials
  } else if (trials == "notSC"){
    dat_sub = dat_angles[dat_angles[[136]] != 'Y' & dat_angles[[12]] == 'N', ]
    #Successful self-control trials
  } else if (trials == "SCgood"){
    dat_sub = dat_angles[dat_angles[[136]] != 'Y' & dat_angles[[12]] == 'Y' & dat_angles[[13]] == 'Y', ]
    #Unsuccessful self-control trials
  } else if (trials == "SCfail"){
    dat_sub = dat_angles[dat_angles[[136]] != 'Y' & dat_angles[[12]] == 'Y' & dat_angles[[13]] != 'Y', ]
  }
  
  #melt the dataset from wide to long
  dat_sub_long = reshape2::melt(dat_sub, id.vars = names(dat_sub)[c(1:34, 136)])
  dat_sub_long[[38]] = as.numeric(gsub( "t", "", as.character(dat_sub_long[[36]])))
  dat_sub_long = dat_sub_long[c(1:34, 38, 37)]
  
  names(dat_sub_long) = c(names(dat_sub_long)[1:33], "method", "TimePoint", "Angle")
  return(dat_sub_long)
}
