function [RSK] = RSKderivedepth(RSK, varargin)

% RSKderivedepth - Calculate depth from pressure.
%
% Syntax:  [RSK] = RSKderivedepth(RSK, [OPTION])
% 
% Calculates depth from pressure and adds the channel metadata in the
% appropriate fields. If the data elements already have a 'depth' channel,
% it is replaced. Users could specify either 'TEOS-10' or 'seawater' 
% toolbox to use, if it exists. Otherwise, depth is calculated using
% the Saunders & Fofonoff method.  
%
% Inputs: 
%    [Required] - RSK - Structure containing the logger metadata and data
%
%    [Optional] - latitude - Location of the pressure measurement in
%                       decimal degrees. Default is 45. 
%
%                 seawaterLibrary - Specify which library to use, should 
%                 be either 'TEOS-10' or 'seawater', default is TEOS-10
%
% Outputs:
%    RSK - RSK structure containing the depth data
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-05-29


rsksettings = RSKsettings;

validSeawaterLibrary = {'TEOS-10','seawater'};
checkSeawaterLibrary = @(x) any(validatestring(x,validSeawaterLibrary));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'latitude', rsksettings.latitude, @isnumeric);
addParameter(p, 'seawaterLibrary', rsksettings.seawaterLibrary, checkSeawaterLibrary);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
latitude = p.Results.latitude;
seawaterLibrary = p.Results.seawaterLibrary;


checkDataField(RSK)

hasTEOS = ~isempty(which('gsw_z_from_p'));
hasSW = ~isempty(which('sw_dpth'));

RSK = addchannelmetadata(RSK, 'dpth01', 'Depth', 'm');
Dcol = getchannelindex(RSK, 'Depth');
[RSKsp, SPcol] = getseapressure(RSK);

castidx = getdataindex(RSK);
for ndx = castidx
    seapressure = RSKsp.data(ndx).values(:, SPcol);
    if hasTEOS && strcmpi(seawaterLibrary,'TEOS-10')
        depth = -gsw_z_from_p(seapressure, latitude);     
    elseif hasSW && strcmpi(seawaterLibrary,'seawater')
        depth = sw_dpth(seapressure, latitude);
    else
        x = (sin(latitude/57.29578)).^2;
        gr = 9.780318*(1.0 + (5.2788e-3 + 2.36e-5*x).*x) + 1.092e-6.*seapressure;
        depth = (((-1.82e-15*seapressure + 2.279e-10).*seapressure - 2.2512e-5).*seapressure + 9.72659).*seapressure;
        depth = depth./gr;
    end
    RSK.data(ndx).values(:,Dcol) = depth;
end
    
logentry = ['Depth calculated using a latitude of ' num2str(latitude) ' degrees.'];
RSK = RSKappendtolog(RSK, logentry);

end