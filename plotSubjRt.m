function plotSubjRt(id_list)
%Quick function to plot everyones rts against contingency

%vars
n_trials = 120; %per run
max_rt = 5000; %in ms

for i = 1:length(id_list)
    
    id = id_list(i);
    %Grab the newfile name based off id
    T = readtable(sprintf('subjects/fMRIEmoClockSupplement_%d_1_tc_tcExport.csv',id));
    figure(id)
    clf;
    %Which was the first contingency
    if strcmpi(T.rewFunc(1),'dev')
        contingency_run1 = [repmat(1500,40,1); repmat(4500,40,1); repmat(1500,40,1)];
        contingency_run2 = [repmat(4500,40,1); repmat(1500,40,1); repmat(4500,40,1)];
    else
        contingency_run1 = [repmat(4500,40,1); repmat(1500,40,1); repmat(4500,40,1)];
        contingency_run2 = [repmat(1500,40,1); repmat(4500,40,1); repmat(1500,40,1)];
    end
    
    %Plot each sunject individually
    subplot(2,1,1)
    plot(1:n_trials,contingency_run1)
    hold on
    plot(1:n_trials,T.rt(1:n_trials))
    axis([0 n_trials 0 max_rt])
    title('Run 1')
    subplot(2,1,2)
    plot(1:n_trials,contingency_run2)
    hold on
    plot(1:n_trials,T.rt(n_trials+1:n_trials*2))
    axis([0 n_trials 0 max_rt])
    title('Run 2')
end