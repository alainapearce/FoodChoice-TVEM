# This list of functions is a subset of functions written by Alaina 
# Pearce in 2015. This function list is being used for 
# the purpose of processing the DMK SC_mouse traking food choice
# task.
# 
#     Copyright (C) 2015 Alaina L Pearce
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

#### Basic Stats ####

##extracts standard deviation table for DV (either 1 variable or a vector of variables)--for more information on how tapply works, use the R help or RStudio help menu
##--DV can be a single variable or a data.frame/matrix of multiple variables 
##     eg. DV=data.frame(RTime.long$Load, cRTime.long$Block)
sd.function = function(data, DV, IV){
	sd=with(data, tapply(DV, IV, sd))
	return(sd)
}

sd.function.na = function(data, DV, IV){
  sd=with(data, tapply(DV, IV, sd, na.rm=T))
  return(sd)
}


##extracts standard error table for DV (either 1 variable or a set of variables)
##--to use with bar_graph.se, set function equal to er
##  eg. er=se.function()
##--DV can be a single variable or a data.frame/matrix of multiple variables 
##     eg. DV=data.frame(RTime.long$Load, cRTime.long$Load)
se.function=function(data, DV, IV){
	sd=with(data, tapply(DV, IV, sd))
	length=with(data, tapply(DV, IV, length))
  #length is determining the n of the data
	er=sd/sqrt(length)
	return(er)
}

se.function.na=function(data, DV, IV){
  sd=with(data, tapply(DV, IV, sd, na.rm=T))
  length=with(data, tapply(DV, IV, length))
  #length is determining the n of the data
  er=sd/sqrt(length)
  return(er)
}

##extracts mean table for DV (either 1 variable or a set of variables)
##--to use with bar_graph.se, set function equal to means
##  eg. means=means.function()
##--DV can be a single variable or a data.frame/matrix of multiple variables 
##     eg. DV=data.frame(RTime.long$Load, cRTime.long$Load)
means.function = function(data, DV, IV){
	means=with(data, tapply(DV, IV, mean))
	return(means)
}

means.function.na = function(data, DV, IV){
  means=with(data, tapply(DV, IV, mean, na.rm=T))
  return(means)
}

##extracts median table for DV (either 1 variable or a set of variables)
##--to use with bar_graph.se, set function equal to medians
##  eg. medians=med.function()
##--DV can be a single variable or a data.frame/matrix of multiple variables 
##     eg. DV=data.frame(RTime.long$Load, cRTime.long$Load)
med.function = function(data, DV, IV){
  means=with(data, tapply(DV, IV, median))
  return(means)
}

med.function.na = function(data, DV, IV){
  means=with(data, tapply(DV, IV, median, na.rm = T))
  return(means)
}

##extracts IQR table for DV (either 1 variable or a set of variables)
##--to use with bar_graph.se, set function equal to interquartile range
##  eg. IQR=IQR.function()
##--DV can be a single variable or a data.frame/matrix of multiple variables 
##     eg. DV=data.frame(RTime.long$Load, cRTime.long$Load)
IQR.function = function(data, DV, IV){
  means=with(data, tapply(DV, IV, IQR))
  return(means)
}

IQR.function.na = function(data, DV, IV){
  means=with(data, tapply(DV, IV, IQR, na.rm = T))
  return(means)
}

##extracts range table for DV (either 1 variable or a set of variables)
##--to use with bar_graph.se, set function equal to interquartile range
##  eg. IQR=IQR.function()
##--DV can be a single variable or a data.frame/matrix of multiple variables 
##     eg. DV=data.frame(RTime.long$Load, cRTime.long$Load)
range.function = function(data, DV, IV){
  ranges=with(data, tapply(DV, IV, range))
  return(ranges)
}

range.function.na = function(data, DV, IV){
  ranges=with(data, tapply(DV, IV, range, na.rm=T))
  return(ranges)
}

##correlation matrix--only show values with p<0.100. Note: missing values are removed via case-wise deletion. var_vector is a data set or matrix with variables, var_names is a vector of strings for collumn headers/variable names
cor.matrix=function(var_vector, var_names){
  l=length(var_vector)
  res_matrix=matrix(numeric(0),l,l)
  dimnames(res_matrix) <- list(var_names, var_names)
  icount=0
  jcount=0
  
  for (i in 1:l) {
    icount=icount+1
    jcount=0
    for (j in 1:l){
      jcount=jcount+1
      x=var_vector[[i]]
      y=var_vector[[j]]
      
      p_res=round(cor.test(x,y, na.rm=TRUE)$p.value, 3)
      c_res=round(cor.test(x,y, na.rm=TRUE)$estimate, 2)
      
      res_matrix[icount,jcount]=c_res
      
    }
    
  }
  
  #diag_matrix=as.dist(res_matrix)
  res_matrix[upper.tri(res_matrix,diag=TRUE)] <- "" 
  diag_matrix=res_matrix[,1:l]
  return(diag_matrix)
}

##correlation matrix--only show values with p<0.100. Note: missing values are removed via case-wise deletion. var_vector is a data set or matrix with variables, var_names is a vector of strings for collumn headers/variable names
cor.matrix_ps=function(var_vector, var_names){
  l=length(var_vector)
  res_matrix=matrix(numeric(0),l,l)
  dimnames(res_matrix) <- list(var_names, var_names)
  icount=0
  jcount=0
  
  for (i in 1:l) {
    icount=icount+1
    jcount=0
    for (j in 1:l){
      jcount=jcount+1
      x=var_vector[[i]]
      y=var_vector[[j]]
      
      p_res=round(cor.test(x,y, na.rm=TRUE)$p.value, 3)
      c_res=round(cor.test(x,y, na.rm=TRUE)$estimate, 2)
      
      res_matrix[icount,jcount]=p_res
      
    }
    
  }
  
  #diag_matrix=as.dist(res_matrix)
  res_matrix[upper.tri(res_matrix,diag=TRUE)] <- "" 
  diag_matrix=res_matrix[,1:l]
  return(diag_matrix)
}


#### Graphing ####

##make bar graph with standard error bars and is designed to be used in congunction with the means and se functions above.  In this case it will only work if your DV vector has 2 or less variables.  If graphing a 3-way interaction see other function for splitting data sets by factors

##--group=0 if only have 1 DV, if DV is multiple variables, group is the variable name for the grouping one
##if group =! 0, it means you have two DV's/a DV and a covariate. The first variable listed in your DV vector will be represtened by different colors in the legend. This will be the "group" variable and will create side by side bars. The second variable will have levels represented on x-axis. note: xpd=False restrains bars to graphic pane (can truncate lower part of graph)
bar_graph.se = function(means, er, xlab, ylab, ymax, ymin, group){
  if (group==0) {
    barx<-barplot(means, col="cornflowerblue", ylab=ylab, xlab=xlab, ylim=c(ymin, ymax), xpd=FALSE)
    axis(2)
    axis(1, at=c(0,7), labels=FALSE)
    #this adds the SE wiskers
    arrows(barx, means+er, barx, means-er, angle=90, code=3, length=0.2)
  }
  
  else {
    #palette(c("steelblue4", "lightsteelblue2", "cornflowerblue", "cyan3", "darkcyan", "aquamarine4", "royalblue4","cornflowerblue", "darkturquoise"))
    palette(c("blue", "cadetblue1", "cornflowerblue", "cyan3", "darkcyan", "aquamarine4", "royalblue4","cornflowerblue", "darkturquoise"))
    len=length(levels(group))
    col.list = 1:len
    col.list_dif = 7:9
    par(fig=c(0, 0.8,0,1), mar=c(4,4,4,4))
    barx<-barplot(means, col=c(col.list), beside=T, ylab=ylab, xlab=xlab, ylim=c(ymin ,ymax), xpd = FALSE, cex.axis=1, cex.lab=1, lwd=1:2, angle=c(45), density=10)
    barx<-barplot(means, add=TRUE, col=c(col.list), beside=T, ylab=ylab, xlab=xlab, ylim=c(ymin ,ymax), xpd = FALSE, cex.axis=1, cex.lab=1)
    #axis(2)
    axis(1, at=c(0,20), labels=FALSE)
    #this adds the SE wiskers
    arrows(barx, means+er, barx, means-er, angle=90, code=3, length=0.2)
    #create space for legend
    par(new=T)
    par(fig=c(0, 0.8, 0, 1), mar=c(4, 4, 4, 0))
    plot(5,5,axes=FALSE, ann=FALSE, xlim=c(0,10),ylim=c(0,10), type="n")
    legend("topright", legend=levels(group), fill=c(col.list), bty="n",cex=1.2)
    
  } 
}

bar_graph.se_food = function(means, er, xlab, ylab, ymax, ymin, group){
  if (group==0) {
    par(fig=c(0, 1, 0.2, 1), mar = c(6, 4.1, 4.1, 2.1))
    barx<-barplot(means, col="cornflowerblue", ylab=ylab, xlab="", ylim=c(ymin, ymax), xpd=FALSE, las=3, cex.names=0.8)
    axis(2)
    axis(1, at=c(0,7), labels=FALSE)
    mtext(xlab, side=1, line=7)
    #this adds the SE wiskers
    arrows(barx, means+er, barx, means-er, angle=90, code=3, length=0.1)
    
  }
  
  else {
    #palette(c("steelblue4", "lightsteelblue2", "cornflowerblue", "cyan3", "darkcyan", "aquamarine4", "royalblue4","cornflowerblue", "darkturquoise"))
    palette(c("blue", "cadetblue1", "cornflowerblue", "cyan3", "darkcyan", "aquamarine4", "royalblue4","cornflowerblue", "darkturquoise"))
    len=length(levels(group))
    col.list = 1:len
    col.list_dif = 7:9
    par(fig=c(0, 0.8,0,1), mar=c(4,4,4,4))
    barx<-barplot(means, col=c(col.list), beside=T, ylab=ylab, xlab=xlab, ylim=c(ymin ,ymax), xpd = FALSE, cex.axis=1, cex.lab=1, lwd=1:2, angle=c(45), density=10, las=3)
    barx<-barplot(means, add=TRUE, col=c(col.list), beside=T, ylab=ylab, xlab=xlab, ylim=c(ymin ,ymax), xpd = FALSE, cex.axis=1, cex.lab=1, las=3)
    #axis(2)
    axis(1, at=c(0,20), labels=FALSE)
    #this adds the SE wiskers
    arrows(barx, means+er, barx, means-er, angle=90, code=3, length=0.2)
    #create space for legend
    par(new=T)
    par(fig=c(0, 0.8, 0, 1), mar=c(4, 4, 4, 0))
    plot(5,5,axes=FALSE, ann=FALSE, xlim=c(0,10),ylim=c(0,10), type="n")
    legend("topright", legend=levels(group), fill=c(col.list), bty="n",cex=1.2)
    
  } 
}

bar_graph_BW.se = function(means, er, xlab, ylab, ymax, ymin, group){
  if (group==0) {
    barx<-barplot(means, col="grey", ylab=ylab, xlab=xlab, ylim=c(ymin, ymax), xpd=FALSE)
    axis(2)
    axis(1, at=c(0,7), labels=FALSE)
    #this adds the SE wiskers
    arrows(barx, means+er, barx, means-er, angle=90, code=3, length=0.2)
  }
  
  else {
    palette(c("grey40", "grey", "grey100"))
    len=length(levels(group))
    col.list = 1:len
    col.list_dif = 7:9
    par(fig=c(0, 0.8,0,1), mar=c(4,4,4,4))
    barx<-barplot(means, col=c(col.list), beside=T, ylab=ylab, xlab=xlab, ylim=c(ymin ,ymax), xpd = FALSE, cex.axis=1, cex.lab=1, lwd=1:2, angle=c(45), density=10)
    barx<-barplot(means, add=TRUE, col=c(col.list), beside=T, ylab=ylab, xlab=xlab, ylim=c(ymin ,ymax), xpd = FALSE, cex.axis=1, cex.lab=1)
    #axis(2)
    axis(1, at=c(0,20), labels=FALSE)
    #this adds the SE wiskers
    arrows(barx, means+er, barx, means-er, angle=90, code=3, length=0.2)
    #create space for legend
    par(new=T)
    par(fig=c(0, 0.8, 0, 1), mar=c(4, 4, 4, 0))
    plot(5,5,axes=FALSE, ann=FALSE, xlim=c(0,10),ylim=c(0,10), type="n")
    legend("topright", legend=levels(group), fill=c(col.list), bty="n",cex=1.2)
    
  } 
}


#### ANOVA Table -> Xtable ####

##To use with ANOVA: output paramater refers to ANVOA table--need to set your ANOVA equal to a name  eg. ANOVA=Anova(y~x)
##To use with regression: output paramater refers to summary table output   eg. Summary=summary(lm(y~x))
##sig_vector is a data frame you create with sig stars entered
##  eg sig_vector=data.frame(c("",".","*","","","",""))--need to be sure to includ blank " " for rows with no sig star so your output and sig tables are of equal length

sig_stars.table=function(output, sig_vector){
  options(xtable.comment = FALSE)
  output_table=data.frame(output)
  output_table1=data.frame(output_table, sig_vector)
  names(output_table1)=c(colnames(output),"")
  output_xtable=xtable(output_table1, align="lccccl", comment = FALSE)
  digits(output_xtable)=c(0,3,3,3,3,0)
  return(output_xtable)
}

sig_stars_lmerTestAll.table=function(output, sig_vector){
  options(xtable.comment = FALSE)
  output_table=data.frame(output)
  output_table1=data.frame(output_table, sig_vector)
  names(output_table1)=c(colnames(output),"")
  output_xtable=xtable(output_table1, align="lccccccl", comment = FALSE)
  digits(output_xtable)=c(0,3,3,3,3,3,3,0)
  return(output_xtable)
}
