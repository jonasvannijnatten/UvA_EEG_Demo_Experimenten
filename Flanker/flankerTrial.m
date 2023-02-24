function [correct,reactionTime] = flankerTrial(condition)
%flankerTrial runs one trial of a Eriksen flanker task  
% receives the condition (congruent or incongruent) as an input
% gives correctness and reactiontime as an output

%fixation cross
put_symbol_inFigure([.5,.5], '+', 'k') % or plot(.5,.5, '+k')
pause(1)
cla

% chose flanker 
flanker = pickone({'H','C'});

% chose target
if strcmp(flanker, 'H') && strcmp(condition, 'congruent')
    target = 'K';
elseif strcmp(flanker, 'C') && strcmp(condition, 'congruent')
    target = 'S';
elseif strcmp(flanker, 'H') && strcmp(condition, 'incongruent')
    target = 'C';
else
    target = 'H';
end

    
% plot distractors
for xCoordinate = [.35,.4,.45,.55,.6,.65]
    put_symbol_inFigure([xCoordinate, .5], flanker, 'k')
end
% plot target
put_symbol_inFigure([.5,.5], target, 'k')


% measure responses
tic
pause
reactionTime = toc;
key = get(gcf, 'CurrentCharacter');

% calculate correctness given button and target: HK-> a, CS-> l
if (strcmp(target, 'H') || strcmp(target, 'K')) && strcmpi(key, 'a')
    correct = 1;
elseif (strcmp(target, 'S') || strcmp(target, 'C')) && strcmpi(key, 'l')
    correct = 1;
else 
    correct = 0;
end

cla

end

