% Blank screen (unrewarded) with 2 second stimulus duration 
% AND surrounding 1 sec of opto stimulation
%
% SLH

disp('Stimulus: Blank with Opto')

% Task object for timing file
taskObjBlank = 1;
optoObj      = 2;

% Define time intervals (in ms)
preStimOptoDuration  = 500;      % Time before stimulus to use opto
postStimOptoDuration = 500;      % Time after stimulus to use opto
stimulusDuration     = 2000;     % Time the video is playing
slopTime             = 40;       % To prevent crashes, inserted gaps between commands...

 % Total time for the entire condition
totalConditionDuration  = preStimOptoDuration + postStimOptoDuration + stimulusDuration + slopTime*2;
fprintf('Ideal condition time: %d ms\n',totalConditionDuration);

% Start the opto
toggleobject(punishmentObj, 'Status','On');
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
    idle(stimulusDuration - reactionTime);
else 
    % Correct Response on blank = no lick (even numbers)
    trialerror(6);
end

% No reward regardless of lick
idle(slopTime);
toggleobject(taskObjBlank,'status','off','Eventmarker',24);

% Turn off the opto stim
idle(postStimOptoDuration)
toggleobject(optoObj, 'Status','Off');
