% Blank screen (unrewarded) with 2 second stimulus duration
%
% Modified from RR and RF scripts
% SLH

disp('Stimulus: Blank')

% Task object for timing file
taskObjBlank = 1;

% Define time intervals (in ms)
stimulusDuration        = 2000;     % Time the video is playing
slopTime                = 50;       % To prevent crashes, inserted gaps between commands...

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
    trialerror(7);
    % Idle for the remaining stimulus time even if licked
    idle(stimulusDuration - reactionTime);
else 
    % Correct Response on blank = no lick (even numbers)
    trialerror(6);
end

% No reward regardless of lick
idle(slopTime);
toggleobject(taskObjBlank,'status','off','Eventmarker',25);
idle(slopTime);
