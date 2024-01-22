function [RSK, SPcol] = getseapressure(RSK)

%GETSEAPRESSURE - Add sea pressure to RSK and return the column index.
%
% Syntax:  [RSK, SPcol] = GETSEAPRESSURE(RSK)
%
% Finds the column index of sea pressure if it exists, if not it derives
% sea pressure and adds it to the RSK structure.
%
% Inputs: 
%    RSK - Structure containing the logger metadata and data.
%
% Outputs:
%    RSK - RSK structure containing the sea pressure data
%
%    SPcol - Channel index for sea pressure.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-06-20

try
    SPcol = getchannelindex(RSK, 'Sea Pressure');
catch
    RSK = RSKderiveseapressure(RSK);
    SPcol = getchannelindex(RSK, 'Sea Pressure');
end

end