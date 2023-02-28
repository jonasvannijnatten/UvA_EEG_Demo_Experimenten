function port = connectSerialPort(serialConnected)
% This functions identifies and connects to available serial ports

% initialize the port variable as 0
port = 0;
% check the user wants to use the serial port
if serialConnected
    % list all available serial devices
    portlist = serialportlist;
    % if there is only one, assume this is the correct serial port
    if length(portlist)==1
        portnr = portlist;
        disp(["COM port selected: " portnr])
        % if there are multiple serial devices, let the user choose one
    elseif length(portlist)>1
        disp("Please indicate which COM port representes the serial port")
        disp(compose("%d: %s", (1:length(portlist))',(portlist)'))
        index = input("Which item from the list should be used? ");
        portnr = portlist(index);
        % if no devices were found, leave the portnr empty
    elseif isempty(portlist)
        portnr = [];
        disp("No connected serial ports found")
    end
    % if serialConnected is 0, don't try to connect
else
    disp('Serial connection is disabled in the code.')
end

% In case a port is selected, use that number to create the port object.
% The port variable is given as output and can be used in the
% function/script to send out markers.
if ~isempty(portnr)
    port = serialport(portnr, 19200,'Timeout',5);
end

