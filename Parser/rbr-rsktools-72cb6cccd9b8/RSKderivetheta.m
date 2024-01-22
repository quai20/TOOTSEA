function [RSK] = RSKderivetheta(RSK, varargin)

% RSKderivetheta - Calculate potential temperature with a reference sea
% pressure of zero.
%
% Syntax: [RSK] = RSKderivetheta(RSK, [OPTIONS])
% 
% Derives potential temperature using either TEOS-10 GSW toolbox
% (http://www.teos-10.org/software.htm) or seawater toolbox. The result is 
% added to the RSK data structure, and the channel list is updated. 
%
% When using TEOS-10 library, the workflow of the function is as below:
%
% 1, Calculate absolute salinity (SA) if it doesn't exist
%    a) When latitude and longitude data are available (either from
%    optional input or station data in RSK.data.latitude/longitude), the
%    function will call SA = gsw_SA_from_SP(salinity,seapressure,lon,lat)
%    b) When latitude and longitude data are absent, the function will call
%    SA = gsw_SR_from_SP(salinity) assuming that reference salinity equals
%    absolute salinity approximately.
% 2, Calculate potential temperature (pt0)
%    pt0 = gsw_pt0_from_t(absolute salinity,temperature,seapressure)
%
% Note: When geographic information are both available from optional inputs
% and RSK.data structure, the optional inputs will override. The inputs
% latitude/longitude must be either a single value of vector of the same
% length of RSK.data.
%
% Inputs: 
%   [Required] - RSK - Structure containing the logger metadata and data
%
%   [Optional] - seawaterLibrary - Specify which library to use, should 
%                be either 'TEOS-10' or 'seawater', default is TEOS-10
%
%              - latitude - Latitude in decimal degrees north [-90 ... +90]
%
%              - longitude - Longitude in decimal degrees east [-180 ... +180]
%
% Outputs:
%    RSK - Updated structure containing potential temperature.
%
% See also: RSKderivesigma, RSKderiveSA.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-11-15


rsksettings = RSKsettings;

validSeawaterLibrary = {'TEOS-10','seawater'};
checkSeawaterLibrary = @(x) any(validatestring(x,validSeawaterLibrary));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'seawaterLibrary', rsksettings.seawaterLibrary, checkSeawaterLibrary);
addParameter(p, 'latitude', [], @isnumeric);
addParameter(p, 'longitude', [], @isnumeric);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
seawaterLibrary = p.Results.seawaterLibrary;
latitude = p.Results.latitude;
longitude = p.Results.longitude;
 

checkDataField(RSK)
checkSeawaterLibraryExistence(seawaterLibrary)

if length(latitude) > 1 && length(RSK.data) ~= length(latitude)
    RSKerror('Input latitude must be either one value or vector of the same length of RSK.data')
end

if length(longitude) > 1 && length(RSK.data) ~= length(longitude)
    RSKerror('Input longitude must be either one value or vector of the same length of RSK.data')
end

Tcol = getchannelindex(RSK, 'Temperature');
[Scol,SPcol] = getchannel_S_SP_index(RSK);

RSK = addchannelmetadata(RSK, 'cnt_00', 'Potential Temperature', '°C'); % cnt_00 will need update when Ruskin sets up a shortname for theta
PTcol = getchannelindex(RSK, 'Potential Temperature');

castidx = getdataindex(RSK);
for ndx = castidx
    SP = RSK.data(ndx).values(:,SPcol);
    S = RSK.data(ndx).values(:,Scol);
    T = RSK.data(ndx).values(:,Tcol);  
    
    if strcmpi(seawaterLibrary,'TEOS-10')    
        [lat,lon] = getGeo(RSK,ndx,latitude,longitude);  
        hasSA = any(strcmp({RSK.channels.longName}, 'Absolute Salinity'));
        if hasSA
            SA = RSK.data(ndx).values(:,getchannelindex(RSK,'Absolute Salinity'));
        else
            SA = deriveSA(S,SP,lat,lon);    
        end       
        PT = gsw_pt0_from_t(SA,T,SP);  
    else
        PT = sw_ptmp(S,T,SP,0);
    end
    
    RSK.data(ndx).values(:,PTcol) = PT;
end

logentry = (['Potential temperature derived using ' seawaterLibrary ' library.']);
RSK = RSKappendtolog(RSK, logentry);

end
