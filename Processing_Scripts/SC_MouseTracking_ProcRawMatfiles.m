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

function [procRatings_dat, proc_dat, proc_LinInt_dat, proc_angle_LinInt_dat] = SC_MouseTracking_ProcRawMatfiles(parID_num, raw_matfile, food_ratings)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%            Create Empty Data Structures             %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %create an empty database to organize data/put after pulling from
    %structure .mat file
    %ratings data
    procRatings_dat = array2table(NaN(6, 80));
    %note: choice 1=left
    foodnames = split(food_ratings.data.image_names(:)', ".");
    procRatings_dat_VN = {'ParID' 'Hunger' 'WebMD_Time' 'Rating' foodnames{:, :, 1}};

    procRatings_dat.Properties.VariableNames = procRatings_dat_VN;
    
    %add ratings data
    procRatings_dat.ParID(:) = parID_num;
    procRatings_dat.Hunger(:) = raw_matfile.data.hungerlevel;
    procRatings_dat.WebMD_Time(:) = raw_matfile.data.health_screen_seconds_viewed;
    procRatings_dat.Rating = string(procRatings_dat.Rating);
    procRatings_dat.Rating(:) = {'Health' 'Taste' 'Like' 'Health_RT' 'Taste_RT' 'Like_RT'};
    procRatings_dat(1, 5:end) = food_ratings.data.choicevalence(:,1)';
    procRatings_dat(2, 5:end) = food_ratings.data.choicevalence(:,2)';
    procRatings_dat(3, 5:end) = food_ratings.data.choicevalence(:,3)';
    procRatings_dat(4, 5:end) = num2cell(food_ratings.data.RT(:,1)');
    procRatings_dat(5, 5:end) = num2cell(food_ratings.data.RT(:,2)');
    procRatings_dat(6, 5:end) = num2cell(food_ratings.data.RT(:,3)');
    
    %create an empty database to organize data/put after pulling from
    %structure .mat file
    proc_dat = array2table(NaN(0, 47));
    %note: choice 1=left
    proc_dat_VN = {'ParID' 'Hunger' 'WebMD_Time' 'Block' 'BlockType' 'Trial' 'TT_Health' ...
        'TT_Taste' 'LikeDif' 'TasteDif' 'HealthDif' 'SC_Trial' 'SC_TrialSuccess' 'TimePoint' 'TimeStamp' ...
        'x_pos_pix' 'y_pos_pix' 'x_posCor_pix' 'y_posCor_pix' 'x_spRemap' 'y_spRemap' ...
        'x_spRemap_choiceD' 'y_spRemap_choiceD' 'L_liking' 'R_liking' 'L_taste' 'R_taste' ...
        'L_health' 'R_health' 'choice' 'chosen_health' 'unchosen_health' 'chosen_taste' 'unchosen_taste' ... 
        'chosen_like' 'unchosen_like' 'choice_type' 'RT' 'mpos_timestamp' 'tlapse_1move'...
        'mappeare_time' 'startbutton_time' 'Ex_Ycross' 'n_Ycross' 'Ex_outbounds' 'n_outbounds' 'Ex_RT'};

    proc_dat.Properties.VariableNames = proc_dat_VN;

    %linearly interpolated data
    proc_LinInt_dat = array2table(NaN(0, 52));
    %note: choice 1=left
    proc_dat_LinInt_VN = {'ParID' 'Hunger' 'WebMD_Time' 'Block' 'BlockType' 'Trial' 'TT_Health' ...
        'TT_Taste' 'LikeDif' 'TasteDif' 'HealthDif' 'SC_Trial' 'SC_TrialSuccess'  'L_liking' 'R_liking' ...
        'L_taste' 'R_taste' 'L_health' 'R_health' 'choice' 'chosen_health' 'unchosen_health' ...
        'chosen_taste' 'unchosen_taste' 'chosen_like' 'unchosen_like' 'choice_type' 'RT' ...
        'Ex_Ycross' 'n_Ycross' 'Ex_outofbounds' 'n_outbounds' 'Ex_RT' 'RowCount' 'TimePoint_ES_LinInt' 'TimeStamp_LinInt' ...
        'x_spRemap_LinInt' 'y_spRemap_LinInt' 'x_spRemap_LinInt_choiceD' 'y_spRemap_LinInt_choiceD' ...
        'x_pos_pix_LinInt' 'y_pos_pix_LinInt' 'angle_LinInt_choiceD' 'angle_LinInt_choiceD_downEx' ...
        'x_spRemap_ES_LinInt' 'y_spRemap_ES_LinInt' 'x_spRemap_ES_LinInt_choiceD' ...
        'y_spRemap_ES_LinInt_choiceD' 'x_pos_pix_ES_LinInt' 'y_pos_pix_ES_LinInt' ...
        'angle_ES_LinInt_choiceD' 'angle_ES_LinInt_choiceD_downEx'};

    proc_LinInt_dat.Properties.VariableNames = proc_dat_LinInt_VN;
    
    %angle data 
    proc_angle_LinInt_dat = array2table(NaN(0, 135));
    timepoints = strcat(repmat('t',101,1), string(linspace(1,101,101))')';
    proc_angle_LinInt_dat_VN = {'ParID' 'Hunger' 'WebMD_Time' 'Block' 'BlockType' 'Trial' 'TT_Health' ...
        'TT_Taste' 'LikeDif' 'TasteDif' 'HealthDif' 'SC_Trial' 'SC_TrialSuccess'  'L_liking' 'R_liking' ...
        'L_taste' 'R_taste' 'L_health' 'R_health' 'choice' 'chosen_health' 'unchosen_health' ...
        'chosen_taste' 'unchosen_taste' 'chosen_like' 'unchosen_like' 'choice_type' 'RT' ...
        'Ex_Ycross' 'n_Ycross' 'Ex_outofbounds' 'n_outbounds' 'Ex_RT', 'Variable', timepoints{:}};

    proc_angle_LinInt_dat.Properties.VariableNames = proc_angle_LinInt_dat_VN;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%        Process Particpant Raw Task Data             %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %loop through trials to create raw data file
    %get number of trials
    ntrials = raw_matfile.data.total_trials;

    %trial and block counters (80/block for mouse and 40 in keyboard
    %block)
    mcount = 0;
    bcount = 1;
    kcount = 0;

    %loop through trials to create raw data file and extract all data
    for t = 1:ntrials
        %get trial type
        ttype = raw_matfile.data.blocktype(t);

        %process data differently if mouse vs keyboard
        if strcmp(ttype, 'mouse')
            %count mouse trials-80 per block
            mcount = mcount + 1;

            %make table for trial that can be added to proc_dat
            trial_length = length(raw_matfile.data.position{t});
            trial_dat = array2table(zeros(trial_length, 47));
            trial_dat.Properties.VariableNames = proc_dat_VN;

            %make it possible for string values to be in vars
            trial_dat.BlockType = string(trial_dat.BlockType);
            trial_dat.Ex_outbounds = string(trial_dat.Ex_outbounds);
            trial_dat.Ex_RT = string(trial_dat.Ex_RT);
            trial_dat.Ex_Ycross = string(trial_dat.Ex_Ycross);
            trial_dat.TT_Health = string(trial_dat.TT_Health);
            trial_dat.TT_Taste = string(trial_dat.TT_Taste);
            trial_dat.SC_Trial = string(trial_dat.SC_Trial);
            trial_dat.SC_TrialSuccess = string(trial_dat.SC_TrialSuccess);
            trial_dat.choice_type = string(trial_dat.choice_type);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%               Extract trial level data              %%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            trial_dat.Block(:) = bcount;
            trial_dat.BlockType(:) = ttype;
            trial_dat.Trial(:) = t;
            trial_dat.TimePoint = linspace(1,trial_length, trial_length)';

            %rating data 
            L_img = raw_matfile.data.imageID(t, 1);
            R_img = raw_matfile.data.imageID(t, 2);

            L_rate_ind = strcmp(food_ratings.data.image_names, L_img);
            R_rate_ind = strcmp(food_ratings.data.image_names, R_img);

            L_rate_row = find(L_rate_ind);
            R_rate_row = find(R_rate_ind);

            trial_dat.L_liking(:) = cell2mat(food_ratings.data.choicevalence(L_rate_row, 3));
            trial_dat.L_health(:) = cell2mat(food_ratings.data.choicevalence(L_rate_row, 1));
            trial_dat.L_taste(:) = cell2mat(food_ratings.data.choicevalence(L_rate_row, 2));

            trial_dat.R_liking(:) = cell2mat(food_ratings.data.choicevalence(R_rate_row, 3));
            trial_dat.R_health(:) = cell2mat(food_ratings.data.choicevalence(R_rate_row, 1));
            trial_dat.R_taste(:) = cell2mat(food_ratings.data.choicevalence(R_rate_row, 2));

            %difference in ratings
            trial_dat.LikeDif(:) = trial_dat.R_liking(1) - trial_dat.L_liking(1);
            trial_dat.TasteDif(:) = trial_dat.R_taste(1) - trial_dat.L_taste(1);
            trial_dat.HealthDif(:) = trial_dat.R_health(1) - trial_dat.L_health(1);

            %trial type information
            if trial_dat.L_health(1) < 0 && trial_dat.R_health(1) < 0
                trial_dat.TT_Health(:) = 'Unhealthy';
            elseif trial_dat.L_health(1) > 0 && trial_dat.R_health(1) > 0
                trial_dat.TT_Health(:) = 'Healthy';
            elseif trial_dat.L_health(1) > 0 && trial_dat.R_health(1) < 0
                trial_dat.TT_Health(:) = 'Discordant';
            elseif trial_dat.L_health(1) < 0 && trial_dat.R_health(1) > 0
                trial_dat.TT_Health(:) = 'Discordant';
            elseif trial_dat.L_health(1) == 0 || trial_dat.R_health(1) == 0
                if trial_dat.L_health(1) + trial_dat.R_health(1) > 0
                    trial_dat.TT_Health(:) = 'HealthyNeutral';
                elseif trial_dat.L_health(1) + trial_dat.R_health(1) < 0
                    trial_dat.TT_Health(:) = 'UnhealthyNeutral';
                else
                    trial_dat.TT_Health(:) = 'Neutral';
                end
            end

            if trial_dat.L_taste(1) < 0 && trial_dat.R_taste(1) < 0
                trial_dat.TT_Taste(:) = 'Bad';
            elseif trial_dat.L_taste(1) > 0 && trial_dat.R_taste(1) > 0
                trial_dat.TT_Taste(:) = 'Good';
            elseif trial_dat.L_taste(1) > 0 && trial_dat.R_taste(1) < 0
                trial_dat.TT_Taste(:) = 'Discordant';
            elseif trial_dat.L_taste(1) < 0 && trial_dat.R_taste(1) > 0
                trial_dat.TT_Taste(:) = 'Discordant';
            elseif trial_dat.L_taste(1) == 0 || trial_dat.R_taste(1) == 0
                if trial_dat.L_taste(1) + trial_dat.R_taste(1) > 0
                    trial_dat.TT_Taste(:) = 'GoodNeutral';
                elseif trial_dat.L_taste(1) + trial_dat.R_taste(1) < 0
                    trial_dat.TT_Taste(:) = 'BadNeutral';
                else
                    trial_dat.TT_Taste(:) = 'Neutral';
                end
            end

            %self-control trials
            if trial_dat.L_taste(1) > trial_dat.R_taste(1) && trial_dat.L_health(1) < trial_dat.R_health(1)
                trial_dat.SC_Trial(:) = 'Y';
            elseif trial_dat.L_taste(1) < trial_dat.R_taste(1) && trial_dat.L_health(1) > trial_dat.R_health(1)
                trial_dat.SC_Trial(:) = 'Y';
            else
                trial_dat.SC_Trial(:) = 'N';
            end

            %choice
            trial_dat.choice(:) = raw_matfile.data.choice(t);
            trial_dat.RT(:) = raw_matfile.data.RT(t);

            %get ratings for chosen and unchosen 
            if trial_dat.choice(1) == 1 
                trial_dat.chosen_health(:) = trial_dat.L_health(1);
                trial_dat.unchosen_health(:) = trial_dat.R_health(1);
                trial_dat.chosen_taste(:) = trial_dat.L_taste(1);
                trial_dat.unchosen_taste(:) = trial_dat.R_taste(1);
                trial_dat.chosen_like(:) = trial_dat.L_liking(1);
                trial_dat.unchosen_like(:) = trial_dat.R_liking(1);
            else
                trial_dat.chosen_health(:) = trial_dat.R_health(1);
                trial_dat.unchosen_health(:) = trial_dat.L_health(1);
                trial_dat.chosen_taste(:) = trial_dat.R_taste(1);
                trial_dat.unchosen_taste(:) = trial_dat.L_taste(1);
                trial_dat.chosen_like(:) = trial_dat.R_liking(1);
                trial_dat.unchosen_like(:) = trial_dat.L_liking(1);
            end

            %determine Self-control success
            if strcmp(trial_dat.SC_Trial, 'Y') 
                if trial_dat.chosen_health(1) > trial_dat.unchosen_health(1)
                    trial_dat.SC_TrialSuccess(:) = 'Y';
                else
                    trial_dat.SC_TrialSuccess(:) = 'N';
                end
            else
                trial_dat.SC_TrialSuccess(:) = NaN;
            end

            %determine choice type--if both have same sign there is no
            %difference in category, else compare chosen to not
            if sign(trial_dat.chosen_health(1)) == sign(trial_dat.unchosen_health(1))
                hstr = '';
            elseif trial_dat.chosen_health(1) > trial_dat.unchosen_health(1)
                hstr = 'Healthy';
            else
                hstr = 'LessHealthy';
            end

            if sign(trial_dat.chosen_taste(1)) == sign(trial_dat.unchosen_taste(1))
                tstr = '';
            elseif trial_dat.chosen_taste(1) > trial_dat.unchosen_taste(1)
                tstr = 'Tasty';
            else
                tstr = 'LessTasty';
            end

            if isempty([hstr, tstr])
                trial_dat.choice_type(:) = 'FullMatch';
            else
                trial_dat.choice_type(:) = [hstr, tstr];
            end

            %mouse position data
            trial_dat.x_pos_pix = raw_matfile.data.position{t}(:, 1);
            trial_dat.y_pos_pix = raw_matfile.data.position{t}(:, 2);
            trial_dat.mpos_timestamp = raw_matfile.data.position_time{t}(:);
            trial_dat.mappeare_time(:) = raw_matfile.data.mousestart(t);
            trial_dat.tlapse_1move(:) = raw_matfile.data.time_to_move(t);
            trial_dat.startbutton_time(:) = raw_matfile.data.start_screen_on(t);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%       process mouse trace data and transform        %%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %in original code, x and y starting positions re-set to origin to
            % account for sampling error
            trial_dat.x_posCor_pix = trial_dat.x_pos_pix;
            trial_dat.y_posCor_pix = trial_dat.y_pos_pix;
            trial_dat.x_posCor_pix(1) = raw_matfile.data.starting_x;
            trial_dat.y_posCor_pix(1) = raw_matfile.data.starting_y;

            %resample so start is at 0,0 to get standard coordinate
            %space--this will force all choices to be on right side
            %(0,0 will coorespond to starting position on Start Box)
            trial_dat.x_spRemap = (trial_dat.x_posCor_pix - trial_dat.x_posCor_pix(1))/...
                                  (trial_dat.x_posCor_pix(end) - trial_dat.x_posCor_pix(1));

            trial_dat.y_spRemap = (trial_dat.y_posCor_pix - trial_dat.y_posCor_pix(1))/...
                                  (trial_dat.y_posCor_pix(end) - trial_dat.y_posCor_pix(1));

            %add choice information back into data by making x
            %coordinates negative for lefthand side.
            if trial_dat.choice(1) == 1
                trial_dat.x_spRemap_choiceD = -1*trial_dat.x_spRemap;
            else
                trial_dat.x_spRemap_choiceD = trial_dat.x_spRemap;
            end
            trial_dat.y_spRemap_choiceD = trial_dat.y_spRemap;

            %get first timepoint based on how task calculated first
            %move time lapse
            first_time = trial_dat.tlapse_1move(1) + raw_matfile.data.afterstart_interval(t) + trial_dat.startbutton_time(1);

            %zero first volume (time step larger between 1 and 2 so
            %will get negative value.
            trial_dat.TimeStamp = [0; trial_dat.mpos_timestamp(2:end) - first_time];

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%             Exclusion criteria by trials            %%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %optional: exclude if cross y axis more than 3 times
            ycross=0;
            for tp=2:trial_length
                if roundn(trial_dat.x_posCor_pix(tp),1) < raw_matfile.data.starting_y && roundn(trial_dat.x_posCor_pix(tp-1),1) >= raw_matfile.data.starting_y ...
                    || roundn(trial_dat.x_posCor_pix(tp),1) > raw_matfile.data.starting_y && roundn(trial_dat.x_posCor_pix(tp-1),1) <= raw_matfile.data.starting_y
                    ycross = ycross+1;
                end
            end

            trial_dat.n_Ycross(:) = ycross;

            if ycross <= 3 && trial_length > 20
                trial_dat.Ex_Ycross(:) = 'N';
            else
                trial_dat.Ex_Ycross(:) = 'Y';
            end

            %over/under shoots--the spatial remapped image box widths
            %span from -1.319 to -0.5 on left and 0.5 to 1.319 on
            %right)
            if sum(trial_dat.x_spRemap > 1.3) > 0 % ... it's an overshoot/undershoot 
                trial_dat.Ex_outbounds(:) = 'Y';
            else
                trial_dat.Ex_outbounds(:) = 'N';
            end

            trial_dat.n_outbounds(:) = sum(trial_dat.x_spRemap > 1.3);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%                Linear Interpolation                 %%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %make table for interpolated data that can be added to proc_dat
            subset = [trial_dat(1, 1:13), trial_dat(1, 24:38), trial_dat(1, 43:47)];
            trial_dat_LinInt = array2table(repmat(table2array(subset), 101, 1));
            trial_dat_LinInt.Properties.VariableNames = proc_dat_LinInt_VN(1:33);
            trial_dat_LinInt = [trial_dat_LinInt, array2table(zeros(101, 19))];
            trial_dat_LinInt.Properties.VariableNames = proc_dat_LinInt_VN;

            %row count
            trial_dat_LinInt.RowCount = linspace(1, 101, 101)';

            %based on zero-ed timestamp data
            trial_dat_LinInt.TimeStamp_LinInt = linspace(trial_dat.TimeStamp(1),trial_dat.TimeStamp(end),101)';

            %based on assumed equally spaced timestamps
            trial_dat_LinInt.TimePoint_ES_LinInt = linspace(1,trial_length,101)';

            %linearly interpolate the resampled, all right-hand side
            %coordinatesx
            %based on time stamps
            trial_dat_LinInt.x_spRemap_LinInt = interp1(trial_dat.TimeStamp,... 
                trial_dat.x_spRemap, trial_dat_LinInt.TimeStamp_LinInt, 'linear');

            trial_dat_LinInt.y_spRemap_LinInt = interp1(trial_dat.TimeStamp,... 
                trial_dat.y_spRemap, trial_dat_LinInt.TimeStamp_LinInt, 'linear');

            %assuming equal distances
            trial_dat_LinInt.x_spRemap_ES_LinInt = interp1(trial_dat.TimePoint,... 
                trial_dat.x_spRemap, trial_dat_LinInt.TimePoint_ES_LinInt, 'linear');

            trial_dat_LinInt.y_spRemap_ES_LinInt = interp1(trial_dat.TimePoint,... 
                trial_dat.y_spRemap, trial_dat_LinInt.TimePoint_ES_LinInt, 'linear');


            %linearly interpolate the resampled, choice maintained
            %coordinates
            %based on time stamps
            trial_dat_LinInt.x_spRemap_LinInt_choiceD = interp1(trial_dat.TimeStamp,... 
                trial_dat.x_spRemap_choiceD, trial_dat_LinInt.TimeStamp_LinInt, 'linear');

            trial_dat_LinInt.y_spRemap_LinInt_choiceD = interp1(trial_dat.TimeStamp,... 
                trial_dat.y_spRemap_choiceD, trial_dat_LinInt.TimeStamp_LinInt, 'linear');

            %assuming equal distances
            trial_dat_LinInt.x_spRemap_ES_LinInt_choiceD = interp1(trial_dat.TimePoint,... 
                trial_dat.x_spRemap_choiceD, trial_dat_LinInt.TimePoint_ES_LinInt, 'linear');

            trial_dat_LinInt.y_spRemap_ES_LinInt_choiceD = interp1(trial_dat.TimePoint,... 
                trial_dat.y_spRemap_choiceD, trial_dat_LinInt.TimePoint_ES_LinInt, 'linear');

            %linearly interpolate with the pixel informaiton maintained
            %coordinates
            %based on time stamps
            trial_dat_LinInt.x_pos_pix_LinInt = interp1(trial_dat.TimeStamp,... 
                trial_dat.x_posCor_pix, trial_dat_LinInt.TimeStamp_LinInt, 'linear');

            trial_dat_LinInt.y_pos_pix_LinInt = interp1(trial_dat.TimeStamp,... 
                trial_dat.y_posCor_pix, trial_dat_LinInt.TimeStamp_LinInt, 'linear');

            %assuming equal distances
            trial_dat_LinInt.x_pos_pix_ES_LinInt = interp1(trial_dat.TimePoint,... 
                trial_dat.x_posCor_pix, trial_dat_LinInt.TimePoint_ES_LinInt, 'linear');

            trial_dat_LinInt.y_pos_pix_ES_LinInt = interp1(trial_dat.TimePoint,... 
                trial_dat.y_posCor_pix, trial_dat_LinInt.TimePoint_ES_LinInt, 'linear');

            % Get the angles of time steps
            trial_dat_LinInt.angle_LinInt_choiceD = ...
                abs(atand(trial_dat_LinInt.x_spRemap_LinInt_choiceD ./ ...
                trial_dat_LinInt.y_spRemap_LinInt_choiceD)) .* ...
                sign(trial_dat_LinInt.x_spRemap_LinInt_choiceD);
            
            trial_dat_LinInt.angle_ES_LinInt_choiceD = ...
                abs(atand(trial_dat_LinInt.x_spRemap_ES_LinInt_choiceD ./ ...
                trial_dat_LinInt.y_spRemap_ES_LinInt_choiceD)) .* ...
                sign(trial_dat_LinInt.x_spRemap_ES_LinInt_choiceD);
            
            %get angles pointing downward and exclude (y axis is lower at 
            %t+1 timpoint than at timepoint t
            angle_LinInt_choiceD_downExInd = [false; ...
                trial_dat_LinInt.y_spRemap_LinInt_choiceD(2:end) < ...
                trial_dat_LinInt.y_spRemap_LinInt_choiceD(1:end-1)];

            trial_dat_LinInt.angle_LinInt_choiceD_downEx = trial_dat_LinInt.angle_LinInt_choiceD;
            trial_dat_LinInt.angle_LinInt_choiceD_downEx(angle_LinInt_choiceD_downExInd) = NaN;
            
            angle_ES_LinInt_choiceD_downExInd = [false; ...
                trial_dat_LinInt.y_spRemap_ES_LinInt_choiceD(2:end) < ...
                trial_dat_LinInt.y_spRemap_ES_LinInt_choiceD(1:end-1)];
            
            trial_dat_LinInt.angle_ES_LinInt_choiceD_downEx = trial_dat_LinInt.angle_ES_LinInt_choiceD;
            trial_dat_LinInt.angle_ES_LinInt_choiceD_downEx(angle_ES_LinInt_choiceD_downExInd) = NaN;
            

            %reformate so each of the 101 timepoints is a column and each trial is
            %row
            timepoints = strcat(repmat('t',101,1), string(linspace(1,101,101))')';
            angles_dat_VN = {timepoints{:}, 'Variable' };

            trial_angle_LinInt_dat = array2table([trial_dat_LinInt.angle_LinInt_choiceD';...
                trial_dat_LinInt.angle_LinInt_choiceD_downEx'; ...
                trial_dat_LinInt.angle_ES_LinInt_choiceD';...
                trial_dat_LinInt.angle_ES_LinInt_choiceD']); 
            
            trial_angle_LinInt_dat.Variable = {'angle_LinInt_choiceD_dat';...
                'angle_LinInt_choiceD_downEx_dat';...
                'angle_ES_LinInt_choiceD_dat';...
                'angle_ES_LinInt_choiceD_downEx_dat'};
            
            trial_angle_LinInt_dat.Properties.VariableNames = angles_dat_VN;
            
            trial_angle_LinInt_dat = [trial_dat_LinInt(1:4, 1:33), ...
                trial_angle_LinInt_dat(:,102), trial_angle_LinInt_dat(:,1:101)];
            
            %get velocity (speed) and accelleration information
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%             Exclusion criteria by trials            %%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % optional: exclude time points where mouse moving downward
            excludeInd = [false; trial_dat_LinInt.y_spRemap_LinInt_choiceD(2:end) < ...
                trial_dat_LinInt.y_spRemap_LinInt_choiceD(1:end-1)];
            trial_dat_LinInt.angle_LinInt_choiceD_downEx = trial_dat_LinInt.angle_LinInt_choiceD;
            trial_dat_LinInt.angle_LinInt_choiceD(excludeInd) = NaN;

            excludeInd_ES = [false; trial_dat_LinInt.y_spRemap_ES_LinInt_choiceD(2:end) < ...
                trial_dat_LinInt.y_spRemap_ES_LinInt_choiceD(1:end-1)];
            trial_dat_LinInt.angle_ES_LinInt_choiceD_downEx = trial_dat_LinInt.angle_ES_LinInt_choiceD;
            trial_dat_LinInt.angle_ES_LinInt_choiceD(excludeInd_ES) = NaN;

            %update block count
            if (floor(mcount/80) + 1) > bcount
                bcount = bcount + 1;
            end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%                   Keyboard Trials                   %%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif strcmp(ttype, 'keyboard')
            kcount = kcount + 1;

            %make table for trial that can be added to proc_dat
            trial_dat = array2table(zeros(1, 47));
            trial_dat.Properties.VariableNames = proc_dat_VN;

            %make it possible for string values to be in vars
            trial_dat.BlockType = string(trial_dat.BlockType);
            trial_dat.Ex_outbounds = string(trial_dat.Ex_outbounds);
            trial_dat.Ex_RT = string(trial_dat.Ex_RT);
            trial_dat.Ex_Ycross = string(trial_dat.Ex_Ycross);
            trial_dat.TT_Health = string(trial_dat.TT_Health);
            trial_dat.TT_Taste = string(trial_dat.TT_Taste);
            trial_dat.SC_Trial = string(trial_dat.SC_Trial);
            trial_dat.SC_TrialSuccess = string(trial_dat.SC_TrialSuccess);
            trial_dat.choice_type = string(trial_dat.choice_type);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%               Extract trial level data              %%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
            trial_dat.Block = bcount;
            trial_dat.BlockType = ttype;
            trial_dat.Trial = t;
            trial_dat.TimePoint = NaN;

            %rating data 
            L_img = raw_matfile.data.imageID(t, 1);
            R_img = raw_matfile.data.imageID(t, 2);

            L_rate_ind = strcmp(food_ratings.data.image_names, L_img);
            R_rate_ind = strcmp(food_ratings.data.image_names, R_img);

            L_rate_row = find(L_rate_ind);
            R_rate_row = find(R_rate_ind);

            trial_dat.L_liking = cell2mat(food_ratings.data.choicevalence(L_rate_row, 3));
            trial_dat.L_health = cell2mat(food_ratings.data.choicevalence(L_rate_row, 1));
            trial_dat.L_taste = cell2mat(food_ratings.data.choicevalence(L_rate_row, 2));

            trial_dat.R_liking = cell2mat(food_ratings.data.choicevalence(R_rate_row, 3));
            trial_dat.R_health = cell2mat(food_ratings.data.choicevalence(R_rate_row, 1));
            trial_dat.R_taste = cell2mat(food_ratings.data.choicevalence(R_rate_row, 2));

            %difference in liking 
            trial_dat.LikeDif = trial_dat.L_liking - trial_dat.R_liking;
            trial_dat.TasteDif = trial_dat.L_taste - trial_dat.R_taste;
            trial_dat.HealthDif = trial_dat.L_health - trial_dat.R_health;

            %trial type information
            if trial_dat.L_health < 0 && trial_dat.R_health < 0
                trial_dat.TT_Health = 'Unhealthy';
            elseif trial_dat.L_health > 0 && trial_dat.R_health > 0
                trial_dat.TT_Health = 'Healthy';
            elseif trial_dat.L_health > 0 && trial_dat.R_health < 0
                trial_dat.TT_Health = 'Discordant';
            elseif trial_dat.L_health < 0 && trial_dat.R_health > 0
                trial_dat.TT_Health = 'Discordant';
            elseif trial_dat.L_health == 0 || trial_dat.R_health == 0
                if trial_dat.L_health + trial_dat.R_health > 0
                    trial_dat.TT_Health = 'HealthyNeutral';
                elseif trial_dat.L_health + trial_dat.R_health < 0
                    trial_dat.TT_Health = 'UnhealthyNeutral';
                else
                    trial_dat.TT_Health = 'Neutral';
                end
            end

            if trial_dat.L_taste < 0 && trial_dat.R_taste < 0
                trial_dat.TT_Taste = 'Bad';
            elseif trial_dat.L_taste > 0 && trial_dat.R_taste > 0
                trial_dat.TT_Taste = 'Good';
            elseif trial_dat.L_taste > 0 && trial_dat.R_taste < 0
                trial_dat.TT_Taste = 'Discordant';
            elseif trial_dat.L_taste < 0 && trial_dat.R_taste > 0
                trial_dat.TT_Taste = 'Discordant';
            elseif trial_dat.L_taste == 0 || trial_dat.R_taste == 0
                if trial_dat.L_taste + trial_dat.R_taste > 0
                    trial_dat.TT_Taste = 'GoodNeutral';
                elseif trial_dat.L_taste + trial_dat.R_taste < 0
                    trial_dat.TT_Taste = 'BadNeutral';
                else
                    trial_dat.TT_Taste = 'Neutral';
                end
            end

            %self control trials
            if trial_dat.L_taste > trial_dat.R_taste && trial_dat.L_health < trial_dat.R_health
                trial_dat.SC_Trial = 'Y';
            elseif trial_dat.L_taste < trial_dat.R_taste && trial_dat.L_health > trial_dat.R_health
                trial_dat.SC_Trial = 'Y';
            else
                trial_dat.SC_Trial = 'N';
            end

            %choice
            trial_dat.choice = raw_matfile.data.choice(t);
            trial_dat.RT = raw_matfile.data.RT(t);

            %get ratings for chosen and unchosen 
            if trial_dat.choice == 1 
                trial_dat.chosen_health = trial_dat.L_health;
                trial_dat.unchosen_health = trial_dat.R_health;
                trial_dat.chosen_taste = trial_dat.L_taste;
                trial_dat.unchosen_taste = trial_dat.R_taste;
                trial_dat.chosen_like = trial_dat.L_liking;
                trial_dat.unchosen_like = trial_dat.R_liking;
            else
                trial_dat.chosen_health = trial_dat.R_health;
                trial_dat.unchosen_health = trial_dat.L_health;
                trial_dat.chosen_taste = trial_dat.R_taste;
                trial_dat.unchosen_taste = trial_dat.L_taste;
                trial_dat.chosen_like = trial_dat.R_liking;
                trial_dat.unchosen_like = trial_dat.L_liking;
            end

            %determine Self-control success
            if strcmp(trial_dat.SC_Trial, 'Y') 
                if trial_dat.chosen_health > trial_dat.unchosen_health
                    trial_dat.SC_TrialSuccess = 'Y';
                else
                    trial_dat.SC_TrialSuccess = 'N';
                end
            else
                trial_dat.SC_TrialSuccess = NaN;
            end

            %determine choice type--if both have same sign there is no
            %difference in category, else compare chosen to not
            if sign(trial_dat.chosen_health) == sign(trial_dat.unchosen_health)
                hstr = '';
            elseif trial_dat.chosen_health > trial_dat.unchosen_health
                hstr = 'Healthy';
            else
                hstr = 'LessHealthy';
            end

            if sign(trial_dat.chosen_taste) == sign(trial_dat.unchosen_taste)
                tstr = '';
            elseif trial_dat.chosen_taste > trial_dat.unchosen_taste
                tstr = 'Tasty';
            else
                tstr = 'LessTasty';
            end

            if isempty([hstr, tstr])
                trial_dat.choice_type = 'FullMatch';
            else
                trial_dat.choice_type = [hstr, tstr];
            end

            %mouse position data
            trial_dat.x_pos_pix = NaN;
            trial_dat.y_pos_pix = NaN;
            trial_dat.mpos_timestamp = NaN;
            trial_dat.mappeare_time = NaN;
            trial_dat.tlapse_1move = NaN;
            trial_dat.startbutton_time = raw_matfile.data.start_screen_on(t);
            trial_dat.startbutton_time = raw_matfile.data.start_screen_on(t);

            %update block count
            if (floor(kcount/40) + 1) > bcount
                bcount = bcount + 1;
            end

        end
        trial_dat.TT_Health = cellstr(trial_dat.TT_Health);
        trial_dat.TT_Taste = cellstr(trial_dat.TT_Taste);
        trial_dat.choice_type = cellstr(trial_dat.choice_type);

        proc_dat = [proc_dat; trial_dat];

        if strcmp(ttype, 'mouse')
            proc_LinInt_dat = [proc_LinInt_dat; trial_dat_LinInt];
            proc_angle_LinInt_dat = [proc_angle_LinInt_dat; trial_angle_LinInt_dat];
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%                Person Level Processing              %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    proc_dat.ParID(:) = parID_num;
    proc_dat.Hunger(:) = raw_matfile.data.hungerlevel;
    proc_dat.WebMD_Time(:) = raw_matfile.data.health_screen_seconds_viewed;

    proc_LinInt_dat.ParID(:) = parID_num;
    proc_LinInt_dat.Hunger(:) = raw_matfile.data.hungerlevel;
    proc_LinInt_dat.WebMD_Time(:) = raw_matfile.data.health_screen_seconds_viewed;

    proc_angle_LinInt_dat.ParID(:) = parID_num;
    proc_angle_LinInt_dat.Hunger(:) = raw_matfile.data.hungerlevel;
    proc_angle_LinInt_dat.WebMD_Time(:) = raw_matfile.data.health_screen_seconds_viewed;
  
    %exclude for RTs > 2SD or 5 sc
    proc_dat.Ex_RT(:) = 'N';
    proc_LinInt_dat.Ex_RT(:) = 'N';
    proc_angle_LinInt_dat.Ex_RT(:) = 'N';
    
    ind_rt500 = proc_dat.RT > 5;
    ind_1TP = proc_dat.TimePoint == 1;
    
    ind_LinInt_rt500 = double(proc_LinInt_dat.RT) > 5;
    ind_rt500_angle = double(proc_angle_LinInt_dat.RT) > 5;
    
    proc_dat.Ex_RT(ind_rt500) = 'Y';
    proc_LinInt_dat.Ex_RT(ind_LinInt_rt500) = 'Y';
    proc_angle_LinInt_dat.Ex_RT(ind_rt500_angle) = 'Y';
    
    twostd = 2*nanstd(proc_dat.RT(ind_1TP));
    mean_RT = mean(proc_dat.RT(ind_1TP), 'omitnan');
    twostd_ind = proc_dat.RT > (mean_RT + twostd);
    twostd_LinInt_ind = double(proc_LinInt_dat.RT) > (mean_RT + twostd);
    twostd_angle_ind = double(proc_angle_LinInt_dat.RT) > (mean_RT + twostd);
    
    proc_dat.Ex_RT(twostd_ind) = 'Y';
    proc_LinInt_dat.Ex_RT(twostd_LinInt_ind) = 'Y';
    proc_angle_LinInt_dat.Ex_RT(twostd_angle_ind) = 'Y';    
    
end
