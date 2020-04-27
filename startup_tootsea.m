function startup_tootsea()
%
addpath(genpath('AutoQC')); 
addpath(genpath('Common')); 
addpath(genpath('GUI')); 
addpath(genpath('Parser')); 
addpath(genpath('Data_test')); 
addpath(genpath('tests')); 

%START TOOTSEA REQ
!synclient HorizTwoFingerScroll=0
main;