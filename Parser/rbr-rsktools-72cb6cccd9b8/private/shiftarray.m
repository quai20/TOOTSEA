function out = shiftarray(in, shift, edgepad)

%SHIFTARRAY - Shift a time series by a specified number of samples. 
%
% Syntax:  [out] = SHIFTARRAY(in, shift, edgepad)
% 
% Shifts a vector time series by a lag corresponding to an integer
% number of samples. Negative shifts correspond to moving the samples
% backward in time (earlier), positive to forward in time
% (later). Values at either the beginning or the end are set to a
% value specified by the argument "edgepad" to conserve the length of
% the input vector, except for the particular case of 'union'.
%
% Inputs:
%    in - Time series.
%
%    shift - Number of samples to shift by.
%
%    edgepad - Values to set the beginning or end values. Options are
%         'mirror' (default), 'zeroorderhold', 'nan', and 'union'.
%
% Outputs:
%    out - The shifted time series.
%
% Example: 
%    shiftedValues = SHIFTARRAY(rsk.data.values(:,1), -3); % shift back by 3 samples
%
% See also: RSKalignchannel.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-08-30

if nargin == 2
    edgepad = 'mirror';
end



n = length(in);
out = NaN*in;

I = 1:n;
Ilag = I-shift;
switch lower(edgepad)
    case 'mirror'
        inpad = mirrorpad(in, abs(shift));  
    case 'zeroorderhold'
        inpad = zeroorderholdpad(in, abs(shift));
    case 'nan'
        inpad = nanpad(in, abs(shift)); 
    case 'union'
        inpad = nanpad(in, abs(shift));
    otherwise
        RSKerror('edgepad argument is not recognized. Must be ''mirror'', ''nan'', or ''zeroorderhold''');
end



if shift>0
    Ilag = I;
else
    Ilag = Ilag-shift;
end

out = inpad(Ilag);
if strcmpi(edgepad, 'union')
    out = out(~isnan(out));
end

end