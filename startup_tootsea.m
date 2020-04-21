function startup_req()
%
addpath(genpath('AutoQC')); 
addpath(genpath('Common')); 
addpath(genpath('GUI')); 
addpath(genpath('Parser')); 
addpath(genpath('Science')); 

%START TOOTSEA REQ
!synclient HorizTwoFingerScroll=0
main;