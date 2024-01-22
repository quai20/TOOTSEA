function [RSK] = RSKderivebuoyancy(RSK,varargin)

% RSKderivebuoyancy - Calculate buoyancy frequency N^2 and stability E.
%
% Syntax:  [RSK] = RSKderivebuoyancy(RSK,[OPTIONS])
% 
% Derives buoyancy frequency and stability using either TEOS-10 GSW toolbox
% (http://www.teos-10.org/software.htm) or seawater toolbox. The result is 
% added to the RSK data structure, and the channel list is updated. 
%
% Note: When using TEOS-10 toolbox, the function makes the assumption that 
%       the Absolute Salinity anomaly is zero to simplify the calculation.  
%       In other words, SA = SR.
%
% Inputs: 
%   [Required] - RSK - Structure containing the logger metadata and data
%
%   [Optional] - latitude - Latitude in decimal degrees north [-90 ... +90]
%                When latitude is available from both optional input and 
%                RSK.data structure, the optional input will override. When
%                neither source is available, it will use 45 as default.
%
%                seawaterLibrary - Specify which library to use, should 
%                be either 'TEOS-10' or 'seawater', default is TEOS-10
%
% Outputs:
%    RSK - Updated structure containing buoyancy frequency and stability.
%
% See also: RSKderivesalinity.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-08-31


rsksettings = RSKsettings;

validSeawaterLibrary = {'TEOS-10','seawater'};
checkSeawaterLibrary = @(x) any(validatestring(x,validSeawaterLibrary));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'latitude', [], @isnumeric);
addParameter(p, 'seawaterLibrary', rsksettings.seawaterLibrary, checkSeawaterLibrary);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
latitude = p.Results.latitude;
seawaterLibrary = p.Results.seawaterLibrary;


checkDataField(RSK)
checkSeawaterLibraryExistence(seawaterLibrary)

Tcol = getchannelindex(RSK, 'Temperature');
[Scol,SPcol] = getchannel_S_SP_index(RSK);

RSK = addchannelmetadata(RSK, 'buoy00', 'Buoyancy Frequency Squared', '1/s²');
N2col = getchannelindex(RSK, 'Buoyancy Frequency Squared');
RSK = addchannelmetadata(RSK, 'stbl00', 'Stability', '1/m');
STcol = getchannelindex(RSK, 'Stability');

castidx = getdataindex(RSK);
for ndx = castidx
    SP = RSK.data(ndx).values(:,SPcol);
    S = RSK.data(ndx).values(:,Scol);
    T = RSK.data(ndx).values(:,Tcol);
    
    if isempty(latitude) 
        if isfield(RSK.data,'latitude') && ~isempty(RSK.data(ndx).latitude)
            latitude = RSK.data(ndx).latitude; 
        else
            latitude = rsksettings.latitude;
        end
    end
   
    if strcmpi(seawaterLibrary,'TEOS-10')    
        [N2,ST] = derive_N2_ST_TEOS10(S,T,SP,latitude);  
    else
        [N2,ST] = derive_N2_ST_SW(S,T,SP,latitude); 
    end
       
    RSK.data(ndx).values(:,N2col) = N2;
    RSK.data(ndx).values(:,STcol) = ST;
end

logentry = (['Buoyancy frequency squared and stability derived using ' seawaterLibrary 'library.']);
RSK = RSKappendtolog(RSK, logentry);


%% Nested functions
function [N2,ST] = derive_N2_ST_TEOS10(S,T,SP,latitude)
    SA = gsw_SR_from_SP(S); % Assume SA ~= SR
    CT = gsw_CT_from_t(SA,T,SP);
    [N2_mid,p_mid] = gsw_Nsquared(SA,CT,SP,latitude);
    grav = gsw_grav(latitude,SP);    
    N2 = interp1(p_mid,N2_mid,SP,'linear','extrap');
    ST = N2./grav;
end

function [N2,ST] = derive_N2_ST_SW(S,T,SP,latitude)    
    [N2_mid,~,p_mid] = sw_bfrq(S,T,SP,latitude);
    z = sw_dpth(SP,latitude);
    grav = sw_g(latitude,z);    
    N2 = interp1(p_mid,N2_mid,SP,'linear','extrap');
    ST = N2./grav;
end

end
