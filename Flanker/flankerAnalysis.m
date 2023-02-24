% script that calculates the average reaction time of all correct and
% congruent trials

RT = [data(:).reactiontime];
correct = [data(:).correct];
condition = {data(:).condition};

condition_idx = strcmp(condition, 'congruent');

meanRTcongCorr = mean(RT(correct & condition_idx));