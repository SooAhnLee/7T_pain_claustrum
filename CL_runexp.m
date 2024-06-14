cd('/Users/7t_mri/Documents/7TCL/7TCL_codes');
clear all; close all; clc;

[subjID, basedir, ts] = CL_fMRI_paintask_subinfo;
cd(basedir);
addpath(genpath(basedir));

%% Run experiment
%% Run 01
CL_fMRI_paintask_240527_mr(subjID, 1, basedir, 'pre', 'audio', 'heat');

%% Run 02
CL_fMRI_paintask_240527_mr(subjID, 2, basedir, 'audio', 'heat');

%% Run 03
CL_fMRI_paintask_240527_mr(subjID, 3, basedir, 'audio', 'heat');

%% Run 04
CL_fMRI_paintask_240527_mr(subjID, 4, basedir, 'audio', 'heat');

%% T1 scan
CL_fMRI_T1(subjID, basedir);

