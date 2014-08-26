% Variable Conditional Script

% Task Object
%Target = 1;
mov = 2
blank = 1

% Define Time Intervals (in ms)
Total_visual_stim_time = 100;
duration_reward = 300;
no_response_idle = 100;
buffer_time = 100;
idle_Time_pre_stim = Total_visual_stim_time-100;
idle_Time_post_stim = Total_visual_stim_time-100;
sample_time = 1000;



threshold = 4; % pulses at 6 v 



toggleobject(blank, 'Eventmarker', 23);
idle(buffer_time);
[ontarget rt] = eyejoytrack('acquiretouch',blank,threshold,sample_time);
if ~ontarget
    trialerror(6); % No response
    idle(buffer_time);
    goodmonkey(duration_reward, 'Numreward',1,'TriggerVal', 5);
    idle(buffer_time);
    toggleobject(blank,'status','off', 'Eventmarker', 24);
    idle(buffer_time);
    return
end
    trialerror(7); % Lick response
    idle(buffer_time);
    toggleobject(blank,'status','off','Eventmarker',24);
    idle(buffer_time);