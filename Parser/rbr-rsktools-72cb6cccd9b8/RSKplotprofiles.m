function varargout = RSKplotprofiles(RSK, varargin)

% RSKplotprofiles - Plot summaries of logger data as profiles.
%
% Syntax:  [OPTIONS] = RSKplotprofiles(RSK, [OPTIONS])
% 
% Plots profiles from automatically detected casts. The default is to
% plot all the casts of all channels available (excluding pressure,
% sea pressure and depth) against sea pressure, or optionally, depth or 
% pressure. Optionally outputs a matrix of handles to the line objects.
%
% Inputs: 
%    [Required] - RSK - Structure containing the logger metadata and data.
%
%    [Optional] - channel - Variables to plot (e.g., temperature, salinity,
%                        etc). Default is all channel (excluding pressure
%                        and sea pressure).
%
%                 profile - Profile number to plot. Default is to plot 
%                        all detected profiles.
% 
%                 direction - 'up' for upcast, 'down' for downcast or
%                        'both'. Default is to use all directions
%                        available. When choosing 'both', downcasts are
%                        plotted with solid lines and upcasts are plotted
%                        with dashed lines.
% 
%                 reference - Channel plotted on the y axis for each
%                        subplot. Default is sea pressure, option for
%                        depth or pressure.
%
% Output:
%     [Optional] - handles - Line object of the plot.
%
%                  axes - Axes object of the plot.
%
% Examples:
%    rsk = RSKopen('profiles.rsk');
%    rsk = RSKreadprofiles(rsk, 'direction', 'down');
%    % plot selective downcasts and output handles for customization 
%    hdls = RSKplotprofiles(rsk, 'channel', {'Conductivity', 'Temperature'}, 'profile', [1 5 10]);
%
% See also: RSKreadprofiles, RSKreaddata.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-04-15


validDirections = {'down', 'up', 'both'};
checkDirection = @(x) any(validatestring(x,validDirections));

validReference = {'Sea Pressure', 'Depth', 'Pressure'};
checkReference = @(x) any(validatestring(x,validReference));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'profile', [], @isnumeric);
addParameter(p, 'channel', 'all')
addParameter(p, 'direction', [], checkDirection);
addParameter(p, 'reference', 'Sea Pressure', checkReference)
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
profile = p.Results.profile;
channel = p.Results.channel;
direction = p.Results.direction;
reference = p.Results.reference;


if ~isfield(RSK,'data')
    RSKerror('The .data structure is missing from your variable. Perhaps you forgot to call RSKreaddata or RSKreadprofiles first?')
else
    if ~isfield(RSK.data,'direction')
        RSKerror('RSK contains no profiles, use RSKreadprofiles first.')
    end
end

chanCol = [];
channels = cellchannelnames(RSK, channel);
for chan = channels
    if ~(strcmp(chan, 'Pressure') || strcmp(chan, 'Sea Pressure') || strcmp(chan, 'Depth'))
        chanCol = [chanCol getchannelindex(RSK, chan{1})];
    end
end
numchannels = length(chanCol);

if numchannels == 0;
    RSKerror('There are only pressure, sea pressure or depth channel in the rsk file, use RSKplotdata...')
end

castidx = getdataindex(RSK, profile, direction);
if strcmpi(reference, 'Depth')
    ycol = getchannelindex(RSK, 'Depth');
    RSKy = RSK;
elseif strcmpi(reference, 'Pressure');
    ycol = getchannelindex(RSK, 'Pressure');
    RSKy = RSK;
else
    [RSKy, ycol] = getseapressure(RSK);
end

clrs = lines(length(castidx));
pmax = 0;
n = 1;

for chan = chanCol
    subplot(1,numchannels,n)
    
    stepsize = 1;
    
    noninput_both = isempty(direction) && length(RSKy.data) > 1 && RSKy.data(1).profilenumber == RSKy.data(2).profilenumber;
    if strcmp(direction, 'both') || noninput_both % downcast in solid and upcast in dashed line with the same color
        stepsize = 2;
    end
    
    ii = 1;
    for ndx = castidx(1:stepsize:end) 
        line1 = '-';
        line2 = '--';

        if stepsize > 1 && strcmp(RSKy.data(1).direction,'up') % first cast is upcast
            line1 = '--';
            line2 = '-';
        end

        ydata = RSKy.data(ndx).values(:, ycol);
        handles(ii,n) = plot(RSK.data(ndx).values(:, chan), ydata,'color',clrs(ii,:),'linestyle',line1);
        hold on

        if stepsize > 1 && ndx+1 <= max(castidx)
            ydata = RSKy.data(ndx+1).values(:, ycol);
            handles(ii+1,n) = plot(RSK.data(ndx+1).values(:, chan), ydata,'color',clrs(ii,:),'linestyle',line2);
        end

        pmax = max([pmax; ydata]);
        ii = ii+1;
        if stepsize > 1, 
            ii = ii+1; 
        end
    end
    axes(n) = gca;
    ylim([0 pmax])
    title(RSK.channels(chan).longName);
    xlabel(RSK.channels(chan).units);
    ylabel([RSKy.channels(ycol).longName ' [' RSKy.channels(ycol).units ']'])
    n = n+1;  
    grid on
end

if stepsize > 1 && strcmp(RSKy.data(1).direction,'up')
    legend('upcast','downcast','location','best')
elseif stepsize > 1 && strcmp(RSKy.data(1).direction,'down')
    legend('downcast','upcast','location','best')
end

ax = findall(gcf,'type','axes');
set(ax, 'ydir', 'reverse')
linkaxes(ax,'y')
shg

if nargout == 0
    varargout = {};
else
    varargout{1} = handles;
    varargout{2} = axes;
end

end