function CL_fMRI_T1(subjID, basedir)
%% SETUP : Basic parameter
global theWindow lb1 rb1 lb2 rb2 H W scale_W anchor_lms anchor_middle korean alpnum space special bgcolor white orange red;

test_mode = false;

if test_mode
    show_cursor = true;
    screen_mode = 'small';
    disp('***** TEST mode *****');
elseif ~test_mode
    show_cursor = false;
    screen_mode = 'middle';
    disp('***** EXPERIMENT mode *****');
end

% ismacbook = false;
% [~, hostname] = system('hostname');
% switch strtrim(hostname)
%     case 'jungin-macbookpro.local'
%         basedir = '/Users/jungin/Dropbox/codes/CL_7T';
%         ismacbook = true;
%     case 'SALeeui-MacBook-Pro-2.local'
%         basedir = '/Users/salee/Dropbox/claustrum_7T/codes/CL_7T';
%         ismacbook = true;
%     case '7T-MRIui-Mac-Pro.local' % 7T MAC
%         basedir = '/Users/7t_mri/Documents/7TCL/7TCL_codes';
% end
%
% cd(basedir);
% addpath(genpath(basedir));

Screen('CloseAll');


%% SETUP : Save data according to subject information

savedir = fullfile(basedir, 'Data');

nowtime = clock;
subjtime = sprintf('%.2d%.2d%.2d', nowtime(1), nowtime(2), nowtime(3));

exp = 'CL7T';
data.type = 'T1';
data.subject = subjID;
data.datafile = fullfile(savedir, sprintf('%s_%s_T1.mat', subjID, subjtime));
data.version = 'CL_cocoanlab_20240525';
data.starttime = datestr(clock, 0);
data.starttime_getsecs = GetSecs;

% if the same file exists, break and retype subject info
if exist(data.datafile, 'file')
    fprintf('\n ** EXSITING FILE: %s %s **', data.subject, subjtime);
    cont_or_not = input(['\nYou already have T1 data previously saved.', ...
        '\nWill you rerun the T1 scan?', ...
        '\n1: Yes.  ,   2: No. I`ll break.\n:  ']);
    if cont_or_not == 2
        error('Breaked.')
    elseif cont_or_not == 1
        save(data.datafile, 'data');
    end
else
    save(data.datafile, 'data');
end


%% Screen settings

% PsychJavaTrouble;
window_num = max(Screen('Screens'));
Screen('Preference','SkipSyncTests',1);

% color
bgcolor = 50;
white = 255;
red = [158 1 66]; 

% Window Setting
[theWindow, window_rect] = Screen('OpenWindow', window_num, bgcolor);

% size
W = window_rect(3); % width
H = window_rect(4); % height

Screen('Preference', 'SkipSyncTests', 1);
% switch screen_mode
%     case 'full'
%         window_rect = [0 0 W H]; % full screen
%     case 'semifull'
%         window_rect = [0 0 W-100 H-100]; % a little bit distance
%     case 'middle'
%         window_rect = [0 0 W/2 H/2];
%     case 'small'
%         window_rect = [0 0 400 300]; % in the test mode, use a little smaller screen
% end

lb1 = W/4; % rating scale left bounds 1/4
rb1 = (3*W)/4; % rating scale right bounds 3/4

lb2 = W/3; % new bound for or not
rb2 = (W*2)/3;

scale_W = (rb1-lb1).*0.1; % Height of the scale (10% of the width)

anchor_lms = [0.014 0.061 0.172 0.354 0.533].*(rb1-lb1)+lb1;
anchor_middle = [0.2 0.5].*(rb1-lb1)+lb1;

% font
fontsize = 40;
Screen('Preference', 'TextEncodingLocale', 'ko_KR.UTF-8');
Screen('Preference','TextRenderer', 0);  % when font is broken


% Window Setting
% [theWindow, window_rect] = Screen('OpenWindow', window_num, black);%, [0,0,1600,1000]);
Screen('Textfont', theWindow, '-:lang=ko');
Screen('TextSize', theWindow, fontsize);

orange = [255 164 0];

% get font parameter
[~, ~, wordrect1, ~] = DrawFormattedText(theWindow, double('코'), lb1-30, H/2+scale_W+40, bgcolor);
[~, ~, wordrect2, ~] = DrawFormattedText(theWindow, double('p'), lb1-30, H/2+scale_W+40, bgcolor);
[~, ~, wordrect3, ~] = DrawFormattedText(theWindow, double('p '), lb1-30, H/2+scale_W+40, bgcolor);
[~, ~, wordrect4, ~] = DrawFormattedText(theWindow, double('^'), lb1-30, H/2+scale_W+40, bgcolor);
[korean.x, korean.y, alpnum.x, alpnum.y, space.x, space.y, special.x, special.y] = deal(...
    wordrect1(3)-wordrect1(1), wordrect1(4)-wordrect1(2), ... % x = 36, y = 50
    wordrect2(3)-wordrect2(1), wordrect2(4)-wordrect2(2), ... % x = 25, y = 50
    wordrect3(3)-wordrect3(1) - (wordrect2(3)-wordrect2(1)), wordrect3(4)-wordrect3(2), ... % x = 12, y = 50
    wordrect4(3)-wordrect4(1), wordrect4(4)-wordrect4(2)); % x = 19, y = 50

Screen(theWindow, 'FillRect', bgcolor, window_rect); % Just getting information, and do not show the scale.
Screen('Flip', theWindow);


%% SETUP : Screen
% PsychDefaultSetup(1);
% screens = Screen('Screens');
% window_num = screens(end);

if ~show_cursor
    HideCursor;
end

% Screen('Preference', 'SkipSyncTests', 1);
% 
% [window_width, window_height] = Screen('WindowSize', window_num);
% switch screen_mode
%     case 'full'
%         window_rect = [0 0 window_width window_height]; % full screen
%     case 'semifull'
%         window_rect = [0 0 window_width-100 window_height-100]; % a little bit distance
%     case 'middle'
%         window_rect = [0 0 window_width/2 window_height/2];
%     case 'small'
%         window_rect = [0 0 400 300]; % in the test mode, use a little smaller screen
% end

% % size
% W = window_rect(3); % width
% H = window_rect(4); % height
% 
% lb1 = W/4; % rating scale left bounds 1/4
% rb1 = (3*W)/4; % rating scale right bounds 3/4
% 
% lb2 = W/3; % new bound for or not
% rb2 = (W*2)/3;
% 
% scale_W = (rb1-lb1).*0.1; % Height of the scale (10% of the width)
% 
% anchor_lms = [0.014 0.061 0.172 0.354 0.533].*(rb1-lb1)+lb1;
% anchor_middle = [0.2 0.5].*(rb1-lb1)+lb1;
% 
% % font
% fontsize = 40;
% Screen('Preference', 'TextEncodingLocale', 'ko_KR.UTF-8');
% Screen('Preference','TextRenderer', 0);  % when font is broken
% 
% % color
% bgcolor = 50;
% white = 255;
% red = [158 1 66];
% 
% % open window
% theWindow = Screen('OpenWindow', window_num, bgcolor, window_rect); % start the screen
% Screen('Textfont', theWindow, '-:lang=ko');
% Screen('TextSize', theWindow, fontsize);
% 
% orange = [255 164 0];
% 
% % get font parameter
% [~, ~, wordrect1, ~] = DrawFormattedText(theWindow, double('코'), lb1-30, H/2+scale_W+40, bgcolor);
% [~, ~, wordrect2, ~] = DrawFormattedText(theWindow, double('p'), lb1-30, H/2+scale_W+40, bgcolor);
% [~, ~, wordrect3, ~] = DrawFormattedText(theWindow, double('p '), lb1-30, H/2+scale_W+40, bgcolor);
% [~, ~, wordrect4, ~] = DrawFormattedText(theWindow, double('^'), lb1-30, H/2+scale_W+40, bgcolor);
% [korean.x, korean.y, alpnum.x, alpnum.y, space.x, space.y, special.x, special.y] = deal(...
%     wordrect1(3)-wordrect1(1), wordrect1(4)-wordrect1(2), ... % x = 36, y = 50
%     wordrect2(3)-wordrect2(1), wordrect2(4)-wordrect2(2), ... % x = 25, y = 50
%     wordrect3(3)-wordrect3(1) - (wordrect2(3)-wordrect2(1)), wordrect3(4)-wordrect3(2), ... % x = 12, y = 50
%     wordrect4(3)-wordrect4(1), wordrect4(4)-wordrect4(2)); % x = 19, y = 50
% 
% Screen(theWindow, 'FillRect', bgcolor, window_rect); % Just getting information, and do not show the scale.
% Screen('Flip', theWindow);


%% SETUP: Input setting (for Mac and test)

if test_mode
    devices = PsychHID('Devices');
    devices_keyboard = [];
    for i = 1:numel(devices)
        if strcmp(devices(i).usageName, 'Keyboard')
            devices_keyboard = [devices_keyboard, devices(i)];
        end
    end
    Exp_key = devices_keyboard(3).index; % 7T test 시에는 (3) / 정인 자리에서는 (2)
elseif ~test_mode
    devices = PsychHID('Devices');
    devices_keyboard = [];
    for i = 1:numel(devices)
        if strcmp(devices(i).usageName, 'Keyboard')
            devices_keyboard = [devices_keyboard, devices(i)];
        end
    end
    Exp_key = devices_keyboard(3).index; % MODIFY if you need
end


%% MAIN : Ready for scan

msgtxt = ['지금부터 구조 촬영이 시작됩니다.\n', ...
    '참가자님은 화면의 + 표시를 응시하면서 편안히 계시면 됩니다.'];
DrawFormattedText(theWindow, double(msgtxt), 'center', H*(1/2), white, [], [], [], 2);
Screen('Flip', theWindow);
while true % Space
    [~,~,keyCode_E] = KbCheck(Exp_key);
    if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
    if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
end

% Fixation cross
start_t = GetSecs;
data.t1_starttime = start_t;

msgtxt = '+';
Screen('TextSize', theWindow, 500);
DrawFormattedText(theWindow, double(msgtxt), 'center', H*(1/2), white, [], [], [], 2);
Screen('Flip', theWindow);
Screen('TextSize', theWindow, fontsize);

while true % Space
    [~,~,keyCode_E] = KbCheck(Exp_key);
    if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
    if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
end


data.t1_duration = GetSecs - start_t;

save(data.datafile, 'data', '-append')

ShowCursor;
sca;
Screen('CloseAll');


end






