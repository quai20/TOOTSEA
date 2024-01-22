function RSK = RSKcorrecttau(RSK, varargin)

% RSKcorrecttau - Apply tau correction and smoothing (optional) algorithm 
% from Fozdar et al. (1985)
%
% Syntax:  RSK = RSKcorrecttau(RSK,'channel','channelName','tauResponse',tauRespone,[OPTIONS])
% 
% Sensors require a finite time to reach equilibrium with the ambient
% environment under variable conditions.  The adjustment process
% alters both the magnitude and phase of the true signal. The time to
% reach 63.2% of the true value is defined as time constant
% (tau). This function applies Fozdar et al. (1985) recursive filter
% in the time domain to correct the phase and response of the measured
% signal to more accurately represent the true signal. The Fozdar algorithm
% reduces to the standard expression when tauSmooth = 0, which is the
% default.
%
% Fozdar, F.M., G.J. Parkar, and J. Imberger, 1985: Matching
% Temperature and Conductivity Sensor Response
% Characteristics. J. Phys. Oceanogr., 15, 1557-1569,
% https://doi.org/10.1175/1520-0485(1985)015<1557:MTACSR>2.0.CO;2
%    
% Inputs:
%   [Required] - RSK - Structure containing logger data.
%
%                channel - Longname of channel to apply tau correction
%                       (e.g., Temperature, Dissolved O2).
%
%                tauResponse - sensor time constant of the channel in
%                       seconds.
%
%   [Optional] - tauSmooth - smoothing time scale in seconds. Default is 0.
%
%                profile - Profile number. Default is all available 
%                       profiles.
%
%                direction - 'up' for upcast, 'down' for downcast, or
%                      'both' for all. Default is all directions available.
%
%                visualize - To give a diagnostic plot on specified profile 
%                      number(s). Original and processed data will be 
%                      plotted to show users how the algorithm works. 
%                      Default is 0.
%
% Outputs:
%    RSK - Structure with corrected channel in place of measured channel.
%
% Example: 
%    rsk = RSKcorrecttau(rsk,'channel','Dissolved O2','tauResponse',1)
%    OR
%    rsk = RSKcorrecttau(rsk,'channel','Temperature','tauResponse',1,'tauSmooth',0.2,'direction','down','profile',1); 
%
% See also: RSKremoveloops, RSKsmooth.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-12-18


validDirections = {'down', 'up', 'both'};
checkDirection = @(x) any(validatestring(x,validDirections));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'channel','',@ischar);
addParameter(p, 'tauResponse',[], @isnumeric);
addParameter(p, 'tauSmooth', 0, @isnumeric);
addParameter(p, 'profile', [], @isnumeric);
addParameter(p, 'direction', [], checkDirection);
addParameter(p, 'visualize', 0, @isnumeric);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
channel = p.Results.channel;
tauResponse = p.Results.tauResponse;
tauSmooth = p.Results.tauSmooth;
profile = p.Results.profile;
direction = p.Results.direction;
visualize = p.Results.visualize;


checkDataField(RSK)

if isempty(channel)
    RSKwarning('Please specify which channel to apply tau correction.')
    return
end

if isempty(tauResponse)
    RSKwarning('Please specify tauResponse for the channel.')
    return
end

channelCol = getchannelindex(RSK, channel);
castidx = getdataindex(RSK, profile, direction);

if visualize ~= 0; 
    [raw, diagndx] = checkDiagPlot(RSK, visualize, direction, castidx); 
end

dt = readsamplingperiod(RSK);
ar = exp(-dt/tauResponse);
as = exp(-dt/tauSmooth);

for ndx = castidx
    in = RSK.data(ndx).values(:,channelCol);   
    intime = RSK.data(ndx).tstamp;
    out = correcttau(in, intime, ar, as);   
    RSK.data(ndx).values(:,channelCol) = out;
    if visualize ~= 0      
        for d = diagndx;
            if ndx == d;
                figure
                doDiagPlot(RSK,raw,'ndx',ndx,'channelidx',channelCol,'fn',mfilename); 
            end
        end
    end 
end


logdata = logentrydata(RSK, profile, direction);
logentry = sprintf('%s tau-corrected using tau response time of %1.0f sec and tau smooth time of %1.0f sec on %s. '...
           , channel, tauResponse, tauSmooth, logdata);
RSK = RSKappendtolog(RSK, logentry);


%% Nested Functions
function out = correcttau(in, intime, ar, as)
% see Fozdar et al. (1985) for details  

    ind = isfinite(in);
    in_itp = interp1(intime(ind),in(ind),intime,'linear','extrap');    
    out = NaN(size(in));
    out(1) = in(1);

    for j = 2:length(out)
        out(j) = ((1-as)./(1-ar)).*(in_itp(j) - ar*in_itp(j-1)) + as*out(j-1);   
    end
    out(~ind) = NaN; 
end

end