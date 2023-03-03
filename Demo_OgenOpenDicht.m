function Demo_OgenOpenDicht(serialConnected)
% Dit is een demo experiment ontworpen voor het EEG practicum. Tijdens dit
% experiment moet de proefpersoon 1 minuut ontspannen met de ogen dicht,
% dan 1 minuut hoofdrekenen met de ogen open, en dan weer 1 minuut
% ontspannen met de ogen dicht. Dit leidt bij de meeste proefpersonen tot
% een zichtbare verandering in occipitale alfa oscillaties

try

    disp('Start demo-experiment: OGEN OPEN DICHT')

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


    %% serialport
    port = connectSerialPort(serialConnected);

    %% Demo experiment
    % tijdsduur per onderdeel, moet 60 seconden zijn
    minuut = 60;

    %% instructies vooraf
    instruction = sprintf([...
        'Je gaat zo beginnen met het demo-experiment.\n'...
        ' \n'...
        'Je begint met een minuut ontspannen met je ogen dicht. \n'...
        'Zorg dat er iemand in de buurt is die aangeeft wanneer de minuut voorbij is. \n'...
        'Daarna doe je je ogen open en volg dan rekeninstructies op het scherm. \n'...
        'Voer dan een minuut lang de rekensom uit in je hoofd. \n'...s
        'Daarna doe je weer je ogen dicht om een minuut te onstpannen. \n'...
        ' \n'...
        'Probeer gedurende het hele experiment zo stil mogelijk te blijven zitten. \n'...
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
    instruction = sprintf('Sluit je ogen voor een minuut en probeer zo veel mogelijk te ontspannen.');
    % plot instructies
    h.text.String = instruction;
    % haal figuur naar de voorgrond
    figure(h.fig)
    % start van het experiment
    if serialConnected
        port.write(20, 'uint8')
    end
    % korte pause voor de volgende marker
    pause(.2)

    % marker uitsturen
    marker = 21;
    if serialConnected
        port.write(marker,'uint8')
    else
        fprintf('marker: %d\n', marker)
    end

    % laat het scherm 1 minuut staan
    pause(minuut)

    %% Ogen open en rekenen
    % instructies voor rekenen
    startgetal = randi([331 378]);
    stapgetal  = randi([3 9]);
    instruction = sprintf('Begin terug te tellen vanaf %d in stappen van %d.', startgetal, stapgetal);
    h.text.String = instruction;
    figure(h.fig)

    marker = 22;
    if serialConnected
        port.write(marker,'uint8')
    else
        fprintf('marker: %d\n', marker)
    end

    % laat het scherm 1 minuut staan
    pause(minuut)


    %% Ogen dicht en ontspannen
    % instructies voor ontspanning
    instruction = sprintf('Sluit je ogen voor een minuut en probeer zo veel mogelijk te ontspannen.');
    h.text.String = instruction;
    figure(h.fig)

    marker = 21;
    if serialConnected
        port.write(marker,'uint8')
    else
        fprintf('marker: %s\n', marker)
    end

    % laat het scherm 1 minuut staan
    pause(minuut)


    %% End of demo experiment
    instruction = sprintf([...
        'Bedankt voor deelname aan het experiment.\n'...
        'Druk op een toets om het scherm af te sluiten en door te gaan naar het volgende experiment.\n']);
    h.text.String = instruction;
    figure(h.fig)
    waitforbuttonpress
    close(h.fig)

    port.delete

catch ME
    if exist('h','var'); close(h.fig); end
    if exist('port','var'); port.delete; end
    warndlg('An error occured, see the command window for more information.','Error')
    ME.rethrow
end
