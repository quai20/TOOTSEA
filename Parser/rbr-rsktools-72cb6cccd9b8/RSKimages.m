function varargout = RSKimages(RSK, varargin)

% RSKimages - Plot profiles in a 2D plot.
%
% Syntax:  [OPTIONS] = RSKimages(RSK, [OPTIONS])
% 
% Generates a plot of the profiles over time. The x-axis is time; the
% y-axis is a reference channel. All data elements must have identical
% reference channel samples. Use RSKbinaverage.m to achieve this. The
% function calls RSKgenerate2D to generate data for visualization and store
% it in RSK.im field. User could make RSK an output if one prefers to alter
% the data in their own way.
%
% Note: If installed, RSKimages will use the perceptually uniform 
%       oceanographic colourmaps in the cmocean toolbox:
%       https://www.mathworks.com/matlabcentral/fileexchange/57773-cmocean-perceptually-uniform-colormaps
%        
%       http://dx.doi.org/10.5670/oceanog.2016.66        
%
% Inputs:
%   [Required] - RSK - Structure, with profiles as read using RSKreadprofiles.
%
%   [Optional] - channel - Longname of channel to plot, can be multiple in
%                      a cell, if no value is given it will plot all
%                      channels.
%
%                profile - Profile numbers to plot. Default is to use all
%                      available profiles.  
%
%                direction - 'up' for upcast, 'down' for downcast. Default
%                      is down.
%
%                reference - Channel that will be plotted as y. Default
%                      'Sea Pressure', can be any other channel.
%
%                showgap - Plotting with interpolated profiles onto a 
%                      regular time grid, so that gaps between each
%                      profile can be shown when set as true. Default is 
%                      false. 
%          
%                threshold - Time threshold in seconds to determine the
%                      maximum gap length shown on the plot. Any gap 
%                      smaller than the threshold will not show. 
%
% Output:
%   [Optional] - handles - Image handles object created, use to set 
%                properties
%
%                axes - Axes object of the plot.
%
%                RSK - Structure, with RSK.im field containing data for 2D
%                visualization.
%
% Example: 
%     handles = RSKimages(rsk,'direction','down'); 
%     OR
%     [handles, axes, rsk] = RSKimages(rsk,'channel',{'Temperature','Conductivity'},'direction','down','interp',true,'threshold',600);
%
% See also: RSKbinaverage, RSKgenerate2D.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-10-01


checkDirection = @(x) ischar(x) || isempty(x);

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'channel', 'all');
addParameter(p, 'profile', [], @isnumeric);
addParameter(p, 'direction', '', checkDirection);
addParameter(p, 'reference', 'Sea Pressure', @ischar);
addParameter(p,'showgap', false, @islogical)
addParameter(p,'threshold', [], @isnumeric)
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
channel = p.Results.channel;
profile = p.Results.profile;
direction = p.Results.direction;
reference = p.Results.reference;
showgap = p.Results.showgap;
threshold = p.Results.threshold;

checkDataField(RSK)
if isempty(direction);
    if isfield(RSK.data,'direction') && all(ismember({RSK.data.direction},'up'))
        direction = 'up';
    elseif isfield(RSK.data,'direction')
        direction = 'down';
    end
end

RSK = RSKgenerate2D(RSK,'channel',channel,'profile',profile,'direction',direction,'reference',reference);
x = RSK.im.x;
y = RSK.im.y;
data = RSK.im.data;
cref = getchannelindex(RSK,reference);

k = 1;
clf
for c = RSK.im.channel

    binValues = data(:,:,k);
    
    axes(k) = subplot(length(RSK.im.channel),1,k);
    if ~showgap
        handles(k) = pcolor(x, y, binValues);
        shading interp
        set(handles(k), 'AlphaData', isfinite(binValues)); % plot NaN values in white.
    else
        unit_time = (x(2)-x(1)); 
        N = round((x(end)-x(1))/unit_time);
        x_itp = linspace(x(1), x(end), N);

        ind_mt = bsxfun(@(x,y) abs(x-y), x(:), reshape(x_itp,1,[]));
        [~, ind_itp] = min(ind_mt,[],2); 
        ind_nan = setxor(ind_itp, 1:length(x_itp));

        binValues_itp = interp1(x,binValues',x_itp)';
        binValues_itp(:,ind_nan) = NaN;

        if ~isempty(threshold);
            diff_idx = diff(ind_itp);
            gap_idx = find(diff_idx > 1);

            remove_gap_idx = [];
            for g = 1:length(gap_idx)
                temp_idx = ind_itp(gap_idx(g))+1 : ind_itp(gap_idx(g))+1+diff_idx(gap_idx(g))-2;
                if length(temp_idx)*unit_time*86400 < threshold; % seconds
                    remove_gap_idx = [remove_gap_idx, temp_idx];
                end
            end

            binValues_itp(:,remove_gap_idx) = [];
            x_itp(remove_gap_idx) = [];

            handles(k) = pcolor(x_itp, y, binValues_itp);
            shading interp
        else
            handles(k) = imagesc(x_itp, y, binValues_itp);       
        end 
        set(handles(k), 'AlphaData', isfinite(binValues_itp)); 
    end

    setcolormap(RSK.channels(c).longName);
    cb = colorbar;
    ylabel(cb, RSK.channels(c).units)
    ylabel(sprintf('%s (%s)', RSK.channels(cref).longName, RSK.channels(cref).units));
    set(gca, 'YDir', 'reverse')
    h = title(sprintf('%s   %s - %s', RSK.channels(c).longName, datestr(RSK.im.x(1), 'mmm dd HH:MM'), datestr(RSK.im.x(end),'mmm dd HH:MM')));
    set(gcf, 'Renderer', 'painters')
    set(h, 'EdgeColor', 'none');
    datetick('x')
    axis tight
    
    k = k + 1;
end

if nargout == 0
    varargout = {};
else
    varargout{1} = handles;
    varargout{2} = axes;
    varargout{3} = RSK;
end

end

