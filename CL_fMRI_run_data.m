%% Save run order.

addpath(genpath(fileparts(mfilename('fullpath'))));

runs = {'run1' 'run2' 'run3' 'run4'};
cond = {'high-cue', 'high-nocue','low-cue','low-nocue'};
durs = repmat(774,1,4); % secs 스칼라 값 714를 가지는 배열을 생성하고, 이 배열을 1행 4열로 반복
n_subj = 12; %참가자 수
n_run = numel(runs);


%% make the marker matfile
marker_mat = false(n_subj, n_run); %참가자별로 run 실행 유무가 행으로 저장되어 있음
marker_mat(:, 1) = true;
 
save('CL_fMRI_run_data.mat', 'runs', 'durs', 'cond', 'marker_mat');


