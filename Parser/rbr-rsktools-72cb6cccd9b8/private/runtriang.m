function out = runtriang(in, windowLength, edgepad)

%RUNTRIANG - Smooth a time series using a triangle filter.
%
% Syntax:  [out] = RUNTRIANG(in, windowLength, edgepad)
% 
% Performs a triangle filter of length windowLength over the time
% series. 
%
% Inputs:
%    in - Time series
%
%    windowLength - Length of the running triangle. It must be odd.
%
%    edgepad - Describes how the filter will act at the edges. Options
%         are 'mirror', 'zeroorderhold' and 'nan'. Default is 'mirror'.
%
% Outputs:
%    out - Smoothed time series
%
% See also: RSKsmooth.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-06-21

if nargin == 2
    edgepad = 'mirror';
end

if mod(windowLength, 2) == 0
    RSKerror('windowLength must be odd');
end



for ndx = 1:windowLength
    if ndx <= (windowLength+1)/2
        coeff(ndx) = 2*ndx/(windowLength+1);
    else
        coeff(ndx) = 2 - (2*ndx/(windowLength+1));
    end
end
normcoeff = (coeff/sum(coeff));



padsize = (windowLength-1)/2;
inpadded = padseries(in, padsize, edgepad);

n = length(in);
out = NaN*in;
for ndx = 1:n
    out(ndx) = sum(inpadded(ndx:ndx+(windowLength-1)).*normcoeff','omitnan');
end

end