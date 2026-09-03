function Serial_Marker_test
% this function connects to a serial port and sends out markers 1 through
% 255 with a short break in between. This function can be used to test
% if the markers are received by a recording system.

% create a serial port object using the custom connectSerialPort function
port = connectSerialPort(1);

% start looping over the 255 markers
disp('start sending serial markers')
for iMarker = 1:255    
    % send out a serial value
    port.write(iMarker, "uint8");
    % print the value of the marker to the command window
    fprintf("Marker nr: %3.0f\n", iMarker)
    % pause before sending the next marker
    pause(.5)
end
% delete the port object
port.delete
disp('Marker test finished!')
