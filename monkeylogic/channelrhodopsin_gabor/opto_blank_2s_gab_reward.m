% Blank screen rewarded with 2 second stimulus duration
% AND opto stim
%
% SLH

disp('Stimulus: Blank Opto with reward')

% Task object for timing file
taskObjBlank = 1;
optoObj      = 2;

% Define time intervals (in ms)
preStimOptoDuration  = 500;      % Time before stimulus to use opto
postStimOptoDuration = 500;      % Time after stimulus to use opto
stimulusDuration     = 2000;     % Time the video is playing
slopTime             = 50;       % To prevent crashes, inserted gaps between commands...
solenoidDuration     = 225;      % Open time for solenoid valve, requires calibration

 % Total time for the entire condition
totalConditionDuration  = preStimOptoDuration + postStimOptoDuration + stimulusDuration + solenoidDuration + slopTime*2;
fprintf('Ideal condition time: %d ms\n',totalConditionDuration);

% Start the opto
toggleobject(optoObj, 'Status','On');
idle(preStimOptoDuration)

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
    trialerror(7);
    % Idle for the remaining stimulus time even if licked
    goodmonkey(solenoidDuration, 'Numreward',1,'TriggerVal', 5);
    idle(stimulusDuration - reactionTime - solenoidDuration);
else 
    trialerror(6);
end
idle(slopTime);
toggleobject(taskObjBlank,'status','off','Eventmarker',25);

% Turn off the opto stim
idle(postStimOptoDuration)
toggleobject(optoObj, 'Status','Off');
