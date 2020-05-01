% This task was provided by Dr. Nikki Sullivan (2015) to assess mouse 
% tracking food choice task in children and is stored on Open Science 
% Framework (https://osf.io/2bctm/). The task was adpated by Dr. Shana
% Adise for the current study.
% 
%     Copyright (C) 2015 Shana Adise
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

function taskone_food_ratings(subject)


%% random seed

try
    RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
catch
    RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
end


%% verify files and params

% if nargin ~= 1
%     subject = input('subject number:\n','s');
% end
% if ~exist('images','dir')%might need to enter file path here
%     disp('WARNING!!!!! no image directory found. exiting.')
%     Screen('CloseAll');
% end
% if ~exist('subject_data','dir')
%     mkdir('subject_data')
% end
% while exist(['subject_data/taskone_s' num2str(subject) 'foods.mat'], 'file') || ...
%         exist(['subject_data/taskone_s' num2str(subject) '_ratings.mat'], 'file')
%     writeover=input('subject number already exists, do you want to overwrite? 1=yes, 0=no ');
%     if ~writeover
%         disp('enter new info:')
%         subject= input('subject number: ', 's');
%     else
%         break
%     end
% end


%% task set up
%data = struct; Mike told me to add this - to start debug mode type in
%dbstop if  incommand window 
% retrieve image names from directory
%all_files = dir('C:\Users\admin_sxa308\Desktop\Visit A SC task\images\');
img_count = 1;
for i = 1:length(all_files)
    if ~all_files(i).isdir
        data.image_names(img_count,1) = {all_files(i).name};
        img_count = img_count+1;
    end
end
% keyboard; < Mike told me to add this to debug to quit debug mode type db
% quit into command window
% scan/experiment parameters, data structure
data.ind = randperm(length(data.image_names))'; % random index list
data.subject = subject;
data.blockname = {'HEALTH' 'TASTE' 'LIKING'};
data.blockdistript = {'HEALTHY each food item is to you' ...
    'TASTY each food item is to you' ...
    'much would you LIKE to eat each food item at the end of the experiment'};
data.nratings = length(data.blockname);
data.ratingsorder = randperm(data.nratings);
data.ntrials = length(data.ind); 


%% display, response key set-up

Screen('Preference', 'VisualDebugLevel', 1);% change psych toolbox screen check to black
[exp_screen, ~] = Screen('OpenWindow', max(Screen('Screens')));
[data.width, data.height] = Screen('WindowSize',exp_screen);

% what do black and white mean on this screen?
bg_color = BlackIndex(exp_screen);
txt_color = WhiteIndex(exp_screen);

Screen('TextFont',exp_screen,'Monaco');
txt_size = 12;
wrapat = 70;
vSpacing = 1.3;
Screen('TextSize', exp_screen, txt_size*2);

% response key set up
KbName('UnifyKeyNames');
data.resp_keys = {'c' 'v' 'b' 'n' 'm'};
data.resp_key_codes = KbName(data.resp_keys);
data.keyguide = 'c             v             b             n             m'; % set key labels
data.guide{1} = {{'very unhealthy'} {'unhealthy'} {'neutral'} {'healthy'} {'very healthy'}};
data.guide{2} = {{'very bad'} {'bad'} {'neutral'} {'good'} {'very good'}};
data.guide{3} = {{'strong dislike'} {'dislike'} {'neutral'} {'like'} {'strong like'}};
data.choicevalence_guide = {{-2 -1 0 1 2} {-2 -1 0 1 2} {-2 -1 0 1 2}};

% randomly set the left-right direction on a participant-by-participant basis
data.scaletype = round(rand(data.nratings,1));


%% instructions

intro{1} = ['Welcome to the study!\n\n\n\n'...
    'First you will rate foods three times. \n\n'...
    'When rating the foods, please do not take too long to choose '...
    'your answer. Go with your "gut" feelings.\n\n'...
    'If you have any questions, at any time throughout the task, '...
    '\n\nplease get my attention.'];
intro{2} = ['You''ll rate foods on how healthy they are, how tasty they are to you, '...
    ' and how much you like them. You will always have the option to rate an'...
    ' item as "neutral", but please avoid doing this whenever possible.'...
    ' Just go with whatever instinct you have about the item.'];
intro{3} = ['First, we will practice using these scales'];
intro{4} = ['Great, now you understand how the scale works. '...
    '\n\nRemember, we will ask you to use this scale to rate different foods '...
    'based on health, taste and liking. You should go with your gut feelings for whatever '...
    'answer you choose. You do not have to think about it too long '...
    'and make your answer choice as quickly as possible.'];

for i = 1:length(intro)
    
    Screen(exp_screen, 'FillRect', bg_color);
    DrawFormattedText(exp_screen,intro{i},'center','center',txt_color,wrapat,...
        [],[],vSpacing);
    Screen(exp_screen, 'Flip');
    WaitSecs(2);%shana changed from .2
    
    DrawFormattedText(exp_screen,intro{i},'center','center',txt_color,wrapat,...
        [],[],vSpacing);
    DrawFormattedText(exp_screen,'Press any key to continue.',...
        'center',data.height*.8,txt_color);
    Screen(exp_screen, 'Flip');
    KbStrokeWait;
    
end



%% collect ratings


blocksum = 1;
for blockcount = data.ratingsorder
    
    % if scale is flipped, flip key:
%     if data.scaletype(blockcount) == 1
%         data.guide{blockcount} = fliplr(data.guide{blockcount});
%         data.choicevalence_guide{blockcount} = fliplr(data.choicevalence_guide{blockcount});
%     end

    % rating instructions & scale
    instr{1} = ['In this part, you will rate foods based on '...
        data.blockname{blockcount} '.\n\nPress any key to continue.'];
    instr{2} = sprintf(['Use the keys below to indicate how %s.\n\n'...
        'Please study the rating scale carefully before continuing.'...
        '\n\n %s\n%s   %s   %s   %s   %s'],...
        cell2mat(data.blockdistript(blockcount)),...
        data.keyguide,cell2mat(data.guide{blockcount}{1}),...
        cell2mat(data.guide{blockcount}{2}),...
        cell2mat(data.guide{blockcount}{3}),...
        cell2mat(data.guide{blockcount}{4}),...
        cell2mat(data.guide{blockcount}{5}));
    instr{3} = ['If you have any questions, please get our '...
        'attention now.'];
    for i = 1:size(instr,2) 
        
        Screen(exp_screen, 'FillRect', bg_color);
        DrawFormattedText(exp_screen,instr{i},...
            'center','center',txt_color,80,[],[],vSpacing);
        Screen(exp_screen, 'Flip');
        WaitSecs(2); % SA changed from .2
        
        DrawFormattedText(exp_screen,instr{i},...
            'center','center',txt_color,80,[],[],vSpacing);
        DrawFormattedText(exp_screen,'Press any key to continue.',...
            'center',data.height*.8,txt_color);
        Screen(exp_screen, 'Flip');
        KbStrokeWait;
        
    end
        
    % run ratings trials
    for trial = 1:data.ntrials
        
        imgfile = imread(['C:\Users\admin_sxa308\Desktop\Visit A SC task\images\' cell2mat(data.image_names(data.ind(trial)))]);%might need to put in full file path here
        img = Screen(exp_screen, 'MakeTexture',imgfile);
        
        Screen('DrawTexture',exp_screen,img);
        Screen('Flip',exp_screen);
        Screen('Close',img);
        data.image_on(trial,blockcount) = GetSecs;
        WaitSecs(.2);
        
        while 1 % listen for response
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown && any(keyCode(data.resp_key_codes)) && length(KbName(keyCode)) == 1
                data.choice(trial,blockcount) = KbName(keyCode);
                data.choicetxt(trial,blockcount) = ...
                    data.guide{blockcount}{data.choice(trial,blockcount)==cell2mat(data.resp_keys)};
                data.choicevalence(trial,blockcount) = ...
                    data.choicevalence_guide{blockcount}(data.choice(trial,blockcount)==cell2mat(data.resp_keys));
                data.RT(trial,blockcount) = GetSecs - data.image_on(trial,blockcount);
                break
            end
        end
        
        % show their response
        DrawFormattedText(exp_screen, ...
            cell2mat(data.choicetxt(trial,blockcount)),...
            'center','center',[75 75 255],txt_size*5);
        Screen(exp_screen, 'Flip');
        WaitSecs(.4);
        
        % fixation
        Screen(exp_screen, 'FillRect', bg_color);
        DrawFormattedText(exp_screen,'+','center','center',txt_color,txt_size*5);
        Screen(exp_screen,'Flip');
        WaitSecs(.3);
        
    end
    save(['subject_data/taskone_s' num2str(subject) '_ratings.mat'],'data'); % save answer
    
    % end-of-block screen
    if blocksum < length(data.ratingsorder)
        DrawFormattedText(exp_screen,['End of this group of ratings!\n\nTo'...
            ' continue on, press any key.'],'center','center', txt_color,...
            wrapat,[],[],vSpacing);
    elseif blocksum == length(data.ratingsorder)
        DrawFormattedText(exp_screen,['You finished the ratings!\n\nPlease'...
            ' press any key for the next part of the experiment (food choices).'],...
            'center','center', txt_color,wrapat,[],[],vSpacing);
    end
    Screen(exp_screen,'Flip');
    KbStrokeWait
    blocksum = blocksum + 1;

end

Screen('CloseAll');



%% create image indices for food choice task based on ratings

% settings: how many of each trial type?
%[files path] = uigetfile; %this gets the file
mousetrials = 240;
keytrials = 40;

% gather foods of each category, exclude neutral foods:
healthy_tasty_ind = (cell2mat(data.choicevalence(:,1)) > 0) + (cell2mat(data.choicevalence(:,2)) > 0);
healthy_untasty_ind = (cell2mat(data.choicevalence(:,1)) > 0) + (cell2mat(data.choicevalence(:,2)) < 0);
unhealthy_tasty_ind = (cell2mat(data.choicevalence(:,1)) < 0) + (cell2mat(data.choicevalence(:,2)) > 0);
unhealthy_untasty_ind = (cell2mat(data.choicevalence(:,1)) < 0) + (cell2mat(data.choicevalence(:,2)) < 0);
for food = 1:length(data.ind)
    images{1} = data.ind(healthy_tasty_ind==2);
    images{2} = data.ind(healthy_untasty_ind==2);
    images{3} = data.ind(unhealthy_tasty_ind==2);
    images{4} = data.ind(unhealthy_untasty_ind==2);
end

% how many combinations are there:
pairings = [nchoosek(1:4,2); [1 1]; [2 2]; [3 3]; [4 4]];
pairings = sortrows(pairings); % b/c i'm OCD

% add an equal number of each pairing type to the indices, randomly.
session_ind_mouse = []; session_ind_key = [];
for p = 1:length(pairings)
    if isempty(images{pairings(p,1)})
        images{pairings(p,1)} = data.ind;
    elseif isempty(images{pairings(p,2)})
        images{pairings(p,2)} = data.ind;
    end
    mouse_index = [randsample(images{pairings(p,1)},mousetrials/length(pairings),'true') randsample(images{pairings(p,2)},mousetrials/length(pairings),'true')];
    key_index = [randsample(images{pairings(p,1)},keytrials/length(pairings),'true') randsample(images{pairings(p,2)},keytrials/length(pairings),'true')];
    
    % make sure both foods aren't the same on any pairing:
    for ind = 1:length(mouse_index)
        while mouse_index(ind,1) == mouse_index(ind,2)
            mouse_index(ind,:) = [randsample(images{pairings(p,1)},1,'true') randsample(images{pairings(p,2)},1,'true')];
        end
    end
    for ind = 1:length(key_index)
        while key_index(ind,1) == key_index(ind,2)
            key_index(ind,:) = [randsample(images{pairings(p,1)},1,'true') randsample(images{pairings(p,2)},1,'true')];
        end
    end
    session_ind_mouse = [session_ind_mouse; mouse_index];
    session_ind_key = [session_ind_key; key_index];
end

% randomize what's on left and right
for trial = 1:mousetrials
    if randi(2) == 1
        session_ind_mouse(trial,:) = session_ind_mouse(trial,:);
    else
        session_ind_mouse(trial,:) = fliplr(session_ind_mouse(trial,:));
    end
end
for trial = 1:keytrials
    if randi(2) == 1
        session_ind_key(trial,:) = session_ind_key(trial,:);
    else
        session_ind_key(trial,:) = fliplr(session_ind_key(trial,:));
    end
end

% randomize order of trials
session_ind_mouse = sortrows([rand(length(session_ind_mouse),1), session_ind_mouse],1);
session_ind_mouse = session_ind_mouse(:,2:3);
session_ind_key = sortrows([rand(length(session_ind_key),1), session_ind_key],1);
session_ind_key = session_ind_key(:,2:3);

% save. food choice task loads this file.
save(['subject_data/taskone_s' num2str(subject) 'foods.mat'], ...
    'session_ind_mouse', 'session_ind_key', 'images')


end % function