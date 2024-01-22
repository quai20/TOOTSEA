function handles = RSKplotTS(RSK, varargin)

% RSKplotTS - Plot a TS diagram in terms of Practical Salinity and
%            Potential Temperature.
%
% Syntax:  [handles] = RSKplotTS(RSK, [OPTIONS])
% 
% Plots potential temperature vs. Practical Salinity using 0 dbar as a
% reference.  Potential density anomaly contours are drawn
% automatically.  Uses functions included in the TEOS-10 GSW toolbox
% (http://www.teos-10.org/software.htm#1). When RSK input contains no
% profiles, it will be considered as time series data and be plotted with
% gradually changing color based on date. Otherwise, it will be considered
% as multiple profiles and be plotted with different colors for all
% profiles.
%
% Note: Absolute Salinity is computed in order to calculate potential
% temperature and potential density.  Here it is assumed that the
% Absolute Salinity (SA) anomaly is zero, which means that SA = SR
% (Reference Salinity).  This is probably the best approach near
% the coast (see http://www.teos-10.org/pubs/TEOS-10_Primer.pdf).
%
% Inputs: 
%    [Required] - RSK - Structure containing the logger metadata and data.
%
%    [Optional] - profile - Profile number to plot. Default is to plot 
%                           all detected profiles.
% 
%                 direction - 'up' for upcast, 'down' for downcast or
%                           'both'. Default is to use all directions
%                           available.
%                 
%                 isopycnal - number of isopycnals to show on the plot, or 
%                           a vector containing desired isopycnals. Default 
%                           is 5.
%
% Output:
%     handles - Line object of the plot.
%
% Examples:
%    rsk = RSKopen('profiles.rsk');
%    rsk = RSKreadprofiles(rsk, 'direction', 'down');
%    rsk = RSKderivesalinity(RSK);
%    % plot selective downcasts and output handles for customization 
%    hdls = RSKplotTS(rsk, 'profile', [1 5 10], 'isopycnal', 10);
%    or
%    hdls = RSKplotTS(rsk, 'isopycnal', (22:0.5:25));
%
% See also: RSKderivesalinity, RSKplotprofiles.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-08-13


validDirections = {'down', 'up', 'both'};
checkDirection = @(x) any(validatestring(x,validDirections));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'profile', [], @isnumeric);
addParameter(p, 'direction', [], checkDirection);
addParameter(p, 'isopycnal', 5);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
profile = p.Results.profile;
direction = p.Results.direction;
isopycnal = p.Results.isopycnal;


hasTEOS = ~isempty(which('gsw_z_from_p'));
if ~hasTEOS
    RSKerror('Must install TEOS-10 toolbox. Download it from here: http://www.teos-10.org/software.htm');
end

checkDataField(RSK)

isProfile = isfield(RSK.data,'direction');
if ~isProfile && ( ~isempty(profile) ||  ~isempty(direction) )
    RSKerror('RSK contains no profiles, use RSKreadprofiles first.');
end

castidx = getdataindex(RSK, profile, direction);
Scol = getchannelindex(RSK, 'salinity');
Tcol = getchannelindex(RSK, 'temperature');
[RSKsp, SPcol] = getseapressure(RSK);

ii = 1;
if isProfile, legendtext = cell(length(castidx),1); end
for ndx = castidx
    % Process isopycnal data
    SP = RSK.data(ndx).values(:,Scol);
    seapressure = RSKsp.data(ndx).values(:,SPcol);
    
    SA = gsw_SR_from_SP(SP); % assume delta SA = 0
    pt = gsw_pt0_from_t(SA, RSK.data(ndx).values(:,Tcol), seapressure);
    
    if ndx == castidx(1)
        SA_min = min(SA);
        SA_max = max(SA);
        pt_min = min(pt);
        pt_max = max(pt);
    end
    
    SA_min = min([min(SA), SA_min]);
    SA_max = max([max(SA), SA_max]);
    pt_min = min([min(pt), pt_min]);
    pt_max = max([max(pt), pt_max]);
    
    SA_axis = SA_min-0.2:(SA_max-SA_min)/200:SA_max+0.2;
    pt_axis = pt_min-0.2:(pt_max-pt_min)/200:pt_max+0.2;
    SA_axis(SA_axis < 0) = NaN;

    [SA_gridded, pt_gridded] = meshgrid(SA_axis,pt_axis);
    isopycs_gridded = gsw_sigma0_pt0_exact(SA_gridded, pt_gridded); % Potential density

    SP_gridded = gsw_SP_from_SR(SA_gridded);

    if isProfile
        handles(ii) = plot(SP, pt, 'o');
        hold on
        legendtext{ii} = [RSK.data(ndx).direction 'cast ' num2str(RSK.data(ndx).profilenumber)];
        ii = ii+1;
    else
        c = linspace(min(min(isopycs_gridded)) ,max(max(isopycs_gridded)), length(SP));
        handles(ii) = scatter(SP, pt, [], c);  
        cb = colorbar;
        for i = 1:length(cb.TickLabels), cb.TickLabels{i} = ''; end
        cb.TickLabels{1} = char(datetime(RSK.data.tstamp(1),'ConvertFrom','datenum'));
        cb.TickLabels{end} = char(datetime(RSK.data.tstamp(end),'ConvertFrom','datenum'));
        cb.Location = 'northoutside';
        hold on
    end

    if ndx == castidx(end)
        [c1,h] = contour(SP_gridded, pt_gridded, isopycs_gridded, isopycnal,':','Color',[.5 .5 .5]);
        clabel(c1,h,'labelspacing',360,'color',[.5 .5 .5]);
        h.LevelList = round(h.LevelList,1);
        hold on
        if isProfile, legend(legendtext,'location','best'), end
    end
end

ylabel(['Potential Temperature (' RSK.channels(Tcol).units ')']);
xlabel('Practical Salinity');
title('\theta_0-S diagram')
hold off
shg

end
