%% runOptoVisStimExp.m
%
% Run an experiment to display stimuli and control a blue LED
% Design consists of 3 stimulus types: a 'blank', and two positions on the 
% monitor. Each of these three can occur with or without LED stimulation 
% wrapping around it. Currently this is one big ugly script that does 
% everything -- all andermann lab functions were specialized. Rather than
% having partial compatability, this starts more or less fresh.
%
% Calls:
%   CreateProceduralGaborMJLM.m - makes Gabor patches
%
% From retinotopic mapping scripts by RR/MJLM, esp procedural_gabor_MJLM
%
% SLH 2014
%#ok<*NBRAK,*UNRCH>
%--------------------------------------------------------------------------
%% Clean up workspace and daq 
%--------------------------------------------------------------------------
forceClear = 1;
if forceClear
    close all force; 
    clear all force;
end
clear forceClear

%--------------------------------------------------------------------------
%% Edit for each animal/experiment change
%--------------------------------------------------------------------------
animalName      = 'FAKEMOUSE00';
expName         = 'USELESSEXP-START';

%--------------------------------------------------------------------------
%% Set filepaths and variables
%--------------------------------------------------------------------------
% Add Psychtoolbox 3 to the path (and on my MAC for testing)
switch computer
    case {'MACI64'}
        addpath(genpath('/Users/stephenholtz/grad-repos/Psychtoolbox-3-master/'));
        tmpMetaFolderName   = '/Users/stephenholtz/Zocalo/stim_metadata';
        useDaqDev = 0;
        Screen('CloseAll');
        Screen('Preference', 'SkipSyncTests', 1);
    case {'PCWIN64'}
        addpath(genpath('C:\toolbox\Psychtoolbox'))
        tmpMetaFolderName   = 'D:\stim_metadata';
        useDaqDev = 1;
        daqreset;
        Screen('CloseAll');
    otherwise
        error('Unrecognized computer')
end

% Set up filepath for saving metadata
fullDateTime        = datestr(now,30);
expDate             = fullDateTime(1:8);
metaSaveDir = fullfile(tmpMetaFolderName,animalName,[expDate '_' expName]);
metaSaveFile = [fullDateTime '_' expName '_' animalName '.mat'];
if ~exist(metaSaveDir,'dir')
    mkdir(metaSaveDir);
end

%--------------------------------------------------------------------------
%% DAQ Setup
%--------------------------------------------------------------------------
if useDaqDev
    niOut = daq.createSession('ni');
    % Determine devID with daq.GetDevices or NI's MAX software
    devID = 'Dev1';
    % Add Analog Channels / names for documentation
    aO = niOut.addAnalogOutputChannel(devID,[0],'Voltage');
    aO(1).Name = 'Psych Toolbox Stimulus Encoding';
    % Add Digital Channels / names for documentation
    dIO = niIn.addDigitalChannel(devID,{'Port0/Line2'},'OutputOnly');
    dIO(1).Name = 'LED ON/OFF'; 
    clear devID
else
    disp('No Daq devices initialized (testing on macbook)')
end

%--------------------------------------------------------------------------
%% Configure psychtoolbox and stimulation
%--------------------------------------------------------------------------
% monitor struct has all information about the display monitor
% Setup/use andermann lab rig definitions
monitor.distance_cm    = 20;
monitor.model          = 'Dell epi rig';
monitor.id             = 1;
monitor.luminanceCalib = 0.37;

winID = Screen('OpenWindow', monitor.id, 128);
interval = Screen('GetFlipInterval', winID);
Screen('CloseAll');
monitor.framerate = 1/interval;

res = Screen('Resolution', monitor.id);
monitor.width_px = res.width;
monitor.height_px = res.height;
monitor.width_cm = 34;
monitor.height_cm = 27;
monitor.px_per_cm = monitor.width_px/monitor.width_cm;
monitor.width_cm = 34;
monitor.height_cm = 27;
monitor.field_view_degs = 2 * atand(monitor.width_cm / (2*monitor.distance_cm));
monitor.px_per_deg = monitor.width_px / monitor.field_view_degs;

clear interval res
%--------------------------------------------------------------------------
%% Set visual/LED stimulus parameters
%--------------------------------------------------------------------------
% stim is stimulus information, iterate over stim.stimLoc to make stimuli
% Padding time before and after the repeated stimuli
stim.durPad = 5;
% Stimulus on/off time in seconds converted into a ceil of 60 Hz
stim.durOff = 3;
stim.durOn = 1;
% Orientation (0 degrees = 'right' / 90 = 'up') andermann lab conventions
stim.orientation = 45+360;
% Spatial frequencies (cpd)
stim.sFreq = 0.04;
% Temporal frequencie (Hz)
stim.tFreq = 2;
% Contrast, from 0 to 1 (Positive values for sinusoidal, negative for step gratings.)
stim.contrast = -0.8;  %don't change
% Luminance to show at end of experiment 
% 0-(black) to 1-(white):
stim.endLuminance = 0.5;  % 0 (black) to 1 (white):
% Field of view, degrees of visual angle (-1==full screen)
stim.fieldOfViewDeg = 22.5;
stim.fieldOfViewRadiusPx = stim.fieldOfViewDeg * 0.5 * monitor.px_per_deg;
stim.aspectRatio = 1;
% Stim Locations, (-,-) = upper left, +15 +15 is off screen (my "blank" stimulus")
stim.stimLoc = [-11, 0; 0 0; +15 +15];
% Stimulus location order 1,2,3 (3 blank, 1:2 positions)
stim.stimLocOrder = repmat([1*ones(1,3) 2*ones(1,3) 3*ones(1,3)],1,2);
% Repeats and randomization
stim.nRepeats = 40;
% LED on(1) and off(0)
stim.ledOnOffOrder = [0*ones(1,9), 1*ones(1,9)];
stim.ledPreVisDurSecs = .5;
stim.ledPostVisDurSecs= .040;

% Instead of adding more variables to the frame_param_struct.m file, make
% a 'frame' struct here, where each entry is a new displayed stimulus 
% frame with LED and monitor information. 
% Expand stimulus list into single-frame list (frame struct)
frame = [];
nFramesOn       = ceil(stim.durOn * monitor.framerate);
nFramesOff      = ceil(stim.durOff * monitor.framerate);
nFramesPad      = ceil(stim.durPad * monitor.framerate);
nFramesLedPre   = ceil(stim.ledPreVisDurSecs * monitor.framerate);
nFramesLedPost  = ceil(stim.ledPostVisDurSecs * monitor.framerate);

% Blank initial duration (maybe for baselining)
frame.contrast = 0*ones(nFramesPad,1);
frame.led      = 0*ones(nFramesPad,1);

nStims = length(stim.stimLocOrder)*stim.nRepeats;
for iStim = 1:nStims
    % Current stimulus ind
    iCurrStim = mod(iStim-1,length(stim.stimLocOrder))+1;

    % Off parameters 
    visStart  = length(frame.contrast) + 1;
    visEnd    = visStart+nFramesOff;
    frame.contrast(visStart:visEnd) = 0;
    frame.led(visStart:visEnd) = 0;

    % On parameters
    visStart  = length(frame.contrast) + 1;
    visEnd    = visStart+nFramesOn;

    % Location of the stimulus (most important setting!)
    iLocation = stim.stimLocOrder(iCurrStim);
    frame.stimType(visStart:visEnd) = iLocation;
    frame.location(visStart:visEnd,:) = repmat(stim.stimLoc(iLocation,:),length([visStart:visEnd]),1);
    frame.contrast(visStart:visEnd) = stim.contrast;
    frame.orientation(visStart:visEnd) = stim.orientation;
    frame.sFreq(visStart:visEnd) = stim.sFreq;
    frame.tFreq(visStart:visEnd) = stim.tFreq;
    frame.fieldOfViewDeg(visStart:visEnd) = stim.fieldOfViewDeg;
    frame.fieldOfViewRadiusPx(visStart:visEnd) = stim.fieldOfViewRadiusPx ;

    % Get the phase of the gabor at each frame (from RR's script):
    %   Each frame advances time by 1/FRAMERATE seconds, so to get TF Hz
    %   temporal frequency, the grating has to be advanced by 
    %   (360/framerate) * TF degrees
    for iFrame = visStart:visEnd
        frame.phase(iFrame) = mod((iFrame+1-visStart)*(360/monitor.framerate)*stim.tFreq, 360);
    end

    % LED on and off (make sure it is the same length as visual stimuli fields)
    frame.led(visStart:visEnd) = 0;
    ledStart = visStart + nFramesLedPre;
    ledEnd = visEnd + nFramesLedPost;
    frame.led(ledStart:ledEnd) = stim.ledOnOffOrder(iCurrStim);
end
% Add some blank periods at the end
visStart  = length(frame.contrast) + 1;
visEnd    = visStart+nFramesPad;
frame.contrast(visStart:visEnd) = 0;

clear nFrames* nStims iStim nStims visStart visEnd ledStart ledEnd iLocation iCurrStim
%--------------------------------------------------------------------------
%% Save metadata before experiment
%--------------------------------------------------------------------------
% Move experiment info to the exp struct
exp.animalName = animalName;
exp.expName = expName;
exp.fullDateTime = fullDateTime;
exp.expDate = expDate; 
exp.metaSaveFile = metaSaveFile;
% Save an empty variable for the PTB timing / debugging struct
screenOut = [];
save(fullfile(metaSaveDir,metaSaveFile),'exp','monitor','stim','frame','screenOut','-v7.3')

clear expDate fullDateTime expName animalName screenOut
%--------------------------------------------------------------------------
%% Final setup + Present stimuli
%--------------------------------------------------------------------------
% Channel 0 is the PTB, Channel 1 is the LED Start with both at zero
if useDaqDev
    niOut.outputSingleScan([0;0]);
end

% Start screen with Gray background
medGrayColor = 255 * sqrt(0.5) * monitor.luminanceCalib;
winID = Screen('OpenWindow', monitor.id, medGrayColor);

% Move mouse pointer out of the way (also try to fully hide it):
import java.awt.Robot;
mouse = Robot;
screenSize = get(0, 'screensize');
mouse.mouseMove(screenSize(3), screenSize(4));
HideCursor(monitor.id);

[gaborID,~] = CreateProceduralGaborMJLM(winID,...
                            monitor.width_px,...
                            monitor.height_px,...
                            monitor.luminanceCalib);

% Draw the gabor once at zero contrast to make sure hardware gets
% initialized before the actual stimulus presentation begins
% kPsychDontDoRotation means that any rotation will be performed 
% by the gabor drawing function rather than by the Screen function.
Screen('DrawTexture',...
    winID,...
    gaborID,...
    [],...%sourceRect
    [],...%destinationRect
    0,...%orientation
    [],...%filterMode
    [],...%globalAlpha
    [],...%modulateColor
    [],...%textureShader
    kPsychDontDoRotation,... 
    [0, 0.01, 50, 0, 1, 0, 0, 0]);

% Perform initial flip to gray background:
Screen('Flip', winID);

% Animation loop:
% Previously had the first frame as a dummy frame, but here it is 
% a buffer period anyways, so it doesn't matter that it is far 
% slower.
for iFrame = 1:length(frame.contrast)
    % Always update the LED first, err on side of too much
    if useDaqDev
        niOut.outputSingleScan([0,frame.led(iFrame)]);
    end
    % Start GPU timer immediately before drawing the stimulus:
    % (Timer will automatically stop at next flip.)
    Screen('GetWindowInfo', winID, 5);
    destinationRect=CenterRect([0 0 monitor.width_px monitor.height_px],...
                                [0 + frame.location(iFrame,1)...
                                 0 + frame.location(iFrame,2)...
                                 monitor.width_px + frame.location(iFrame,1)...
                                 monitor.height_px + frame.location(iFrame,2)]);
    % Draw the Gabor patch using the "procedural texture" syntax:
    % Note: kPsychDontDoRotation = rotation will be performed by the gabor drawing 
    % function rather than by the Screen function
    Screen('DrawTexture',...
            winID,...
            gaborID,...
            [],...                  %sourceRect
            destinationRect,...    %destinationRect
            frame.orientation(iFrame),...
            [],...                  %filterMode
            [],...                  %globalAlpha
            [],...                  %modulateColor
            [],...                  %textureShader
            kPsychDontDoRotation,...%See above
            [frame.phase(iFrame), frame.sFreq(iFrame), frame.fieldOfViewRadiusPx(iFrame), frame.contrast(iFrame), stim.aspectRatio, 0, 0, 0]);

    % Flip next frame onto screen. PTB pauses execution until the flip has happened.
    [screenOut.systemTimeStamp(iFrame),...
     screenOut.onsetTimeEstimate(iFrame),...
     screenOut.endOfFlipTimeStamp(iFrame),...
     screenOut.missed(iFrame),...
     screenOut.beampos(iFrame)] = Screen('Flip', winID);

    % Send analogue out at the end of a frame that is the stimulus position
    % pos 1 = 1V, pos 2 = 2V; pos 3 = 3V; may not be used but useful redundancy
    % no value sent during the off periods (when contrast is 0)
    if useDaqDev
        encodedStimVoltage = (abs(frame.contrast(iFrame)) > 0) * (frame.stimType(iFrame));
        niOut.outputSingleScan([encodedStimVoltage,frame.led(iFrame)]);
        niOut.outputSingleScan([0,frame.led(iFrame)]);
    end

    % After drawing and flipping, poll GPU to return processing time:
    while true
        winfo = Screen('GetWindowInfo', winID);
        if winfo.GPULastFrameRenderTime > 0
            screenOut.gpuDrawtime(iFrame) = winfo.GPULastFrameRenderTime;
            break
        end
    end

    % Test for keypress to abort
    if KbCheck
        break
    end
end

%--------------------------------------------------------------------------
%% End experiment
%--------------------------------------------------------------------------
% Save metadata again (now with screenOut populated)
save(fullfile(metaSaveDir,metaSaveFile),'exp','monitor','stim','frame','screenOut','-v7.3')

% Should already be no signal out, just to be sure:
if useDaqDev
    niOut.outputSingleScan([0,0]);
end

% A final synced flip, so we can be sure all drawing is finished when we
% reach this point:
Screen('Flip', winID);

% Flip to empty screen as final state of stimulus presentation:
finalColor = repmat(WhiteIndex(winID) * sqrt(stim.endLuminance) * stim.luminanceCalibration, 3);
Screen('FillRect', winID, finalColor);
Screen('Flip', winID);

% Wait at the end until keyboard press is detected:
disp('Waiting for Keyboard Press, stimuli complete');
KbWait

% Close window, release all resources
Screen('CloseAll');
ShowCursor;
