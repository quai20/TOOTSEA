function RSK = RSKcreate(varargin) 

% RSKcreate - Create rsk structure with given time series data.
%
% Syntax: RSK = RSKcreate('tstamp',tstamp,'values',values,...
%               'channel',channel,'unit',unit,[OPTIONS])
%
% RSKcreate creates rsk structure with data that could originate from
% other CTDs or floats, which allows users to apply RSKtools post
% processing and other functions to any data they prefer.
%
% Inputs:
%    [Required] - tstamp - an array of time stamps (datenum format) of 
%                 size (n,1)
%
%                 values - a matrix of data of size (n,m)
%
%                 channel - cell array with channel names of size(1,m)
%
%                 unit - cell array with channel units of size(1,m)
%
%    [Optional] - filename - filename to give a general description of the
%                 data, default is 'sample.rsk'
%
%                 model - instrument model from which data was collected, 
%                 default is 'unknown'
%    
%                 serialID - serial ID of the instrument from which data
%                 was collected, default is 0
%
% Outputs:
%    RSK - created RSK structure with given time series data
%
% Example:
%    tstamp = [735722.625196759;
%              735722.625198692; 
%              735722.625200613];
%    values =  [39.9973,   16.2695,   10.1034;
%               39.9873,   16.2648,   10.1266;
%               39.9887,   16.2553,   10.1247];
%    channel = {'Conductivity','Temperature','Pressure'};
%    unit = {'mS/cm','°C','dbar'};
%    rsk = RSKcreate('tstamp',tstamp,'values',values,...
%                    'channel',channel,'unit',unit);
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-12-19


validateChannelsUnits = @(x) (ischar(x) || iscell(x));

p = inputParser;
addParameter(p,'tstamp',[], @isnumeric);
addParameter(p,'values',[], @isnumeric);
addParameter(p,'channel','', validateChannelsUnits);
addParameter(p,'unit', '', validateChannelsUnits);
addParameter(p,'filename','sample.rsk', @ischar);
addParameter(p,'model','unknown', @ischar);
addParameter(p,'serialID', 0, @isnumeric);
parse(p, varargin{:})

tstamp = p.Results.tstamp;
values = p.Results.values;
channel = p.Results.channel;
unit = p.Results.unit;
filename = p.Results.filename;
model = p.Results.model;
serialID = p.Results.serialID;


RSK = [];
if isempty(tstamp)
    RSKwarning('Please specify tstamp.')
    return
elseif isempty(values)
    RSKwarning('Please specify values.')
    return
elseif isempty(channel)
    RSKwarning('Please specify channel names.')
    return
elseif isempty(unit)
    RSKwarning('Please specify channel units.')
    return
else
    % do nothing
end

% Check consistency among input arguments
[nsamples,nchannels] = size(values);
if nsamples ~= length(tstamp)
    RSKerror('The length of time stamp is not equal to number of rows in values.')
end

if nchannels ~= length(channel) || nchannels ~= length(unit)
    RSKerror('The length of channel or unit is not equal to number of columns in values.')
end

% Create data, channel and other logger metadata fields
tstamp = tstamp(:);
data = struct('tstamp',tstamp,'values',values);
shortName = getchannelshortname(channel);
channels = struct('shortName',shortName','longName',channel','units',unit');
RSK = struct('data',data,'channels',channels);

RSK.toolSettings.filename = filename; 
RSK.toolSettings.readHiddenChannels = 1;

RSK.dbInfo.version = '2.0.0';
RSK.dbInfo.type = 'full';

RSK.instruments.serialID = serialID;
RSK.instruments.model = model;

RSK.deployments.deploymentID = 1;
RSK.deployments.serialID = serialID;
RSK.deployments.firmwareVersion = '11.62';
RSK.deployments.timeOfDownload = datenum2rsktime(max(tstamp));
RSK.deployments.name = filename;
RSK.deployments.sampleSize = nsamples;

RSK.schedules.scheduleID = 1;
RSK.schedules.deploymentID = 1;
RSK.schedules.samplingPeriod = round(median(diff(tstamp))*86400*1000); % milliseconds
RSK.schedules.mode = 'continuous';
RSK.schedules.gate = '';

RSK.epochs.deploymentID = 1;
RSK.epochs.startTime = min(tstamp);
RSK.epochs.endTime = max(tstamp);

RSK = RSKappendtolog(RSK,'RSK structure created by RSKcreate function.');

end