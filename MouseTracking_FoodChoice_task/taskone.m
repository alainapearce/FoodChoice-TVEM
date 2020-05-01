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



function taskone(subject,update)


%% random seed depending on matlab version
subject = 101;
try
    RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
catch
    RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));%SA changed from default to global
end


%% verify files and params

if ~exist('subject','var')
    subject = input('\nsubject number: ','s');
end
if ~exist('update','var')
    update = input('\nupdate food stock catalog? ');
end
if ~exist(['subject_data/taskone_s' num2str(subject) 'foods.mat'],'file');
    disp('WARNING!!!!! no food ratings found. exiting.')
    Screen('CloseAll');
end
if ~exist('images','dir')
    disp('WARNING!!!!! no image directory found. exiting.')
    Screen('CloseAll');
end
if ~exist('subject_data','dir')
    mkdir('subject_data')
end
while exist(['subject_data/taskone_results_subj' num2str(subject) '.mat'], 'file') 
    writeover=input('subject number already exists. overwrite? 1=yes, 0=no ');
    if ~writeover
        data.subject= input('enter new subject number: ', 's');
    else
        break
    end
end

%% task set up

results_file = ['subject_data/taskone_results_subj' num2str(subject) '.mat'];
imagelist_file = ['subject_data/taskone_s' num2str(subject) 'foods'];

% retrieve image names from directory
all_files = dir('C:\Users\admin_sxa308\Desktop\Visit A SC task\images\');
img_count = 1;
for i = 1:length(all_files)
    if ~all_files(i).isdir
        image_names(img_count,1) = {all_files(i).name};
        img_count = img_count+1;
    end
end

% scan/experiment parameters, data structure
data.subject = subject;
data.date = fix(clock);
data.total_mousetrials = 240;
data.total_keytrials = 40;% SA changed below 3 to 4
temp = [{repmat({'mouse'},1,(data.total_mousetrials/3))} {repmat({'mouse'},1,(data.total_mousetrials/3));}...
   {repmat({'mouse'},1,(data.total_mousetrials/3))} {repmat({'keyboard'},1,(data.total_keytrials));}];
data.block_order = randperm(4);
data.blocktype = [temp{data.block_order(1)} ...
    temp{data.block_order(2)} temp{data.block_order(3)}...
    temp{data.block_order(4)}];
data.total_trials = data.total_mousetrials + data.total_keytrials;
data.choice_text = cell(1,data.total_trials);
data.RT(1:data.total_trials) = NaN;

% retrieve image names from directory
load(imagelist_file);
indices = linspace(80,240,3);%SA changing 80,240, 3 to 10,30,3 
temp = [{session_ind_mouse(1:indices(1),:)}; % mouse block one
    {session_ind_mouse(indices(1)+1:indices(2),:)}; % mouse block two
    {session_ind_mouse(indices(2)+1:indices(3),:)}; % mouse block three
    {session_ind_key}]; % key block
data.image_index = [[temp{data.block_order(1),:}];
    [temp{data.block_order(2),:}];
    [temp{data.block_order(3),:}]];
    [temp{data.block_order(4),:}];
data.rest_interval = 40; % rest every X trials
data.rest = (mod(1:data.total_trials,data.rest_interval)==0); % 1 == take a rest

% ITIs for all runs
data.afterstart_interval = sortrows([rand(data.total_trials,1),...
    repmat([.2 .3 .4 .5], 1, ceil(data.total_trials/4))']);
data.afterstart_interval = data.afterstart_interval(:,2);
data.reset_screen = sortrows([rand(data.total_trials,1),...
    repmat([.4 .5 .6 .7], 1, ceil(data.total_trials/4))']);
data.reset_screen = data.reset_screen(:,2);


%% display, response key set-up

Screen('Preference', 'VisualDebugLevel', 1);% change psych toolbox screen check to black
[exp_screen, ~] = Screen('OpenWindow', max(Screen('Screens')));
[data.width, data.height] = Screen('WindowSize',exp_screen);

% what do black and white mean on this screen?
bg_color = BlackIndex(exp_screen);
txt_color = WhiteIndex(exp_screen);

Screen('TextFont',exp_screen,'Monaco');
HideCursor;
wrapat = 45;
vSpacing = 1.3;
start_box_height = 65;
start_box_width = 95;
start_box = [data.width*.5-start_box_width data.height*.8-start_box_height data.width*.5+start_box_width data.height*.8+start_box_height];

% image boxes
box_height = [131 131]; %img_height*.35;
box_width = [174 174];%img_width*.35;
left_box = [data.width*.2-box_width(1) data.height*.25-box_height(1) ...
    data.width*.2+box_width(1) data.height*.25+box_height(1)];
right_box = [data.width*.8-box_width(2) data.height*.25-box_height(2) ...
    data.width*.8+box_width(2) data.height*.25+box_height(2)];


% --- response key set up
KbName('UnifyKeyNames');
resp_keys = {'1!' '0)'};
resp_key_codes = KbName(resp_keys);
hunger_keys = [{'Not at all'} {'A little'} {'Moderately'} {'Extremely'}];
hunger_key_codes = KbName({'1!' '2@' '3#' '4$'});

% mouse tracking setup
data.starting_x = round(data.width*.5); % cursor start position each trial
data.starting_y = round(data.height*.8);

% get screen refresh rate and calculate how often to get mouse samples:
data.screenHz = Screen('NominalFrameRate',exp_screen);
data.sample_rate = 1/data.screenHz % sample every x seconds (will be approx. 0.01) 


%% display healthy eating info

Screen('TextSize', exp_screen, 22);
Screen(exp_screen, 'FillRect', bg_color);
DrawFormattedText(exp_screen, ['Please read the following'...
    ' from an article on WebMD.com entitled "Healthy Eating":'], ...
    'center', data.height*.1, txt_color,wrapat,[],[],vSpacing);
webmd = Screen(exp_screen, 'MakeTexture',imread('webMD.jpg'));
webmd_height = size(imread('webMD.jpg'),1);
webmd_width = size(imread('webMD.jpg'),2);
Screen('DrawTexture',exp_screen,webmd,[],...
    [data.width*.5-webmd_width*.9 data.height*.5-webmd_height*.9 ...
    data.width*.5+webmd_width*.9 data.height*.5+webmd_height*.9]);
Screen(exp_screen, 'Flip');

tic; % start timer
WaitSecs(.5);% set this to 2 
DrawFormattedText(exp_screen, ['Please read the following'...
    ' from an article on WebMD.com entitled "Healthy Eating":'], ...
    'center', data.height*.1, txt_color,wrapat,[],[],vSpacing);
Screen('DrawTexture',exp_screen,webmd,[],...
    [data.width*.5-webmd_width*.9 data.height*.5-webmd_height*.9 ...
    data.width*.5+webmd_width*.9 data.height*.5+webmd_height*.9]);
DrawFormattedText(exp_screen, 'Press any key to continue', ...
    'center', data.height*.8, txt_color);
Screen(exp_screen, 'Flip');
KbStrokeWait;
data.health_screen_seconds_viewed = toc; % end timer

% health factor reminder
Screen(exp_screen, 'FillRect', bg_color);
DrawFormattedText(exp_screen, ['During this task, please try to factor the'...
    ' health of each food into your decision.\n\n\n\nPress any key to continue'], ...
    'center','center', txt_color,wrapat,[],[],vSpacing);
Screen(exp_screen, 'Flip');
KbStrokeWait;


%% instructions

instruct{1} = ['In this task you will see a bunch of foods.\n\n\n\n'...
    'I am going to ask you to choose the food you would like to eat right now.' ...
    '\n\nAt the end, we will choose one of these foods, and you will be required to eat it.' ...
    ' So make sure you really choose the foods that you would like to eat.'];
instruct{2} = ['In each trial, you will first see a start button. '...
    'Before making your choice, you will have to click the start button.'...
    '\n\nNext, you will see two foods. After you select one, '...
    'we''ll ask you about another pair of foods, and you''ll see a fixation '...
    'cross displayed on the screen.\n\nNext we''ll tell you how to '...
    'enter your response.'];
instruct{3} = ['In some trials, you will use your mouse to respond. To begin '...
    'each trial, click on the screen''s start button. Enter your response by '...
    'moving your mouse into the white box around the food you want to eat '...
    'more.\n\n'...
    'You''ll be able to see the foods as soon as you start moving '...
    'the cursor.'];
instruct{4} = ['In other trials, you will use the keyboard. To begin '...
    'each trial, press the spacebar. Enter your response by '...
    'using the one (1) and zero (0) keys.\n\n'...
    'The 1 key will always represent the left-hand option, and 0 will '...
    'always represent the right-hand option.'];
instruct{5} = ['In this experiment, it''s crucial that you respond '...
    'quickly and truthfully.\n\n'...
    'It''s important you move the mouse without stopping '... 
    'towards the food you like better. '...
    '\n\nPlease do not "play" with the mouse by moving it in spirals, etc.'];

instruct{6} = ['We will try a practice trial'];

instruct{7} = ['Remember to factor a food''s healthiness into your '...
    'decision.\n\n'...
    'Please tell me now if you have any questions, and '...
    'we can go over the directions again.'];

Screen('TextSize', exp_screen, 26)
tic; % start timer
for i=1:length(instruct)
    
    Screen(exp_screen, 'FillRect', bg_color);
    DrawFormattedText(exp_screen, instruct{i}, ...
        'center', 'center', txt_color,wrapat,[],[],vSpacing);
    Screen(exp_screen, 'Flip');
    WaitSecs(.5);% set this to 2.25
    
    DrawFormattedText(exp_screen, instruct{i}, ...
        'center', 'center', txt_color,wrapat,[],[],vSpacing);
    DrawFormattedText(exp_screen,'Press any key to continue.',...
        'center',data.height*.8,txt_color);
    Screen(exp_screen,'Flip');
    KbStrokeWait;
    
end
data.instruct_seconds_viewed = toc; % end timer

%% ask about hunger

Screen(exp_screen, 'FillRect', bg_color);
DrawFormattedText(exp_screen,['First:\n'...
    'How hungry are you right now? (Use the keyboard to respond)\n\n\n\n'...
    '1            2           3           4    \n\n'...
    'Not at all     A little    Moderately  Extremely'],...
    'center','center',txt_color);
Screen(exp_screen,'Flip');
while 1
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown && any(keyCode(hunger_key_codes))
        data.hungerlevel = KbName(keyCode);
        data.hungerlevel = str2double(data.hungerlevel(1));
        data.hunger_text = hunger_keys(data.hungerlevel);
        break
    end
end


%% food choices

% preallocate variables for speed
data.start_screen_on = NaN(data.total_trials,1);
data.trial_start = NaN(data.total_trials,1);
data.choicescreen_on = NaN(data.total_trials,1);
data.RT = NaN(data.total_trials,1);
data.choice = NaN(data.total_trials,1);
data.choice_text = cell(1,data.total_trials);
data.position = cell(1,data.total_trials);
data.position_time = cell(1,data.total_trials);
data.mousestart = NaN(data.total_trials,1);
data.time_to_move = NaN(data.total_trials,1);

for trial = 1:data.total_trials 
    
    Screen('TextSize', exp_screen, 26);
    if trial == 1 
        
        % block type notification screen for first trial
        Screen(exp_screen, 'FillRect', bg_color);
        DrawFormattedText(exp_screen,['You will answer this set of questions using'...
            ' the ' data.blocktype{trial} '.\n\nPress any key to begin!'],...
            'center','center',txt_color,45);
        Screen(exp_screen,'Flip');
        KbStrokeWait;

    elseif trial > 1 && (~strcmp(data.blocktype{trial},data.blocktype{trial-1}) ...
            || data.rest(trial-1)) % block type notification screen if type is changing, or if have just "rested"
        
        Screen('TextSize', exp_screen, 26);
        Screen(exp_screen, 'FillRect', bg_color);
        DrawFormattedText(exp_screen,['You will answer this set of questions using'...
            ' the ' data.blocktype{trial} '.\n\nPress any key to begin!'],...
            'center','center',txt_color,45);
        Screen(exp_screen,'Flip');
        KbStrokeWait;
        
    end
    
    % start button screen
    Screen('TextSize', exp_screen, 38);
    Screen(exp_screen, 'FillRect', bg_color);
    Screen('FrameRect',exp_screen,txt_color,start_box,2);
    DrawFormattedText(exp_screen,'START',...
        data.width*.44,data.height*.75,txt_color);
    Screen(exp_screen,'Flip');
    data.start_screen_on(trial) = GetSecs;
    
    % wait for start trigger
    if strcmp(data.blocktype{trial},'keyboard')
        while 1
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown && any(keyCode(32)) % if spacebar is down
                Screen(exp_screen, 'FillRect', bg_color);
                Screen(exp_screen,'Flip');
                break
            end
        end
    elseif strcmp(data.blocktype{trial},'mouse')
        ShowCursor('Arrow');
        SetMouse(data.starting_x,data.starting_y); %WaitTicks(1); %set mouse to middle of screen. 
        while 1
            [x,y,buttons] = GetMouse(exp_screen);
            if buttons(1) ...
                && x > start_box(1) && x < start_box(3) ...
                && y > start_box(2) && y < start_box(4)
            
                Screen(exp_screen, 'FillRect', bg_color);
                Screen(exp_screen,'Flip');
                HideCursor;
                break
                
            end
        end
    end
    WaitSecs(data.afterstart_interval(trial));

    % load images (but don't display them yet)
    data.trial_start(trial) = GetSecs;
    data.imageID(trial,:) = image_names(data.image_index(trial,:));
    imgfile{1} = imread(['C:\Users\admin_sxa308\Desktop\Visit A SC task\images\' cell2mat(data.imageID(trial,1))]);
    imgfile{2} = imread(['C:\Users\admin_sxa308\Desktop\Visit A SC task\images\' cell2mat(data.imageID(trial,2))]);
    img_left = Screen(exp_screen, 'MakeTexture',imgfile{1});
    img_right = Screen(exp_screen, 'MakeTexture',imgfile{2});
    img_height = [size(imgfile{1},1), size(imgfile{2},1)];
    img_width = [size(imgfile{1},2), size(imgfile{2},2)];
    
    if strcmp(data.blocktype{trial},'keyboard')
        
        % display stimuli
        Screen('TextSize', exp_screen, 48);
        Screen(exp_screen, 'FillRect', bg_color);
        Screen('DrawTexture',exp_screen,img_left,[],...
            [data.width*.2-173 data.height*.25-130 ...
            data.width*.2+173 data.height*.25+130]);
        Screen('DrawTexture',exp_screen,img_right,[],...
            [data.width*.8-173 data.height*.25-130 ...
            data.width*.8+173 data.height*.25+130]);
        Screen('FrameRect',exp_screen,txt_color,right_box,2);
        Screen('FrameRect',exp_screen,txt_color,left_box,2);
        Screen(exp_screen,'Flip');
        data.choicescreen_on(trial) = GetSecs;
        while 1 % listen for response
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown && any(keyCode(resp_key_codes))
                data.RT(trial) = GetSecs - data.choicescreen_on(trial);
                resp = KbName(keyCode);
                data.choice(trial) = abs(str2double(resp(1))-2); % convert to 1(left) and 2(right)
                data.choice_text(trial) = data.imageID(trial,data.choice(trial));
                break
            end
        end
        
    elseif strcmp(data.blocktype{trial},'mouse')
        
        % wait for mouse to move, then display images
        SetMouse(data.starting_x,data.starting_y); %WaitTicks(2);
        ShowCursor('Arrow');
        [x,y] = GetMouse(exp_screen); % record position
        data.position{trial} = [x y];
        data.position_time{trial} = GetSecs;
        data.mousestart(trial) = GetSecs;
        next_time = data.mousestart(trial) + data.sample_rate;
        while 1
            [x,y,buttons] = GetMouse(exp_screen);
            % if mouse has started moving, display stimuli:
            if sum([x y] == [data.starting_x data.starting_y]) ~= 2
                
                data.time_to_move(trial) = GetSecs - (data.afterstart_interval(trial) + ...
                    data.start_screen_on(trial));
                Screen('TextSize', exp_screen, 48);
                Screen(exp_screen, 'FillRect', bg_color);
                Screen('DrawTexture',exp_screen,img_left,[],...
                    [data.width*.2-173 data.height*.25-130 ...
                    data.width*.2+173 data.height*.25+130]);
                Screen('DrawTexture',exp_screen,img_right,[],...
                    [data.width*.8-173 data.height*.25-130 ...
                    data.width*.8+173 data.height*.25+130]);
                Screen('FrameRect',exp_screen,txt_color,right_box,2);
                Screen('FrameRect',exp_screen,txt_color,left_box,2);
                Screen(exp_screen,'Flip');
                data.choicescreen_on(trial) = GetSecs;
                break
                
            end            
        end
        
        % record mouse position until click in one food box
        while 1
            [x,y,buttons] = GetMouse(exp_screen);
            % check for response
            if buttons(1) ...
                    && ((x > left_box(1) && x < left_box(3) ...
                    && y > left_box(2) && y < left_box(4)) ...
                    || (x > right_box(1) && x < right_box(3) ...
                    && y > right_box(2) && y < right_box(4)))
                data.RT(trial) = GetSecs - data.choicescreen_on(trial);
                % record response
                if (x > left_box(1) && x < left_box(3) && y > left_box(2) && y < left_box(4))
                    data.choice_text(trial) = data.imageID(trial,1);
                    data.choice(trial) = 1;
                elseif (x > right_box(1) && x < right_box(3) && y > right_box(2) && y < right_box(4))
                    data.choice_text(trial) = data.imageID(trial,2);
                    data.choice(trial) = 2;
                end
                HideCursor;
                break;
            end
            if GetSecs > next_time  % record position & timestamp
                data.position{trial} = [data.position{trial}; x y];
                data.position_time{trial} = [data.position_time{trial}; GetSecs];
                next_time = next_time + data.sample_rate;
            end
        end
        
        % remind to respond quickly, if haven't answered in 2.5s
        if data.RT(trial) > 2.5
            Screen('TextSize', exp_screen, 26);
            Screen(exp_screen, 'FillRect', bg_color);
            DrawFormattedText(exp_screen,['Please move the mouse to '...
                'your choice faster.'], 'center', 'center', txt_color, wrapat);
            Screen(exp_screen,'Flip');
            WaitSecs(1.5);
            Screen('TextSize', exp_screen, 48); % reset text size
        end
        
    end
    save(results_file, 'data');
            
    % fixation
    Screen(exp_screen, 'FillRect', bg_color);
    DrawFormattedText(exp_screen,'+','center','center',txt_color);
    Screen(exp_screen,'Flip');
    WaitSecs(data.reset_screen(trial));
    
    % end-of-block display
    Screen('TextSize', exp_screen, 26);
    Screen(exp_screen, 'FillRect', bg_color);
    if trial == data.total_trials
        
        DrawFormattedText(exp_screen,['You finished the task!\n\n\n'...
            'Now we will randomly select one food choice. Please wait.'], ...
            'center','center', txt_color);
        Screen(exp_screen,'Flip');
        WaitSecs(3);
        
    elseif (trial > 1 && ~strcmp(data.blocktype{trial},data.blocktype{trial+1})) ...
            || data.rest(trial) % if we're resting, or if next trial is a different type
        
        DrawFormattedText(exp_screen,['Break time! Take a rest if you''d like,'...
            ' and then press any key to continue.'],'center','center', txt_color);
        Screen(exp_screen,'Flip');
        KbStrokeWait;
        
    end
    
end



%% select a food to count from what's in stock, update stock

% Screen('TextSize', exp_screen, 26);
% load('stockfoods_batch')
% match_found = 0;iteration = 1;data.nofoodfound=[];data.chosen_food=[];
% while ~match_found
%     chosen_index = randi(length(data.choice_text)); % pick a random choice
%     stock_index = find(strcmp(data.choice_text(chosen_index),stock(cell2mat(stock(:,2)) > 0))); % where's that food - is it in stock?
%     if ~isempty(stock_index)
%         data.chosen_food = data.choice_text(chosen_index);
%         match_found = 1;
%         if update % then update stock foods
%             stock(stock_index,2) = {cell2mat(stock(stock_index,2)) - 1};
%             save('stockfoods_batch','stock')
%         end
%         break
%     else
%         iteration = iteration + 1;
%     end
%     if iteration >= 1000
%         data.nofoodfound = 1;
%         break
%     end    
% end

% runs the script foodslist.m which contains the list of foods which are
% available
foodslist

% make a random vector of indicies the same length as the vector of choices

rand_ind = randperm(length(data.choice_text));
found = 0;
for i = 1:length(data.choice_text)
    % check to see if its in stock
    for j = 1:length(foods)
        if strcmp(data.choice_text(rand_ind(i)), foods{j})
            found = 1;
            break
        end
    end
    if found == 1
        data.chosen_food = data.choice_text(rand_ind(i));
        break
    end
end

% add a dummy string if you didn't find anything
if found == 0
    data.chosen_food = 'not found';
end

% if ~isempty(data.nofoodfound)
if found
    imgfile = imread(cell2mat(['images/' data.chosen_food]));
    img = Screen(exp_screen,'MakeTexture',imgfile);
    Screen(exp_screen, 'FillRect', bg_color);
    DrawFormattedText(exp_screen,'The randomly selected food item is','center',data.height*.1,txt_color);
    Screen('DrawTexture',exp_screen,img);
    DrawFormattedText(exp_screen,['Please raise your hand so the experimenter'...
        ' can see what food was selected.'],...
        'center',data.height*.8,txt_color,45);
else % oh god, what if it failed?!
    Screen(exp_screen, 'FillRect', bg_color);
    DrawFormattedText(exp_screen,['It''s  your lucky day! Please raise your hand'...
        ' to get the experimeter''s attention. You get to pick any food you''d'...
        ' like from the food stock.'],...
        'center','center',txt_color);
end
Screen(exp_screen,'Flip');
WaitSecs(15)

Screen('CloseAll');clc;
save(results_file, 'data');
disp([' ']);disp('Chosen food:');disp(data.chosen_food) % print food to screen



end % whole function