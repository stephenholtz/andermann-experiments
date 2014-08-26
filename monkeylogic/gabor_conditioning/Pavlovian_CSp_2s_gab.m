%Pavlovian Conditioning CSp

% Task Object
Target = 1;


% Define Time Intervals (in ms)
Total_visual_stim_time = 2000;
% wait_for_pic = 1000;
sample_time = 1500;
duration_reward = 300;
no_response_idle = duration_reward;
buffer_time = 100;
idle_Time = Total_visual_stim_time - sample_time  - buffer_time;
additional_wait_time = 1000;


threshold = 4; % pulses at 6 v 


toggleobject(Target,'Eventmarker',23);
idle(idle_Time);
[ontarget rt] = eyejoytrack('acquiretouch',Target,threshold,sample_time);
if ~ontarget
    trialerror(9); % No Response
    idle(buffer_time)
    toggleobject(Target,'Eventmarker',24);
    idle(buffer_time);
    goodmonkey(duration_reward, 'Numreward',1,'TriggerVal', 5);
    idle(buffer_time);
    return
end
trialerror(8); % Correct Response
idle(buffer_time); % stimuli ending too early??
idle(additional_wait_time);
toggleobject(Target,'Eventmarker',24);
idle(buffer_time);
goodmonkey(duration_reward, 'Numreward',1,'TriggerVal', 5);
idle(buffer_time);