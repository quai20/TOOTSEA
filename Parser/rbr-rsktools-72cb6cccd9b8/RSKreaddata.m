function RSK = RSKreaddata(RSK, varargin)

% RSKreaddata - Read the data tables from an RBR RSK SQLite file.
%
% Syntax:  [RSK] = RSKreaddata(RSK, [OPTIONS])
% 
% Reads the actual data tables from the RSK file previously opened
% with RSKopen(). Will either read the entire data structure, or a subset
% specified by the 't1' and 't2' arguments.
%
% Note: If the file type is 'skinny' the file has to be opened with
% Ruskin before RSKtools can read the data because the data is in a
% raw bin file.
% 
% Inputs: 
%    [Required] - RSK - Structure containing the logger metadata returned 
%                       by RSKopen. If provided as the only argument the 
%                       data for the entire file is read. Depending on the 
%                       amount of data in your dataset, and the amount of 
%                       memory on your computer, you can read bigger or 
%                       smaller chunks before Matlab complains and runs out
%                       of memory. 
%
%    [Optional] - t1 - Start time for range of data to be read, specified
%                       using the MATLAB datenum format. 
%
%                 t2 - End time for range of data to be read, specified
%                       using the MATLAB datenum format. 
%
%
% Outputs:
%    RSK - Structure containing the logger metadata, along with the
%          added 'data' fields. Note: This function replaces all entries
%          and elements in the data field. 
%
% Example: 
%    rsk = RSKopen('sample.rsk');  
%    % Read 1/2 day of data since logger started.
%    rsk = RSKreaddata(rsk, 't2', RSK.epochs.startTime+0.5);
%
% See also: RSKopen, RSKreadburstdata.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-07-10

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 't1', [], @isnumeric);
addParameter(p, 't2', [], @isnumeric);
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

if t2 <= t1
    RSKerror('The end time (t2) must be greater (later) than the start time (t1).')
end



%% Check if file type is skinny
if strcmp(RSK.dbInfo(end).type, 'skinny')
    RSKerror('File must be opened in Ruskin before RSKtools can read the data.');
end



%% Load data
sql = ['select tstamp/1.0 as tstamp,* from data where tstamp between ' num2str(t1) ' and ' num2str(t2) ' order by tstamp'];
results = doSelect(RSK, sql);
if isempty(results)
    RSKwarning('No data found in that interval.')
    return
end


results = removeunuseddatacolumns(results);
results = arrangedata(results);

t=results.tstamp';
results.tstamp = rsktime2datenum(t);

isCoda = isfield(RSK,'instruments') && isfield(RSK.instruments,'model') && strcmpi(RSK.instruments.model,'RBRcoda');
isBPR = isfield(RSK,'instruments') && isfield(RSK.instruments,'model') && strncmpi(RSK.instruments.model,'RBRquartz',9);
if ~strcmpi(RSK.dbInfo(end).type, 'EPdesktop') && ~isCoda && ~isBPR && isfield(RSK,'instrumentChannels')     
    instrumentChannels = RSK.instrumentChannels;
    if isfield(instrumentChannels,'channelStatus')
        ind = logical(bitget([instrumentChannels.channelStatus],3));
        instrumentChannels(ind) = [];
        isHidden = logical(bitget([instrumentChannels.channelStatus],1));          
        if ~RSK.toolSettings.readHiddenChannels
            results.values = results.values(:,~isHidden);
        end
    end
end

%% Put data into data field of RSK structure.
RSK.data = results;

%% Calculate Salinity  
% NOTE : We no longer automatically derive salinity when you read data from
% database. Use RSKderivesalinity(RSK) to calculate salinity.

end