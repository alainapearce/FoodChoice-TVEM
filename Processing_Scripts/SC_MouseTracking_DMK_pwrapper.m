%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%   Mouse Traking SC Task data processing script      %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script was written by Alaina Pearce in February 2019 for 
% the purpose of processing the DMK SC_mouse tracking food choice
% task. The processing of mouse trajectories was adapated from 
% 'updatedCode.m' publicly provided by Nikki Sullivan on 
% OSF (https://osf.io/2bctm/).
% 
%     Copyright (C) 2019 Alaina L Pearce
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <https://www.gnu.org/licenses/>.

function SC_MouseTracking_DMK_pwrapper(parID, trajectory)
%parID-participant id; can be a single ID or a vector of id's 
%(e.g., [1, 3, 5]) or can specify 'ALL'

%trajectory: 'Both'-process data and trajectories; 'Y' just trajectory, 'N' just process data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%                         Setup                       %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%!need to edit this section (and all paths) if move script or any directories it calls!

%get working directory path for where this script is saved
script_wd = mfilename('fullpath');

%check if is mac and set direction of slash for paths
if ismac()
    slash_loc = find(script_wd == '/');
    slash = '/';
else 
    slash_loc = find(script_wd == '\');
    slash = '\';
end


%get location/character number for '/" in file path
slashloc_wd=find(script_wd==slash);

%get path without script name
base_wd = [script_wd(1:slashloc_wd(end)) 'Data' slash];

%this will tell matlab to look at all files withing the base_wd--so any
%subfolder will be added to search path
addpath(genpath(base_wd));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%         Load Databases and Clean up old ones        %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check if Databases directory exists-if doesn't, make one, if it does,
%load newest version
if ~exist([base_wd slash 'Databases'], 'dir')
    %make directory
    mkdir([base_wd slash 'Databases']);
    
    %make data struct
    %angle data 
    SC_MouseTracking_dat = array2table(NaN(0, 16));
    SC_MouseTracking_dat_VN = {'ParID' 'Hunger' 'WebMD_Time' 'nSC_Trials' 'percSC_success'  ...
        'nEx_outofbounds' 'meanTPoutbounds' 'nEx_Ycross' 'meanRT'  'medRT' 'meanRT_mouse' ...
        'medRT_mouse' 'meanRT_button'  'medRT_button' 'Ex_RT', 'meanYcross'};

    SC_MouseTracking_dat.Properties.VariableNames = SC_MouseTracking_dat_VN;
    
else
    cd([base_wd slash 'Databases']);

    %create str to identify files using wildcard '*'
    database_file_str = 'SC_MouseTracking_*.csv';

    %use str to identify files--save as table
    database_file = dir(char(database_file_str));
    database_file_tab = struct2table(database_file);

    if height(database_file_tab) > 1
        database_file_tab = sortrows(database_file_tab, 3, 'descend');
        SC_MouseTracking_dat = readtable(char(database_file_tab.name(1)), 'ReadVariableNames', true);
        SC_MouseTracking_dat_VN = SC_MouseTracking_dat.Properties.VariableNames;
    else
        SC_MouseTracking_dat = readtable(char(database_file_tab.name), 'ReadVariableNames', true);
        SC_MouseTracking_dat_VN = SC_MouseTracking_dat.Properties.VariableNames;
    end

    %make sure first collumn variable name is 'ParID' for both databases-- 
    %sometimes reads first collumn header in weird (e.g., 'x__ParID');
    if ~strcmp(SC_MouseTracking_dat_VN(1), 'ParID')
        SC_MouseTracking_dat_VN(1) = {'ParID'};
        SC_MouseTracking_dat.Properties.VariableNames = SC_MouseTracking_dat_VN;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%              Participant ID loop Setup              %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%if parID is 'ALL' get list
if strcmp(parID, 'ALL') || strcmp(parID, 'All') 
    par_files = dir(char([base_wd slahs 'RawData' slash '*']));
    par_files_tab = struct2table(par_files);
    
    %make sure only have files that start with 1 or 2-others have notes
    %about why can't use
    par_ind = startsWith(par_files_tab.name, '1') | startsWith(par_files_tab.name, '2');
    par_files_tab = par_files_tab(par_ind, :);
    
    %make participant numbers into numbers, not strings
    parID = str2double(par_files_tab.name(:));
end
    
%get number of participants
npar = length(parID);

%start loop based on number of inputs in parID variable
for p = 1:npar
    
    %parID
    parID_num = parID(p);
    
    %participant ID entry errors
    if parID_num == 101
        parID_file = 1001;
    elseif parID_num == 132
        parID_file = 1321;
    else
        parID_file = parID_num;
    end
    
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%        Process Particpant Raw Task Data             %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Go to raw data and load .txt file that was exported
    cd([base_wd slash 'RawData' slash num2str(parID_num) slash]);

    %load .mat file
    raw_matfile = load(['taskone_results_subj' num2str(parID_file) '.mat']);

    %load food ratings
    food_ratings = load(['taskone_s' num2str(parID_file) '_ratings.mat']);
    
    %get date
    today_date = date;

    %run raw data processing script to get two processed databases
    if strcmp(trajectory, 'N') || strcmp(trajectory, 'Both')
        [procRatings_dat, proc_dat, proc_LinInt_dat, proc_angle_LinInt_dat] = SC_MouseTracking_ProcRawMatfiles(parID_num, raw_matfile, food_ratings);
        
        %make directory
        if ~exist([base_wd slash 'ProcessedData'], 'dir')
            mkdir([base_wd slash 'ProcessedData']);
        end
        
        %go to processed data directory and write out processed data file
        cd([base_wd slash 'ProcessedData']);
        writetable(proc_dat, sprintf('SC_MouseTracking_Processed_%d_%s.csv', parID_num, today_date), 'WriteRowNames',true);
        writetable(proc_LinInt_dat, sprintf('SC_MouseTracking_Processed_LinearInt_%d_%s.csv', parID_num, today_date), 'WriteRowNames',true);
        writetable(proc_angle_LinInt_dat, sprintf('SC_MouseTracking_Processed_LinearInt_anglewide_%d_%s.csv', parID_num, today_date), 'WriteRowNames',true);
        writetable(procRatings_dat, sprintf('SC_MouseTracking_Processed_FoodRatings_%d_%s.csv', parID_num, today_date), 'WriteRowNames',true);
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%      Add Particpant Raw to Summary Database         %%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        IDcheck = SC_MouseTracking_dat.ParID == parID_num;
        if sum(IDcheck) ~= 0
            %message = sprintf('Participant %d existis. Do you want to delete and replace data? 1:yes, 2:no.', parID_num);
            %delete_parID = input(message);
            delete_parID = 1;
            if delete_parID == 1
                SC_MouseTracking_dat(IDcheck, :) = [];
            end
        end    

        if sum(IDcheck) == 0 || delete_parID == 1
            sum_res = array2table(NaN(1, 16));
            sum_res.Properties.VariableNames = SC_MouseTracking_dat_VN;

            ind_1TP = proc_dat.TimePoint == 1;
            ind_1TPmouse = strcmp(proc_dat.BlockType, 'mouse') & proc_dat.TimePoint == 1;
            ind_1TPbutton = strcmp(proc_dat.BlockType, 'keyboard');

            sum_res.ParID = parID_num;
            sum_res.Hunger = raw_matfile.data.hungerlevel;
            sum_res.WebMD_Time = raw_matfile.data.health_screen_seconds_viewed;

            sum_res.nSC_Trials = sum(strcmp(proc_dat.SC_Trial(ind_1TP), 'Y'));
            sum_res.percSC_success = sum(strcmp(proc_dat.SC_TrialSuccess(ind_1TP), 'Y'))/sum_res.nSC_Trials(1);
            sum_res.nEx_outofbounds = sum(strcmp(proc_dat.Ex_outbounds(ind_1TP), 'Y'));
            sum_res.meanTPoutbounds = mean(proc_dat.n_outbounds(ind_1TP));
            sum_res.nEx_Ycross = sum(strcmp(proc_dat.Ex_Ycross(ind_1TP), 'Y'));
            sum_res.meanYcross = mean(proc_dat.n_Ycross(ind_1TP));

            sum_res.meanRT = nanmean(proc_dat.RT(ind_1TP));
            sum_res.medRT = nanmedian(proc_dat.RT(ind_1TP));
            sum_res.meanRT_mouse = nanmean(proc_dat.RT(ind_1TPmouse));
            sum_res.medRT_mouse = nanmedian(proc_dat.RT(ind_1TPmouse));
            sum_res.meanRT_button = nanmean(proc_dat.RT(ind_1TPbutton));
            sum_res.medRT_button = nanmedian(proc_dat.RT(ind_1TPbutton));
            sum_res.Ex_RT = sum(strcmp(proc_dat.Ex_RT(ind_1TP), 'Y'));
        end
        
        %all participants
        SC_MouseTracking_dat = [SC_MouseTracking_dat; sum_res];
        
        %write out database
        writetable(SC_MouseTracking_dat, [base_wd slash 'Databases' slash sprintf('SC_MouseTracking_%s.csv', date)], 'WriteRowNames',true);

    end

    %run trajectory image script if indicated
    if strcmp(trajectory, 'Y') || strcmp(trajectory, 'Both')
        SC_MouseTracking_RawTrajectories(base_wd, parID_num, slash);
    end
end

