% Variable Conditional Script

% Task Object
%Target = 1;
mov = 2
blank = 1

% Define Time Intervals (in ms)
Total_visual_stim_time = 2000;
duration_reward = 300;
no_response_idle = 100;
buffer_time = 100;
idle_Time_pre_stim = Total_visual_stim_time-100;
idle_Time_post_stim = Total_visual_stim_time-100;
sample_time = Total_visual_stim_time-100;



threshold = 4; % pulses at 6 v 


toggleobject(mov,'Eventmarker',25);
idle(Total_visual_stim_time);
toggleobject(mov,'status','off','Eventmarker',26);
idle(buffer_time);
toggleobject(blank);
idle(buffer_time);
[ontarget rt] = eyejoytrack('acquiretouch',blank,threshold,sample_time);
if ~ontarget
    trialerror(1); % No response
    idle(buffer_time);
    toggleobject(blank,'status','off');
    idle(buffer_time);
    return
end
trialerror(0); % Correct Response
idle(buffer_time);
goodmonkey(duration_reward, 'Numreward',1,'TriggerVal', 5);
idle(buffer_time);
toggleobject(blank, 'status','off');
idle(buffer_time);
