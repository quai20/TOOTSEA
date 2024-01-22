function [RSK, holdpts] = RSKcorrecthold(RSK, varargin)

% RSKcorrecthold - Replace zero-order hold points with interpolated
%                  value or NaN.
%
% Syntax:  [RSK, holdpts] = RSKcorrecthold(RSK, [OPTIONS])
% 
% The analog-to-digital (A2D) converter on RBR instruments must
% recalibrate periodically.  In the time it takes for the calibration
% to finish, one or more samples are missed.  The onboard firmware
% fills the missed sample with the same data measured during the
% previous sample, a simple technique called a zero-order hold.
%
% The function identifies zero-hold points by looking for where
% consecutive differences for each channel are equal to zero, and
% replaces them with an interpolated value or a NaN.
%
% An example of where zero-order holds are important is when computing
% the vertical profiling rate from pressure.  Zero-order hold points
% produce spikes in the profiling rate at regular intervals, which can
% cause the points to be flagged by RSKremoveloops.
%
%
% Inputs:
%   [Required] - RSK - Structure containing logger data.
%
%
%   [Optional] - channel - Longname of channel to correct the zero-order
%                      hold (e.g., temperature, salinity, etc)
%
%                profile - Profile number. Default is all available
%                      profiles.
%
%                direction - 'up' for upcast, 'down' for downcast, or
%                      'both' for all. Default is all directions available.
%
%                action - Action to perform on a hold point. The default is
%                      'nan', whereby hold points are replaced with NaN. 
%                      Another option is 'interp', whereby hold points are
%                      replaced with values calculated by linearly 
%                      interpolating from the neighbouring points.
%
%                visualize - To give a diagnostic plot on specified profile 
%                      number(s). Original, processed data and flagged
%                      data will be plotted to show users how the algorithm
%                      works. Default is 0.
%
% Outputs:
%    RSK - Structure with zero-order hold corrected values.
%
%    holdpts - Structure containing the index of the corrected hold points; 
%              if more than one channel has hold points, hold is a structure
%              with a field for each channel.  
%
% Example: 
%    [rsk, holdpts] = RSKcorrecthold(rsk)
%     OR
%    [rsk, holdpts] = RSKcorrecthold(rsk, 'channel', 'Temperature', 'action', 'interp','visualize',1); 
%
% See also: RSKdespike, RSKremoveloops, RSKsmooth.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-06-06


validActions = {'interp', 'nan'};
checkAction = @(x) any(validatestring(x,validActions));

validDirections = {'down', 'up', 'both'};
checkDirection = @(x) any(validatestring(x,validDirections));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'channel','all');
addParameter(p, 'profile', [], @isnumeric);
addParameter(p, 'direction', [], checkDirection);
addParameter(p, 'action', 'nan', checkAction);
addParameter(p, 'visualize', 0, @isnumeric);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
channel = p.Results.channel;
profile = p.Results.profile;
direction = p.Results.direction;
action = p.Results.action;
visualize = p.Results.visualize;


checkDataField(RSK)

chanCol = [];
channels = cellchannelnames(RSK, channel);
for chan = channels
    chanCol = [chanCol getchannelindex(RSK, chan{1})];
end
castidx = getdataindex(RSK, profile, direction);

if visualize ~= 0; [raw, diagndx] = checkDiagPlot(RSK, visualize, direction, castidx); end

%loop through channels
for c = chanCol 
    k = 1;
    for ndx = castidx
        in = RSK.data(ndx).values(:,c);
        intime = RSK.data(ndx).tstamp; 
        [out, index] = correcthold(in, intime, action);  
        RSK.data(ndx).values(:,c) = out;
        holdpts(k).index{c} = index;       
        if all(visualize ~= 0) && c == chanCol(1);    
            for d = diagndx;
                if ndx == d;
                    figure
                    doDiagPlot(RSK,raw,'index',index,'ndx',ndx,'channelidx',chanCol(1),'fn',mfilename); 
                end
            end
        end        
        k = k+1;
    end     
end

logentry = sprintf(['Zero-order hold corrected for ' repmat('%s ', 1, length(channels)) 'channel.' ' Hold points were treated with %s.'], channels{:}, action);
RSK = RSKappendtolog(RSK, logentry);

    %% Nested Functions
    function [y, I] = correcthold(x, t, action)
    % Replaces zero-order hold values with either a NaN or interpolated 
    % value using the neighbouring points. 

        y = x;
        I = find(diff(x) == 0) + 1;
        good = find(ismember(1:length(t),I) == 0);
        hashold = ~isempty(I);

        if hashold && any(x) % Check if the channel contains zero value only
            switch action  
              case 'interp'
                y(I) = interp1(t(good), x(good), t(I)); 
              case 'nan'
                y(I) = NaN;
            end
        end  
    end

end