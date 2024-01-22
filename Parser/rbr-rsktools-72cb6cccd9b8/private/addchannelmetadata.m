function RSK = addchannelmetadata(RSK, shortName, longName, units)

% ADDCHANNELMETADATA - Add the metadata for a new channel.
%
% Syntax:  [RSK] = ADDCHANNELMETADATA(RSK, shortName, longName, units)
% 
% Adds all the metadata associated with a new channel in the channel field
% of the RSK structure.
%
% Inputs:
%   RSK - Input RSK structure
%
%   shortName - Short name of the new channel
%
%   longName - Full name of the new channel
%            
%   units - Units of the new channel. 
%
% Outputs:
%    RSK - RSK structure containing new channel metadata.
%
% See also: RSKderivedepth, RSKderiveseapressure, RSKderivesalinity.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-11-09

hasChan = any(strcmpi({RSK.channels.longName}, longName));

if ~hasChan
    nchannels = length(RSK.channels);
    RSK.channels(nchannels+1).shortName = shortName;
    RSK.channels(nchannels+1).longName = longName;
    RSK.channels(nchannels+1).units = units;
end

end