function   check = iscompatibleversion(RSK, minimumvsnMajor, minimumvsnMinor, minimumvsnPatch)

%ISCOMPATIBLEVERSION - Find if version is equal or greater than minimum given.
%
% Syntax:  [check] = ISCOMPATIBLEVERSION(RSK, minimumvsnMajor, minimumvsnMinor, minimumvsnPatch)
%
% Returns a logical index that describes if the RSK version is equal to or
% greater than the specified minimum version required.
%
% Inputs:
%    RSK - Structure containing the logger metadata, returned by RSKopen
%
%    minimumvsnMajor - Minimum requirement version number of category major
%
%    minimumvsnMinor - Minimum requirement version number of category minor
%
%    minimumvsnPatch - Minimum requirement version number of category patch
%
% Output:
%    check - A logical index 1, version is compatible; 0, version is
%            not compatible.
%
% See also: RSKopen, RSKreadcalibrations.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-06-20

check = 0;

[~, vsnMajor, vsnMinor, vsnPatch] = returnversion(RSK);

if (vsnMajor > minimumvsnMajor) 
    check = 1;
elseif (vsnMajor == minimumvsnMajor) && (vsnMinor > minimumvsnMinor)
    check = 1;
elseif (vsnMajor == minimumvsnMajor) && (vsnMinor == minimumvsnMinor) && (vsnPatch >= minimumvsnPatch)
    check = 1;
end

end