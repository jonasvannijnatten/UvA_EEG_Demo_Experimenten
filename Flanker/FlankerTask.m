function FlankerTask
% Flanker task made after the paper of Hsieh, Yu, Chen, Yang & Wang (2020):
% ERP correlates of a flanker task with varying levels of analytic-holistic cognitive style
% https://www.sciencedirect.com/science/article/pii/S0191886919306051#fig0002

%% set up variables
conCounter = 0;
incCounter = 0;

trial = 0;

minCorrect = 2;

data(200) = struct('ppn', [], 'condition', [], 'reactiontime', [], 'correct', []);



try
    %% Initialize figure window & Axes
    close
    fh = figure(WindowState="fullscreen");
    fh.MenuBar="none";
    ah = axes(fh); %, Visible="off");
    % ah.Position = [0 0 1 1];
    axis off
    ah.XLim = [0 1];
    ah.YLim = [0 1];

    %% Instructions
    instructionText = sprintf(['You are about to do a Flanker task.\n' ...
        'During this nine arrows will appear on screen in a 3 by 3 reactangle.\n' ...
        'You have to indicate in which direction the center arrow is pointing\n' ...
        'Press "a" for left and "l" for right.\n\n' ...
        'Press any key to start the task' ...
        ]);

    text(ah,.2,.75, instructionText, FontSize=30);
    pause
    cla

    %% start
    fixh = text(ah,.5,.5,'+',FontSize=100, Color='k', Visible='off');
    axis off
    ah.XLim = [0 1];
    ah.YLim = [0 1];

    fixh.Visible=1;
    pause(rand(1,1)*.5+1)
    fixh.Visible=0;
    %%
    hold on
    % create targer right congruent arrows
    conRXs = [.1; .1; .1; .4; .4; .4; .7; .7; .7];
    conRYs = [.75; .5; .25; .75; .5; .25; .75; .5; .25];
    conRUs = ones(9,1)*.2;
    conRVs = zeros(9,1);
    conRQuiver = quiver(ah, conRXs, conRYs, conRUs, conRVs, 0, LineWidth=10, MaxHeadSize=1, Color='k', Visible='off');

    % create target left congruent arrows
    conLXs = [.3; .3; .3; .6; .6; .6; .9; .9; .9];
    conLYs = [.75; .5; .25; .75; .5; .25; .75; .5; .25];
    conLUs = ones(9,1)*-.2;
    conLVs = zeros(9,1);
    conLQuiver = quiver(conLXs, conLYs, conLUs, conLVs, 0, LineWidth=10, MaxHeadSize=1, Color='k', Visible='off');

    % create target right incongruent arrows
    incRXs = [.3; .3; .3; .6; .4; .6; .9; .9; .9];
    incRYs = [.75; .5; .25; .75; .5; .25; .75; .5; .25];
    incRUs = ones(9,1)*-.2; incRUs(5)=-incRUs(5);
    incRVs = zeros(9,1);
    incRQuiver = quiver(incRXs, incRYs, incRUs, incRVs, 0, LineWidth=10, MaxHeadSize=1, Color='k', Visible='off');

    % create target left incongruent arrows
    incLXs = [.1; .1; .1; .4; .6; .4; .7; .7; .7];
    incLYs = [.75; .5; .25; .75; .5; .25; .75; .5; .25];
    incLUs = ones(9,1)*.2; incLUs(5)=-incLUs(5);
    incLVs = zeros(9,1);
    incLQuiver = quiver(incLXs, incLYs, incLUs, incLVs, 0, LineWidth=10, MaxHeadSize=1, Color='k', Visible='off');

    arrowHandles = [conRQuiver conLQuiver incRQuiver incLQuiver];

    axis off
    ah.XLim = [0 1];
    ah.YLim = [0 1];


    for itrial = 1:10
        condition = randi(4);
        arrowHandles(condition).Visible = 1;
        figure(fh)
        pause(.2)
        arrowHandles(condition).Visible = 0;
        fixh.Visible=1;
        pause
        pause(rand(1,1)*.5+1)
        fixh.Visible=0;
    end

 
    cla
    text(ah,.42,.5,'Done!', FontSize=60)
    pause(.5)
    close(fh)

catch ME
    close
    ME.rethrow
end

