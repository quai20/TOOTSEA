function RSK = RSKsmooth(RSK, varargin)

% RSKsmooth - Apply a low pass filter on specified channel.
%
% Syntax:  [RSK] = RSKsmooth(RSK, 'channel', 'channelName', [OPTIONS])
% 
% Low-pass filter a specified channel or multiple channels with a
% running average or median.  The sample being evaluated is always in
% the centre of the filtering window to avoid phase distortion.  Edge
% effects are handled by mirroring the original time series.
%
% Inputs: 
%    [Required] - RSK - Structure containing the logger data.
%
%                 channel - Longname of channel to filter. Can be a 
%                       single channel, or a cell array for multiple 
%                       channels.
%               
%    [Optional] - filter - The weighting function, 'boxcar' or 'triangle'.
%                       Use 'median' to compute the running median. 
%                       Defaults to 'boxcar.'
%
%                 profile - Profile number. Defaults to operate on all
%                       available profiles.  
%
%                 direction - 'up' for upcast, 'down' for downcast, or
%                       'both' for all. Defaults to all directions available.
%
%                 windowLength - The total size of the filter window. Must
%                       be odd. Default is 3.
%
%                 visualize - To give a diagnostic plot on specified
%                       profile number(s). Original and processed data will
%                       be plotted to show users how the algorithm works.
%                       Default is 0.
%
% Outputs:
%    RSK - Structure with filtered values.
%
% Example: 
%    rsk = RSKopen('file.rsk');
%    rsk = RSKreadprofiles(rsk, 'profile', 1:10); 
%    rsk = RSKsmooth(rsk, 'channel', {'Temperature', 'Salinity'}, 'windowLength', 17);
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-12-03


validFilterNames = {'median', 'boxcar', 'triangle'};
checkFilter = @(x) any(validatestring(x,validFilterNames));

validDirections = {'down', 'up', 'both'};
checkDirection = @(x) any(validatestring(x,validDirections));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'channel','');
addParameter(p, 'filter', 'boxcar', checkFilter);
addParameter(p, 'profile', [], @isnumeric);
addParameter(p, 'direction', [], checkDirection);
addParameter(p, 'windowLength', 3, @isnumeric);
addParameter(p, 'visualize', 0, @isnumeric);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
channel = p.Results.channel;
filter = p.Results.filter;
profile = p.Results.profile;
direction = p.Results.direction;
windowLength = p.Results.windowLength;
visualize = p.Results.visualize;


checkDataField(RSK)
if isempty(channel)
    RSKwarning('Please specify which channel(s) to apply the low pass filter.')
    return
end

chanCol = [];
channels = cellchannelnames(RSK, channel);
for chan = channels
    chanCol = [chanCol getchannelindex(RSK, chan)];
end
castidx = getdataindex(RSK, profile, direction);

if visualize ~= 0; 
    [raw, diagndx] = checkDiagPlot(RSK, visualize, direction, castidx); 
end

for c = chanCol
    for ndx = castidx
        in = RSK.data(ndx).values(:,c);
        switch filter
            case 'boxcar'
                out = runavg(in, windowLength);
            case 'median'
                out = runmed(in, windowLength);
            case 'triangle'
                out = runtriang(in, windowLength);
        end      
        RSK.data(ndx).values(:,c) = out;       
    end
    logdata = logentrydata(RSK, profile, direction);
    logentry = sprintf('%s filtered using a %s filter with a %1.0f sample window on %s.', RSK.channels(c).longName, filter, windowLength, logdata);
    RSK = RSKappendtolog(RSK, logentry);
end

if visualize ~= 0      
    for d = diagndx;
        figure
        doDiagPlot(RSK,raw,'ndx',d,'channelidx',chanCol,'fn',mfilename); 
    end
end 

end