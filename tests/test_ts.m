%
% Testing some functions of tootsea
% Created : 27/04/2020
% Author : kbalem

%%% 
function tests = test_io
    tests = functiontests(localfunctions);
end
%%%

% Actual tests
function test_create(testCase)
    %testing create TS object
    TS=create_test_TS();
    assert(isobject(TS),'Creating Time Serie object failed');
    %plot testing
    assert(ishandle(TS.Plot(axes())),'Plotting Time Serie object failed');
end

function TS=create_test_TS()
    time=1:1000;
    data=rand(1,1000);
    TS=TimeSerie('TEST',time,data);    
end
