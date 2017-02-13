function b=makeVBARegressors(b,out)
%Depending upon the options if we tracked PE or not you will need to select
%the correct index of the out.suffStat.muX array.

if out.options.inF.track_pe==1
    mu_ij = out.suffStat.muX(out.options.inF.nbasis+1:out.options.inF.nbasis*2,:)';
else
    mu_ij = out.suffStat.muX';
end
gaussmat = out.options.inG.gaussmat;
ntimesteps = out.options.inF.ntimesteps;
trials = length(b.stim_OnsetTime);

%To get the value of each timestep for each trial
for i = 1:trials
    v_jt=mu_ij(i,:)'*ones(1,ntimesteps) .* gaussmat; %Its not i+1 because we skip the first trial in the vba script right???
    v_func = sum(v_jt);
    v_it(i,:) = v_func;
end

v_it = v_it';
b.out.v_it = v_it;
b.out.vmax = max(v_it);
b.out.v_chosen = v_it(logical(out.y));
b.out.v_chosen_standardized = zscore(b.out.v_chosen);