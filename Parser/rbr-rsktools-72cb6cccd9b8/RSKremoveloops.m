function [RSK, flagidx] = RSKremoveloops(RSK, varargin)

% RSKremoveloops - Remove data exceeding a threshold profiling rate and 
% with reversed pressure (loops).
%
% Syntax: [RSK, flagidx] = RSKremoveloops(RSK, [OPTIONS])
% 
% Identifies and flags data obtained when the logger vertical profiling
% speed falls below a threshold value or when the logger reversed the
% desired cast direction (forming a loop). The flagged data is replaced 
% with NaNs. All logger channels except depth are affected.    
% 
% Profiling speed is estimated by differenciating depth. The depth channel 
% is first smoothed with a 3-point running average to reduce noise. 
% 
% Inputs:
%   [Required] - RSK - RSK structure with logger data and metadata
%
%   [Optional] - profile - Profile number. Defaults to all profiles.
%
%                direction - 'up' for upcast, 'down' for downcast, or
%                      'both' for all. Defaults to all directions available.
% 
%                threshold - Minimum speed at which the profile must
%                      be taken. Defaults to 0.25 m/s.
%
%                visualize - To give a diagnostic plot on specified profile 
%                      number(s). Original, processed data and flagged
%                      data will be plotted to show users how the algorithm
%                      works. Default is 0.
%
% Outputs:
%    RSK - Structure with data filtered by threshold profiling speed and
%          removal of loops.
%
%    flagidx - Index of the samples that are filtered.
%
% Example: 
%    rsk = RSKopen('file.rsk');
%    rsk = RSKreadprofiles(rsk);
%    rsk = RSKremoveloops(rsk);
%    OR
%    rsk = RSKremoveloops(rsk,'profile',7:9,'direction','down','threshold',0.3,'visualize',8);
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-05-07


rsksettings = RSKsettings;

validDirections = {'down', 'up', 'both'};
checkDirection = @(x) any(validatestring(x,validDirections));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'profile', [], @isnumeric);
addParameter(p, 'direction', [], checkDirection);
addParameter(p, 'threshold', rsksettings.loopThreshold, @isnumeric);
addParameter(p, 'accelerationThreshold', -Inf, @isnumeric);
addParameter(p, 'visualize', 0, @isnumeric);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
profile = p.Results.profile;
direction = p.Results.direction;
threshold = p.Results.threshold;
accelerationThreshold = p.Results.accelerationThreshold;
visualize = p.Results.visualize;


checkDataField(RSK)
try
    Dcol = getchannelindex(RSK, 'Depth');
catch
    RSKerror('RSKremoveloops requires a depth channel to calculate velocity (m/s). Use RSKderivedepth...');
end

castidx = getdataindex(RSK, profile, direction);
if visualize ~= 0; 
    [raw, diagndx] = checkDiagPlot(RSK, visualize, direction, castidx); 
    diagChanCol = [getchannelindex(RSK, 'Conductivity'), getchannelindex(RSK, 'Temperature')];
end

k = 1;
for ndx = castidx
    d = RSK.data(ndx).values(:,Dcol);
    depth = runavg(d, 3, 'nan');
    time = RSK.data(ndx).tstamp;

    velocity = calculatevelocity(depth, time);
    acc = calculatevelocity(velocity, time);
    
    if getcastdirection(depth, 'up')
        flag = velocity > -threshold | acc > -accelerationThreshold;
        cm = cummin(depth);
        flag((depth - cm) > 0) = true;
    else
        flag = velocity < threshold | acc < accelerationThreshold; 
        cm = cummax(depth);
        flag((depth - cm) < 0) = true;
    end
    
    flagChannels = ~ismember({RSK.channels.longName},{'Depth','Pressure','Sea Pressure'});
    RSK.data(ndx).values(flag,flagChannels) = NaN;
    flagidx(k).index = find(flag);  
    if visualize ~= 0      
        for d = diagndx;
            if ndx == d;
                figure
                doDiagPlot(RSK,raw,'index',find(flag),'ndx',ndx,'channelidx',diagChanCol,'fn',mfilename); 
            end
        end
    end 
    k = k + 1;
end


logdata = logentrydata(RSK, profile, direction);
logentry = ['Samples measured at a profiling velocity less than ' num2str(threshold) ' m/s were replaced with NaN on ' logdata '.'];
RSK = RSKappendtolog(RSK, logentry);

end
