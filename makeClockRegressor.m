function [out]=makeClockRegressor(id,fpath,out)

try out; catch; out=0; end

if ~ischar(id)
    id = num2str(id);
end

%Grab the newfile name based off id
fpath = char(fpath);
T = readtable(fpath);

fprintf('\nCreating subject specific regressor files\n\n');

%Local data storage
data_dump_str=sprintf('regs/%s/%s',id,id);
sub_folder=sprintf('regs/%s',id);
 
if ~exist(sub_folder,'file')
    mkdir(sub_folder)
    fprintf('Creating id specific reg folder in: %s\n\n',sub_folder);
end

b.id = id; %set id
b.regs = [];
n_t = length(T.trial); %Number of trials
b.total_blocks = max(T.run);

b.trials_per_block = n_t/b.total_blocks;

firstfix_Onset = T.clock_onset(1); %very first time point
b.trial_index = 1:b.trials_per_block:b.total_blocks*b.trials_per_block;
b.stim_OnsetTime = T.clock_onset;
b.stim_RT = T.rt/1000; %Get in seconds
b.feedback_OnsetTime = T.feedback_onset;
b.feedback_OffsetTime = T.iti_onset;
%Create choice and feedback regressor
b.choice_and_feedback_censor = ~(T.rt==0); %Include these trials...
b.itionset = T.iti_onset;

%Create volume-wise censor regressor
b=createClockCensorRegressor(b);

%Return vba_regressors data
if isstruct(out)
    b=makeVBARegressors(b,out);
end

%% Pre-allocate memory for regressor time structures
decision.event_beg=zeros(b.trials_per_block,b.total_blocks);
decision.event_end=zeros(b.trials_per_block,b.total_blocks);
feedback.event_beg=zeros(b.trials_per_block,b.total_blocks);
feedback.event_end=zeros(b.trials_per_block,b.total_blocks);




%Like shark task I don't think you need to subject the first onset Time
%Matlab has received the scanner pulse and regesters in real time when the
%clock has first appeared...
for block= 1:b.total_blocks
    
    %Set up trial ranges
    trial_index_1 = b.trial_index(block);
    trial_index_2 = trial_index_1 + b.trials_per_block-1;
    
    %for decision onset to response (motor response)
    decision.event_beg(:,block) = b.stim_OnsetTime(trial_index_1:trial_index_2);
    %decision.event_beg(:,block) = b.stim_OnsetTime(trial_index_1:trial_index_2)-firstfix_Onset;
    %decision.event_end(:,block) = b.stim_OffsetTime(trial_index_1:trial_index_2)-firstfix_Onset;
    %decision.event_end(:,block) = b.stim_OnsetTime(trial_index_1:trial_index_2)-firstfix_Onset + b.stim_RT(trial_index_1:trial_index_2); %Duration should be length of RT
    decision.event_end(:,block) = b.stim_OnsetTime(trial_index_1:trial_index_2) + b.stim_RT(trial_index_1:trial_index_2); %Duration should be length of RT
    
    %for feedback onset to offset
    feedback.event_beg(:,block) = b.feedback_OnsetTime(trial_index_1:trial_index_2);
    %feedback.event_beg(:,block) = b.feedback_OnsetTime(trial_index_1:trial_index_2)-firstfix_Onset;
    %feedback.event_end(:,block) = b.feedback_OnsetTime(trial_index_1:trial_index_2)-firstfix_Onset+stick; %Just make the durations all a 1 second stick
    %feedback.event_end(:,block) = b.feedback_OffsetTime(trial_index_1:trial_index_2)-firstfix_Onset;
    feedback.event_end(:,block) = b.feedback_OffsetTime(trial_index_1:trial_index_2);
    
%     trial.event_beg(:,block) = b.stim_OnsetTime(trial_index_1:trial_index_2)-firstfix_Onset;
%     trial.event_end(:,block) = b.feedback_OffsetTime-firstfix_Onset; %From stim onset to feedback offset
    trial.event_beg(:,block) = b.stim_OnsetTime(trial_index_1:trial_index_2);
    trial.event_end(:,block) = b.feedback_OffsetTime; %From stim onset to feedback offset
    
    if block<b.total_blocks
        %Update the first fix onset to be the first trial in the next block
        firstfix_Onset = b.stim_OnsetTime(trial_index_2+1);
    end
end

%Reshape into single vector
decision.event_beg=reshape(decision.event_beg,[n_t,1]);
decision.event_end=reshape(decision.event_end,[n_t,1]);
feedback.event_beg=reshape(feedback.event_beg,[n_t,1]);
feedback.event_end=reshape(feedback.event_end,[n_t,1]);
trial.event_beg=reshape(feedback.event_beg,[n_t,1]);
trial.event_end=reshape(feedback.event_end,[n_t,1]);

%% Decision aligned Regressors
%Decision stick
dec_stick = .01; %100 ms
[b.stim_times.resp_fsl,b.stim_times.resp_spmg]=write3Ddeconv_startTimes(data_dump_str,decision.event_beg,decision.event_end,'decision_Times',b.choice_and_feedback_censor,0,b);
[b.stim_times.resp_fsl,b.stim_times.resp_spmg]=write3Ddeconv_startTimes(data_dump_str,decision.event_beg,decision.event_beg + dec_stick,'decision_TimesWithStick',b.choice_and_feedback_censor,0,b);

%Motor -- same as decision_Times
[b.stim_times.resp_fsl,b.stim_times.resp_spmg]=write3Ddeconv_startTimes(data_dump_str,decision.event_beg,decision.event_end,'right',b.choice_and_feedback_censor,0,b);

%Value
[b.stim_times.resp_fsl,b.stim_times.resp_spmg]=write3Ddeconv_startTimes(data_dump_str,decision.event_beg,decision.event_end,'valueDecisionAligned',b.out.vmax',0,b);
[b.stim_times.resp_fsl,b.stim_times.resp_spmg]=write3Ddeconv_startTimes(data_dump_str,decision.event_beg,decision.event_end,'valueChosen',b.out.v_chosen,0,b);
[b.stim_times.resp_fsl,b.stim_times.resp_spmg]=write3Ddeconv_startTimes(data_dump_str,decision.event_beg,decision.event_end,'valueChosenStandardized',b.out.v_chosen_standardized,0,b);

%% Feedback aligned Regressors
[b.stim_times.feedback_fsl,b.stim_times.feedback_spmg]=write3Ddeconv_startTimes(data_dump_str,feedback.event_beg,feedback.event_end,'feedback_Times',b.choice_and_feedback_censor,0,b);

% Reward-Stake aligned with Feedback
[b.stim_times.rew_stake,b.stim_times.rew_stake]=write3Ddeconv_startTimes(data_dump_str,feedback.event_beg,feedback.event_end,'rewardMagnitudeFeedbackAligned',T.score,0,b);

% Win/Loss aligned with Feedback win = 1 loss = 0
[b.stim_times.rew_stake,b.stim_times.rew_stake]=write3Ddeconv_startTimes(data_dump_str,feedback.event_beg,feedback.event_end,'winLossFeedbackAligned',T.score>0,0,b); 

%% Censor file
gdlmwrite([data_dump_str 'clockCensorOnly.regs'],b.hrf_regs.to_censor');


function [x,y]=write3Ddeconv_startTimes(file_loc,event_beg,event_end,fname,modulator,noFSL,b)
% Function will write FSL styled regressors in dat files for fMRI analysis
% Inputs:
% file_loc: file location (str)
% event_beg: the time in miliseconds of the event beginning
% event_end: the time in milliseconds of the event ending
% fname: the file names
% censor: the censor vector or parametric value vector depending on the regressor
% noFSL either to write a FSL file or a different single line version (see 3dDeconvolve help for more info)
% trial_index: the position of when a new block starts (trialwise)

if nargin <6
    %censor = 1;
    noFSL=0;
end
format long
x(:,1) = event_beg';
x(:,2) = event_end'-event_beg';
%x=x./1000; %Convert to seconds (not for clock already in seconds)
x(:,3) = ones(length(x),1).*modulator; %originally was modulator'
%write the -stim_times_FSL

if ~noFSL
    %Save to regs folder
    %dlmwrite([file_loc fname '.dat'],x,'delimiter','\t','precision','%.6f')
    c = asterisk(x,b); %Add in asterisks and clean up data
    dlmcell([file_loc fname '.dat'],c,'delimiter','\t')
    %dlmcell([data_dump_str filename],c,'\t');
    y=0;
else
    %write the -stim_times file
    fname = [fname '_noFSL'];
    y = x(logical(x(:,3)),1)';
    %Quick fix hack for just first ten trials troubleshoot SPMG2
    %y = y(1:10);
    dlmwrite([file_loc fname '.dat'],y,'delimiter','\t','precision','%.6f')
end
return

function c = asterisk(x,b)
%adding asterisk to existing .dat files also removes any nans present

c=[];
ast = {'*', '*', '*'};
for i = 1:length(b.trial_index)
    %Set up trial ranges
    trial_index_1 = b.trial_index(i);
    trial_index_2 = trial_index_1 + b.trials_per_block-1;
    block_data = num2cell(x(trial_index_1: trial_index_2,:));
    if i<length(b.trial_index)
        c = [c; block_data; ast];
    else
        c = [c; block_data;];
    end
end

%clean up any nans
%fh = @(y) all(isnan(y(:)));
c = c(~any(cellfun(@isnan,c),2),:);
%c(cellfun(fh, c)) = [];
%Check on c!

return
