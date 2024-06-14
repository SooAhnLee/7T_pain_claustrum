function [subjID, basedir, ts] = CL_fMRI_paintask_subinfo

[~, hostname] = system('hostname');
switch strtrim(hostname)
    case '7T-MRIui-Mac-Pro.local' % 7T MAC
        basedir = '/Users/7t_mri/Documents/7TCL/7TCL_codes';
        outputdev.HostAudioAPIName = 'Core Audio';
        outputdev.DeviceName = '내장 출력';
end

cd(basedir);
addpath(genpath(basedir));

subjID = upper(input('\nSubject ID (e.g., CL001_HGD)? ', 's')); %test 시에도 CL001_TEST

% load or make ts file
ts_dir = fullfile(basedir, 'trial_sequence'); %부분들을 결합하여 완전한 파일 경로를 생성(아직 만든 건 아님)
while true
    ts_fname = filenames(fullfile(ts_dir, [subjID '*.mat']), 'char');% 이거 돌리기 전에 mkdir('trial_sequence') 해야 함 .파일 이름에 subject ID이 들어가는 것들을 찾음
    if size(ts_fname,1) == 1
        if contains(ts_fname, 'no matches found') % 만약에 해당 이름의 ps 파일이 없으면
            CL_generate_trial_sequence(subjID, basedir); % make ts
        else
            load(ts_fname); break;
        end
    elseif size(ts_fname,1)>1
        error('There are more than one ts file. Please check and delete the wrong files.')
    elseif size(ts_fname,1) == 0
        ts = CL_generate_trial_sequence(subjID, basedir); % make ts
    end
end

end