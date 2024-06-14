function CL_fMRI_paintask_240527_mr(subjID, subjrun, basedir, varargin)
%% before run
% run_data_mat, ts 파일 만들어졌나 확인

%% SETUP : Basic parameter

global subjnum runtype theWindow lb1 rb1 lb2 rb2 H W scale_W anchor_lms anchor_middle korean alpnum space special bgcolor white orange red;

test_mode = false;

prescan = false;
audio_test = false;
heat_test = false;
USE_BIOPAC = false;

if test_mode
    %USE_BIOPAC = false;
    show_cursor = true;
    screen_mode = 'small';
    disp('***** TEST mode *****');
elseif ~test_mode
    % USE_BIOPAC = true;
    show_cursor = false;
    screen_mode = 'full';
    disp('***** EXPERIMENT mode *****');
end

ismacbook = false;
[~, hostname] = system('hostname');
switch strtrim(hostname)
    case '7T-MRIui-Mac-Pro.local' % 7T MAC
        outputdev.HostAudioAPIName = 'Core Audio';
        outputdev.DeviceName = '내장 출력';
end

% Data, trial_sequence 폴더 없으면 만들기
if ~exist(fullfile(basedir,'Data')); mkdir(fullfile(basedir,'Data')); end
if ~exist(fullfile(basedir,'trial_sequence')); mkdir(fullfile(basedir,'trial_sequence')); end

Screen('CloseAll');


%% PARSING VARARGIN

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'audio'}
                audio_test = true;
            case {'heat'}
                heat_test = true;
            case {'pre' 'prescan'}
                prescan = true;
            case {'biopac'}
                USE_BIOPAC = true;
        end
    end
end


%% SETUP : Check subject info
subjnum = str2double(subjID(3:5));
if isempty(subjID) || isempty(subjnum) || isempty(subjrun) %만약 이중에 입력 안 된거 있으면 error 뜨도록해라
    error('Wrong subj info. Break.')
end

% load or make ts file
ts_dir = fullfile(basedir, 'trial_sequence');
ts_fname = filenames(fullfile(ts_dir, [subjID '*.mat']), 'char');% 이거 돌리기 전에 mkdir('trial_sequence') 해야 함 .파일 이름에 subject ID이 들어가는 것들을 찾음
if ~exist(ts_fname) % 만약에 해당 이름의 ts 파일이 없으면
    fprintf('No file. Create one.\n');
    ts = CL_generate_trial_sequence(basedir, subjID); % make ts file
elseif size(ts_fname,1)>1
    error('There are more than one ts file. Please check and delete the wrong files.');
else
    load(ts_fname);
end


%% SETUP : Load randomized run data and Compare the markers
% run 순서 제대로 실행했는 지 확인하는 코드
markerfile = fullfile(basedir, 'CL_fMRI_run_data.mat'); %run 순서 데이터 있는 파일로 가는 경로 만들기
load(markerfile, 'runs', 'durs', 'cond', 'marker_mat');% markerfile로부터 세 개의 변수인 runs, durs,cond, marker_mat을 로드
runmarker = find(marker_mat(subjnum, :)); %find 함수는 0이 아닌 값의 인덱스를 찾음, run 하나를 할 때 마다 다음 run이 1이되고 나머지는 0으로 초기화

if runmarker ~= subjrun
    cont_or_not = input(['\nThe run number is inconsistent with the latest progress. Continue?', ...
        '\n1: Yes.  ,   2: No, break.\n:  ']);
    if cont_or_not == 1
        runmarker = subjrun;
    elseif cont_or_not == 2
        error('Break.')
    else
        error('Wrong number. Break.')
    end
end


%% SETUP : Save data in first
savedir = fullfile(basedir, 'Data');

nowtime = clock;
subjtime = sprintf('%.2d%.2d%.2d', nowtime(1), nowtime(2), nowtime(3));

exp = 'CL7T';
data.subject = subjID;
data.datafile = fullfile(savedir, sprintf('%s_%s_run%.2d.mat', subjID, subjtime, runmarker));
data.version = 'CL_cocoanlab_20240525';
data.starttime = datestr(clock, 0);
data.starttime_getsecs = GetSecs;

% CHECK!!
ip = '192.168.0.3';  % ip = '192.168.0.3';
port = 20121;

save(data.datafile, 'data');

%% SETUP : Paradigm & run order
S.type = runs{runmarker}; %현재 run에 대한 정보들 저장해놓은 struct
S.dur = durs(runmarker);
S.cond_all = ts.cond_run_trial(runmarker,:);

runtype = S.type;
data.dat.type = S.type;
data.dat.duration = S.dur;
data.dat.cond_order = S.cond_all;

postrun_start_t = 2; % postrun start waiting time.
postrun_end_t = 2; % postrun questionnaire waiting time.

runs_for_display = runs;
runs_for_display{runmarker} = sprintf('[[%s]]', runs_for_display{runmarker});
fprintf('\n\n');
fprintf('Runs: %s\n\n', string(join(runs_for_display)));

%% Screen settings

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
    Scan_key = devices_keyboard(1).index; % should modify for the scanner
    
else
    devices = PsychHID('Devices');
    devices_keyboard = [];
    for i = 1:numel(devices)
        if strcmp(devices(i).usageName, 'Keyboard')
            devices_keyboard = [devices_keyboard, devices(i)];
        end
    end
    Exp_key = devices_keyboard(3).index; % MODIFY if you need
    Scan_key = devices_keyboard(1).index; % should modify for the scanner
end

if ismember(S.type, {'run1', 'run2', 'run3', 'run4'})
    InitializePsychSound;
    padev = PsychPortAudio('GetDevices');
    padev_output = padev([padev(:).NrOutputChannels] > 0);
    padev_output = padev_output(strcmp({padev_output.DeviceName}, outputdev.DeviceName) & strcmp({padev_output.HostAudioAPIName}, outputdev.HostAudioAPIName));
end
vol = 0.5;

%% Biopack Python setting
PATH = getenv('PATH');
if isempty(strfind(PATH,':/Library/Frameworks/Python.framework/Versions/3.7/bin'))
    setenv('PATH', [PATH ':/Library/Frameworks/Python.framework/Versions/3.7/bin']);
end

%% Pre-scan instruction

if prescan
    msgtxt = ['참가자님의 머리 위치 파악을 위한 예비 촬영을 진행하겠습니다.\n', ...
        '화면의 + 표시를 응시하면서 편안히 계시면 됩니다.'];
    DrawFormattedText(theWindow, double(msgtxt), 'center', H*(1/2), white, [], [], [], 2);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end
    
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
    
    % Finish testing
    msgtxt = ['예비 촬영이 완료되었습니다.\n'];
    DrawFormattedText(theWindow, double(msgtxt), 'center', H*(1/2), white, [], [], [], 2);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end
end

%% Audio test
if audio_test
    msgtxt = ['본 촬영에 앞서, 음향 테스트를 진행하겠습니다.\n', ...
        '소리가 너무 크거나 작으면 실험자에게 알려주세요.'];
    DrawFormattedText(theWindow, double(msgtxt), 'center', H*(1/2), white, [], [], [], 2);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        if keyCode_E(KbName('a'))
            while keyCode_E(KbName('a'))
                Beeper(1000,vol,1);
                [~,~,keyCode_E] = KbCheck(Exp_key);
                if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            end
        end
    end
end

%% test thermal pain
wait_preheat = 5;  wait_stimulus = wait_preheat + 14.5;
if heat_test
    msgtxt = ['이번에는 열 자극 테스트를 진행하겠습니다.\n'];
    DrawFormattedText(theWindow, double(msgtxt), 'center', H*(1/2), white, [], [], [], 2);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end
    
    data.dat.pretest_starttime = GetSecs;
    
    %% -------------Pre heat: Setting Pathway------------------
    main(ip,port,1, 149);     % heat_param = 149(47C) is the highest temperature
    waitsec_fromstarttime(data.dat.pretest_starttime, wait_preheat-2)
    
    %% -------------Pre_state: Ready for Pathway------------------
    main(ip,port,2); %ready to pre-start
    waitsec_fromstarttime(data.dat.pretest_starttime, wait_preheat) % Because of wait_pathway_setup-2, at least we need 2 secs
    
    %% ------------- start to trigger thermal stimulus------------------
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    Screen('TextSize', theWindow, 500);
    DrawFormattedText(theWindow, double('+'), 'center', H*(1/2), white, [], [], [], 1.2);
    Screen('Flip', theWindow);
    
    main(ip,port,2);  % stim start
    
    %% stimulus time adjusting
    waitsec_fromstarttime(data.dat.pretest_starttime, wait_stimulus)
end

%% SETUP:generating and saving jitter list & HEAT intensity list
% jitter
jitter1 = 0:4;  % summed with preheat = 5 secs; jitter1 = 5~9
jitter2 = 5-jitter1;  % jitter2 = 5~1; total 10 secs
jitter_index_list = ts.jitter_index_list(runmarker,:);

data.dat.jitter_index_list = jitter_index_list;

% Making pathway program list
heat_temp = [44.500,47.000];
PathPrg = load_PathProgram('7TCl');
[~,indx] = ismember(heat_temp, [PathPrg{:,1}]);
heat_param.program = [PathPrg{indx,4}];
heat_param.intensity = heat_temp;
data.dat.heat_param = heat_param;


%% MAIN : Ready for scan

Screen(theWindow, 'FillRect', bgcolor, window_rect); % Just getting information, and do not show the scale.
Screen('TextSize', theWindow, fontsize);
msgtxt = ['실험자는 모든 세팅 및 참가자님의 준비가 완료되었는지 확인하기 바랍니다.\n', ...
    '준비가 완료되면 실험자는 SPACE 키를 눌러 주시기 바랍니다.'];
DrawFormattedText(theWindow, double(msgtxt), 'center', H*(1/2), white, [], [], [], 2);
Screen('Flip', theWindow);

while true
    [~,~,keyCode_E] = KbCheck(Exp_key);
    if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
    if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
end

msgtxt = ['지금부터 본 실험이 시작됩니다.\n', ...
    '주의: 촬영 중 머리를 움직이거나 잠에 들지 않도록 유의해주세요!!!'];
DrawFormattedText(theWindow, double(msgtxt), 'center', H*(1/2), orange, [], [], [], 2);
Screen('Flip', theWindow);
while true % Space
    [~,~,keyCode_E] = KbCheck(Exp_key);
    if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
    if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
end

%% MAIN : Sync (S key)

msgtxt = '스캔을 시작합니다. (S 키)';
DrawFormattedText(theWindow, double(msgtxt), 'center', H*(1/2), white, [], [], [], 2);
Screen('Flip', theWindow);
while true
    [~,~,keyCode_S] = KbCheck(Scan_key);
    if keyCode_S(KbName('s')); break; end
    [~,~,keyCode_E] = KbCheck(Exp_key);
    if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
end

%% MAIN : Disdaq (30 secs)

% 2 secs : scanning...
start_t = GetSecs;
data.dat.runscan_starttime = start_t; % run 시작

msgtxt = '시작하는 중...';
DrawFormattedText(theWindow, double(msgtxt), 'center', H*(1/2), white, [], [], [], 2);
Screen('Flip', theWindow);

% 2초동안 위의 '시작하는 중...' 화면 유지하도록
while true
    cur_t = GetSecs;
    if cur_t - start_t >= 2
        break
    end
end

% start biopac
if USE_BIOPAC
    bio_trigger_range = 1.5;
    command = 'python3 labjack.py ';
    full_command = [command bio_trigger_range];
    data.dat.biopac_start_trigger_s = GetSecs;
    
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    Screen('Flip', theWindow);
    unix(full_command)
    %     unix('python3 labjack.py 3')
    data.dat.biopac_start_trigger_e = GetSecs;
    data.dat.biopac_start_trigger_dur = data.dat.biopac_start_trigger_e - data.dat.biopac_start_trigger_s;
end

% disdaq 30 secs
start_t = GetSecs;
data.dat.disdaq_starttime = cur_t;

msgtxt = '+';
Screen('TextSize', theWindow, 500);
DrawFormattedText(theWindow, double(msgtxt), 'center', H*(1/2), white, [], [], [], 2);
Screen('Flip', theWindow);

while true
    cur_t = GetSecs;
    if cur_t - start_t >= 30
        break
    end
end
data.dat.disdaq_endtime = cur_t;
data.dat.disdaq_duration = cur_t - start_t;

%% MAIN: Experiment
data.dat.run_starttime = GetSecs;

%% Pre-rest (40s)
start_t = GetSecs;
data.dat.run_pre_rest_start = start_t;

while true
    cur_t = GetSecs;
    if cur_t - start_t >= 40
        break
    end
end
data.dat.run_pre_rest_end = cur_t;
data.dat.pre_rest_duration = cur_t - start_t;

%% switching trials
wait_preheat = 5;  wait_cue = 2; % cue 몇 초 동안 제시되는지
for trial_num = 1:length(S.cond_all)
    fprintf('***** Trial %.2d start. *****\n',trial_num);
    switch S.cond_all{trial_num}
        case 'high-cue'
            data.dat.cond{trial_num}.trial = 'high-cue';
            
            % SETUP: ITI
            wait_cue = 2; % cue 몇 초 동안 제시되는지
            wait_jitter1 = wait_cue + wait_preheat + jitter1(jitter_index_list(trial_num));% 2 + 5 + (0~4) = 7~11
            wait_stimulus = wait_jitter1 + 14.5; % 2 + 5+ (0~4) + 14.5 = 21.5~25.5
            wait_jitter2 = wait_stimulus + jitter2(jitter_index_list(trial_num));% 2 + 5+ (0~4) + 14.5 + (5~1) = 26.5
            
            % check preheat+jitter1+jitter2 = 14
            wait_resting = wait_jitter2 + 29; % 2 + 5+ (0~4) + 14.5 + (4~0) + 29 = 54.5
            total_trial_time = 55.5;  % = wait_resting
            
            %% Data recording
            data.dat.cond{trial_num}.trial_starttime = GetSecs;
            data.dat.cond{trial_num}.jitter_value = [jitter1(jitter_index_list(trial_num)) jitter2(jitter_index_list(trial_num))];
            data.dat.cond{trial_num}.jitter_index = jitter_index_list(trial_num);
            
            %% Check cue time
            data.dat.cond{trial_num}.cue_starttime = GetSecs;
            waitsec_fromstarttime(data.dat.cond{trial_num}.cue_starttime, 0.5)  % buffer
            
            Beeper(1000,vol,1);  % auditory cue: freq, volume, secs
            waitsec_fromstarttime(data.dat.cond{trial_num}.cue_starttime, wait_cue)
            
            data.dat.cond{trial_num}.cue_endtime = GetSecs;
            data.dat.cond{trial_num}.cue_duration = data.dat.cond{trial_num}.cue_endtime - data.dat.cond{trial_num}.cue_starttime;
            
            %% Check jitter1 time
            data.dat.cond{trial_num}.jitter1_starttime = GetSecs;
            waitsec_fromstarttime(data.dat.cond{trial_num}.cue_starttime, wait_cue+jitter1(jitter_index_list(trial_num)))  % = wait_jitter1-wait_preheat
            data.dat.cond{trial_num}.jitter1_endtime = GetSecs;
            data.dat.cond{trial_num}.jitter1_duration = data.dat.cond{trial_num}.jitter1_endtime - data.dat.cond{trial_num}.jitter1_starttime;
            
            %% Heat stimulation
            data.dat.cond{trial_num}.preheat_starttime = GetSecs;
            
            %% -------------Pre_State: Setting Pathway------------------
            main(ip,port,1,heat_param.program(2));     % select the program
            waitsec_fromstarttime(data.dat.cond{trial_num}.preheat_starttime,wait_preheat-2);
            
            %% -------------Pre_state: Ready for Pathway------------------
            main(ip,port,2); %ready to pre-start
            waitsec_fromstarttime(data.dat.cond{trial_num}.preheat_starttime,wait_preheat) % Because of wait_pathway_setup-2, at least we need 2 secs

            %% ------------- start to trigger thermal stimulus------------------
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            Screen('TextSize', theWindow, 500);
            DrawFormattedText(theWindow, double('+'), 'center', H*(1/2), white, [], [], [], 1.2);
            Screen('Flip', theWindow);
            Screen('TextSize', theWindow, fontsize);
            
            main(ip,port,2);  % stim start
            
            data.dat.cond{trial_num}.stimulus_starttime = GetSecs;
            waitsec_fromstarttime(data.dat.cond{trial_num}.cue_starttime, wait_stimulus);
            
            data.dat.cond{trial_num}.stimulus_endtime = GetSecs;
            data.dat.cond{trial_num}.stimulus_duration = data.dat.cond{trial_num}.stimulus_endtime - data.dat.cond{trial_num}.stimulus_starttime;
            
            %% Check jitter2 time: cue+jitter1+heat+jitter2
            data.dat.cond{trial_num}.jitter2_starttime = GetSecs;
            waitsec_fromstarttime(data.dat.cond{trial_num}.cue_starttime, wait_jitter2)
            
            data.dat.cond{trial_num}.jitter2_endtime = GetSecs;
            data.dat.cond{trial_num}.jitter2_duration = data.dat.cond{trial_num}.jitter2_endtime - data.dat.cond{trial_num}.jitter2_starttime;
            
            %% Check resting time: cue+jitter1+heat+jitter2+resting
            data.dat.cond{trial_num}.resting_starttime = GetSecs;
            waitsec_fromstarttime(data.dat.cond{trial_num}.cue_starttime, wait_resting)
            
            data.dat.cond{trial_num}.resting_endtime =GetSecs;
            data.dat.cond{trial_num}.resting_duration = data.dat.cond{trial_num}.resting_endtime - data.dat.cond{trial_num}.resting_starttime;
            
            %% Adjusting total trial time
            waitsec_fromstarttime(data.dat.cond{trial_num}.cue_starttime, total_trial_time)
            
            %% saving trial end time
            data.dat.cond{trial_num}.trial_endtime = GetSecs;
            data.dat.cond{trial_num}.trial_duration = data.dat.cond{trial_num}.trial_endtime - data.dat.cond{trial_num}.trial_starttime;
            
            if trial_num > 1
                data.dat.between_trial_time(trial_num) = data.dat.cond{trial_num}.trial_starttime - data.dat.cond{trial_num-1}.trial_endtime;
            elseif trial_num == 1
                data.dat.between_trial_time(trial_num) = 0;
            end
            save(data.datafile, '-append', 'data');
            
        case 'high-nocue'
            data.dat.cond{trial_num}.trial = 'high-nocue'; %cell 벗기기 위해서 {}씀
            
            % SETUP: ITI
            wait_jitter1 = wait_preheat + jitter1(jitter_index_list(trial_num)); % 5 + (0~4) = 5~9
            wait_stimulus = wait_jitter1 + 14.5; % 5 + (0~4) + 14.5 = 19.5~23.5
            wait_jitter2 = wait_stimulus + jitter2(jitter_index_list(trial_num));% 5 + (0~4) + 14.5 + (5~1) = 24.5
            
            % check preheat+jitter1+jitter2 = 14
            wait_resting = wait_jitter2 + 29; % 5 + (0~4) + 14.5 + (4~0) + 29 = 52.5
            total_trial_time = 53.5;  % = wait_resting
            
            %% Data recording
            data.dat.cond{trial_num}.trial_starttime = GetSecs;
            data.dat.cond{trial_num}.jitter_value = [jitter1(jitter_index_list(trial_num)) jitter2(jitter_index_list(trial_num))];
            data.dat.cond{trial_num}.jitter_index = jitter_index_list(trial_num);
            
            %% Check jitter1 time
            data.dat.cond{trial_num}.jitter1_starttime = GetSecs;
            waitsec_fromstarttime(data.dat.cond{trial_num}.jitter1_starttime, jitter1(jitter_index_list(trial_num)))  % = wait_jitter1-wait_preheat
            data.dat.cond{trial_num}.jitter1_endtime = GetSecs;
            data.dat.cond{trial_num}.jitter1_duration = data.dat.cond{trial_num}.jitter1_endtime - data.dat.cond{trial_num}.jitter1_starttime;
            
            %% Heat stimulation
            data.dat.cond{trial_num}.preheat_starttime = GetSecs;
            
            %% -------------Pre_State: Setting Pathway------------------
            main(ip,port,1,heat_param.program(2));     % select the program
            waitsec_fromstarttime(data.dat.cond{trial_num}.preheat_starttime,wait_preheat-2);
            
            %% -------------Pre_state: Ready for Pathway------------------
            main(ip,port,2); %ready to pre-start
            waitsec_fromstarttime(data.dat.cond{trial_num}.preheat_starttime,wait_preheat) % Because of wait_pathway_setup-2, at least we need 2 secs

            %% ------------- start to trigger thermal stimulus------------------
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            Screen('TextSize', theWindow, 500);
            DrawFormattedText(theWindow, double('+'), 'center', H*(1/2), white, [], [], [], 1.2);
            Screen('Flip', theWindow);
            Screen('TextSize', theWindow, fontsize);
            
            main(ip,port,2);  % stim start
            
            data.dat.cond{trial_num}.stimulus_starttime = GetSecs;
            waitsec_fromstarttime(data.dat.cond{trial_num}.jitter1_starttime, wait_stimulus);
            
            data.dat.cond{trial_num}.stimulus_endtime = GetSecs;
            data.dat.cond{trial_num}.stimulus_duration = data.dat.cond{trial_num}.stimulus_endtime - data.dat.cond{trial_num}.stimulus_starttime;
            
            %% Check jitter2 time: jitter1+heat+jitter2
            data.dat.cond{trial_num}.jitter2_starttime = GetSecs;
            waitsec_fromstarttime(data.dat.cond{trial_num}.jitter1_starttime, wait_jitter2)
            
            data.dat.cond{trial_num}.jitter2_endtime = GetSecs;
            data.dat.cond{trial_num}.jitter2_duration = data.dat.cond{trial_num}.jitter2_endtime - data.dat.cond{trial_num}.jitter2_starttime;
            
            %% Check resting time: jitter1+heat+jitter2+resting
            data.dat.cond{trial_num}.resting_starttime= GetSecs;
            waitsec_fromstarttime(data.dat.cond{trial_num}.jitter1_starttime, wait_resting)
            
            data.dat.cond{trial_num}.resting_endtime = GetSecs;
            data.dat.cond{trial_num}.resting_duration = data.dat.cond{trial_num}.resting_endtime - data.dat.cond{trial_num}.resting_starttime;
            
            %% Adjusting total trial time
            waitsec_fromstarttime(data.dat.cond{trial_num}.jitter1_starttime, total_trial_time)
            
            %% saving trial end time
            data.dat.cond{trial_num}.trial_endtime = GetSecs;
            data.dat.cond{trial_num}.trial_duration = data.dat.cond{trial_num}.trial_endtime - data.dat.cond{trial_num}.trial_starttime;
            
            if trial_num > 1
                data.dat.between_trial_time(trial_num) = data.dat.cond{trial_num}.trial_starttime - data.dat.cond{trial_num-1}.trial_endtime;
            elseif trial_num == 1
                data.dat.between_trial_time(trial_num) = 0;
            end
            save(data.datafile, '-append', 'data');
            
        case 'low-cue'
            data.dat.cond{trial_num}.trial = 'low-cue'; %cell 벗기기 위해서 {}씀
            
            % SETUP: ITI
            wait_cue = 2; % cue 몇 초 동안 제시되는지
            wait_jitter1 = wait_cue + wait_preheat + jitter1(jitter_index_list(trial_num));% 2 + 5 + (0~4) = 7~11
            wait_stimulus = wait_jitter1 + 14.5; % 2 + 5+ (0~4) + 14.5 = 21.5~25.5
            wait_jitter2 = wait_stimulus + jitter2(jitter_index_list(trial_num));% 2 + 5+ (0~4) + 14.5 + (5~1) = 26.5
            
            % check preheat+jitter1+jitter2 = 14
            wait_resting = wait_jitter2 + 29; % 2 + 5+ (0~4) + 14.5 + (4~0) + 29 = 54.5
            total_trial_time = 55.5;  % = wait_resting
            
            %% Data recording
            data.dat.cond{trial_num}.trial_starttime = GetSecs;
            data.dat.cond{trial_num}.jitter_value = [jitter1(jitter_index_list(trial_num)) jitter2(jitter_index_list(trial_num))];
            data.dat.cond{trial_num}.jitter_index = jitter_index_list(trial_num);
            
            %% Check cue time
            data.dat.cond{trial_num}.cue_starttime = GetSecs;
            waitsec_fromstarttime(data.dat.cond{trial_num}.cue_starttime, 0.5)  % buffer
            
            Beeper(1000,vol,1);  % auditory cue: freq, volume, secs
            waitsec_fromstarttime(data.dat.cond{trial_num}.cue_starttime, wait_cue)
            
            data.dat.cond{trial_num}.cue_endtime = GetSecs;
            data.dat.cond{trial_num}.cue_duration = data.dat.cond{trial_num}.cue_endtime - data.dat.cond{trial_num}.cue_starttime;
            
            %% Check jitter1 time
            data.dat.cond{trial_num}.jitter1_starttime = GetSecs;
            waitsec_fromstarttime(data.dat.cond{trial_num}.cue_starttime, wait_cue+jitter1(jitter_index_list(trial_num)))  % = wait_jitter1-wait_preheat
            data.dat.cond{trial_num}.jitter1_endtime = GetSecs;
            data.dat.cond{trial_num}.jitter1_duration = data.dat.cond{trial_num}.jitter1_endtime - data.dat.cond{trial_num}.jitter1_starttime;
            
            %% Heat stimulation
            data.dat.cond{trial_num}.preheat_starttime = GetSecs;
            
            %% -------------Pre_State: Setting Pathway------------------
            main(ip,port,1,heat_param.program(1));     % select the program
            waitsec_fromstarttime(data.dat.cond{trial_num}.preheat_starttime,wait_preheat-2);
            
            %% -------------Pre_state: Ready for Pathway------------------
            main(ip,port,2); %ready to pre-start
            waitsec_fromstarttime(data.dat.cond{trial_num}.preheat_starttime,wait_preheat) % Because of wait_pathway_setup-2, at least we need 2 secs

            %% ------------- start to trigger thermal stimulus------------------
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            Screen('TextSize', theWindow, 500);
            DrawFormattedText(theWindow, double('+'), 'center', H*(1/2), white, [], [], [], 1.2);
            Screen('Flip', theWindow);
            Screen('TextSize', theWindow, fontsize);
            
            main(ip,port,2);  % stim start
            
            data.dat.cond{trial_num}.stimulus_starttime = GetSecs;
            waitsec_fromstarttime(data.dat.cond{trial_num}.cue_starttime, wait_stimulus);
            
            data.dat.cond{trial_num}.stimulus_endtime = GetSecs;
            data.dat.cond{trial_num}.stimulus_duration = data.dat.cond{trial_num}.stimulus_endtime - data.dat.cond{trial_num}.stimulus_starttime;
            
            %% Check jitter2 time: cue+jitter1+heat+jitter2
            data.dat.cond{trial_num}.jitter2_starttime = GetSecs;
            waitsec_fromstarttime(data.dat.cond{trial_num}.cue_starttime, wait_jitter2)
            
            data.dat.cond{trial_num}.jitter2_endtime = GetSecs;
            data.dat.cond{trial_num}.jitter2_duration = data.dat.cond{trial_num}.jitter2_endtime - data.dat.cond{trial_num}.jitter2_starttime;
            
            %% Check resting time: cue+jitter1+heat+jitter2+resting
            data.dat.cond{trial_num}.resting_starttime = GetSecs;
            waitsec_fromstarttime(data.dat.cond{trial_num}.cue_starttime, wait_resting)
            
            data.dat.cond{trial_num}.resting_endtime = GetSecs;
            data.dat.cond{trial_num}.resting_duration = data.dat.cond{trial_num}.resting_endtime - data.dat.cond{trial_num}.resting_starttime;
            
            %% Adjusting total trial time
            waitsec_fromstarttime(data.dat.cond{trial_num}.cue_starttime, total_trial_time)
            
            %% saving trial end time
            data.dat.cond{trial_num}.trial_endtime = GetSecs;
            data.dat.cond{trial_num}.trial_duration = data.dat.cond{trial_num}.trial_endtime - data.dat.cond{trial_num}.trial_starttime;
            
            if trial_num > 1
                data.dat.between_trial_time(trial_num) = data.dat.cond{trial_num}.trial_starttime - data.dat.cond{trial_num-1}.trial_endtime;
            elseif trial_num == 1
                data.dat.between_trial_time(trial_num) = 0;
            end
            save(data.datafile, '-append', 'data');
            
        case 'low-nocue'
            data.dat.cond{trial_num}.trial = 'low-nocue'; %cell 벗기기 위해서 {}씀
            
            % SETUP: ITI
            wait_jitter1 = wait_preheat + jitter1(jitter_index_list(trial_num)); % 5 + (0~4) = 5~9
            wait_stimulus = wait_jitter1 + 14.5; % 5 + (0~4) + 14.5 = 19.5~23.5
            wait_jitter2 = wait_stimulus + jitter2(jitter_index_list(trial_num));% 5 + (0~4) + 14.5 + (5~1) = 24.5
            
            % check preheat+jitter1+jitter2 = 14
            wait_resting = wait_jitter2 + 29; % 5 + (0~4) + 14.5 + (5~1) + 29 = 52.5
            total_trial_time = 53.5;  % = wait_resting
            
            %% Data recording
            data.dat.cond{trial_num}.trial_starttime = GetSecs;
            data.dat.cond{trial_num}.jitter_value = [jitter1(jitter_index_list(trial_num)) jitter2(jitter_index_list(trial_num))];
            data.dat.cond{trial_num}.jitter_index = jitter_index_list(trial_num);
            
            %% Check jitter1 time
            data.dat.cond{trial_num}.jitter1_starttime = GetSecs;
            waitsec_fromstarttime(data.dat.cond{trial_num}.jitter1_starttime, jitter1(jitter_index_list(trial_num)))  % = wait_jitter1-wait_preheat
            data.dat.cond{trial_num}.jitter1_endtime = GetSecs;
            data.dat.cond{trial_num}.jitter1_duration = data.dat.cond{trial_num}.jitter1_endtime - data.dat.cond{trial_num}.jitter1_starttime;
            
            %% Heat stimulation
            data.dat.cond{trial_num}.preheat_starttime = GetSecs;
            
            %% -------------Pre_State: Setting Pathway------------------
            main(ip,port,1,heat_param.program(1));     % select the program
            waitsec_fromstarttime(data.dat.cond{trial_num}.preheat_starttime,wait_preheat-2);
            
            %% -------------Pre_state: Ready for Pathway------------------
            main(ip,port,2); %ready to pre-start
            waitsec_fromstarttime(data.dat.cond{trial_num}.preheat_starttime,wait_preheat) % Because of wait_pathway_setup-2, at least we need 2 secs

            %% ------------- start to trigger thermal stimulus------------------
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            Screen('TextSize', theWindow, 500);
            DrawFormattedText(theWindow, double('+'), 'center', H*(1/2), white, [], [], [], 1.2);
            Screen('Flip', theWindow);
            Screen('TextSize', theWindow, fontsize);
            
            main(ip,port,2);  % stim start
            
            data.dat.cond{trial_num}.stimulus_starttime = GetSecs;
            waitsec_fromstarttime(data.dat.cond{trial_num}.jitter1_starttime, wait_stimulus);
            
            data.dat.cond{trial_num}.stimulus_endtime = GetSecs;
            data.dat.cond{trial_num}.stimulus_duration = data.dat.cond{trial_num}.stimulus_endtime - data.dat.cond{trial_num}.stimulus_starttime;
            
            %% Check jitter2 time: jitter1+heat+jitter2
            data.dat.cond{trial_num}.jitter2_starttime = GetSecs;
            waitsec_fromstarttime(data.dat.cond{trial_num}.jitter1_starttime, wait_jitter2)
            
            data.dat.cond{trial_num}.jitter2_endtime = GetSecs;
            data.dat.cond{trial_num}.jitter2_duration = data.dat.cond{trial_num}.jitter2_endtime - data.dat.cond{trial_num}.jitter2_starttime;
            
            %% Check resting time: jitter1+heat+jitter2+resting
            data.dat.cond{trial_num}.resting_starttime = GetSecs;
            waitsec_fromstarttime(data.dat.cond{trial_num}.jitter1_starttime, wait_resting)
            
            data.dat.cond{trial_num}.resting_endtime = GetSecs;
            data.dat.cond{trial_num}.resting_duration = data.dat.cond{trial_num}.resting_endtime - data.dat.cond{trial_num}.resting_starttime;
            
            %% Adjusting total trial time
            waitsec_fromstarttime(data.dat.cond{trial_num}.jitter1_starttime, total_trial_time)
            
            %% saving trial end time
            data.dat.cond{trial_num}.trial_endtime = GetSecs;
            data.dat.cond{trial_num}.trial_duration = data.dat.cond{trial_num}.trial_endtime - data.dat.cond{trial_num}.trial_starttime;
            
            if trial_num > 1
                data.dat.between_trial_time(trial_num) = data.dat.cond{trial_num}.trial_starttime - data.dat.cond{trial_num-1}.trial_endtime;
            elseif trial_num == 1
                data.dat.between_trial_time(trial_num) = 0;
            end
            save(data.datafile, '-append', 'data');
            
    end
end

%% post-rest (20s)

start_t = GetSecs;
data.dat.run_post_rest_start = start_t;

msgtxt = '+';
Screen('TextSize', theWindow, 500);
DrawFormattedText(theWindow, double(msgtxt), 'center', H*(1/2), white, [], [], [], 2);
Screen('Flip', theWindow);

while true
    cur_t = GetSecs;
    if cur_t - start_t >= 20
        break
    end
end
data.dat.run_post_rest_end = GetSecs;
data.dat.post_rest_duration = data.dat.run_post_rest_end - data.dat.run_post_rest_start;

% end BIOPAC
if USE_BIOPAC
    bio_trigger_range = num2str(subjrun * 0.2);
    command = 'python3 labjack.py ';
    full_command = [command bio_trigger_range];
    
    data.dat.biopac_end_trigger_s = GetSecs;
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    Screen('Flip', theWindow);
    unix(full_command)
    %     unix('python3 labjack.py 1')
    
    data.dat.biopac_end_trigger_e = GetSecs;
    data.dat.biopac_end_trigger_dur = data.dat.biopac_end_trigger_e - data.dat.biopac_end_trigger_s;
end

data.dat.run_endtime = GetSecs;
data.dat.run_total_dur = data.dat.run_endtime - data.dat.run_starttime;

save(data.datafile, '-append', 'data');


%% ==================================================================================================================================
%% MAIN : Postrun questionnaire
all_start_t = GetSecs;
data.dat.postrun_rating_timestamp = all_start_t;

post = call_ratingtypes_cl;
rating_types.postallstims = post.alltypes;
rating_types.postprompts = post.prompts;

for i = 1:numel(rating_types.postprompts)
    rating_types.postprompts{i} = double(rating_types.postprompts{i});
end
scales = rating_types.postallstims;
data.dat.post_scales = post.postalltypes{1};

Screen(theWindow, 'FillRect', bgcolor, window_rect);
Screen('TextSize', theWindow, fontsize);
Screen('Flip', theWindow); % clear screen

% Going through each scale
for scale_i = 1:numel(scales)
    
    % First introduction
    if scale_i == 1
        
        msgtxt = '잠시 후 질문들이 제시될 것입니다. 참가자께서는 잠시 기다려주시기 바랍니다.';
        DrawFormattedText(theWindow, double(msgtxt), 'center', H*(1/2), white, [], [], [], 2);
        Screen('Flip', theWindow);
        
        start_t = GetSecs;
        while true
            cur_t = GetSecs;
            if cur_t - start_t >= postrun_start_t %postrun_start_t = 2
                break
            end
        end
        
    end
    
    % Parse scales and basic setting
    scale = scales{scale_i};
    
    [lb, rb, start_center] = draw_scale_cl(scale);
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    
    start_t = GetSecs;
    data.dat = setfield(data.dat, sprintf('%s_timestamp', scale), start_t);
    
    ratetype = strcmp(rating_types.postallstims, scale);
    
    % Initial position
    if start_center
        SetMouse(2720,545); % set mouse at the center for SEPARATE DISPLAY; should use fixed values...
    else
        SetMouse(lb,H/2); % set mouse at the left
    end
    
    % Get ratings
    while true % Button
        DrawFormattedText(theWindow, rating_types.postprompts{ratetype}, 'center', H*(2/5), white, [], [], [], 2);
        
        [lb, rb, start_center] = draw_scale_cl(scale);
        
        [x,~,button] = GetMouse(theWindow);
        if x < lb; x = lb; elseif x > rb; x = rb; end
        if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        
        Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
        Screen('Flip', theWindow);
    end
    
    end_t = GetSecs;
    data.dat = setfield(data.dat, sprintf('%s_rating', scale), (x-lb)./(rb-lb));
    data.dat = setfield(data.dat, sprintf('%s_RT', scale), end_t - start_t);
    
    % Freeze the screen 0.5 second with red line
    Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
    Screen('Flip', theWindow);
    
    freeze_t = GetSecs;
    while true
        freeze_cur_t = GetSecs;
        if freeze_cur_t - freeze_t > 0.5
            break
        end
    end
    
    if scale_i == numel(scales)
        
        msgtxt = '질문이 끝났습니다.';
        DrawFormattedText(theWindow, double(msgtxt), 'center', H*(1/2), white, [], [], [], 2);
        Screen('Flip', theWindow);
        
        start_t = GetSecs;
        while true
            cur_t = GetSecs;
            if cur_t - start_t >= postrun_end_t %postrun_end_t = 2
                break
            end
        end
        
    end
    
end

all_end_t = GetSecs;
data.dat.postrun_total_RT = all_end_t - all_start_t;

save(data.datafile, '-append', 'data');


%% Closing screen

msgtxt = ['세션이 끝났습니다.\n', ...
    '참가자님은 눈을 감아주시길 바랍니다.\n', ...
    '세션을 마치려면, 실험자는 SPACE 키를 눌러주세요.'];
DrawFormattedText(theWindow, double(msgtxt), 'center', H*(1/2), white, [], [], [], 2);
Screen('Flip', theWindow);
while true % Space
    [~,~,keyCode_E] = KbCheck(Exp_key);
    if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
    if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
end

ShowCursor;
sca;
Screen('CloseAll');


%% Update markers and finish experiment

if runmarker < size(marker_mat,2) % 행렬 A의 두 번째 차원(열)의 크기를 반환 . 참가자 수 설정해둔 것보다 적으면
    runmarker = runmarker + 1;
elseif runmarker == size(marker_mat,2)
    runmarker = 1;
end

marker_mat(subjnum, :) = false; %모든 행의 요소를 0으로 만듦
marker_mat(subjnum, runmarker) = true; % 다음 runmarker만 1로 만듦

save(markerfile, '-append', 'marker_mat');

disp('Done');


end

