%% Trip the solenoid valve

daqreset; clc;
close all force;
clear all force;

dS = daq.createSession('ni');
dS.addDigitalChannel('Dev1','port0/line0:1','OutputOnly');

% Fill valves with button pushes
fprintf(['========Solenoid Trigger========\n',...
        'All Valves by entering     "A".\n'...
        'No Valves by entering      "0".\n'...
        'Valve 1 by entering        "1".\n',...
        'Valve 2 by entering        "2".\n'...
        'Quit by entering anything else.\n'])

valveFilling = 1;
while valveFilling
    keyPressed = input('? ','s');
    if keyPressed == '0'
        dS.outputSingleScan([0 0])
    elseif keyPressed == '1'
        dS.outputSingleScan([1 0])
    elseif keyPressed == '2'
        dS.outputSingleScan([0 1])
    elseif strcmpi(keyPressed,'a')
        dS.outputSingleScan([1 1])
    else
        dS.outputSingleScan([0 0])
        delete(dS)
        valveFilling = 0;
        fprintf('Done.\n')
    end
end

%% Cycle the output for debugging

doTest = 0;
if doTest
    
    daqreset; clc;
    close all force;
    clear all force;
    
    dS = daq.createSession('ni');
    dS.addDigitalChannel('Dev1','port0/line0:1','OutputOnly');
    
    for i = 1:100
        dS.outputSingleScan(repmat([1 1],1))
        pause(2)
        dS.outputSingleScan(repmat([0 0],1))
        pause(1)
    end
end
