function [RSK, geodata] = readgeodata(RSK, varargin)

% readgeodata - Read the geodata of a .rsk file.
%
% Syntax:  [RSK, geodata] = readgeodata(RSK)
%
% Returns the geodata of a file, includes timestamp, latitude, longitude
% accuracy and the accuracy type. If a UTCdelta time is available in the
% file, it is applied, unless a value is input.
%
% Inputs:
%    RSK - Structure containing the logger metadata.
%
%    UTCdelta - The offset of the timestamp. Uses the input value, if none
%               the value in the epochs field, if none, 0.
%
% Output:
%    RSK - Structure containing previously present logger metadata as well
%          as geodata.
%
%    geodata - Contents of the geodata field returned as an array.
%
% See also: RSKopen.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-09-14

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'UTCdelta', 0);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
UTCdelta = p.Results.UTCdelta;



RSK.geodata = doSelect(RSK, 'select tstamp/1.0 as tstamp, latitude, longitude, accuracy, accuracyType from geodata');
if isempty(RSK.geodata)
    RSK = rmfield(RSK, 'geodata');
    return;
elseif strcmpi(p.UsingDefaults, 'UTCdelta')
    try
        tmp = doSelect(RSK, 'select UTCdelta/1.0 as UTCdelta from epoch');
        UTCdelta = tmp.UTCdelta;
        RSK.epochs.UTCdelta = UTCdelta;
    catch
        UTCdelta = 0;
    end
end  
for ndx = 1:length(RSK.geodata)
    RSK.geodata(ndx).tstamp = rsktime2datenum(RSK.geodata(ndx).tstamp + UTCdelta);
end

geodata = [[RSK.geodata.tstamp]', [RSK.geodata.latitude]', [RSK.geodata.longitude]', [RSK.geodata.accuracy]'];

end
