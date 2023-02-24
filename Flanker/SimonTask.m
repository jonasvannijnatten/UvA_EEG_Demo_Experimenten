% function SimonTask
% Simon task made after the paper of Praamstra & Oostenveld (2003)
% https://www.sciencedirect.com/science/article/pii/S0926641002002860?via%3Dihub#FIG1
%

%% Initialize figure window & Axes
close
fh = figure(WindowState="fullscreen");
fh.MenuBar="none";
ah = axes(fh); %, Visible="off");
% ah.Position = [0 0 1 1];

% ph = plot(ah,1,1, Marker='+', Markersize=32, MarkerEdgeColor='k');

axis off
ah.XLim = [0 1];
ah.YLim = [0 1];
%% task instructions

instructions = sprintf(['' ...
    'You are about to perform the Simon Task.\n' ... 
    'During this task you will see a fixation cross in the middle of the screen.\n' ...
    'Try to keep your gaze on the fixation cross during the experiment.\n\n' ...
    'On either side of the fixation cross are rectangles. In these rectangles the letters A and B will appear.\n' ...
    'When you see the letter A appear, click the "a" key on the keyboard.\n' ...
    'When you see the letter B appear, click the "l" key on the keyboard.\n' ...
    'The side on which the letter appears is not important.\n\n' ...
    'Press any key when you are ready to start.' ...
    '']);

text(.2, .6, instructions, FontSize=25);



pause(5)
figure(fh)
pause()



cla

%% plot fixation cross & rectangles
th = text(ah,.5,.5,'+',FontSize=80, Color='k');

rectangle(ah, "Position",[.05 .3 .2 .4])
rectangle(ah, "Position",[.75 .3 .2 .4])

% Initialize letters
ALeft = text(ah, .135, .5, 'A', FontSize=60, Visible="off");
BLeft = text(ah, .135, .5, 'A', FontSize=60, Visible="off");
ARight = text(ah, .835, .5, 'A', FontSize=60, Visible="off");
BRight = text(ah, .835, .5, 'B', FontSize=60, Visible="off");
letters = [ALeft BLeft ARight BRight];
axis off
ah.XLim = [0 1];
ah.YLim = [0 1];

pause

ARight.Visible = 1 - ARight.Visible ;

pause()

ARight.Visible = 1 - ARight.Visible ;

pause()

close(fh)