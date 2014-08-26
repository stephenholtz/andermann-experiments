%% quickly switch LED on and off for testing

daqreset; clc;
close all force;
clear all force;

dS = daq.createSession('ni');
dS.addDigitalChannel('Dev1','port0/line2','OutputOnly');

% Fill valves with button pushes
fprintf(['====LED Trigger: Port0/line2====\n',...
        'On by entering "1".\n'...
        'Off by entering "0".\n'...
        'Quit by entering anything else.\n'])

ledTesting = 1;
while ledTesting
    keyPressed = input('? ','s');
    if keyPressed == '0'
        dS.outputSingleScan(0)
    elseif keyPressed == '1'
        dS.outputSingleScan(1)
    else
        dS.outputSingleScan(0)
        delete(dS)
        ledTesting = 0;
        fprintf('Done.\n')
    end
end
