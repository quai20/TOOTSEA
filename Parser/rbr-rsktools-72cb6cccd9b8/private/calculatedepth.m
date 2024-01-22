function depth = calculatedepth(seapressure, latitude)

% CALCULATEDEPTH - Calculate depth from sea pressure.
%
% Syntax:  [depth] = CALCULATEDEPTH(seapressure, latitude)
% 
% Calculates depth using sea pressure data and latitude. Uses TEOS-10 
% toolbox if it is installed. The toolbox can be found at 
% http://www.teos-10.org/software.htm#1. Otherwise, it is calculated using
% the Saunders & Fofonoff method.  
% 
% Inputs:
%    seapressure - Vector of sea pressure values in dbar
%
%    latitude - Location of the sea pressure measurement in decimal degrees
%               north. 
%
% Outputs:
%    depth - Vector containing depth in meters.
%
% Example: 
%    depth = CALCULATEDEPTH(seapressure, 52)
%
% See also: RSKderivedepth.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-06-12

hasTEOS = ~isempty(which('gsw_z_from_p'));

if hasTEOS
    depth = -gsw_z_from_p(seapressure, latitude);     
else
    x = (sin(latitude/57.29578)).^2;
    gr = 9.780318*(1.0 + (5.2788e-3 + 2.36e-5*x).*x) + 1.092e-6.*seapressure;
    depth = (((-1.82e-15*seapressure + 2.279e-10).*seapressure - 2.2512e-5).*seapressure + 9.72659).*seapressure;
    depth = depth./gr;
end

end