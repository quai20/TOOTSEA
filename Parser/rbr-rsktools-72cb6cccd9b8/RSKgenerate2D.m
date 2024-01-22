function RSK = RSKgenerate2D(RSK, varargin)

% RSKgenerate2D - Generate data for 2D plot by RSKimages.
%
% Syntax:  RSK = RSKgenerate2D(RSK, [OPTIONS])      
%
% Arranges a series of profiles from selected channels into in a 3D matrix.  
% The matrix has dimensions MxNxP, where M is the number depth or pressure 
% levels, N is the number of profiles, and P is the number of channels.  
% Arranged in this way, the matrices are useful for analysis and for 2D 
% visualization (RSKimages uses RSKgenerate2D). It may be particularly 
% useful for users wishing to visualize multidimensional data without using
% RSKimages. Each profile must be placed on a common reference grid before 
% using RSKgenerate2D (see RSKbinaverage). 
%
% Note: Calling RSKimages may overwrite RSK.im field if RSKimages allows
% RSK as outputs.
%
% Inputs:
%   [Required] - RSK - Structure, with profiles as read using RSKreadprofiles.
%
%   [Optional] - channel - Longname of channel to generate data, can be 
%                      multiple in a cell, if no value is given it will use
%                      all channels.
%
%                profile - Profile numbers to use. Default is to use all
%                      available profiles.  
%
%                direction - 'up' for upcast, 'down' for downcast. Default
%                      is down when both directions are available.
%
%                reference - Channel that will be used as y dimension. 
%                      Default is 'Sea Pressure', can be any other channel.
%
% Output:
%     RSK - Structure, with RSK.im field containing data, channel, profile,
%     direction and reference channel information.
%
% Example: 
%     rsk = RSKgenerate2D(rsk,'channel',{'Temperature','Conductivity'},'direction','down');
%
% See also: RSKbinaverage, RSKimages.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2020-01-06


checkDirection = @(x) ischar(x) || isempty(x);

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'channel', 'all');
addParameter(p, 'profile', [], @isnumeric);
addParameter(p, 'direction', '', checkDirection);
addParameter(p, 'reference', 'Sea Pressure', @ischar);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
channel = p.Results.channel;
profile = p.Results.profile;
direction = p.Results.direction;
reference = p.Results.reference;


checkDataField(RSK)

if isempty(direction);
    if isfield(RSK.data,'direction') && all(ismember({RSK.data.direction},'up'))
        direction = 'up';
    elseif isfield(RSK.data,'direction')
        direction = 'down';
    end
end

castidx = getdataindex(RSK, profile, direction);
chanCol = [];
channels = cellchannelnames(RSK, channel);
for chan = channels
    if ~any(strcmpi(chan{1},{'Sea Pressure','Depth','Pressure'}))
        chanCol = [chanCol getchannelindex(RSK, chan{1})];
    end
end
YCol = getchannelindex(RSK, reference);

for ndx = 1:length(castidx)-1
    if length(RSK.data(castidx(ndx)).values(:,YCol)) == length(RSK.data(castidx(ndx+1)).values(:,YCol));
        binCenter = RSK.data(castidx(ndx)).values(:,YCol);
    else 
        RSKerror('The reference channel data of all the selected profiles must be identical. Use RSKbinaverage.m for selected cast direction.')
    end
end

RSK.im.x = cellfun( @(x)  min(x), {RSK.data(castidx).tstamp});
RSK.im.y = binCenter;
RSK.im.channel = chanCol;
if isempty(profile)
    RSK.im.profile = unique([RSK.data.profilenumber]);
else
    RSK.im.profile = profile;
end
RSK.im.direction = direction;
RSK.im.data = NaN(length(binCenter),length(castidx),length(chanCol));
RSK.im.reference = reference;
RSK.im.reference_unit = RSK.channels(getchannelindex(RSK,reference)).units;

k = 1;
for c = chanCol
    binValues = NaN(length(binCenter), length(castidx));
    for ndx = 1:length(castidx)
        binValues(:,ndx) = RSK.data(castidx(ndx)).values(:,c);
    end
    RSK.im.data(:,:,k) = binValues;
    k = k + 1;
end
end

