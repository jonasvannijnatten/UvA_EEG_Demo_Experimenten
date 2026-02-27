function Demo_OgenOpenDicht(port)
% Dit is een demo experiment ontworpen voor het EEG practicum. Tijdens dit
% experiment moet de proefpersoon 1 minuut ontspannen met de ogen dicht,
% dan 1 minuut hoofdrekenen met de ogen open, en dan weer 1 minuut
% ontspannen met de ogen dicht. Dit leidt bij de meeste proefpersonen tot
% een zichtbare verandering in occipitale alfa oscillaties


if nargin == 0
    port = 0;
end

try


    disp('Start demo-experiment: OGEN OPEN DICHT')

    
    %% send marke at the start of the experiment
    if port == 0
        disp("Running experiment without markers")
    end

    %% init figuur

    % open en maximaliseer figuur
    h.fig  = figure;
    h.fig.Visible =  'off';
    h.fig.WindowState   = 'fullscreen';
    h.fig.ToolBar       = 'none';
    h.fig.MenuBar       = 'none';

    % plot eerste tekst
    h.text = text(0.5, 0.6, 'Start');
    h.text.FontSize = 35;
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
    % tijdsduur per onderdeel, moet 60 seconden zijn
    duur = 20;

    %% instructies vooraf
    instruction = sprintf([...
        'Je gaat zo beginnen met het demo-experiment.\n'...
        ' \n'...
        'Je begint met 20 seconden ontspannen met je ogen dicht. \n'...
        'Zorg dat er iemand in de buurt is die aangeeft wanneer de tijd voorbij is. \n'...
        'Daarna doe je je ogen open en volg dan rekeninstructies op het scherm. \n'...
        'Voer dan 20 seconden lang de rekensom uit in je hoofd. \n'...s
        'Daarna doe je beide onderdelen nog een keer. \n'...
        ' \n'...
        'Probeer gedurende het hele experiment zo stil mogelijk te blijven zitten, \n'...
        'ook wanneer je overgaat van ogen dicht naar open en vice versa.\n'...
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

    %% Ogen dicht en ontspannen
    % instructies voor onstpanning
    instruction = sprintf('Sluit je ogen en probeer zo veel mogelijk te ontspannen.');
    % plot instructies
    h.text.String = instruction;

    % voeg progress bar toe
    h.line = line(h.axis, [0 1],[-.8 -.8], linewidth=8);

    % haal figuur naar de voorgrond
    figure(h.fig)
    % start van het experiment
    if port~=0
        port.write(20, 'uint8')
    else
        disp(20)
    end
    % korte pause voor de volgende marker
    pause(.2)

    % marker uitsturen
    marker = 21;
    if port~=0
        port.write(marker,'uint8')
    else
        fprintf('marker: %d\n', marker)
    end

    % laat het scherm 1 minuut staan
    % pause(minuut)

    tic;
    while toc < duur
        % toc/duur
        h.line.XData = [0 1-(toc/duur)];
        h.axis.XLim = [0 1];
        h.axis.YLim = [-1 1.5];
        refresh(h.fig);      
        figure(h.fig)
        pause(.05) 

    end
    % delete(h.line)

    %% Ogen open en rekenen
    % instructies voor rekenen
    startgetal = randi([331 378]);
    stapgetal  = randi([3 9]);
    instruction = sprintf('Begin terug te tellen vanaf %d in stappen van %d.', startgetal, stapgetal);
    h.text.String = instruction;
    figure(h.fig)

    marker = 22;
    if port~=0
        port.write(marker,'uint8')
    else
        fprintf('marker: %d\n', marker)
    end

    % laat het scherm 1 duur staan
    % pause(duur)
    tic;
    while toc < duur
        % toc/duur
        h.line.XData = [0 1-(toc/duur)];
        h.axis.XLim = [0 1];
        h.axis.YLim = [-1 1.5];
        refresh(h.fig);      
        figure(h.fig)
        pause(.05)
    end


    %% Ogen dicht en ontspannen
    % instructies voor ontspanning
    instruction = sprintf('Sluit je ogen en probeer zo veel mogelijk te ontspannen.');
    h.text.String = instruction;
    figure(h.fig)

    marker = 21;
    if port~=0
        port.write(marker,'uint8')
    else
        fprintf('marker: %d\n', marker)
    end

    % laat het scherm 1 minuut staan
    % pause(minuut)
    tic;
    while toc < duur
        % toc/duur
        h.line.XData = [0 1-(toc/duur)];
        h.axis.XLim = [0 1];
        h.axis.YLim = [-1 1.5];
        refresh(h.fig);
        figure(h.fig)
        pause(.05)
    end

    %% Ogen open en rekenen
    % instructies voor rekenen
    startgetal = randi([331 378]);
    stapgetal  = randi([3 9]);
    instruction = sprintf('Begin terug te tellen vanaf %d in stappen van %d.', startgetal, stapgetal);
    h.text.String = instruction;
    figure(h.fig)

    marker = 22;
    if port~=0
        port.write(marker,'uint8')
    else
        fprintf('marker: %d\n', marker)
    end

    % laat het scherm staan
    % pause(duur)
    tic;
    while toc < duur
        % toc/duur
        h.line.XData = [0 1-(toc/duur)];
        h.axis.XLim = [0 1];
        h.axis.YLim = [-1 1.5];
        refresh(h.fig);      
        figure(h.fig)
        pause(.05)
    end
    
    h.line.Visible = "off";

    %% End of demo experiment
    instruction = sprintf([...
        'Bedankt voor deelname aan het experiment.\n'...
        'Druk op een toets om het scherm af te sluiten en door te gaan naar het volgende experiment.\n']);
    h.text.String = instruction;
    figure(h.fig)
    waitforbuttonpress
    close(h.fig)

    % if port~= 0; port.delete; end

catch ME
    if exist('h','var') && ishandle(h.fig); close(h.fig); end
    if exist('port','var') && port~=0; port.delete; end
    warndlg('An error occured, see the command window for more information.','Error')
    ME.rethrow
end
