% Pavlovian punishment - w/ 4 second duration
% 2 secons of stimulus, 2 seconds of blank window
% 
% Modified from RR and RF scripts
% SLH

disp('Stimulus: Pavlovian Punishment')

% Task object for timing file
taskObjBlank = 1;
taskObjMovie = 2;
punishmentObj = 3;

% Define Time Intervals (in ms)
stimulusDuration        = 2000;     % Time the video is playing (bars or blank)
rewardSampleDuration    = 2000;     % Time over which mouse can lick and be rewarded
solenoidDuration        = 75;      % Open time for solenoid valve, requires calibration
slopTime                = 40;       % To prevent crashes, inserted gaps between commands...

totalConditionDuration  = stimulusDuration + solenoidDuration + slopTime*3; % Total time for the entire condition
fprintf('Ideal condition time: %d ms\n',totalConditionDuration);

% Threshold for counting a lick (ON/OFF is 6V/0V)
lickThreshold = 4;

% Display video, then turn off 
toggleobject(taskObjMovie,'Eventmarker',25);
idle(stimulusDuration);
toggleobject(taskObjMovie,'status','off','Eventmarker',26);
idle(slopTime);

% Display blank screen (also = reward period) and wait for licks during
toggleobject(taskObjBlank);
idle(slopTime);
[licked, reactionTime] = eyejoytrack('acquiretouch',taskObjBlank,lickThreshold,rewardSampleDuration);
if licked
    % Incorrect response, shouldn't lick to punished
    trialerror(9);
    idle(rewardSampleDuration - reactionTime)
else
    % No response, correct
    trialerror(8);
end
% deliver solenoid regardless of lick
toggleobject(taskObjBlank);
toggleobject(punishmentObj, 'status','on');
idle(solenoidDuration)
toggleobject(punishmentObj, 'status','off');
disp('     Punishment delivered')
