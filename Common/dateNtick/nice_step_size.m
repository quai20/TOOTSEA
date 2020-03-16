function step_size = nice_step_size(raw_num, raw_num_upper)
% Comes up with a 'nice' step size.
%
% step_size = nice_step_size(raw_num, [raw_num_upper])
%
% Inputs:
%   raw_num             Either a lower limit of numerical range or the
%                           upper limit (when lower limit is zero).
%   raw_num_upper       Optional.  If range of numbers is from x to y,
%                           call nice_step_size(x, y)
%                         If it's zero to y, you can skip the zero &
%                           call nice_step_size(y)
% Output:
%   step_size

% Kevin J. Delaney
% September 22, 2008
% October 23, 2008      Adapted for negative numbers & ranges that don't
%                           start at zero
  
if ~exist('raw_num', 'var')
    help(mfilename);
    step_size = [];
    return
end

if isempty(raw_num) || ...
   ~isnumeric(raw_num)
    errordlg('Input "raw_num" is empty or non-numeric.', mfilename);
    step_size = [];
    return
end

%   Default: range starts at zero.
numerical_span = raw_num;

if exist('raw_num_upper', 'var') && ...
   ~isempty(raw_num_upper) && ...
   isnumeric(raw_num_upper)
    numerical_span = raw_num_upper - raw_num;
end

%   Scale to between 1 & 10.
orig_sign = sign(numerical_span);
scale_factor = 10 .^ (floor(log10(abs(numerical_span))));
numerical_span_scaled = abs(numerical_span) ./ scale_factor;
step_size_scaled = zeros(size(numerical_span_scaled));

for k = 1:length(numerical_span_scaled)
    if numerical_span_scaled(k) < 3
        step_size_scaled(k) = 0.25;
    elseif numerical_span_scaled(k) < 5
        step_size_scaled(k) = 0.5;
    else
        step_size_scaled(k) = 1;
    end 
end

step_size = orig_sign * step_size_scaled .* scale_factor;