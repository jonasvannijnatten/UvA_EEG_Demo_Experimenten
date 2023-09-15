% function SerialMarkerSnippet
% This is an example script on how to detect serial port devices, set up a
% connection and send markers over a serial port.
%
% The detection of the COM port and creation of serial port object need to
% be done only once at the beginning of your experiment.
%
% The markers are sent each time an event of interest happens in the
% experiment, for example when an image is shown, audio is played, the
% subject presses a key etc. The code to send out the marker should be as
% close as possible to the code of the event (e.g. the plot() fuction,
% getkey() function etc.


% find and stop any pre-existing connection with the serial port.
if exist('port','var'); port.delete; end

%% detect and choose COM port
% get a list of all available serial connections on your computer
portlist = serialportlist;

% if there is only one serial port connected, assume this is the serial
% marker cable and use this COM port nr.
if length(portlist)==1
    portnr = portlist;
    disp(["COM port selected: " portnr])

    % if multiple serial ports are connected, provide a list of
    % available COM ports and let the user select which one to use by
    % typing in the number in the list
elseif length(portlist)>1
    sprintf("Please indicate which COM port representes the " + ...
        "serial port you want to use by typing in the " + ...
        "corresponding number in the list.")
    disp(compose("%i: %s", (1:length(portlist))', portlist'))
    index = input("Use COM port nr: ");
    portnr = portlist(index);

    % if no serial port is connected, give feedback to user and quit
    % the script
elseif isempty(portlist)
    disp("No connected serial ports found")
    return
end

%% create serial port object
% The serial port object is a variable through which Matlab can send
% out the markers
port = serialport(portnr, 19200,'Timeout',5);
disp(port)

%% Example of sending markers in a loop
% here the marker numbers 0 until 255 are sent out with a pause of
% 100ms in between he markers.
for iMarker = 0:255
    % the command port.write sends out out the marker. the first input
    % argument is the marker nr (here the value of i), the second input
    % argument determines the value format; leave this at 'uint8'.
    port.write(iMarker,'uint8')
    % with the display function the marker value is also printed to the
    % command window, this is not necessary in a real experiment.
    disp(iMarker)
    % the pause function here makes sure there is a break before the
    % next marker is sent out. In an actual experiment this should be
    % the stimulus duration or reaction time for example.
    pause(.1)
end


%% delete the created serial port object
% make sure to delete the serial port object at the end of your script or
% function, otherwise when rerunning the code Matlab will say the COM port
% is already in use and cannot establish a new connection.
port.delete