function out = runavg(in, windowLength, edgepad)

%RUNAVG - Smooth data using a running average low-pass filter.
%
% Syntax:  [out] = RUNAVG(in, windowLength, edgepad)
% 
% Performs a running average with a boxcar window of length
% windowLength over the data. 
%
% Inputs:
%    in - Time series
%
%    windowLength - Length of the averaging window. It must be odd.
%
%    edgepad - Describes how the filter will act at the edges. Options
%         are 'mirror', 'zeroorderhold' and 'nan'. Default is 'mirror'.
%
% Outputs:
%    out - Smoothed time series.
%
% See also: RSKsmooth, RSKcalculateCTlag.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-11-01

if nargin == 2
    edgepad = 'mirror';
end

if mod(windowLength, 2) == 0
    RSKerror('windowLength must be odd');
end



padsize = (windowLength-1)/2;
inpadded = padseries(in, padsize, edgepad);



n = length(in);
out = NaN*in;
for ndx = 1:n
    out(ndx) = mean(inpadded(ndx:ndx+(windowLength-1)),'omitnan');
end

end