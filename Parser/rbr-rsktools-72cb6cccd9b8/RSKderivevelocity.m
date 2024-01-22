function RSK = RSKderivevelocity(RSK, varargin)

% RSKcalculatevelocity - Calculate velocity from depth and time.
%
% Syntax:  [RSK] = RSKcalculatevelocity(RSK, [OPTIONS])
% 
% Differenciates depth to estimate the profiling speed. The depth channel
% is first smoothed with a 'windowLength' running average to reduce noise.
%
% Inputs: 
%   [Required] - RSK - Structure containing the logger metadata and data
%
%   [Optional] - windowLength - The total size of the filter window used
%                       to filter depth. Must be odd. Default is 3.
%
% Outputs:
%    RSK - RSK structure containing the velocity data.
%
% See also: RSKremoveloops, calculatevelocity.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-05-29


p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'windowLength', 3, @isnumeric);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
windowLength = p.Results.windowLength;


checkDataField(RSK)

try
    Dcol = getchannelindex(RSK, 'Depth');
catch
    RSKerror('RSKcalculatevelocity requires a depth channel to calculate velocity (m/s). Use RSKderivedepth...');
end

RSK = addchannelmetadata(RSK, 'pvel00', 'Velocity', 'm/s');
Vcol = getchannelindex(RSK, 'Velocity');

castidx = getdataindex(RSK);
for ndx = castidx
    d = RSK.data(ndx).values(:,Dcol);
    depth = runavg(d, windowLength, 'nan');
    time = RSK.data(ndx).tstamp;
    vel = calculatevelocity(depth, time);
    
    RSK.data(ndx).values(:,Vcol)  = vel;
end

logentry = ['Profiling velocity calculated from depth filtered with a windowLength of ' num2str(windowLength) ' samples.'];
RSK = RSKappendtolog(RSK, logentry);

end