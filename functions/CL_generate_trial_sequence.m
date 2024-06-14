function ts = CL_generate_trial_sequence(subjID, basedir)

ts_dir = fullfile(basedir,'trial_sequence');
ts.subj_id = subjID;

%% cond order in each run
rng('default');
rng('shuffle');
% 주어진 조건
conditions = {'high-cue', 'high-nocue', 'low-cue', 'low-nocue'};

repetitions = 3; % 각 조건당 반복 횟수

ts.cond_run_trial=cell(4,12);
for j = 1:4
    % 각 조건을 반복하여 리스트 생성
    condition_list = repelem(conditions, repetitions);
    
    % 조건 리스트를 랜덤하게 섞음
    cond_order = condition_list(randperm(length(condition_list)));
    ts.cond_run_trial(j,:) = cond_order(:);
end

%% heat trial table
ts.heat_run_trial = ts.cond_run_trial;
ts.heat_run_trial(contains(ts.heat_run_trial,'high')) = {'47'};
ts.heat_run_trial(contains(ts.heat_run_trial,'low')) = {'44.5'};

%% heat session jitter order
% Random generation for stimulus parameters and jittering
rng('default');
rng('shuffle');
numbers=randperm(5);

ts.jitter_index_list=NaN(4,12);

for j = 1:4
    % 각 조건을 반복하여 리스트 생성
    jitter_kind = horzcat(numbers,numbers,numbers(1:2));
    % 조건 리스트를 랜덤하게 섞음
    ts.jitter_index_list(j,:) = jitter_kind(randperm(length(jitter_kind)));
end

%% save ts
nowtime = clock;
subjdate = sprintf('%.2d%.2d%.2d', nowtime(1), nowtime(2), nowtime(3));

savename = fullfile(ts_dir, [subjID, '_', subjdate, '.mat']);
save(savename, 'ts'); %작업 공간 안에 있는 변수 'ts'를 fullfile로 저장함.

end
