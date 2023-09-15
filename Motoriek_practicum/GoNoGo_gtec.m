% GO-NoGo EXPERIMENT
% Go-NoGo Task developed for Motoriek practicum for Psychobiologie
% This script runs a Go/No-Go task where the subject has to press a button
% when an low tone is heard. The frequency of the low can be varied
% to study the effect of target frequency on Go/No-Go responses and
% related brain activity.
%
% The experiment starts with a practice round (optional) with a target
% frequency of 50%. Then two rounds of the actual experiment start. During
% the first round there is a 20% change of targets, during the second round
% there is an 80% change of a target. The participant is instructed to
% press the 'spacebar' when a target (low tone) is heard and do nothing
% when a high tone is heard.
%
% MARKERS
% The experiment can send out markers via the DIO-box to use it in
% combination with EEG. Therefore set the variable 'online' to 1.
% The marker coding is as follows:
% Marker 1 --> 80% NoGo condition, non-target (high tone)
% Marker 2 --> 80% NoGo condition, target (low tone)
% Marker 3 --> 80% NoGo condition, key press
% Marker 4 --> 20% NoGo condition, non-target (high tone)
% Marker 5 --> 20% NoGo condition, target (low tone)
% Marker 6 --> 20% NoGo condition, key press
%
% SOFTWARE REQUIREMENTS
% - Psychtoolbox
% - National instrument drivers NI-DAQmx
%
% HARDWARE REQUIREMENTS
% - National Instruments DIO-box USB-6501 (for sending markers).


%% Experiment parameters
disp('setting experiment parameters')
trialDuration = 1.5;

nroftrials = 150; % nr of trials per condition
pauseafter = 50; % pause after x trials
conditionTypes = [0 0 0 0 1 ; 1 1 1 1 0]; % 0 - high tone, 1 - low tone

totaltrial = 0;
practicetrials = 1; % make 1 if practice should be shown
numpractice = 15; % specify number of practice trials
practiceTypes = [1 0]; % 50-50 high and low tones in practice

%% initialize DIO-box & markers
% Set online to 1 to send markers to the DIO-box.
% Set online to 0 to run the experiment without sending markers.
online = 1;
if online
    dev = addDIObox;
    if isempty(dev)
        fprintf('Sluit de DIObox aan of run het experiment offline.\n')
    return
    end
    dev.outputSingleScan([ 0 0 0 0 0 0])
end
markersOFF = [0 0 0 0 0 0];
markers = markersOFF;

%% read audio files
disp('reading audio files')
[loTone, FsLo] = audioread('lowTone.mp3');
% loTone = audioplayer(loTone, FsLo);
[hiTone, FsHi] = audioread('highTone.mp3');
% hiTone = audioplayer(hiTone, FsHi);


%% setup data struct
if exist('data', 'var') % safetynet in case data of last run is not stored properly there is one more chance
    datalastrun = data;
    clear data
end
data(nroftrials) = struct('ppn', [],'condition', [], 'trial', [], 'tone', [], 'reactiontime', [], 'keypressed', []);

%% start experiment in try-catch loop
try
    %% set figure properties
    figure
    set(gcf, 'MenuBar', 'none')
    set(gcf, 'ToolBar', 'none')
    set(gcf, 'Windowstate', 'fullscreen')
    set(gca, 'visible', 'off')
    set(gcf, 'Color', 'k')
    
    %% ask for ppn (used to store data)
    ppn = inputdlg('Participantnumber');
    ppn = str2double(ppn{1});
    
    %% Hide cursor and prevent key presses to type in the command window or
    % script
    disp('disabling keyboard')
    ListenChar(2);
    HideCursor;
    PsychDefaultSetup(2);
    
    
    %% practice trials
    if practicetrials
        disp('start practice trials')
        % instructions
        instructions = sprintf(['In this experiment you will hear two types of tones;\n' ...
            'A low tone and a high tone.\n' ...
            'When you hear the LOW TONE you have to PRESS SPACE BAR as quickly as possible.\n' ...
            'When you hear the HIGH TONE you have to DO NOTHING.\n\n'...
            'Press any key to start the practice' ...
            ]);
        t_practice = text(.2, .6, instructions, 'color', 'w','fontsize', 16);
        pause(.1)
        sound(loTone,FsLo)
        sound(hiTone,FsHi)
        KbWait([],2);
        set(t_practice, 'Visible', 'off')
        
        % run trials
        t_fixcross = text(.45, .5, '+', 'color', 'w','fontsize', 40);
        pause(.1)
        
        for ipractice = 1:numpractice
            type = practiceTypes(randi(length(practiceTypes)));
            
            % check if key is pressed
            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
            while keyIsDown % if key is pressed, wait until it is released
                [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
            end
            disp('start trial')
            
            % play sound
            disp('playing sound')
            if type
                sound(loTone,FsLo)
            else
                sound(hiTone,FsHi)
            end
            
            tstart = GetSecs();
            while GetSecs()-tstart<trialDuration && (keyIsDown==0)
                [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
            end
            
            keypress = KbName(keyCode);
            WaitSecs(trialDuration-(GetSecs()-tstart));
        end
        set(t_fixcross, 'Visible', 'off')
        pause(.1)
    end
    
    %% start real trials
    disp('start real experiment')
    for condition = 1:2 % 1 - 20% go, 2 - 80% go
        %% show screen with instructions - add proper instructions here
        if condition==1
            instructions = sprintf(['Now the real experiment will start. \n\n' ...
                'During this block the low tone will be played less frequently than the high tone. \n\n'...
                'When you hear the LOW TONE you have to PRESS SPACE BAR as quickly as possible.\n' ...
                'When you hear the HIGH TONE you have to DO NOTHING.\n\n'...
                'Press any key to continue' ...
                ]);
        elseif condition==2
            instructions = sprintf(['Now the second part of the experiment will start. \n\n' ...
                'During this block the low tone will be played more frequently than the high tone. \n\n'...
                'When you hear the LOW TONE you have to PRESS SPACE BAR as quickly as possible.\n' ...
                'When you hear the HIGH TONE you have to DO NOTHING.\n\n'...
                'Press any key to continue' ...
                ]);
        end
        t_instructions = text(.2, .6, instructions, 'color', 'w','fontsize', 16);
        pause(.1)
        KbWait([],2);
        set(t_instructions, 'Visible', 'off')
        t_fixcross = text(.45, .5, '+', 'color', 'w','fontsize', 40);
        pause(.1)
        
        % start type (20% or 80% target)
        for itrial = 1:nroftrials
            
            %% START TRIAL %%
            %%% select condition %%%
            type = conditionTypes(condition, randi(length(conditionTypes)));
            fprintf('condition %d; trial: %d / %d;  type: %d \n',condition, itrial, nroftrials, type)
           
            
            %%% wait until key is released %%%
            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
            while keyIsDown % if key is pressed, wait until it is released
                [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
            end
            disp('start trial')
            
            
            %%% play sound %%%
            disp('playing sound')
            if type
                sound(loTone,FsLo)
            else
                sound(hiTone,FsHi)
            end
            
            
            %%% set marker %%%
            % Marker 1 --> 20% target condition, target (low tone)
            % Marker 2 --> 20% target condition, non-target (high tone)
            % Marker 4 --> 80% target condition, target (low tone)
            % Marker 5 --> 80% target condition, non-target (high tone)
            if condition==1 && type==0
                markers(1) = 1;
            elseif condition==1 && type==1
                markers(2)=1;
            elseif condition==2 && type==0
                markers(4)=1;
            elseif condition==2 && type==1
                markers(5)=1;
            end
            if online; dev.outputSingleScan(markers); end
            disp(markers)
            
            %%% wait for keypress %%%
            tstart = GetSecs();
            while GetSecs()-tstart<trialDuration && (keyIsDown==0)
                [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
            end
            
            %%% set marker %%%
            % Marker 3 --> 20% target condition, key press
            % Marker 6 --> 80% target condition, key press
            if keyIsDown && condition == 1
                markers(3) = 1;
            elseif keyIsDown && condition == 2
                markers(6) = 1;
            end
            if online; dev.outputSingleScan(markers); pause(.1); end
            disp(markers)
            
            %%% set markers %%%
            % turn off all markers
            markers= markersOFF;
            if online
                dev.outputSingleScan(markers)
            end
            disp(markers)
            
            
            %%% finish trial %%%
            % if key was pressed, wait until trial time is finished
            WaitSecs(trialDuration-(GetSecs()-tstart));
            
            %%% get RT and key pressed %%%
            RT = NaN;
            keypress = KbName(keyCode);
            if isempty(keypress) % in case no key is pressed
                keypressed = 'none';
            elseif iscell(keypress) % in case multiple keys are pressed
                keypressed = keypress{1};
                RT = round(secs - tstart,2);
            else % in case a single key is pressed
                keypressed = keypress;
                RT = round(secs - tstart,2);
            end
            fprintf('key = %s\nrt  = %.4f \n', keypressed, RT)
            
            pause(rand()/2+.5) % random ITI between 0.5 and 1 second
            %% END TRIAL %%
            
            
            %% insert pause screen every x trials
            if mod(itrial, pauseafter) == 0 && itrial ~= nroftrials
                disp('pause for subject')
                % insert pause instruction and wait for press
                set(t_fixcross, 'Visible', 'off')
                instructions = sprintf([ ...
                    'Pause - press any key to continue with the experiment\n\n' ...
                    'Block: %d/2, trial %d/%d' ... 
                    ], condition, itrial, nroftrials);
                t_pause = text(.2, .6, instructions, 'color', 'w','fontsize', 16);
                pause(2)
                KbWait([],2);
                set(t_pause, 'Visible', 'off')
                set(t_fixcross, 'Visible', 'on')
                pause(1)
            end
            
            
            %% store data
            totaltrial = totaltrial + 1;
            data(totaltrial) = struct('ppn', ppn, 'condition', condition, 'trial', itrial, 'tone', type, 'reactiontime', RT, 'keypressed', keypressed);
            
            fprintf('end of trial\n')
            fprintf('t = %.4f \n\n', GetSecs() - tstart) % show total trial duration 
            
        end
        set(t_fixcross, 'Visible', 'off')
        pause(.1)
    end
    
    %%%%%%%%%%%%%%%%%%%%%
    % END OF EXPERIMENT %
    %%%%%%%%%%%%%%%%%%%%%
    disp('Experiment finished')
    % re-enable keyboard and mouse
    disp('reenabling keyboard and screen')
    Screen('CloseAll');
    ListenChar;
    ShowCursor;
    
    %save data to harddrive
    writetable(struct2table(data), ['GoNogo_' datestr(date,'yyyymmdd') '_ppn', num2str(ppn)])
%     save(['GoNogo_' datestr(date,'yyyymmdd') '_ppn', num2str(ppn)], 'data')
    
    
    %thank you screen
    set(t_fixcross,'visible', 'off')
    text(.2, .5, 'This is the end of the experiment', 'color', 'w','fontsize', 16);
    pause
    close all
    
catch ME
    disp('oops, something went wrong')
    
    % In case of error
    % Close screen and re-enable mouse and keyboard
    disp('reanabling keyboard and screen')
    Screen('CloseAll');
    ListenChar;
    ShowCursor;
    
    % emergency data save
    save(['GoNoGo_emergencySave_' datestr(datetime,'yyyymmdd_HHMM') '_ppn' num2str(ppn)])
    close all
    rethrow(ME)
end



function dev = addDIObox()
disp('looking for DIO-box')
if exist("dev","var")
    clear dev
end
daqreset
% list devices
devs = daqlist;
% find National instruments USB-6501
devnr = find(ismember(devs.Model, ["USB-6501 (OEM)", "USB-6501"]));

if ~isempty(devnr)
    disp('DIObox')
    devInfo = devs(devnr,:);
    % display device info
    devInfo.DeviceInfo.disp
    % create daq object
    dev = daq.createSession('ni'); % hardcoded version
    
    % add channels to daq session
    dev.addDigitalChannel(devInfo.DeviceID, 'port0/line0', 'OutputOnly');
    dev.addDigitalChannel(devInfo.DeviceID, 'port0/line1', 'OutputOnly');
    dev.addDigitalChannel(devInfo.DeviceID, 'port0/line2', 'OutputOnly');
    dev.addDigitalChannel(devInfo.DeviceID, 'port0/line3', 'OutputOnly');
    dev.addDigitalChannel(devInfo.DeviceID, 'port0/line4', 'OutputOnly');
    dev.addDigitalChannel(devInfo.DeviceID, 'port0/line5', 'OutputOnly');
else
    disp('DIO-box niet gevonden')
    dev = [];
    return
end
end


