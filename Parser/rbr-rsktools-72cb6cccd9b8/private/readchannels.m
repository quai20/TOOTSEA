function RSK = readchannels(RSK)

%READCHANNELS - Populate the channels table.
%
% Syntax:  [RSK] = READCHANNELS(RSK)
%
% If available, uses the instrumentChannels table to read the channels with
% matching channelID. Otherwise, directly reads the metadata from the
% channels table. Only returns non-marine channels, unless it is a
% EPdesktop file, and enumerates duplicate channel names.
%
% Inputs:
%    RSK - Structure opened using RSKopen.m.
%
% Outputs:
%    RSK - Structure containing channels.
%
% See also: readstandardtables, RSKopen.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2021-09-22

p = inputParser;
addRequired(p, 'RSK', @isstruct);
parse(p, RSK)

RSK = p.Results.RSK;

tables = doSelect(RSK, 'SELECT name FROM sqlite_master WHERE type="table"');

if any(strcmpi({tables.name}, 'instrumentChannels')) 
    RSK.instrumentChannels = doSelect(RSK, 'select * from instrumentChannels');
    RSK.channels = doSelect(RSK, ['SELECT c.shortName as shortName,'...
                        'c.longName as longName,'...
                        'c.units as units, '...
                        'c.channelID as channelID '...
                        'FROM instrumentChannels ic '... 
                        'JOIN channels c ON ic.channelID = c.channelID '...
                        'ORDER by ic.channelOrder']);
end


if (~isfield(RSK,'channels')||isempty(RSK.channels))
    RSK.channels = doSelect(RSK, 'SELECT shortName, longName, units, channelID FROM channels ORDER by channels.channelID');
end

% ensure there is no trailing space at the end of the longName
% workaround Ruskin bug RSK-8255
for k=1:length(RSK.channels)
    if (RSK.channels(k).longName(end)==' ')
        RSK.channels(k).longName=RSK.channels(k).longName(1:end-1);
    end
end

RSK = removenonmarinechannels(RSK);
RSK = renamechannels(RSK);

end