function velocity = calculatevelocity(depth, time)

%CALCULATEVELOCTIY- Calculate velocity from depth and time.
%
% Syntax:  [velocity] = CALCULATEVELOCITY(depth, time)
% 
% Calculates velocity using the midpoints of depth and time and
% interpolates back to the original time and depth point given.
% 
% Inputs:
%   pressure - Vector of depth values in m.
%
%   time - Time at each depth value in datenum.
%
% Outputs:
%    velocity - velocity at the input time values in m/s.
%
% Example: 
%    velocity = CALCULATEVELOCITY(depth, time)
%
% See also: RSKremoveloops.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-07-04

secondsperday = 86400;
deltaD = diff(depth);
deltaT = diff(time * secondsperday);
dDdT = deltaD ./ deltaT;
midtime = time(1:end-1) + deltaT/(2*secondsperday);
velocity = interp1(midtime, dDdT, time, 'linear', 'extrap');
    
end