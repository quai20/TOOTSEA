function [RSK] = RSKderiveC25(RSK, varargin)

% RSKderiveC25 - Calculate specific conductivity at 25 degrees Celsius
%                in units of µS/cm.
%
% Syntax:  [RSK] = RSKderiveC25(RSK, [OPTIONS])
%
% This function computes the specific conductivity in µS/cm at 25
% degrees Celsius given the conductivity in mS/cm and temperature in
% degrees Celsius.  The default temperature sensitivity coefficient,
% alpha, is 0.0191 deg C-1.
%    
% Inputs: 
%    [Required] - RSK - Structure containing the logger metadata and data. 
%
%    [Optional] - alpha - temperature coefficient, with default 0.0191 deg C-1.
%
% Outputs:
%    RSK - Updated structure containing a new channel for specific conductivity.
%
% See also: RSKderivesalinity.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-05-29


p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'alpha', 0.0191, @isnumeric);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
alpha = p.Results.alpha;


checkDataField(RSK)

Ccol = getchannelindex(RSK, 'Conductivity');
Tcol = getchannelindex(RSK, 'Temperature');

RSK = addchannelmetadata(RSK, 'scon00', 'Specific Conductivity', 'µS/cm'); % cond08 is a temporary solution for Ruskin to read, will change in future
SCcol = getchannelindex(RSK, 'Specific Conductivity');

castidx = getdataindex(RSK);
for ndx = castidx
    c25 = deri_speccond(RSK.data(ndx).values(:, Ccol), RSK.data(ndx).values(:, Tcol), alpha);
    RSK.data(ndx).values(:,SCcol) = c25*1000; % convert unit from mS/cm to µS/cm
end

logentry = ['Specific conductivity at 25 degrees Celsius is derived using temperature sensitivity coefficient of ' num2str(alpha,4) ' deg C-1.'];
RSK = RSKappendtolog(RSK, logentry);

%% Nested function
    function out = deri_speccond(c,t,alpha)
    out = c./(1 + alpha.*(t-25));
    end
end
