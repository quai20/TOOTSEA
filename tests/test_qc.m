%
% Testing some qualification functions of tootsea
% Created : 27/04/2020
% Author : kbalem

%%%
function tests = test_qc
    tests = functiontests(localfunctions);
end
%%%  

% Actual tests
function test_qualifRoutines(testCase)
    %
    qc_conf=read_test_conf();
    [PARAMETERS,ParamList]=create_test_PARAM();
    
    for i=1:4
        eval(['hQC_Serie = ',qc_conf(i).file,'(qc_conf(i),ParamList,PARAMETERS,1,1);']);          
        assert(isnumeric(hQC_Serie),['QC routine : ',qc_conf(i).file,' failed to return numeric']);
    end      
end

function [PARAMETERS,ParamList]=create_test_PARAM()
    time=1:1000;    
    ts1=TimeSerie('T1',time,10*rand(1,1000));    
    PARAMETERS=[ts1];
    ParamList={'T1'};
end

function qc_conf=read_test_conf()
    fid=fopen('tests/qc_conf_test.txt','r');
        for i=1:4 %QC NuMBER   
            line=fgetl(fid); %--------------------
            line=fgetl(fid); %#QC TITLE
            qc_conf(i).file=fgetl(fid); %filename
            qc_conf(i).parm=str2num(fgetl(fid)); %test conf            
            qc_conf(i).val=str2num(fgetl(fid)); %QC values
        end
    fclose(fid);
end