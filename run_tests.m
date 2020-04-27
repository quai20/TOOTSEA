%
% My own test suite simple setup
% Created : 27/04/2020
% Author : kbalem%
% 

% load path
addpath(genpath('AutoQC')); 
addpath(genpath('Common')); 
addpath(genpath('GUI')); 
addpath(genpath('Parser')); 
addpath(genpath('Data_test')); 
addpath(genpath('tests')); 

%Find test_*** in tests directory & fill test list
test_list={};

list=dir('tests');
for i=1:length(list)
    if(regexp(list(i).name,'test_.*.m'))        
        test_list=[test_list,list(i).name];
    end
end

%Run tests
for i=1:length(test_list)    
    eval(['run(',test_list{i}(1:end-2),')']);
end