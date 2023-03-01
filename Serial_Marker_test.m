function Serial_Marker_test
% this function connects to a serial port and sends out markers 1 through
% 255 with a break of 200 ms in between. This function can be used to test
% if the markers are received by a recording system.

port = connectSerialPort(1);

% start looping over the 255 markers
dips('start sending serial markers')
for iMarker = 1:255    
    port.write(iMarker, "uint8");
    fprintf("Marker nr: %3.0f\n", iMarker)
    pause(.4)
end
port.delete
disp('Marker test finished!')
