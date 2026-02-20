function Demo_Artefacten(port)
% Dit is een demo experiment ontworpen voor het EEG practicum. Tijdens dit
% experiment wordt het effect van verschillende bewegingen op het EEG
% signaal zichtbaar gemaakt.

try

    disp('Start demo-experiment: ARTEFACTEN')

    %% send marker at the start of the experiment
    if port == 0
        disp("Running experiment without markers")
    elseif port~=0
        port.write(10, 'uint8')
    end

    %% Init figuur

    % open en maximaliseer figuur
    h.fig  = figure;
    h.fig.Visible =  'off';
    h.fig.WindowState   = 'fullscreen';
    h.fig.ToolBar       = 'none';
    h.fig.MenuBar       = 'none';

    % plot eerste tekst
    h.text = text(0.5, 0.6, 'Start');
    h.text.FontSize = 32;
    h.text.HorizontalAlignment = 'center';

    % bepaal axis eigenschappen
    h.axis = h.fig.Children;
    h.axis.Color = h.fig.Color;
    h.axis.XColor = h.fig.Color;
    h.axis.YColor = h.fig.Color;
    h.axis.XTick = [];
    h.axis.YTick = [];

    % maak figuur zichtbaar
    h.fig.Visible =  'on';

    %% Demo experiment
    % tijdsduur per onderdeel
    seconden = 10;

    %% instructies vooraf
    instruction = sprintf([...
        'Je gaat zo beginnen met het demo-experiment ARTEFACTEN.\n'...
        ' \n'...
        'Tijdens deze demo wordt het effect zichtbaar van: \n'...
        '- oogknippers            \n'...
        '  - oogbewegingen        \n'...
        '    - kaakspieren / kauwen \n'...
        '  - hoofdbewegingen     \n'...
        '- nekspieren              \n'...
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
    pause(3)
    waitforbuttonpress;


    %% instructies
    instructions = {...
        'Zit zo stil en ontspannen mogelijk',...
        'Knipper met je ogen', ...
        'Beweeg je ogen van links naar rechts', ...
        'Zet kaken je flink op elkaar', ...
        'Draai je hoofd voorzichtig rond', ...
        'Beweeg je hoofd op en neer (ja knikken)', ...
        };

    %% Loop over instructies heen
    for itrial = 1:6

        % instructies voor onstpanning
        instruction = instructions{itrial};
        % plot instructies
        h.text.String = instruction;
        % haal figuur naar de voorgrond
        figure(h.fig)

        % indien serialport is aangesloten stuur het uit, anders print marker
        if port~=0
            port.write(10+itrial,'uint8')
        else
            fprintf('marker: 1%i\n', itrial)
        end

        % laat het scherm 1 minuut staan
        pause(seconden)

    end

    %% Einde van het demo experiment
    instruction = sprintf([...
        'Bedankt voor deelname aan het experiment.\n'...
        'Druk op een toets om het scherm af te sluiten en door te gaan naar het volgende experiment.\n']);
    h.text.String = instruction;
    figure(h.fig)
    waitforbuttonpress
    close(h.fig)

    % port.delete

catch ME
    if exist('h','var'); close(h.fig); end
    if exist('port','var') && port~= 0; port.delete; end
    warndlg('An error occured, see the command window for more information.','Error')
    ME.rethrow
end

