function varargout = RSKplotdata(RSK, varargin)

% RSKplotdata - Plot a time series of logger data.
%
% Syntax:  [OPTIONS] = RSKplotdata(RSK, [OPTIONS])
% 
% Generates a plot displaying the logger data as a time series. If data 
% field has been arranged as profiles (using RSKreadprofiles), then 
% RSKplotdata will plot a time series of a (user selectable) profile upcast
% or downcast. When a particular profile is chosen, but not a cast 
% direction, the function will plot the first direction (downcast or 
% upcast) of the profile only. It also allows plotting cast direction
% (using start and end time from profile field) as patches on top of the
% time series to double check if the profile detection algorithm is working
% properly. 
%
% Inputs:
%    [Required] - RSK - Structure containing the logger metadata and data.
%
%    [Optional] - channel - Longname of channel to plot, can be multiple in
%                       a cell, if no value is given it will plot all
%                       channels.
%
%                 profile - Profile number. Default is 1.
% 
%                 direction - 'up' for upcast, 'down' for downcast. Default
%                       is the first string in RSK.profiles.order; the
%                       first cast.
%
%                 showcast - Show cast direction when set as true. Default
%                       is false. It is recommended to show the cast 
%                       direction patch for time series data only. This
%                       argument will not work when pressure and sea
%                       pressure channels are not available.
%
% Output:
%     [Optional] - handles - Line object of the plot.
%
%                  axes - Axes object of the plot.
%
% Example: 
%    rsk = RSKopen('sample.rsk');   
%    rsk = RSKreaddata(rsk);  
%    handles = RSKplotdata(rsk);
%    -OR-
%    handles = RSKplotdata(rsk, 'channel', {'Temperature', 'Conductivity'})
%    -OR-
%    handles = RSKplotdata(rsk, 'channel', 'Pressure', 'showcast', true);
%
% See also: RSKreadprofiles, RSKplotprofiles, RSKplotdownsample.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2020-04-03


validDirections = {'down', 'up'};
checkDirection = @(x) any(validatestring(x,validDirections));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'channel', 'all');
addParameter(p, 'profile', [], @isnumeric);
addParameter(p, 'direction', [], checkDirection);
addParameter(p, 'showcast', false, @islogical);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
channel = p.Results.channel;
profile = p.Results.profile;
direction = p.Results.direction;
showcast = p.Results.showcast;


checkDataField(RSK)

if length(RSK.data) == 1 && ~isempty(profile) && ~isfield(RSK.data,'direction')
    RSKerror('RSK structure does not contain any profiles, use RSKreadprofiles or RSKtimeseries2profiles.')
end

if isempty(profile); 
    profile = 1; 
end

chanCol = [];
channels = cellchannelnames(RSK, channel);
for chan = channels
    chanCol = [chanCol getchannelindex(RSK, chan{1})];
end

if showcast     
    if any(strcmpi({RSK.channels.longName},'pressure')) && any(strcmpi(channels,'pressure'));
        pCol = getchannelindex(RSK,'Pressure');
    end
    
    if any(strcmpi({RSK.channels.longName},'sea pressure')) && any(strcmpi(channels,'sea pressure'));
        spCol = getchannelindex(RSK,'Sea Pressure');
    end    
    
    if length(RSK.data) ~= 1;
        RSKerror('RSK structure must be time series for showcast, use RSKreaddata.')
    end
    if ~isfield(RSK,'regionCast') || ~isfield(RSK,'profiles')
        RSKerror('RSK does not have cast events for profiles, use RSKfindprofiles or RSKtimeseries2profiles.')
    end
end

castidx = getdataindex(RSK, profile, direction);
if isfield(RSK, 'profiles') && isfield(RSK.profiles, 'order') && any(strcmp(p.UsingDefaults, 'direction'))
    direction = RSK.profiles.order{1};
    castidx = getdataindex(RSK, profile, direction);
end
if size(castidx,2) ~= 1 
    RSKerror('RSKplotdata can only plot one cast and direction. To plot multiple casts or directions, use RSKplotprofiles.')
end


[handles,axes] = channelsubplots(RSK, 'data', 'chanCol', chanCol, 'castidx', castidx);

if isfield(RSK.data,'profilenumber') && isfield(RSK.data,'direction');
    legend(['Profile ' num2str(RSK.data(castidx).profilenumber) ' ' RSK.data(castidx).direction 'cast']);
end

if showcast
    try
        subplotShowcast(RSK,pCol,chanCol,axes)
    catch
        try
            subplotShowcast(RSK,spCol,chanCol,axes)
        catch
            RSKwarning('No pressure or sea pressure channel is specified or available for showcast')
        end
    end
end

if nargout == 0
    varargout = {};
else
    varargout{1} = handles;
    varargout{2} = axes;
end

%% nested function
function subplotShowcast(RSK,COL,chanCol,axes)
    
    pmax = max(RSK.data.values(:,COL));
    
    % Construct vectors of patch vertices from RSK.profiles
    dstart = [RSK.profiles.downcast.tstart]';
    dend   = [RSK.profiles.downcast.tend]';
    ustart = [RSK.profiles.upcast.tstart]';
    uend   = [RSK.profiles.upcast.tend]';
    dpmax = repmat(1.01*pmax,1,length(dstart));
    dpmin = zeros(1,length(dstart));
    upmax = repmat(1.01*pmax,1,length(ustart));
    upmin = zeros(1,length(ustart));

    % Add the patches
    hold on
    hPatch(1) = patch([dstart ; dend ; dend ; dstart],[dpmin ; dpmin ; dpmax ; dpmax],0.9*ones(1,3),'parent',axes(COL == chanCol));
    hPatch(2) = patch([ustart ; uend ; uend ; ustart],[upmin ; upmin ; upmax ; upmax],0.6*ones(1,3),'parent',axes(COL == chanCol));
    alpha(hPatch(1),0.2);
    alpha(hPatch(2),0.2);
    [~, L] = legend(hPatch,'downcast','upcast');
    PatchInLegend = findobj(L, 'type', 'patch');
    set(PatchInLegend, 'facea', 0.2);
end


end
