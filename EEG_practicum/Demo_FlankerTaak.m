function Demo_FlankerTaak(port, nroftrials, instructionDuration, breakTrials, breakDuration)
% function for a Flanker task using arrows pointing left and right.
% Flanker task made after the paper of Hsieh, Yu, Chen, Yang & Wang (2020):
% ERP correlates of a flanker task with varying levels of analytic-holistic cognitive style
% https://www.sciencedirect.com/science/article/pii/S0191886919306051#fig0002

% run the function without input for test mode. Provide input for a real
% experiment
if nargin == 0
    port = 0;
    nroftrials = 10;
    instructionDuration = 2;
    breakTrials = 5;
    breakDuration = 5;
    serialConnected = 0;
end

% define filename to store data, even in case of an error
filename = "Flanker_Data_" +  string(datetime('today','Format','yyyyMMdd'));

try
    close
%     ppn = input('please provide a subject nr: ');
%     while isempty(ppn) || ~isnumeric(ppn)
%         ppn = input('please provide a subject nr: ');
%     end

    %% set up variables
    data(nroftrials) = struct('condition', [], 'RT', [], 'key', [], 'correct', []);

    %% Initialize figure window & Axes
    fh = figure(WindowState="fullscreen");
    fh.MenuBar="none";
    ah = axes(fh); %, Visible="off");
    % ah.Position = [0 0 1 1];
    axis off
    ah.XLim = [0 1];
    ah.YLim = [0 1];

    %% Instructions
    % create general instruction text
    instructionText = sprintf(['You are about to do a Flanker task.\n' ...
        'The task will take about 10 minutes. There will be a break every 25 trials.\n\n' ...
        'During this task nine arrows will appear on screen in a 3 by 3 reactangle.\n' ...
        'You have to indicate in which direction the center arrow is pointing.\n' ...
        'The direction of the other arrows is irrelevant.\n\n' ...
        'When the center arrow points towards the LEFT, press "a" \n' ...
        'When the center arrow points towards the RIGHT, press "l" \n\n' ...
        ]);
    % plot the instruction
    th = text(ah,.5,.75, instructionText, FontSize=20, VerticalAlignment="top", HorizontalAlignment="center");
    % create a countdown loop from 10 to 1
    for countdown = instructionDuration:-1:1
        % print the countdown value under the instructions
        th.String = sprintf([instructionText '%d'], countdown);
        % wait one second before updating the countdown
        pause(1)
        % bring the figure window to the front
        figure(fh)
    end
    % replace countdown with the instruction to press a key
    th.String = sprintf([instructionText 'Press any key to start the task']);
    % wait for user key press
    pause
    th.Visible = 0;

    %% Initialize all the screens with handles but keep them invisible
    % create the fixation cross with handle
    fixh = text(ah,.5,.5,'+',FontSize=100, Color='k', Visible='off', ...
        HorizontalAlignment='center', VerticalAlignment='middle');

    %%
    hold on
    % create targer right congruent arrows
    conRXs = [.1; .1; .1; .4; .4; .4; .7; .7; .7];
    conRYs = [.75; .5; .25; .75; .5; .25; .75; .5; .25];
    conRUs = ones(9,1)*.2;
    conRVs = zeros(9,1);
    conRQuiver = quiver(ah, conRXs, conRYs, conRUs, conRVs, 0, ...
        LineWidth=10, MaxHeadSize=1, Color='k', Visible='off');

    % create target left congruent arrows
    conLXs = [.3; .3; .3; .6; .6; .6; .9; .9; .9];
    conLYs = [.75; .5; .25; .75; .5; .25; .75; .5; .25];
    conLUs = ones(9,1)*-.2;
    conLVs = zeros(9,1);
    conLQuiver = quiver(conLXs, conLYs, conLUs, conLVs, 0, ...
        LineWidth=10, MaxHeadSize=1, Color='k', Visible='off');

    % create target right incongruent arrows
    incRXs = [.3; .3; .3; .6; .4; .6; .9; .9; .9];
    incRYs = [.75; .5; .25; .75; .5; .25; .75; .5; .25];
    incRUs = ones(9,1)*-.2; incRUs(5)=-incRUs(5);
    incRVs = zeros(9,1);
    incRQuiver = quiver(incRXs, incRYs, incRUs, incRVs, 0, ...
        LineWidth=10, MaxHeadSize=1, Color='k', Visible='off');

    % create target left incongruent arrows
    incLXs = [.1; .1; .1; .4; .6; .4; .7; .7; .7];
    incLYs = [.75; .5; .25; .75; .5; .25; .75; .5; .25];
    incLUs = ones(9,1)*.2; incLUs(5)=-incLUs(5);
    incLVs = zeros(9,1);
    incLQuiver = quiver(incLXs, incLYs, incLUs, incLVs, 0, ...
        LineWidth=10, MaxHeadSize=1, Color='k', Visible='off');

    % save the handles to all of the different stimuli into one variable.
    arrowHandles = [conRQuiver conLQuiver incRQuiver incLQuiver];

    % hide the axes and fix the X & Y limits to [0 1]
    axis off
    ah.XLim = [0 1];
    ah.YLim = [0 1];

    % make the fixation cross visible
    fixh.Visible=1;

    %% loop over trial
    for itrial = 1:nroftrials
        % randomly pick one of four conditions
        condition = randi(4);
        % 1 second pre stimulus
        pause(1)
        % make fixation cross invisible
        fixh.Visible=0;
        % show the stimulus (arrows)
        arrowHandles(condition).Visible = 1;
        % start measuring reaction time
        tic
        % send out a serial marker of the value 1, 2, 3 or 4, corresponding
        % with the condition
        if port~=0
            port.write(30 + condition, "uint8")
        end
        % call the figure function to bring the figure to the foreground in
        % case the computer accidentally changed to another window.
        figure(fh)
        % show the arrows for 200 ms
        pause(.2)
        % make the arrows invisible again, and show the fixation cross.
        arrowHandles(condition).Visible = 0;
        fixh.Visible=1;
        figure(fh)
        % wait for the user to respond
        pause
        % get reaction time
        RT = toc;
        % save the reaction time, keypress, correctness and the condition.
        data(itrial).condition = condition;
        data(itrial).RT = RT;
        key = fh.get.CurrentCharacter;
        data(itrial).key = key;
        % If the center arrow points to the right (condition 1 & 3), then
        % the correct response is 'l'.
        % If the center arrow points to the left  (condition 2 & 4), then
        % the correct response is 'a'.
        if ismember(condition, [1 3]) && strcmpi(key, 'l')
            data(itrial).correct = 1;
        elseif ismember(condition, [2 4]) && strcmpi(key, 'a')
            data(itrial).correct = 1;
        else
            data(itrial).correct = 0;
        end

        % add an inter-trial-interval of 1-2 seconds
        pause(rand(1))

        %% break every 25 trials
        if itrial < nroftrials && (mod(itrial,breakTrials) == 0)
            % hide the fixation cross
            fixh.Visible=0;
            breakInstructions = sprintf([ ...
                'You are at trial %d of %d of the experiment.\n' ...
                'Try to sit as still as possible during the task and blink in between trials.\n' ...
                'Take a short break before you continue.\n\n' ...
                ] , itrial, nroftrials);
            th.String = breakInstructions;
            th.Visible = 1;

            % have a break of at least 5 seconds with coutdown
            for countdown = breakDuration:-1:1
                th.String = sprintf([breakInstructions '%d' ...
                ], countdown);

                % pause 1 second before updating the break countdown
                pause(1)
                % call the figure function to bring the figure to the
                % foreground in case the computer accidentally changed to
                % another window.
                figure(fh)
            end
            % after the countdown, wait for the participant to continue
            th.String = sprintf([breakInstructions ...
                'Press any key to continue' ...
                ] , itrial, nroftrials);
            % wait until the participant presses a key
            figure(fh)
            pause
            th.Visible = 0;    
            
            % make the fixation cross visible
            fixh.Visible=1;
            % pause for 1-2 seconds
            pause(rand(1))
        end

    end
    cla
%     [data.ppn] = deal(ppn);
    save(filename,'data')
    endMessage = sprintf(['You are done with the experiment.\n' ...
        'Thank you for participating.\n\n' ...
        'Press any key to close this window.']);
    text(ah,.42,.5,endMessage, FontSize=30)
    pause
    close(fh)
catch ME
    if exist('fh','var') && isvalid(fh); close(fh); end
    if exist('port','var') && port~=0; port.delete; end
    filename = filename + "_ERROR";
    save(filename,'data')
    opts.WindowStyle = 'modal';
    opts.Interpreter = 'tex';
    message = sprintf('Oops! Something went wrong :(.\n See the command window for more information.');
    warndlg(['\fontsize{20}' message], 'Error',opts)
    ME.rethrow
end

%% Data analysis
% select data file to load
% uiload 

% get data as variables from the struct
RT = [data(:).RT]';
correct = [data(:).correct]';
condition = [data(:).condition]';

% Get the hit trials for the congruent and incongruent conditions
conHits = correct & ismember(condition, [1 2]) & RT<5;
incHits = correct & ismember(condition, [3 4]) & RT<5;

% get the reaction times of both conditions
ConRT = RT(conHits);
IncRT = RT(incHits);

% calculate mean and SD
meanCon = mean(ConRT);
meanInc = mean(IncRT);
sdCon = std(ConRT);
sdInc = std(IncRT);

figure
subplot(1,2,1)
histogram(ConRT, 10)
hold on
histogram(IncRT, 10)
legend({'Congruent','Incongruent'})
xlabel('reaction times (sec)')
ylabel('count')
% boxplot([ConRT; IncRT],[repmat("Congruent",[length(ConRT),1]); repmat("Incongruent", [length(IncRT),1])])
% title('Reaction times on the Flanker Task')
% xlabel("Condition")
% ylabel("Reaction time (sec)")
hold off
subplot(1,2,2)
stats = sprintf("Mean and standard deviation\n of the reaction times:\n" + ...
    "Congruent: %2.3fsec (%2.3f)\n" + ...
    "Incongruent: %2.3fsec (%2.3f)\n", ...
    meanCon, sdCon, meanInc, sdInc);
text(.1,.7,stats)
axis off