function varargout = getchannelindex(RSK, channel)

% GETCHANNELINDEX - Return index of channels.
%
% Syntax:  [channelIdx1,channelIdx2,...] = GETCHANNELINDEX(RSK, channel)
% 
% Finds the channel index in the RSK of the channel longNames given. If the
% channel(s) is not in the RSK, it returns an error.
%
% Inputs:
%   RSK - RSK structure
%
%   channel - LongName as written in RSK.channels.
%
% Outputs:
%
%   channelIdx(n) - Index of channels, note that the index must be in the
%   same sequence as the input, when there are multiple inputs.
%
% See also: getdataindex, getcastdirection.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-04-04

if ~iscell(channel)
    channel = {channel};    
end

if all(ismember(lower(channel),lower({RSK.channels.longName})))    
    [~,~,channelIdx] = intersect(lower(channel),lower({RSK.channels.longName}),'stable');
    varargout = cell(size(channelIdx));
    for i = 1:length(channelIdx)
        varargout{i} = channelIdx(i); 
    end
else
    channelNotFound = channel(~ismember(lower(channel),lower({RSK.channels.longName})));
    RSKerror(['There is no ' strjoin(channelNotFound) ' channel in this file.']);   
end

end