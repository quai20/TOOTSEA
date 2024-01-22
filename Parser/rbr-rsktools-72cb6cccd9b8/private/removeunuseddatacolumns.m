function dataresults = removeunuseddatacolumns(results)

%REMOVEUNUSEDDATACOLUMNS - Remove data that is unused, if they are present. 
%
% Syntax:  [dataresults] = REMOVEUNUSEDDATACOLUMNS(results)
%
% Data queries may contain columns that are unnecessary in the RSK
% structure. These columns are tstamp_1 and datasetId; they are removed if
% they are present.
%
% Inputs:
%    results - Output from the SQL query to a data table.
%
% Outputs:
%    dataresults - Data table without tstamp_1 and datasetId.
%
% See also: RSKreaddata, RSKreadburstdata.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-06-21

dataresults = rmfield(results,'tstamp_1');

names = fieldnames(dataresults);
fieldmatch = strcmpi(names, 'datasetid');

if sum(fieldmatch)
    dataresults = rmfield(dataresults, names(fieldmatch));
end

end