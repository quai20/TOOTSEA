function [RSK] = RSKderivesalinity(RSK,varargin)

% RSKderivesalinity - Calculate practical salinity.
%
% Syntax:  [RSK] = RSKderivesalinty(RSK,[OPTIONS])
% 
% Derives salinity using either TEOS-10 library
% (http://www.teos-10.org/software.htm) or sea water library
% (http://www.cmar.csiro.au/datacentre/ext_docs/seawater.htm). 
% Default is TEOS-10. The result is added to the RSK data structure, 
% and the channel list is updated. If salinity is already in the RSK 
% data structure (i.e., from Ruskin), it will be overwritten.
%
% Inputs: 
%    [Required] - RSK - Structure containing the logger metadata and data.
%
%    [Optional] - seawaterLibrary - Specify which library to use, should 
%                 be either 'TEOS-10' or 'seawater', default is TEOS-10
%
% Outputs:
%    RSK - Updated structure containing practical salinity.
%
% Examples:
%    rsk = RSKderivesalinity(rsk);
%    OR
%    rsk = RSKderivesalinity(rsk,'seawaterLibrary','seawater');
%
% See also: RSKcalculateCTlag.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-11-12


rsksettings = RSKsettings;

validSeawaterLibrary = {'TEOS-10','seawater'};
checkSeawaterLibrary = @(x) any(validatestring(x,validSeawaterLibrary));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'seawaterLibrary', rsksettings.seawaterLibrary, checkSeawaterLibrary);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
seawaterLibrary = p.Results.seawaterLibrary;


checkDataField(RSK)
checkSeawaterLibraryExistence(seawaterLibrary)
    
RSK = addchannelmetadata(RSK, 'sal_00', 'Salinity', 'PSU');
[Ccol,Tcol,Scol] = getchannelindex(RSK,{'Conductivity','Temperature','Salinity'});
[RSKsp, SPcol] = getseapressure(RSK);

castidx = getdataindex(RSK);
for ndx = castidx
    C = RSK.data(ndx).values(:, Ccol);
    T = RSK.data(ndx).values(:, Tcol);
    SP = RSKsp.data(ndx).values(:, SPcol);
    if strcmpi(seawaterLibrary,'TEOS-10')
        salinity = gsw_SP_from_C(C, T, SP);
    else
        salinity = sw_salt(C/sw_c3515, T, SP);
    end
    RSK.data(ndx).values(:,Scol) = salinity;
end

logentry = (['Practical Salinity derived using ' seawaterLibrary ' library.']);
RSK = RSKappendtolog(RSK, logentry);

end
