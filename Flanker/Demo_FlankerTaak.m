% Script that runs the Erikson Flanker task until at least minCorrect
% (standard 20) trials of both conditions have been run

try

    %% serialport
    serialConnected = 1;

    if serialConnected
        portlist = serialportlist;
        if length(portlist)==1
            portnr = portlist;
            disp(["COM port selected: " portnr])
        elseif lenght(portlist)>1
            sprintf("Please indicate which COM port representes the serial port\n")
            disp(compose("%s", portlist)')
            index = input("");
            portnr = portlist(index);
        elseif isempty(portlist)
            disp("No connected serial ports found")
        end
    end
    port = serialport(portnr, 19200,'Timeout',5);

    marker = 30;
    if serialConnected
        port.write(marker,'uint8')
    else
        fprintf('marker: %i\n', marker)
    end

    %% Init figuur

    % open & maximize figure while hidden
    h.fig  = figure;
    h.fig.Visible       =  'off';
    h.fig.WindowState   = 'fullscreen';
    h.fig.ToolBar       = 'none';
    h.fig.MenuBar       = 'none';

    % plot first text
    h.text = text(0.5, 0.6, 'Start');
    h.text.FontSize = 32;
    h.text.HorizontalAlignment = 'center';

    % set axis properties
    h.axis = h.fig.Children;
    h.axis.Color = h.fig.Color;
    h.axis.XColor = h.fig.Color;
    h.axis.YColor = h.fig.Color;
    h.axis.XTick = [];
    h.axis.YTick = [];

    % make figure visible
    h.fig.Visible =  'on';

    %% set up variables
    congrCounter = 0;
    incongrCounter = 0;

    trial = 0;

    minCorrect = 50;

    data(200) = struct('ppn', [], 'condition', [], 'reactiontime', [], 'correct', []);


    %% Instructions
    % Er worden letter reeksen getoond. De middelste letter is anders dan de
    % omringende letters.
    % Druk 'a' wanneer de middelste letter een 'H' of 'K' is.
    % Druk 'l' wanneer de middelste letter een 'C' of 'S' is.

    instruction = sprintf([...
        'Je gaat zo beginnen met het demo-experiment FLANKER TAAK.\n'...
        'De middelste letter is anders dan de omringende letters. \n'...
        'Druk "a" wanneer de middelste letter een "H" of "K" is. \n'...
        'Druk "l" wanneer de middelste letter een "C" of "S" is. \n'...
        ' \n'...
        'Probeer gedurende het hele experiment verder zo stil mogelijk te blijven zitten. \n'...
        ' \n'...
        'Ga vast klaar zitten en druk op een toets zodra je klaar bent om te beginnen. \n'...
        ]);

    % centreer de tekst
    h.text.HorizontalAlignment = 'center';
    % plot instructies
    h.text.String = instruction;
    % Geef de juiste grootte van de letters van de tekst aan
    h.text.FontSize = 20;
    % haal figuur naar de voorgrond
    figure(h.fig)
    % wacht tot proefpersoon een toets indrukt
    waitforbuttonpress;
    cla
    hold on

    %% Experiment loop
    % run experiments until both conditions have at least 20 correct trials
    while congrCounter < minCorrect || incongrCounter < minCorrect

        % run experiment
        condition = pickone({'congruent', 'incongruent'});

        % count hits
        if strcmp(condition, 'congruent')

            % stuur marker code uit
            marker = 31;
            % indien serialport is aangesloten stuur het uit, anders print marker
            if serialConnected
                port.write(marker,'uint8')
            else
                fprintf('marker: %d\n', marker)
            end
        else
            % stuur marker code uit
            marker = 32;
            % indien serialport is aangesloten stuur het uit, anders print marker
            if serialConnected
                port.write(marker,'uint8')
            else
                fprintf('marker: %d\n', marker)
            end
        end

        [correct, reactionTime] = flankerTrial(condition);
        trial = trial +1;
        cla

        % count hits
        if strcmp(condition, 'congruent')
            congrCounter = congrCounter + correct;
        else
            incongrCounter = incongrCounter + correct;
        end


        % store data
        data(trial).condition = condition;
        data(trial).reactiontime = reactionTime;
        data(trial).correct = correct;

    end

    data = data(1:trial);
    save(['Flanker_demo_data_' datestr(date, 'yyyymmdd') '.mat'],'data')

    %% End of Flanker demo experiment
    instruction = sprintf([...
        'Bedankt voor deelname aan het experiment.\n'...
        'Sla nu de data op in EEG recorder.\n'...
        'Druk op een toets om het scherm af te sluiten.\n']);
    text(0.5, 0.6,instruction, 'FontSize',35,'HorizontalAlignment','center');
    waitforbuttonpress
catch ME
    if exist('h','var')
        close(h.fig)
    end
    if exist('port','var')
        port.delete
    end
%     rethrow(ME)
end
close(h.fig)

port.delete

