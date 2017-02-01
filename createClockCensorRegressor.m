function b=createClockCensorRegressor(b)
%This is a file of 1s and 0s, indicating which
%time points are to be included (1) and which are
%to be excluded (0).


frequency_scale_hz = 10;
%bin_size = 1/frequency_scale_hz; %I believe we are in seconds?
bin_size = 1/frequency_scale_hz*1000;
scan_tr = .6;

%If we didn't already grab the subjects volume run length do it now
file_str = sprintf('subjects/%s/%s_block_lengh.mat',num2str(b.id),num2str(b.id));

if ~exist(file_str,'file')
    b=findBlockLength(b);
    block_length = b.block_length; %This is subject specific create that function to grab this from 3dinfo
    save(file_str,'block_length')
else
    load(file_str)
end

%     b=findBlockLength(b);
%     block_length = b.block_length; %This is subject specific create that function to grab this from 3dinfo
%     save(file_str,'block_length')

%This "censor" was initally meant to be the modulator of the decision and
%feedback regressors, not the logical array that should be fed into the
%createSimpleRegressor script. That logical array shouls be 0 for all
%trials not missed and 1 for trials missed.
b.trials_to_censor = ~b.choice_and_feedback_censor; %Includes rt == 0

%We need to convert the times to ms
stim_OnsetTime = b.stim_OnsetTime.*1000;
feedback_OffsetTime = b.feedback_OffsetTime.*1000;
%stim_NextOnsetTime=[stim_OnsetTime(2:end); (stim_OnsetTime(end)+b.stim_RT(end)*1000)]; %
endOfTrial = b.itionset.*1000;


for block_n = 1:b.total_blocks
    %Set up trial ranges
    trial_index_1 = b.trial_index(block_n);
    trial_index_2 = trial_index_1 + b.trials_per_block-1;
    
    %Create epoch eindow
    epoch_window = stim_OnsetTime(trial_index_1:trial_index_2):bin_size:stim_OnsetTime(trial_index_1:trial_index_2)+scan_tr*block_length(block_n)*1000;
    %epoch_window3 = stim_OnsetTime(trial_index_1):bin_size:stim_OnsetTime(trial_index_1)+scan_tr*block_length(block_n)*1000; % Another perhaps more simple way to do the same thing?
    %epoch_window = stim_OnsetTime(b.trial_index(block_n)):bin_size:(feedback_OffsetTime(b.trials_per_block + b.trial_index(block_n) -1));
    event_beg = stim_OnsetTime(trial_index_1:trial_index_2); event_end = endOfTrial(trial_index_1:trial_index_2);
    
    
    tmp_reg.(['regressors' num2str(block_n)]).to_censor = ...
        createSimpleRegressor(event_beg, event_end, epoch_window, b.trials_to_censor(trial_index_1:trial_index_2));
    tmp_reg.(['regressors' num2str(block_n)]).to_censor = ones(size(tmp_reg.(['regressors' num2str(block_n)]).to_censor)) - tmp_reg.(['regressors' num2str(block_n)]).to_censor; %Goes from logical to double
    
    
    % NB: the first 5s are censored because they capture HRF to events
    % preceding the first trial
    tmp_reg.(['hrfreg' num2str(block_n)]).to_censor = ...
        gsresample( ...
        [zeros(50,1)' tmp_reg.(['regressors' num2str(block_n)]).to_censor(1:end-51)], ...
        10,1./scan_tr);
    
end

fnm = fieldnames(tmp_reg.regressors1)';
%Added switch case for subjects with irregular trials
ct=1:length(fnm);
switch b.total_blocks
    case 1
        for ct=1:length(fnm)
            b.hrf_regs.(fnm{ct}) = [tmp_reg.hrfreg1.(fnm{ct})];
        end
    case 2
        for ct=1:length(fnm)
            b.hrf_regs.(fnm{ct}) = [tmp_reg.hrfreg1.(fnm{ct}) tmp_reg.hrfreg2.(fnm{ct})];
        end
    case 3
        for ct=1:length(fnm)
            b.hrf_regs.(fnm{ct}) = [tmp_reg.hrfreg1.(fnm{ct}) tmp_reg.hrfreg2.(fnm{ct}) tmp_reg.hrfreg3.(fnm{ct})];
        end
    otherwise
        disp('Error occured somewhere')
end

b.hrf_regs.to_censor = 1-(ceil(b.hrf_regs.to_censor));
b.hrf_regs.to_censor = ~b.hrf_regs.to_censor;



function foo = createSimpleRegressor(event_begin,event_end,epoch_window,conditional_trials)
% this was not a problem earlier, but for some reason it is now: find indices that would
% result in a negative value and set them both to 0
qbz = ( event_begin == 0 ); qez = ( event_end == 0 );
event_begin( qbz | qez ) = 0; event_end( qbz | qez ) = 0;

% check if optional censoring variable was used
if(~exist('conditional_trials','var') || isempty(conditional_trials))
    conditional_trials = true(length(event_begin),1);
elseif(~islogical(conditional_trials))
    % needs to be logical format to index cells
    conditional_trials = logical(conditional_trials);
end

% this only happened recently, but it's weird
if(any((event_end(conditional_trials)-event_begin(conditional_trials)) < 0))
    error('MATLAB:bandit_fmri:time_travel','feedback is apparently received before RT');
end

% create epoch windows for each trial
epoch = arrayfun(@(a,b) a:b,event_begin,event_end,'UniformOutput',false);

% for each "epoch" (array of event_begin -> event_end), count events
% per_event_histcs = cellfun(@(h) histc(h,epoch_window),epoch(conditional_trials),'UniformOutput',false);
% foo = logical(sum(cell2mat(per_event_histcs),1));

foo = zeros(size(epoch_window));

for n = 1:numel(epoch)
    if(conditional_trials(n))
        foo = logical(foo + histc(epoch{n},epoch_window));
    end
end


% createAndCatRegs(event_begin,event_end,epoch_window);

return

function b=findBlockLength(b)
%Will use expect script to find subject specific block length for specific
%run

fprintf('Logging into Thorndike now....\n')

%How many runs
for run = 1:b.total_blocks
    
    %set command string
    %cmd_str = sprintf('"C:/Users/emtre/OneDrive/Documents/GitHub/explore_clock/expectTest.exp %s %s"', num2str(b.id),num2str(run));
    %JW: Let's make sure the expect scripts are in a dir called aux scripts
    %from now on
    cmd_str = sprintf('"aux_scripts/expectTest.exp %s %s"', num2str(b.id),num2str(run));
    
    
    %set command string based on which directory you are currently in (explore_clock or bpd_clock)
    %     cdir= cd;
    %     if strcmp(cdir,'C:\Users\emtre\OneDrive\Documents\GitHub\bpd_clock')
    %         cmd_str = sprintf('"C:/Users/emtre/OneDrive/Documents/GitHub/bpd_clock/expectTest.exp %s %s"', num2str(b.id),num2str(run));
    %     else
    %          cmd_str = sprintf('"C:/Users/emtre/OneDrive/Documents/GitHub/explore_clock/expectTest.exp %s %s"', num2str(b.id),num2str(run));
    %     end
    %cmd_str = sprintf('"c:/kod/explore_clock/aux_scripts/expectTest.exp %s %s"', num2str(b.id),num2str(run));
    
    %set cygwin path string
    cygwin_path_sting = 'E:\cygwin\bin\bash --login -c ';
    
    %Run it kick out if failed
    fprintf('Grabbing volumes....\n')
    [status,cmd_out]=system([cygwin_path_sting cmd_str]);
    if status==1
        error('Connection to Thorndike failed :(')
    end
    
    %Grab the volume number
    reg_out = regexp(cmd_out,'(?<=wc -l\s+)[0-9]{3,4}','match');
    
    %Make reg out a number
    b.block_length(run)=str2double(reg_out{1});
end