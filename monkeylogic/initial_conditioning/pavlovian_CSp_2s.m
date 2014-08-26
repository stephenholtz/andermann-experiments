% Pavlovian Conditioning CSp - w/ 2 second stimulus duration
%
% Modified from RR and RF scripts
% SLH

disp('Stimulus: Pavlovian Food Reward (UCR)')

% Task object for timing file
taskObjMovie = 1; % associated with a movie in the "conditions file"

% Define time intervals (in ms)
stimulusDuration = 2000;     % Time the video is playing
solenoidDuration = 150;      % Open time for solenoid valve, requires calibration
slopTime         = 40;       % To prevent crashes, inserted gaps between commands...

totalConditionDuration  = stimulusDuration + solenoidDuration + slopTime*2; % Total time for the entire condition
fprintf('Ideal condition time: %d ms\n',totalConditionDuration);

% Threshold for counting a lick (ON/OFF is 6V/0V)
lickThreshold = 4;

% Start the movie
toggleobject(taskObjMovie,'Eventmarker',25);

% Period during movie when animal's lick is not counted as 
idle(slopTime);

% Window during which the video is playing when licks are registered
[licked, reactionTime] = eyejoytrack('acquiretouch',taskObjMovie,lickThreshold,stimulusDuration);
if licked
    % Correct Response on pavlovian (even numbers)
    trialerror(8);
    % Idle for the remaining stimulus time even if licked
    idle(stimulusDuration - reactionTime)
else 
    % No Response on pavlovian (odd numbers)
    trialerror(9); 
end

% Recieves reward regarless of lick or lick time
toggleobject(taskObjMovie,'Eventmarker',25);
idle(slopTime);
goodmonkey(solenoidDuration, 'Numreward',1,'TriggerVal', 5);
disp('     Reward delivered')
