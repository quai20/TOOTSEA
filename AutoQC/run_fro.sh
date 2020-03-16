#!/bin/csh
#
#LAUNCH MATLAB ENV NO DESKTOP AND RUN TOOTSEA REQ

set SRC = /home4/homedir4/perso/kbalem/TOOTSEA_b2

cd $SRC

matlab_2015 -nodesktop -nosplash -r "addpath(genpath('AutoQC')); addpath(genpath('Common')); addpath(genpath('GUI')); addpath(genpath('Parser')); addpath(genpath('Science')); main; "

