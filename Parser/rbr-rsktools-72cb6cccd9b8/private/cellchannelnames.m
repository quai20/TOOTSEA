function chanNames = cellchannelnames(RSK, channel)

%CELLCHANNELNAMES - Make a cell of the channel names.
%
% Syntax:  [chanNames] = CELLCHANNELNAMES(RSK, channel)
%
% Sets up channel names into a cell to facilitate iterating through many
% different channels for other functions. If the channel argument is 'all',
% all the channels.longName in the structure are put into a cell. If there
% is only one channel name, it simply puts it in a cell, and if there are
% many channel names, they stay in a cell. 
%
% Inputs:
%    RSK - Structure containing some logger metadata
%
%    channel - Channel names or 'all'.
%
% Output:
%    chanNames - Cell containing the channels' longName.
%
% See also: RSKplotprofiles, RSKplotdata, RSKsmooth.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-06-21

if strcmpi(channel, 'all')
    chanNames = {RSK.channels.longName};
elseif ~iscell(channel)
    chanNames = {channel};
else
    chanNames = channel;
end

end