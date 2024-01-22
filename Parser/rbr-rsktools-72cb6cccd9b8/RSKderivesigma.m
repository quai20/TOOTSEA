function [RSK] = RSKderivesigma(RSK, varargin)

% RSKderivesigma - Calculate potential density anomaly using TEOS-10 or
% seawater library.
%
% Syntax: [RSK] = RSKderivesigma(RSK, [OPTIONS])
% 
% The result is added to the RSK data structure, and the channel list is 
% updated. When using TEOS-10 library, the workflow of the function is 
% as below:
%
% 1, Calculate absolute salinity (SA) if it doesn't exist
%    a) When latitude and longitude data are available (either from
%    optional input or station data in RSK.data.latitude/longitude), the
%    function will call SA = gsw_SA_from_SP(salinity,seapressure,lon,lat)
%    b) When latitude and longitude data are absent, the function will call
%    SA = gsw_SR_from_SP(salinity) assuming that reference salinity equals
%    absolute salinity approximately.
% 2, Calculate potential temperature (pt0) if it doesn't exist
%    pt0 = gsw_pt0_from_t(absolute salinity,temperature,seapressure)
% 3, Calculate potential density anomaly (sigma0)
%    sigma0 = gsw_sigma0_pt0_exact(absolute salinity,potential temperature)
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
%    RSK - Updated structure containing potential density anomaly.
%
% See also: RSKderivesalinity.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-07-22


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

RSK = addchannelmetadata(RSK, 'dden00', 'Density Anomaly', 'kg/m³');
DAcol = getchannelindex(RSK, 'Density Anomaly');

castidx = getdataindex(RSK);
for ndx = castidx
    SP = RSK.data(ndx).values(:,SPcol);
    S = RSK.data(ndx).values(:,Scol);
    T = RSK.data(ndx).values(:,Tcol);   
    
    if strcmpi(seawaterLibrary,'TEOS-10')     
        hasSA = any(strcmp({RSK.channels.longName}, 'Absolute Salinity'));
        hasPT = any(strcmp({RSK.channels.longName}, 'Potential Temperature'));
        [lat,lon] = getGeo(RSK,ndx,latitude,longitude);    
        
        if hasSA
            SA = RSK.data(ndx).values(:,getchannelindex(RSK,'Absolute Salinity'));
        else
            SA = deriveSA(S,SP,lat,lon);    
        end  

        if hasPT
            pt0 = RSK.data(ndx).values(:,getchannelindex(RSK,'Potential Temperature'));
        else
            pt0 = gsw_pt0_from_t(SA,T,SP);
        end

        DA = gsw_sigma0_pt0_exact(SA,pt0);      
    else
        dens = sw_pden(S,T,SP,0);
        DA = dens - 1000;
    end
    
    RSK.data(ndx).values(:,DAcol) = DA;
end

logentry = (['Potential density anomaly derived using ' seawaterLibrary ' library.']);
RSK = RSKappendtolog(RSK, logentry);

end
