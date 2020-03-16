function dateNtick(axis_id, date_format_code, varargin)
% Expands upon Matlab-standard "datetick" by adding time notations to its
% date notations.
%
% dateNtick(axis_id, date_format_code, 'keeplimits', 'keepticks', 'linked_axes', 'axes_handle', axes_handle)
%
% Inputs:
%   axis_id             Character like 'x' or 'y'  (Can't do 'z' yet).
%   date_format_code    Option: integer that specifies date/time formatting.
%                       (see "help datetick" for details)
%                           default: style #2 (mm/dd/yy)
% Options:
%   'keeplimits'
%   'keepticks'
%   'linked_axes'
%   'axes_handle', axes_handle

%   Based on original code by:
%       Peter Torrione 12 Jul 1999 
%
%   Extended by:
%       Kevin J. Delaney October 24, 2008
%
%   Revisions:
%       October 29, 2008    Changed auto-setting of time tics to use 
%                               limits of the DATA, not limits of existing
%                               plot.
%       October 31, 2008    Eliminated testing for manual axis mode.
%                           If user called this routine, they want it to
%                           work automatically.
%       November 3, 2008    Added 'linked_axes' as an option.
%       December 30, 2008   Made more robust if no data lines are found.
%       January  5, 2009    Added 'axes_handle' option.
%       January 12, 2009    Made sure 'datetick' points at the right axes.
%       March 3, 2009       1) Fixed the way it searches for subplots.
%                               Looking for axes with empty tags isn't
%                               enough anymore.  Need to look for all axes
%                               belonging to this parent, then eliminate
%                               those tagged "legend".
%                           2) Made sure 'text' points at the right axes.
%       April 20, 2009      Better of handling of inputs as a Callback.
%       May 11, 2009        Gracefully handle cases where there's just one
%                               data point.
%       September 1, 2009   Insert bug workaround re: renderer.
%       January 15, 2010    Ensure 'keeplimits' really works.
%
%   Constants
ten_minutes = datenum(0, 0, 0, 0, 10, 0);
horizontal_offset_fraction = 0.30;

%   Defaults
if ~exist('axis_id', 'var') || ...
   ~ischar(axis_id)
    axis_id = 'x';
end

if ~exist('date_format_code', 'var') || ...
   ~isnumeric(date_format_code)
    date_format_code = 20;
end

keep_limits_on = false;
keep_ticks_on = false;
axes_are_linked = false;

%   Scan the user's options.
varargin_index = 1;

while varargin_index <= length(varargin)
    varargin_name = varargin{varargin_index};
    
    if ~ischar(varargin_name)
        errordlg('Option name is non-char.', mfilename);
        return
    end
    
    switch lower(varargin_name)
        
        case {'keeplimits', 'keep_limits'}
            keep_limits_on = true;
            varargin_index = varargin_index + 1;
        
        case {'keepticks', 'keeptics', 'keep_ticks', 'keep_tics'}
            keep_ticks_on = true;
            varargin_index = varargin_index + 1;
        
        case {'linked_axes', 'linkedaxes'}
            axes_are_linked = true;
            varargin_index = varargin_index + 1;

        case {'axes_handle', 'axeshandle', 'axes', 'handle'}
            varargin_index = varargin_index + 1;
            
            if varargin_index <= length(varargin)
                axes_handle = varargin{varargin_index};
                varargin_index = varargin_index + 1;
                
                if ~ishandle(axes_handle)
                    errordlg('Axes handle provided is not a valid handle.', ...
                        mfilename);
                    return
                end
                
                if ~strcmp(get(axes_handle, 'Type'), 'axes')
                    errordlg('Handle provided is not an axes handle.', ...
                        mfilename);
                    return
                end
            else
                errordlg('Option "axes_handle" provided without a matching axes_handle.', ...
                    mfilename);
                return
            end
        
        case 'x'
            axis_id = 'x';
            varargin_index = varargin_index + 1;
            
            if varargin_index <= length(varargin)
                option_value = varargin{varargin_index};
                varargin_index = varargin_index + 1;

                if isnumeric(option_value) && iswhole(option_value)
                    date_format_code = option_value;
                else
                    errordlg('Unknown date_format_code accompanying "x" axis option.', ...
                        mfilename);
                    return
                end
            end
            
        case 'y'
            axis_id = 'y';
            varargin_index = varargin_index + 1;
            
            if varargin_index <= length(varargin)
                option_value = varargin{varargin_index};
                varargin_index = varargin_index + 1;

                if isnumeric(option_value) && iswhole(option_value)
                    date_format_code = option_value;
                else
                    errordlg('Unknown date_format_code accompanying "y" axis option.', ...
                        mfilename);
                    return
                end
            end            
            
        otherwise
            errordlg(['Unknown option name: ', varargin_name], mfilename);
            return
    end
    
end

if ~exist('axes_handle', 'var') || ...
   isempty(axes_handle) || ...
   ~ishandle(axes_handle)
    axes_handle = gca;
end

%   Make sure we're not inside a legend by mistake!
if strcmp(get(axes_handle, 'Tag'), 'legend')
    return
end
%
%   Bug workaround:
%
% "It has been observed that sometimes exponents remain on axes labels even
%  when they're not needed when the OpenGL renderer is used. The best
%  workaround in this case is to change the renderer to �zbuffer� renderer
%  using the following command: set(gcf,'renderer','zbuffer'). Once you
%  execute this command, the exponent in your axes labels should vanish."
figure_handle = get(axes_handle, 'Parent');

if isempty(figure_handle) || ...
   ~ishandle(figure_handle) || ...
   ~strcmp(get(figure_handle, 'Type'), 'figure')
    errordlg('Unable to find "Parent" of axes_handle.', mfilename);
    return
end

set(figure_handle, 'renderer', 'zbuffer');

%   Come back here if figure zoomed, panned or resized.
h = zoom(figure_handle);

if isempty(get(h, 'ActionPostCallback'))
    set(h, 'ActionPostCallback', {@pan_zoom_dateNtick, axis_id, date_format_code}, ...
           'Enable', 'on', ...
           'Motion', 'both');
end
%
%   Specify how axes will get relabeled when panned.
%
h = pan(figure_handle);

if isempty(get(h, 'ActionPostCallback'))
    set(h, 'ActionPostCallback', {@pan_zoom_dateNtick, axis_id, date_format_code}, ...
           'Enable', 'on', ...
           'Motion', 'both');
end
%
%   Come back here for tweak of labels if figure resized.
%
if isempty(get(figure_handle, 'ResizeFcn'))
    set(figure_handle, 'PaperPositionMode', 'auto', ...
                       'ResizeFcn', {@resize_dateNtick, axes_handle, axis_id, date_format_code});
end
%
%   Get rid of old labels, in case dateNtick is being called a second time.
%
delete(findobj('Parent', axes_handle, 'Tag', 'dateNtick_labels'));
other_axes_handles = find_overlaid_axes(axes_handle);

for k = 1:length(other_axes_handles)
    delete(findobj('Parent', other_axes_handles(k), 'Tag', 'dateNtick_labels'));
end

switch axis_id
    case 'x'
        %   Pick some smart ticks.
        if ~keep_ticks_on
            
            current_data_limits = get_axes_data_limits('x', axes_handle);
            
            if isempty(current_data_limits)
                %   Then there's no way to apply axis tics.
                return
            end
            
            if keep_limits_on || axes_are_linked
                %   We won't go back out to full extent of data, but
                %   there's never sense in putting plot limits WIDER than
                %   the data need.
                current_axes_limits = get(axes_handle, 'XLim');
                axes_data_limits = find_overlap(current_axes_limits, current_data_limits);
                
                %   What if there's no overlap?
                if isempty(axes_data_limits)
                    axes_data_limits = current_data_limits;
                end
            else
                axes_data_limits = current_data_limits;
            end

            time_tics = nice_time_tics(axes_data_limits(1), axes_data_limits(2));
            
            if isempty(time_tics)
                %errordlg(['Unable to form time tics from data limits: [', ...
                %    num2str(axes_data_limits(1)), ', ', num2str(axes_data_limits(2)), ']'], ...                
                %    mfilename);
                return
            elseif length(time_tics) == 1
                time_tics = time_tics + [0, units(1, 'seconds', 'day')];
            end
            
            %   Don't change axes limits if these axes are linked to
            %   others.
            if axes_are_linked
                set(axes_handle, 'XTick', time_tics);
            elseif keep_limits_on
                set(axes_handle, 'XTick', time_tics, 'XLim', axes_data_limits);
            else
                set(axes_handle, 'XTick', time_tics, ...
                         'XLim', [time_tics(1), time_tics(end)]);
            end
        end

    case 'y'
        %   Pick some smart ticks.
        if ~keep_ticks_on

            current_data_limits = get_axes_data_limits('y', axes_handle);
                    
            if isempty(current_data_limits)
                %   Then there's no way to apply axis tics.
                return
            end

            if keep_limits_on || axes_are_linked
                %   We won't go back out to full extent of data, but
                %   there's never sense in putting plot limits WIDER than
                %   the data need.
                current_axes_limits = get(axes_handle, 'YLim');
                axes_data_limits = find_overlap(current_axes_limits, current_data_limits);
                
                %   What if there's no overlap?
                if isempty(axes_data_limits)
                    axes_data_limits = current_data_limits;
                end
            else
                axes_data_limits = current_data_limits;
            end

            time_tics = nice_time_tics(axes_data_limits(1), axes_data_limits(2));
                
            if isempty(time_tics)
                %errordlg(['Unable to form time tics from data limits: [', ...
                %    num2str(axes_data_limits(1)), ', ', num2str(axes_data_limits(2)), ']'], ...                
                %    mfilename);
                return
            elseif length(time_tics) == 1
                time_tics = time_tics + [0, units(1, 'seconds', 'day')];
            end

            %   Don't change axes limits if these axes are linked to
            %   others.
            if axes_are_linked
                set(axes_handle, 'YTick', time_tics);
            elseif keep_limits_on
                set(axes_handle, 'YTick', time_tics, 'YLim', axes_data_limits);
            else
                set(axes_handle, 'YTick', time_tics, ...
                         'YLim', [time_tics(1), time_tics(end)]);
            end

        end

    otherwise
        errordlg(['Unable to handle "', axis_id, '" axis'], mfilename);
        return
end

fsize = min(get(axes_handle, 'FontSize'),10);
set(gca,'FontName','FixedWidth');

%   First, use the standard Matlab function to do the heavy lifting.
datetick(axes_handle, axis_id, date_format_code, 'keepticks', 'keeplimits');

%   How many subplots?
subplot_handles = findobj('Type', 'axes', ...
                          'Parent', get(axes_handle, 'Parent'));
legend_handles = findobj('Tag', 'legend', ...
                         'Parent', get(axes_handle, 'Parent'));
subplot_handles = setdiff(subplot_handles, legend_handles);

%   Make additional text a little tighter if there are >= 3 subplots.
if length(subplot_handles) > 3
    vertical_offset_fraction = 0.19;
else
%     vertical_offset_fraction = 0.25;
    vertical_offset_fraction = 0.28;
%    vertical_offset_fraction = 0.4;
end

switch axis_id 
    case 'x'        
        %   Now, based on time span, figure out what kind of time tics we need.
        xlim = get(axes_handle, 'XLim');
        
        %   If it's more than ten minutes, probably don't want seconds.
        if diff(xlim) >= ten_minutes
            time_format_code = 15;
        else
            time_format_code = 13;
        end
         
        xtics = get(axes_handle, 'XTick');
        
        %   Only keep ticks that are within the plot limits.
        within_limits_syndrome = ((xtics >= xlim(1)) & (xtics <= xlim(2)));
        xtics = xtics(within_limits_syndrome);
        
        %   If we just wiped out the ticks, compute new ones.
        if isempty(xtics)
            xtics = nice_time_tics(xlim(1), xlim(2));
            set(axes_handle, 'XTick', xtics);
            
            %   Better repeat the datetick labeling.
            datetick(axis_id, date_format_code, 'keepticks');
        end
        
        %   If the hr/min/sec labels will all be "00:00", skip them.
        if all(is_whole_day(xtics))
            return
        end
        
        set(axes_handle, 'units', 'inches');
        axes_position_vector = get(axes_handle, 'position'); 
        yaxlinch = axes_position_vector(4);

        %   Compute amount text must be moved in the y-direction.
        ylims = get(axes_handle, 'ylim');
        
        if strcmp(get(axes_handle, 'YScale'), 'linear')
            offset = vertical_offset_fraction * abs(ylims(2) - ylims(1)) / yaxlinch;
        else
            offset = vertical_offset_fraction * abs(log10(ylims(2)) - log10(ylims(1))) / yaxlinch;
        end
        
        %   Account for whether x-axis is on top or bottom of plot...
        if strcmp(get(axes_handle, 'XAxisLocation'), 'bottom')
            %   ...and whether y-axis is upside-down...
            if strcmp(get(axes_handle, 'YDir'), 'normal')
                %...and whether the y-axis is linear or log.
                if strcmp(get(axes_handle, 'YScale'), 'linear')
                    y_position_of_time_labels = ylims(1) - offset;
                else
                    y_position_of_time_labels = 10 .^ (log10(ylims(1)) - offset);
                end
            else
                if strcmp(get(axes_handle, 'YScale'), 'linear')
                    y_position_of_time_labels = ylims(2) + offset;
                else
                    y_position_of_time_labels = 10 .^ (log10(ylims(2)) + offset);
                end
            end
        else
            if strcmp(get(axes_handle, 'YDir'), 'normal')
                if strcmp(get(axes_handle, 'YScale'), 'linear')
                    y_position_of_time_labels = ylims(2) + offset;
                else
                    y_position_of_time_labels = 10 .^ (log10(ylims(2)) + offset);
                end
            else
                if strcmp(get(axes_handle, 'YScale'), 'linear')
                    y_position_of_time_labels = ylims(1) - offset;
                else
                    y_position_of_time_labels = 10 .^ (log10(ylims(1)) - offset);
                end
            end
        end

        xlen = 0;
        ypos = y_position_of_time_labels * ones(length(xtics), 1);

        labels = datestr(xtics, time_format_code);
%
% 29/05/2015 : C. Kermabon
% 		On convertit ypos en double pour compatibilite matlab 2015a.
%
        text(xtics - xlen, double(ypos), labels, ...
             'Color', get(axes_handle, 'XColor'), ...
             'FontSize', fsize, ...
             'FontName','Times',...
             'HorizontalAlignment', 'center', ...
             'Parent', axes_handle, ...
             'Tag', 'dateNtick_labels');

        set(axes_handle,'units','normal');

        aa = get(get(axes_handle,'xlabel'),'position');

        if strcmp(get(axes_handle, 'YScale'), 'linear')
            offset = ylims(1) - (0.4 * (ylims(2) - ylims(1)) / yaxlinch);
        else
            offset = 10 .^ (log10(ylims(1)) - (0.4 * (log10(ylims(2)) - log10(ylims(1))) / yaxlinch));
        end
        
        set(get(axes_handle, 'xlabel'), 'position', [aa(1) offset 0]);

    case 'y'
        %   Now, based on time span, figure out what kind of time tics we need.
        ylim = get(axes_handle, 'YLim');
        
        %   If it's more than ten minutes, probably don't want seconds.
        if diff(ylim) >= ten_minutes
            time_format_code = 15;
        else
            time_format_code = 13;
        end

        ytics = get(axes_handle, 'YTick');
        
        %   Only keep ticks that are within the plot limits.
        within_limits_syndrome = ((ytics >= ylim(1)) & (ytics <= ylim(2)));
        ytics = ytics(within_limits_syndrome);
        
        %   If we just wiped out the ticks, compute new ones.
        if isempty(ytics)
            ytics = nice_time_tics(ylim(1), ylim(2));
            set(axes_handle, 'YTick', ytics);
            
            %   Better repeat the datetick labeling.
            datetick(axis_id, date_format_code, 'keepticks');
        end

        %   If the hr/min/sec labels will all be "00:00", skip them.
        if all(is_whole_day(ytics))
            return
        end
        
        set(axes_handle, 'units', 'inches');
        axes_position_vector = get(axes_handle, 'position'); 
        xaxlinch = axes_position_vector(3);

        %   Allow for reverse-direction x-axes.
        xlims = get(axes_handle, 'xlim');
%         offset = 0.30 * abs(xlims(2) - xlims(1)) / xaxlinch;
        
        if strcmp(get(axes_handle, 'XScale'), 'linear')
            offset = horizontal_offset_fraction * abs(xlims(2) - xlims(1)) / xaxlinch;
        else
            offset = horizontal_offset_fraction * abs(log10(xlims(2)) - log10(xlims(1))) / xaxlinch;
        end

        if strcmp(get(axes_handle, 'YAxisLocation'), 'left')
            if strcmp(get(axes_handle, 'XDir'), 'normal')
                if strcmp(get(axes_handle, 'XScale'), 'linear')
                    xx = xlims(1) - offset;
                else
                    xx = 10 .^ (log10(xlims(1)) - offset);
                end
            else
                if strcmp(get(axes_handle, 'XScale'), 'linear')
                    xx = xlims(2) + offset;
                else
                    xx = 10 .^ (log10(xlims(2)) + offset);
                end
            end
        else
            if strcmp(get(axes_handle, 'XDir'), 'normal')
                if strcmp(get(axes_handle, 'XScale'), 'linear')
                    xx = xlims(2) + offset;
                else
                    xx = 10 .^ (log10(xlims(2)) + offset);
                end
            else
                if strcmp(get(axes_handle, 'XScale'), 'linear')
                    xx = xlims(1) - offset;
                else
                    xx = 10 .^ (log10(xlims(1)) - offset);
                end
            end
        end

        ylen = (ytics(end) - ytics(1)) * .035;
        xpos = xx * ones(length(ytics),1);

        labels = datestr(ytics, time_format_code);
        text(xpos, ytics - ylen, labels, ...
             'Color', get(axes_handle, 'YColor'), ...
             'FontSize', get(axes_handle, 'FontSize'), ...
             'HorizontalAlignment', 'center', ...
             'Parent', axes_handle, ...
             'Tag', 'dateNtick_labels');

        set(axes_handle,'units','normal');

        aa = get(get(axes_handle,'ylabel'), 'position');
        
        if strcmp(get(axes_handle, 'XScale'), 'linear')
            offset = xlims(1) - (0.4 * (xlims(2) - xlims(1)) / xaxlinch);
        else
            offset = 10 .^ (log10(xlims(1)) - (0.4 * (log10(xlims(2)) - log10(xlims(1))) / xaxlinch));
        end
        
        set(get(axes_handle, 'ylabel'), 'position', [aa(1) offset 0]);

    otherwise
        errordlg(['Unable to handle "', axis_id, '" axis'], mfilename);
        return
end

function pan_zoom_dateNtick(~, evd, axis_id, date_format_code)
    
    dateNtick(axis_id, date_format_code, 'axes_handle', evd.Axes, 'keeplimits');

    
    
function resize_dateNtick(~, ~, axes_handle, axis_id, date_format_code)
    
    dateNtick(axis_id, date_format_code, 'axes_handle', axes_handle, 'keeplimits');
    
