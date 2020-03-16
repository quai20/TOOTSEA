function axes_data_limits = get_axes_data_limits(axis_id, axes_handle)
% Examines all the line objects in a given axes & finds the extrema.
%
% axes_data_limits = get_axes_data_limits(axis_id, axes_handle)
%
% Inputs:
%   axis_id             Text like 'x', 'y', 'z'
%   axes_handle         Optional handle to axes.  Default: current axes
%
% Output:
%   axes_data_limits    vector of [min, max] of the plotted data

% Kevin J. Delaney
% October 29, 2008
% August 28, 2009       Extended to work in pcolor/surf cases.

axes_data_limits = [];

if ~exist('axis_id', 'var')
    help(mfilename);
    return
end

if ~ischar(axis_id)
    errordlg('Input "axis_id" is non-char.', mfilename);
    return
end

if ~exist('axes_handle', 'var') || ...
   ~ishandle(axes_handle)
    axes_handle = gca;
end

line_object_handles = findobj('Type', 'line', 'Parent', axes_handle);

if isempty(line_object_handles)
    switch axis_id
        case 'x'
            axes_data_limits = get(axes_handle, 'XLim');

        case 'y'
            axes_data_limits = get(axes_handle, 'YLim');
            
        case 'z'
            axes_data_limits = get(axes_handle, 'ZLim');

        otherwise
            errordlg(['Unknown axis ID: ', axis_id], mfilename);
            return
    end
    
%     errordlg('Can''t find any lines in specified axes.', mfilename);
    return
end

switch axis_id
    case 'x'
        xdata = get(line_object_handles(1), 'XData');
        axes_data_limits = [min(xdata), max(xdata)];

        for line_index = 2:length(line_object_handles)
            xdata = get(line_object_handles(line_index), 'XData');
            line_data_limits = [min(xdata), max(xdata)];
            [AND_limits, axes_data_limits] = find_overlap(line_data_limits, axes_data_limits);
        end

    case 'y'        
            ydata = get(line_object_handles(1), 'YData');
            axes_data_limits = [min(ydata), max(ydata)];

        for line_index = 2:length(line_object_handles)
            ydata = get(line_object_handles(line_index), 'YData');
            line_data_limits = [min(ydata), max(ydata)];
            [AND_limits, axes_data_limits] = find_overlap(line_data_limits, axes_data_limits);
        end

    case 'z'            
            zdata = get(line_object_handles(1), 'ZData');
            axes_data_limits = [min(zdata), max(zdata)];

        for line_index = 2:length(line_object_handles)
            zdata = get(line_object_handles(line_index), 'ZData');
            line_data_limits = [min(zdata), max(zdata)];
            [AND_limits, axes_data_limits] = find_overlap(line_data_limits, axes_data_limits);
        end

    otherwise
        errordlg(['Unknown axis ID: ', axis_id], mfilename);
        return
end