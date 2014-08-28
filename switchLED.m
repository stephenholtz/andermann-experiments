%% quickly switch LED on and off for testing
% 
% Works with legacy and session-based interface

daqreset; clc;
close all force;
clear all force;

% Fill valves with button pushes
fprintf(['====LED Trigger: Port2/line5====\n',...
        'On by entering "1".\n'...
        'Off by entering "0".\n'...
        'Quit by entering anything else.\n'])

ledTesting = 1;
switch computer('arch')
    case {'win32'}
        dio = digitalio('nidaq','Dev1');
        addline(dio,5,2,'out');
        start(dio)

        while ledTesting
            keyPressed = input('? ','s');
            if keyPressed == '0'
                putvalue(dio,0)
            elseif keyPressed == '1'
                putvalue(dio,1)
            else
                putvalue(dio,0)
                delete(dio)
                ledTesting = 0;
                fprintf('Done.\n')
            end
        end
    case {'win64'}
        dS = daq.createSession('ni');
        dS.addDigitalChannel('Dev1','port0/line2','OutputOnly');

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
    otherwise
        error('Computer architecture not accounted for')
end
