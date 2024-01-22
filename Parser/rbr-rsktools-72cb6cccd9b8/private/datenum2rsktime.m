function rtime = datenum2rsktime(dnum)

% datenum2rsktime - Convert MATLAB datenum format to RSK logger time.
%
% Syntax:  [rtime] = datenum2rsktime(dnum)
% 
% Converts MATLAB datenum format to 'rtime', as recorded by the logger.
%
% Inputs:
%    dnum - MATLAB datenum.
% 
% Outputs:
%    rtime - Raw time read from the RSK file, corresponding to milliseconds
%           elapsed since January 1 1970 (i.e. unix time or POSIX time). 
%
% Example: 
%    datenum2rsktime(datenum('01-Jan-2015'))
% 
%    ans =
%
%    1.4201e+12
%
% See also: rsktime2datenum, unixtime2datenum, datenum2unixtime.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-06-20

rtime=datenum2unixtime(dnum)*1000;

end
