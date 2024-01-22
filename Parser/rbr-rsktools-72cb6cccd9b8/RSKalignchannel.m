function RSK = RSKalignchannel(RSK, varargin)

% RSKalignchannel - Align a channel using a specified lag.
%
% Syntax:  [RSK] = RSKalignchannel(RSK,'channel','channelName','lag',lag,[OPTIONS])
% 
% Applies a sample lag to a specified channel. Typically used for
% conductivity to minimize salinity spiking from C/T mismatches when
% the sensors are moving through strong gradients.
%
% Inputs: 
%    [Required] - RSK - Input RSK structure
%
%                 channel - Longname of channel to align (e.g. temperature)
%
%                 lag - The lag (in samples or seconds) to apply to the 
%                       channel. A negative lag shifts the channel 
%                       backwards in time (earlier), while a positive lag 
%                       shifts the channel forward in time (later). To 
%                       apply a different lag to each data element, specify
%                       the lags in a vector.
%
%    [Optional] - profile - Profile number. Default is to operate on all of
%                       data's elements. 
%
%                 direction - 'up' for upcast, 'down' for downcast, or
%                       'both' for all. Defaults to all directions 
%                       available.
%
%                 shiftfill - Values that will fill the void left at the
%                        beginning or end of the time series. 'nan', fills
%                        the removed samples of the shifted channel with
%                        NaN, 'zeroorderhold' fills the removed samples of
%                        the shifted channels with the first or last value,
%                        'mirror' fills the removed values with the
%                        reflection of the original end point, and 'union'
%                        removes the values of the OTHER channels that
%                        do not align with the shifted channel (note: this
%                        will reduce the size of values array by "lag"
%                        samples).  
%
%                 lagunits - Units of the lag entry. Can be samples
%                        (default) or seconds
%
%                 visualize - To give a diagnostic plot on specified
%                        profile number(s). Original and processed data 
%                        will be plotted to show users how the algorithm 
%                        works. Default is 0.
%
% Outputs:
%    RSK - Structure with aligned channel values.
%
% Example: 
%    rsk = RSKopen('file.rsk');
%    rsk = RSKreadprofiles(rsk, 'profile', 1:10, 'direction', 'down'); 
%
%   1. Shift temperature channel of first four profiles with the same lag value.
%    rsk = RSKalignchannel(rsk,'channel','temperature','lag',2,'profile',1:4);
%
%   2. Shift oxygen channel of first 4 profiles with profile-specific lags.
%    rsk = RSKalignchannel(rsk,'channel','Dissolved O2','lag',[2 1 -1 0],'profile',1:4);
%
%   3. Shift conductivity channel from all downcasts with optimal lag calculated 
%      with RSKcalculateCTlag.m.
%    lag = RSKcalculateCTlag(rsk);
%    rsk = RSKalignchannel(rsk,'channel','Conductivity','lag',lag);
%
% See also: RSKcalculateCTlag.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-12-18


validShiftfill = {'zeroorderhold', 'union', 'nan', 'mirror'};
checkShiftfill = @(x) any(validatestring(x,validShiftfill));

validDirections = {'down', 'up', 'both'};
checkDirection = @(x) any(validatestring(x,validDirections));

validlagunits = {'samples', 'seconds'};
checklagunits = @(x) any(validatestring(x,validlagunits));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'channel', '', @ischar);
addParameter(p, 'lag', [], @isnumeric);
addParameter(p, 'profile', [], @isnumeric);
addParameter(p, 'direction', [], checkDirection);
addParameter(p, 'shiftfill', 'zeroorderhold', checkShiftfill);
addParameter(p, 'lagunits', 'samples', checklagunits);
addParameter(p, 'visualize', 0, @isnumeric);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
channel = p.Results.channel;
lag = p.Results.lag;
profile = p.Results.profile;
direction = p.Results.direction;
shiftfill = p.Results.shiftfill;
lagunits = p.Results.lagunits;
visualize = p.Results.visualize;


if isempty(channel)
    RSKwarning('Please specify which channel to align.')
    return
end

if isempty(lag)
    RSKwarning('Please specify lag to apply to the channel.')
    return
end

checkDataField(RSK)

castidx = getdataindex(RSK, profile, direction);
lags = checklag(lag, castidx, lagunits);
channelCol = getchannelindex(RSK, channel);

if visualize ~= 0; 
    [raw, diagndx] = checkDiagPlot(RSK, visualize, direction, castidx); 
end

counter = 0;
for ndx =  castidx
    counter = counter + 1;       
    channelData = RSK.data(ndx).values(:, channelCol);
    
    if strcmpi(lagunits, 'seconds')
        timelag = lags(counter);
        
        profile_time_length = RSK.data(ndx).tstamp(end,1) - RSK.data(ndx).tstamp(1,1);
        if timelag/86400 > profile_time_length;
            RSKwarning('Time lag must be smaller than profile time length.')
            return
        end
        
        shifttime = RSK.data(ndx).tstamp+timelag/86400;
        shiftchan = interp1(shifttime, channelData, RSK.data(ndx).tstamp);
        if lags(counter) > 0
            samplelag = find(~isnan(shiftchan), 1, 'first') - 1; 
            shiftchan = [shiftchan(samplelag+1:end); shiftchan(1:samplelag)];
        else
            samplelag = find(~isnan(shiftchan), 1, 'last') - length(channelData); 
            shiftchan = [shiftchan(end+samplelag+1:end); shiftchan(1:end+samplelag)];
        end      
    else
        samplelag = lags(counter);       
        if samplelag > length(channelData);
            RSKwarning('Sample lag must be smaller than profile sample length.')
            return
        end
        shiftchan = channelData;
    end
    channelShifted = shiftarray(shiftchan, samplelag, shiftfill);
    
    if strcmpi(shiftfill, 'union')
        if lags(counter) > 0 
            RSK.data(ndx).values = RSK.data(ndx).values(samplelag+1:end,:);
            RSK.data(ndx).tstamp = RSK.data(ndx).tstamp(samplelag+1:end);
        elseif lags(counter) < 0 
            RSK.data(ndx).values = RSK.data(ndx).values(1:end+samplelag,:);
            RSK.data(ndx).tstamp = RSK.data(ndx).tstamp(1:end+samplelag);
        end
    end
    RSK.data(ndx).values(:, channelCol) = channelShifted;
end

if visualize ~= 0      
    for d = diagndx;
        figure
        doDiagPlot(RSK,raw,'ndx',d,'channelidx',channelCol,'fn',mfilename); 
    end
end 

%% Log entry
if length(lag) == 1
    logdata = logentrydata(RSK, profile, direction);
    logentry = [channel ' aligned using a ' num2str(lags(1)) ' ' lagunits ' lag and ' shiftfill ' shiftfill on ' logdata '.'];
    RSK = RSKappendtolog(RSK, logentry);
else
    for ndx = 1:length(castidx)
        logdata = logentrydata(RSK, ndx, direction);
        logentry = [channel ' aligned using a ' num2str(lags(ndx)) ' ' lagunits ' lag and ' shiftfill ' shiftfill on ' logdata '.'];
        RSK = RSKappendtolog(RSK, logentry);
    end
end



%% Nested function
    function lags = checklag(lag, castidx, lagunits)
    % Checks if the lag values are intergers and either: one for all
    % profiles or one for each profiles. 

        if ~isequal(fix(lag),lag) && strcmpi(lagunits, 'samples')
           RSKerror('Lag values must be integers.')
        end

        if length(lag) == 1 && length(castidx) ~= 1
            lags = repmat(lag, 1, length(castidx));
        elseif length(lag) > 1 && length(lag) ~= length(castidx)
            RSKerror(['Length of lag must equal the number of profiles or be a ' ...
                   'single value']);
        else
            lags = lag;
        end
    end

end
