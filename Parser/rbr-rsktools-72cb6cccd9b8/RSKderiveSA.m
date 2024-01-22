function [RSK] = RSKderiveSA(RSK, varargin)

% RSKderiveSA - Calculate absolute salinity.
%
% Syntax: [RSK] = RSKderiveSA(RSK, [OPTIONS])
% 
% Derives absolute salinity using the TEOS-10 GSW toolbox
% (http://www.teos-10.org/software.htm). The result is added to the RSK 
% data structure, and the channel list is updated. The function acts
% differently depending on if GPS information is available:
%
% a) When latitude and longitude data are available (either from
% optional input or station data in RSK.data.latitude/longitude), the
% function will call SA = gsw_SA_from_SP(salinity,seapressure,lon,lat)
%
% b) When latitude and longitude data are absent, the function will call
% SA = gsw_SR_from_SP(salinity) assuming that reference salinity equals
% absolute salinity approximately.
%
% Note: When geographic information are both available from optional inputs
% and RSK.data structure, the optional inputs will override. The inputs
% latitude/longitude must be either a single value or vector of the same
% length of RSK.data.
%
% Inputs: 
%   [Required] - RSK - Structure containing the logger metadata and data
%
%   [Optional] - latitude - Latitude in decimal degrees north [-90 ... +90]
%
%              - longitude - Longitude in decimal degrees east [-180 ... +180]
%
% Outputs:
%    RSK - Updated structure containing absolute salinity.
%
% See also: RSKderivesigma, RSKderivetheta.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-11-15


p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'latitude', [], @isnumeric);
addParameter(p, 'longitude', [], @isnumeric);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
latitude = p.Results.latitude;
longitude = p.Results.longitude;
 

hasTEOS = ~isempty(which('gsw_SA_from_SP'));
if ~hasTEOS
    RSKerror('Must install TEOS-10 toolbox. Download it from here: http://www.teos-10.org/software.htm');
end

checkDataField(RSK)

if length(latitude) > 1 && length(RSK.data) ~= length(latitude)
    RSKerror('Input latitude must be either one value or vector of the same length of RSK.data')
end

if length(longitude) > 1 && length(RSK.data) ~= length(longitude)
    RSKerror('Input longitude must be either one value or vector of the same length of RSK.data')
end

[Scol,SPcol] = getchannel_S_SP_index(RSK);

RSK = addchannelmetadata(RSK, 'cnt_00', 'Absolute Salinity', 'g/kg'); % nt_00 will need update when Ruskin sets up a shortname for SA
SAcol = getchannelindex(RSK, 'Absolute Salinity');

castidx = getdataindex(RSK);
for ndx = castidx
    SP = RSK.data(ndx).values(:,SPcol);
    S = RSK.data(ndx).values(:,Scol);
    [lat,lon] = getGeo(RSK,ndx,latitude,longitude);
    SA = deriveSA(S,SP,lat,lon);    
    RSK.data(ndx).values(:,SAcol) = SA;
end

logentry = ('Absolute salinity derived using TEOS-10 GSW toolbox.');
RSK = RSKappendtolog(RSK, logentry);

end
