function port = connectSerialPort(serialConnected)
% This functions identifies and connects to available serial ports

if nargin==0
    serialConnected=1;
end

% initialize the port variable as 0
port = 0;
portnr = [];
% check the user wants to use the serial port
if serialConnected
    % list all available serial devices
    portlist = serialportlist;
    % if there is only one, assume this is the correct serial port
    if length(portlist)==1
        portnr = portlist;
        disp("COM port selected: " + portnr)
        % if there are multiple serial devices, let the user choose one
    elseif length(portlist)>1
        % disp("Please indicate which COM port representes the serial port")
        % disp(compose("%d: %s", (1:length(portlist))',(portlist)'))
        % d.Visible="on";
        % uiwait(d)
        % index = input("Please type in the position in the list");
        selection = chooseCOMport(portlist);
        portnr = portlist(selection);
        disp("COM port selected: " + portnr)
        % if no devices were found, leave the portnr empty
    elseif isempty(portlist)
        msg = ("\fontsize{16}No serial port was detected. This means no markers can be sent out." + ...
            "Do you want to continue without markers? Click ""Conintue"" to run the task without markers, or click ""cancel"" to abort");

        opts.Default = "Cancel";
        opts.Interpreter = "tex";
        opts.FontSize = 20;
        answer = questdlg(msg, "No serial port detected.", "Cancel", "Continue", opts);
        if strcmp(answer, "Cancel")
            port = [];
        else
            disp("Continuing without markers")
        end
    end
    % if serialConnected is 0, don't try to connect
else
    disp('Serial connection is disabled in the code.')
    pause(1)
end


% In case a port is selected, use that number to create the port object.
% The port variable is given as output and can be used in the
% function/script to send out markers.
if ~isempty(portnr)
    port = serialport(portnr, 19200,'Timeout',5);
end

end

% function to create a pop-up window to allow the user to select the
% correct COM port
function selection = chooseCOMport(options)
d = dialog(WindowStyle="modal", Position=[400 500 600 300]);
uicontrol('Parent', d, ...
    'Style', 'text', ...
    'Position', [20 200 500 80], ...
    'String', 'select which COM port to use to send markers:', ...
    'FontSize', 16 ...
    );

uicontrol('Parent', d, ...
    'Style', 'popupmenu', ...
    'Position',[40 180 400 40], ...
    'String', options, ...
    'FontSize', 12 ...
    );

uicontrol('Parent',d,...
    'Position',[40 120 70 40],...
    'String','Ok',...
    'FontSize' , 16, ...
    'Callback',@drpdwn_callback);

uiwait(d)
    function drpdwn_callback(btn,~)
        selection = btn.Parent.Children(2).Value;
        delete(gcf);
    end
end