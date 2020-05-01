%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%   Mouse Traking SC Task data trajectories script      %%%%
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

function SC_MouseTracking_RawTrajectories(base_wd, parID_num, slash)
    %make directory
    if ~exist([base_wd slash 'ProcessedData' slash 'IndTrajectory_Plots' slash char(string(parID_num))], 'dir')
        mkdir([base_wd slash 'ProcessedData' slash 'IndTrajectory_Plots' slash char(string(parID_num))]);
    end
    
    if ~exist([base_wd slash 'ProcessedData' slash 'IndTrajectory_remapped_Plots' slash char(string(parID_num))], 'dir')
        mkdir([base_wd slash 'ProcessedData' slash 'IndTrajectory_remapped_Plots' slash char(string(parID_num))]);
    end

    %go to processed data directory 
    cd([base_wd slash 'ProcessedData']);
    
    %load processed data file
    proc_data_str = struct2table(dir(char(['*Processed_' num2str(parID_num) '*.csv'])));
    proc_dat = readtable(char(proc_data_str.name), 'ReadVariableNames', true);
    
    %subset to mouse only trials
    mouse_ind = strcmp(proc_dat.BlockType, "mouse");
    proc_dat_mouse = proc_dat(mouse_ind, :);
    
    %remove exclusion trials
    trial_exclude_ind = strcmp(proc_dat_mouse.Ex_outbounds, "Y") | strcmp(proc_dat_mouse.Ex_RT, "Y") | strcmp(proc_dat_mouse.Ex_Ycross, "Y");
    proc_dat_mouse = proc_dat_mouse(~trial_exclude_ind, :);
    
    %number of trials
    ntrials = unique(proc_dat_mouse.Trial);

    clf;
    for t = 1:length(ntrials)
        %get trial data
        trial = ntrials(t);
        trial_ind = proc_dat_mouse.Trial == trial;
        proc_dat_trial = proc_dat_mouse(trial_ind, :);
        
        %Raw trajectories
        TrialTrajectory = figure('visible','off');
            %% From Sullivan Code: start here
            fontsize=14;
            hold on; 
            
            % stimuli
            %Below from taskone.m script
            screenDims = [1280 1040];
            box_height = [131 131]; %img_height*.35;
            box_width = [174 174];%img_width*.35;
            
            left_box = [screenDims(1)*.2-box_width(1) screenDims(2)*.25-box_height(1) ...
                screenDims(1)*.2+box_width(1) screenDims(2)*.25+box_height(1)];
            right_box = [screenDims(1)*.8-box_width(2) screenDims(2)*.25-box_height(2) ...
                   screenDims(1)*.8+box_width(2) screenDims(2)*.25+box_height(2)];
               
            start_box_height = 65;
            start_box_width = 95;
            start_box = [screenDims(1)*.5-start_box_width screenDims(2)*.8-start_box_height ...
                screenDims(1)*.5+start_box_width screenDims(2)*.8+start_box_height];
          

            % mouse trajectory - Pearce edits from Sullivan code
            plot([left_box(1) left_box(3)],[left_box(4) left_box(4)],'k')
            plot([left_box(1) left_box(3)],[left_box(2) left_box(2)],'k')
            plot([left_box(1) left_box(1)],[left_box(2) left_box(4)],'k')
            plot([left_box(3) left_box(3)],[left_box(2) left_box(4)],'k')
            plot([right_box(1) right_box(3)],[right_box(4) right_box(4)],'k')
            plot([right_box(1) right_box(3)],[right_box(2) right_box(2)],'k')
            plot([right_box(1) right_box(1)],[right_box(2) right_box(4)],'k')
            plot([right_box(3) right_box(3)],[right_box(2) right_box(4)],'k')

            plot([start_box(1) start_box(3)],[start_box(4) start_box(4)],'k')
            plot([start_box(1) start_box(3)],[start_box(2) start_box(2)],'k')
            plot([start_box(1) start_box(1)],[start_box(2) start_box(4)],'k')
            plot([start_box(3) start_box(3)],[start_box(2) start_box(4)],'k')

            plot(proc_dat_trial.x_pos_pix, proc_dat_trial.y_pos_pix,'color','k','linewidth',2);
            xlim([0 screenDims(1)])
            ylim([0 screenDims(2)])
            xlabel('X Coord. (Pixels)','fontsize',fontsize)
            ylabel('Y Coord. (Pixels)','fontsize',fontsize)
            box on
            set(gca,'ydir','reverse')
            
            title(['Trial ' num2str(trial) ' Mouse Trajectory - Participant ' char(string(parID_num))])     
        saveas(TrialTrajectory, [base_wd slash 'ProcessedData' slash 'IndTrajectory_Plots' slash char(string(parID_num)) slash 'Trial' char(string(trial)) '.pdf'])
    
    %spatially remapped
    TrialTrajectory_spRemap = figure('visible','off');
            fontsize=14;
            hold on; 

            % stimuli    
            left_box = [-1-.35 1+.25 ...
                -1+.35 1-.25];
            right_box = [1-.35 1+.25 ...
                1+.35 1-.25];
   
            start_box = [0-.25 0+.2 ...
                0+.25 0-.2];
            
            % mouse trajectory - Pearce edits from Sullivan code
            plot([left_box(1) left_box(3)],[left_box(4) left_box(4)],'k')
            plot([left_box(1) left_box(3)],[left_box(2) left_box(2)],'k')
            plot([left_box(1) left_box(1)],[left_box(2) left_box(4)],'k')
            plot([left_box(3) left_box(3)],[left_box(2) left_box(4)],'k')
            plot([right_box(1) right_box(3)],[right_box(4) right_box(4)],'k')
            plot([right_box(1) right_box(3)],[right_box(2) right_box(2)],'k')
            plot([right_box(1) right_box(1)],[right_box(2) right_box(4)],'k')
            plot([right_box(3) right_box(3)],[right_box(2) right_box(4)],'k')

            plot([start_box(1) start_box(3)],[start_box(4) start_box(4)],'k')
            plot([start_box(1) start_box(3)],[start_box(2) start_box(2)],'k')
            plot([start_box(1) start_box(1)],[start_box(2) start_box(4)],'k')
            plot([start_box(3) start_box(3)],[start_box(2) start_box(4)],'k')

            plot(proc_dat_trial.x_spRemap_choiceD, proc_dat_trial.y_spRemap_choiceD,'color','k','linewidth',2);
            xlim([-2.5 2.5])
            ylim([-1 2.5])
            xlabel('X Coord. (re-map)','fontsize',fontsize)
            ylabel('Y Coord. (re-map)','fontsize',fontsize)
            box on
            
            title(['Trial ' num2str(trial) ' Re-Mapped Mouse Trajectory - Participant ' char(string(parID_num))])     
        saveas(TrialTrajectory_spRemap, [base_wd slash 'ProcessedData' slash 'IndTrajectory_remapped_Plots' slash char(string(parID_num)) slash 'spRemap_Trial' char(string(t)) '.pdf'])  
    end
end
