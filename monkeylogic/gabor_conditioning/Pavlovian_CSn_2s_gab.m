% Variable Conditional Script

% Task Object
Target = 1;



% Define Time Intervals (in ms)
Total_visual_stim_time = 2000;
duration_reward = 100;
no_response_idle = duration_reward;
buffer_time = 100;
idle_Time_pre_stim = 500;
idle_Time_post_stim = 500;
additional_wait_time = 1000;
sample_time = Total_visual_stim_time - idle_Time_pre_stim;



threshold = 4; % pulses at 6 v 


toggleobject(Target,'Eventmarker',23);
idle(idle_Time_pre_stim);
[ontarget rt] = eyejoytrack('acquiretouch',Target,threshold,sample_time);
if ~ontarget
    trialerror(3); % Ignored
    idle(buffer_time);
    toggleobject(Target,'Eventmarker',24);
    idle(buffer_time);
    return
end
trialerror(2); % Incorrect Response
idle(sample_time - rt);
idle(idle_Time_post_stim); % stimuli ending too early??
toggleobject(Target,'Eventmarker',24);
idle(buffer_time);
