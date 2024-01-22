function RSK = readevents(RSK, varargin)

% readevents - Read the events from an RBR RSK SQLite file.
%
% Syntax:  [RSK] = readevents(RSK, [OPTIONS])
% 
% Reads the events from the RSK file previously opened with
% RSKopen(). Either reads all the events or a subset specified by the
% 't1' and 't2' input arguments.
% 
% Inputs: 
%    [Required] - RSK - Structure containing the logger metadata returned 
%                       by RSKopen. If provided as the only argument events
%                       for the entire file are read. 
%
%    [Optional] - t1 - Start time for range of data to be read, specified
%                       using the MATLAB datenum format. 
%                 t2 - End time for range of data to be read, specified
%                       using the MATLAB datenum format. 
%
% Example: 
%    RSK = RSKopen('sample.rsk');  
%    RSK = readevents(RSK);
%
% See also: RSKopen, RSKreaddata, RSKreadburstdata.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-09-14

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addOptional(p, 't1', [], @isnumeric);
addOptional(p, 't2', [], @isnumeric);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
t1 = p.Results.t1;
t2 = p.Results.t2;



if isempty(t1)
    t1 = RSK.epochs.startTime;
end
if isempty(t2)
    t2 = RSK.epochs.endTime;
end
t1 = datenum2rsktime(t1);
t2 = datenum2rsktime(t2);



sql = ['select tstamp/1.0 as tstamp, deploymentID, type, sampleIndex, channelIndex from events where tstamp/1.0 between ' num2str(t1) ' and ' num2str(t2) ' order by tstamp'];
results = doSelect(RSK, sql);
if isempty(results)
    return
end



results = arrangedata(results);
t=results.tstamp';
results.tstamp = rsktime2datenum(t);
RSK.events=results;

end

