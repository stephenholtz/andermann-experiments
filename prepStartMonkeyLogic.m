%% Prepare monkeylogic path for epi/opto rig
clear all force;
close all force;

% Add the experiment repository to the path
repoDir = fileparts(which(mfilename));
restoredefaultpath;
addpath(genpath(repoDir));

% Add the monkeylogic repository to the path
monkeyDir = fullfile(repoDir,'..','monkeylogic-running');
addpath(genpath(monkeyDir));

cd(monkeyDir);

% Start monkeylogic
monkeylogic;