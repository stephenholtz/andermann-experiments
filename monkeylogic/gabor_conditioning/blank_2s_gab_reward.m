% Blank screen (unrewarded) with 2 second stimulus duration
%
% Modified from RR and RF scripts
% SLH

disp('Stimulus: Blank')

% Task object for timing file
taskObjBlank = 1;

% Define time intervals (in ms)
stimulusDuration = 2000;     % Time the video is playing
slopTime         = 50;       % To prevent crashes, inserted gaps between commands...
solenoidDuration = 150;      % Open time for solenoid valve, requires calibration

totalConditionDuration  = stimulusDuration + slopTime*2; % Total time for the entire condition
fprintf('Ideal condition time: %d ms\n',totalConditionDuration);

% Threshold for counting a lick (ON/OFF is 6V/0V)
lickThreshold = 4;

% Start the movie
toggleobject(taskObjBlank,'Eventmarker',25);

% Period during movie when animal's lick is not counted
idle(slopTime);

% Window during which the video is playing when licks are registered
[licked, reactionTime] = eyejoytrack('acquiretouch',taskObjBlank,lickThreshold,stimulusDuration);
if licked
    % Incorrect Response on blank = lick (odd numbers)
    % Except in this case I am copying rohan's convention
    % and making the blank lick an even number
    trialerror(6);
    % Idle for the remaining stimulus time even if licked
    goodmonkey(solenoidDuration, 'Numreward',1,'TriggerVal', 5);
    idle(stimulusDuration - reactionTime - solenoidDuration);
else 
    trialerror(7);
end
idle(slopTime);
toggleobject(taskObjBlank,'status','off','Eventmarker',25);
idle(slopTime);
