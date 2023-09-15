%% Go-NoG0 analysis

uiopen();

celldata = struct2cell(data);

RT = [data.reactiontime];

target = [data.tone]';

key = char(data.keypressed);
key = ismember(key, 'space','rows');

hits    = target==1 & key==1;
misses  = target==1 & key==0;
FAs     = target==0 & key==1;
CRs     = target==0 & key==0;

histogram(RT(hits))
histogram(RT(FAs))


