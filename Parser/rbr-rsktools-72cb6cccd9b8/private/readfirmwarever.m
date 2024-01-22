function [v, vsnMajor, vsnMinor]  = readfirmwarever(RSK)

% readfirmwarever - Return the firmware version of the RSK file.
%
% Syntax:  [v, vsnMajor, vsnMinor] = readfirmwarever(RSK)
%
% Returns the most recent version of the firmware; the information is
% retrieved from 'instruments' fields for files older than v1.12.2 or
% 'deployments' for more recent files.
%
% Inputs:
%    RSK - Structure containing the logger metadata returned by RSKopen.
%
% Output:
%    v - Lastest version of the firmware
%    vsnMajor - Latest version number of category major
%    vsnMinor - Latest version number of category minor
%    vsnPatch - Latest version number of category patch
%
% See also: returnversion.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-09-14

if iscompatibleversion(RSK, 1, 12, 2) && isfield(RSK.instruments,'firmwareVersion');
    v = RSK.instruments.firmwareVersion;
elseif isfield(RSK.deployments,'firmwareVersion')
    v = RSK.deployments.firmwareVersion;
else
    v = [];
    return
end

vsn = textscan(v,'%s','delimiter','.');
vsnMajor = str2double(vsn{1}{1});
vsnMinor = str2double(vsn{1}{2});

end