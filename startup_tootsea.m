function startup_tootsea()
%
addpath(genpath('AutoQC')); 
addpath(genpath('Common')); 
addpath(genpath('GUI')); 
addpath(genpath('Parser')); 

%START TOOTSEA REQ
!synclient HorizTwoFingerScroll=0
main;