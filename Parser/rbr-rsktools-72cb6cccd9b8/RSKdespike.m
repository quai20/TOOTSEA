function [RSK, spike] = RSKdespike(RSK, varargin)

% RSKdespike - Despike a time series on a specified channel.
%
% Syntax:  [RSK, spike] = RSKdespike(RSK,'channel','channelName',[OPTIONS])
% 
% Identifies and treats spikes using a median filtering algorithm.  A
% reference time series is created by filtering the input channel with
% a median filter of length 'windowLength'. A residual ("high-pass")
% series is formed by subtracting the reference series from the
% original signal.  Data in the reference series lying outside of
% 'threshold' standard deviations are defined as spikes.  Spikes are
% then treated by one of three methods (see below).
%    
% Inputs:
%   [Required] - RSK - Structure containing logger data.
%
%                channel - Longname of channel to despike (e.g., 
%                      temperature, salinity, etc)
%
%   [Optional] - profile - Profile number. Default is all available 
%                      profiles.
%
%                direction - 'up' for upcast, 'down' for downcast, or
%                      'both' for all. Default is all directions available.
%
%                threshold - Amount of standard deviations to use for the
%                      spike criterion. Default value is 2. 
%
%                windowLength - Total size of the filter window. Must be
%                      odd. Default is 3. 
%
%                action - Action to perform on a spike. The default is 
%                      'nan', whereby spikes are replaced with NaN. Other 
%                      options are 'replace', whereby spikes are replaced 
%                      with the corresponding reference value, and 'interp' 
%                      whereby spikes are replaced with values calculated
%                      by linearly interpolating from the neighbouring 
%                      points.
%
%                visualize - To give a diagnostic plot on specified profile 
%                      number(s). Original, processed data and flagged
%                      data will be plotted to show users how the algorithm
%                      works. Default is 0.
%
% Outputs:
%    RSK - Structure with de-spiked series.
%
%    spike - Structure containing the index of the spikes; if more than one
%          channel was despiked, spike is a structure with a field for each
%          profile.   
%
% Example: 
%    [rsk, spike] = RSKdespike(rsk,'channel','Turbidity')
%     OR 
%    [rsk, spike] = RSKdespike(rsk,'channel','Temperature','profile',3:5,...
%                   'direction','down','threshold',4,'windowLength',11,...
%                   'action','nan','visualize',4); 
%
% See also: RSKremoveloops, RSKsmooth.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-12-17


validActions = {'replace', 'interp', 'nan'};
checkAction = @(x) any(validatestring(x,validActions));

validDirections = {'down', 'up', 'both'};
checkDirection = @(x) any(validatestring(x,validDirections));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'channel','',@ischar);
addParameter(p, 'profile', [], @isnumeric);
addParameter(p, 'direction', [], checkDirection);
addParameter(p, 'threshold', 2, @isnumeric);
addParameter(p, 'windowLength', 3, @isnumeric);
addParameter(p, 'action', 'nan', checkAction);
addParameter(p, 'visualize', 0, @isnumeric);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
channel = p.Results.channel;
profile = p.Results.profile;
direction = p.Results.direction;
windowLength = p.Results.windowLength;
threshold = p.Results.threshold;
action = p.Results.action;
visualize = p.Results.visualize;


checkDataField(RSK)

if isempty(channel)
    RSKwarning('Please specify which channel to despike.')
    spike = [];
    return
end

channelCol = getchannelindex(RSK, channel);
castidx = getdataindex(RSK, profile, direction);

if visualize ~= 0; 
    [raw, diagndx] = checkDiagPlot(RSK, visualize, direction, castidx); 
end

k = 1;
for ndx = castidx
    in = RSK.data(ndx).values(:,channelCol);
    intime = RSK.data(ndx).tstamp;
    [out, index] = despike(in, intime, threshold, windowLength, action);
    RSK.data(ndx).values(:,channelCol) = out;
    spike(k).index = index;    
    if visualize ~= 0      
        for d = diagndx;
            if ndx == d;
                figure
                doDiagPlot(RSK,raw,'index',index,'ndx',ndx,'channelidx',channelCol,'fn',mfilename); 
            end
        end
    end 
    k = k+1;
end

logdata = logentrydata(RSK, profile, direction);
logentry = sprintf(['%s de-spiked using a %1.0f sample window and %1.0f sigma threshold on %s. '...
           'Spikes were treated with %s.'], channel, windowLength, threshold, logdata, action);
RSK = RSKappendtolog(RSK, logentry);

    %% Nested Functions
    function [y, I] = despike(x, t, threshold, windowLength, action)
    % Replaces the values that are > threshold*standard deviation away from
    % the residual between the original time series and the running median
    % with the median, a NaN or interpolated value using the non-spike
    % values. The output is the x series with spikes fixed and I is the
    % index of the spikes. 
        y = x;
        ref = runmed(x, windowLength);
        dx = x - ref;
        sd = std(dx(isfinite(dx)));
        I = find(abs(dx) > threshold*sd);
        good = find(abs(dx) <= threshold*sd);

        switch action
          case 'replace'
            y(I) = ref(I);
          case 'nan'
            y(I) = NaN;
          case 'interp'
            y(I) = interp1(t(good), x(good), t(I)) ;
        end
    end

end