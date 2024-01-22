function utime = datenum2unixtime(dnum)

%DATENUM2UNIXTIME - Convert MATLAB datenum format to unix time
%
% Syntax:  [utime] = DATENUM2UNIXTIME(dnum)
% 
% Converts MATLAB datenum format to "unix time", (i.e. POSIX time,
% the number of seconds since 1970-01-01 00:00:00.000).
%
% Inputs:
%    dnum - MATLAB datenum.
% 
% Outputs:
%    utime - Unix time. The number of seconds since 1970-01-01.
%
% Example: 
%    datenum2unixtime(datenum('01-Jan-2015'))
% 
%    ans =
%
%    1.4201e+09
%
% See also: unixtime2datenum, rsktime2datenum, datenum2rsktime.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-06-20

utime = double(86400 * (dnum - datenum('01-Jan-1970')));

end

