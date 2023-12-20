%% Demo experiment
% Dit script runt de verschillende delen van het Demo experiment voor het
% EEG practicum bestaande uit:
% - Demo_Artefacten
% - Demo_OgenOpenDicht
% - Demo_FlankerTaak

%% controleer of een recente versie van Matlab wordt gebruikt
v = version('-release');
v = str2double(v(1:4));
if v<2021
    error("Gebruik voor deze demo een Matlab versie van 2021a of later.")
end

%% bewaar origineel Matlab path
% add Flanker task to path
curdir = cd;
addpath(genpath([curdir filesep 'Flanker']))

%% Geef aan of je de serial poort wil gebruiken
serialConnected = 1;

%% Doe de Demo Experimenten
disp('Start demo-experiment')

Demo_Artefacten(serialConnected)

Demo_OgenOpenDicht(serialConnected)

Demo_FlankerTaak(serialConnected, 200, 10, 25, 5)

%% Herstel origineel Matlab path
% remove Flanker task from path
rmpath(genpath([curdir filesep 'Flanker']))