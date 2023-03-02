% script that calculates the average reaction time of all correct and
% congruent trials

uiload

%%
RT = [data(:).RT]';
correct = [data(:).correct]';
condition = [data(:).condition]';

condition_idx = ismember(condition, [1 2]);

meanRTcongCorr = mean(RT(correct & condition_idx));

conHits = correct & ismember(condition, [1 2]);
incHits = correct & ismember(condition, [3 4]);

ConRT = RT(conHits);
IncRT = RT(incHits);

histogram(ConRT, 10)
hold on
histogram(IncRT, 10)



