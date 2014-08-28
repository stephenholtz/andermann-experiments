%% Trip solenoids hooked up to a 5V transistor switch  
% 
% Works with legacy and session-based interface

daqreset; clc;
close all force;
clear all force;

% Fill valves with button pushes
fprintf(['========Solenoid Trigger========\n',...
        'All Valves by entering     "A".\n'...
        'No Valves by entering      "0".\n'...
        'Valve 1 by entering        "1".\n',...
        'Valve 2 by entering        "2".\n'...
        'Quit by entering anything else.\n'])
    
valveFilling = 1;

switch computer('arch')
    case {'win32'}
        dio = digitalio('nidaq','Dev1');
        addline(dio,0:1,'out');
        start(dio)

        while valveFilling
            keyPressed = input('? ','s');
            if keyPressed == '0'
                putvalue(dio,[0 0])
            elseif keyPressed == '1'
                putvalue(dio.Line(1),1)
            elseif keyPressed == '2'
                putvalue(dio.Line(2),1)
            elseif strcmpi(keyPressed,'a')
                putvalue(dio,[1 1])
            else
                putvalue(dio,[0 0])
                delete(dio)
                valveFilling = 0;
                fprintf('Done.\n')
            end
        end
    case {'win64'}
        dS = daq.createSession('ni');
        dS.addDigitalChannel('Dev1','port0/line0:1','OutputOnly');
        
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
    otherwise
        error('Computer architecture not accounted for')
end
