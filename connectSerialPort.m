function port = connectSerialPort(serialConnected)
% This functions identifies and connects to available serial ports


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
else
    disp('Serial connection is disabled in the code.')
end
port = serialport(portnr, 19200,'Timeout',5);
