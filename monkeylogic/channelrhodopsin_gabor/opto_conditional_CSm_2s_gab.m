% Conditional Script Conditioning CSm - w/ 4 second duration
% 2 secons of stimulus, 2 seconds of blank window
% 
% Using what Monkeylogic calls "TTL 1" to trigger the punishment
% (punishmentObj)
%
% Modified from RR and RF scripts
% SLH

disp('Stimulus: Conditional Punishment (CS-)')

% Task object for timing file
taskObjBlank  = 1;
taskObjMovie  = 2;
punishmentObj = 3;

% Define Time Intervals (in ms)
stimulusDuration     = 2000;     % Time the video is playing (bars or blank)
rewardSampleDuration = 2000;     % Time over which mouse can lick and be rewarded
solenoidDuration     = 75;      % Open time for solenoid valve, requires calibration
slopTime             = 40;       % To prevent crashes, inserted gaps between commands...

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
    % Lick Response (incorrect)
    trialerror(5);
    toggleobject(punishmentObj, 'Status','On');
    idle(solenoidDuration)
    toggleobject(punishmentObj, 'Status','Off');
    % Only idle if there is time left
    if (rewardSampleDuration - solenoidDuration - slopTime - reactionTime) > 0
        idle(rewardSampleDuration - solenoidDuration - reactionTime)
    end
    disp('     Punishment delivered (False Alarm)')
else
    % No response, (correct) 
    trialerror(4);
    disp('     Punishment avoided (Correct Reject)')
end

idle(slopTime);
toggleobject(taskObjBlank,'status','off');% Variable Conditional Script
