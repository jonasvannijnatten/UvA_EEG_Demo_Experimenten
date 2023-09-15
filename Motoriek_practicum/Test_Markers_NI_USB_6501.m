daqreset
% discover devices
disp('Looking for device')
apparaat = daq.getDevices;
% create & start data acquisition session
disp('Creating data acquisition object')
session = daq.createSession(apparaat.Vendor.ID);
% add channels to daq session
disp('Adding channels 1-6')
addDigitalChannel(session, apparaat.ID, 'port0/line0', 'OutputOnly');
addDigitalChannel(session, apparaat.ID, 'port0/line1', 'OutputOnly');
addDigitalChannel(session, apparaat.ID, 'port0/line2', 'OutputOnly');
addDigitalChannel(session, apparaat.ID, 'port0/line3', 'OutputOnly');
addDigitalChannel(session, apparaat.ID, 'port0/line4', 'OutputOnly');
addDigitalChannel(session, apparaat.ID, 'port0/line5', 'OutputOnly');

%% Sending markers through the DIO-box
% The status of the marker channels is set using outputSingleScan()
% the first input argument refers to the data aquisition object
% the second input argument is an array of six 0s and 1s, defining the 
% status of each marker channel.
disp('testing channels')
outputSingleScan(session, [0 0 0 0 0 0]) % turn all 6 channels 'OFF'
WaitSecs(.2);
outputSingleScan(session, [1 0 0 0 0 0]) % set channel to 1 'ON', 2-6 'OFF'
WaitSecs(.2);
outputSingleScan(session, [0 1 0 0 0 0]) % set chan 1,3,4,5,6 'OFF', chan 2 'ON'
WaitSecs(.2);
outputSingleScan(session, [0 0 1 0 0 0])
WaitSecs(.2);
outputSingleScan(session, [0 0 0 1 0 0])
WaitSecs(.2);
outputSingleScan(session, [0 0 0 0 1 0])
WaitSecs(.2);
outputSingleScan(session, [0 0 0 0 0 1])
WaitSecs(.2);
outputSingleScan(session, [0 0 0 0 0 0])
WaitSecs(.2);

%% Test all 6 channels
% set all channels to 1
channels = ones(1,6);
outputSingleScan(session, channels);
disp(channels)
pause(.1); 

% set all channels to 0
channels = zeros(1,6);
outputSingleScan(session, channels);
pause(.1);
disp(channels)
% loop through all channels and turn then on and off sequentually
for ichan = 1:6
    channels(ichan) = 1;
    disp(channels)
    outputSingleScan(session, channels);
    pause(.1)
    channels = zeros(1,6);
    outputSingleScan(session, channels);
    pause(.1)
    
end
% set all channels to 0
channels = ones(1,6);
outputSingleScan(session, channels);
disp(channels)

pause(.1); 

% set all channels to 0
channels = zeros(1,6);
outputSingleScan(session, channels);
pause(.1);
disp(channels)
disp('Marker test finished')