%
% Testing some parsing functions of tootsea
% Created : 27/04/2020
% Author : kbalem

%%%
function tests = test_parser
    tests = functiontests(localfunctions);
end
%%%  

% Actual tests
function test_seabird(testCase)
    %testing reading binary input from seabird
    SBST=SBE3x('Data_test/SBE/microcatifremer3999.asc',1);
    assert(isstruct(SBST),'reading of seabird testfile failed');                
end

function test_nortek(testCase)
    %testing reading binary input from aquadopp
    AQST = aquadoppVelocityParse({'Data_test/CURRENT/AQD2034_AS1001.aqd'},1);
    assert(isstruct(AQST),'reading of nortek testfile failed');
end

function test_rdi(testCase)
    %test reading binary input from workhorse adcp
    WHST=workhorseParse('Data_test/ADCP/ov05-2Cbis-wh75.000');
    assert(isstruct(WHST),'reading of rdi testfile failed');
end

