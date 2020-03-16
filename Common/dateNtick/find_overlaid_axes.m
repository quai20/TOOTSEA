function other_axes_handles = find_overlaid_axes(axes_handles)
% Finds handles of other axes with the same positions.
%
% other_axes_handles = find_overlaid_axes(axes_handles)
%
% Input:
%   axes_handles            Matlab graphics handle
%
% Output:
%   other_axes_handles      vector of all other axes that are overlaid
%                               with this one.

% Kevin J. Delaney
% October 10, 2008
% December 1, 2008      Allow "this_axes_handle" to be a vector.

other_axes_handles = [];
threshold_fraction = 0.01;

if ~exist('axes_handles', 'var')
    help(mfilename);
    return
end

if isempty(axes_handles) || ...
   any(~ishandle(axes_handles))
    errordlg('Input "axes_handles" is empty or is not a valid handle.', ...
        mfilename);
    return
end

for axes_index = 1:length(axes_handles)
    this_axes_handle = axes_handles(axes_index);
    
    %   Check on OTHER axes that may share the same position--overlaid axes.
    figure_handle = get(this_axes_handle, 'Parent');
    all_axes_handles = findobj('Type', 'axes', 'Parent', figure_handle);

    for k = 1:length(all_axes_handles)
        axes_handle_to_test = all_axes_handles(k);
        position_magnitude = sum(abs(get(this_axes_handle, 'Position')));
        threshold = position_magnitude * threshold_fraction;

        if (axes_handle_to_test ~= this_axes_handle) && ...
           sum(abs(get(axes_handle_to_test, 'Position') - get(this_axes_handle, 'Position'))) < threshold
            other_axes_handles = [other_axes_handles; axes_handle_to_test];
        end
    end
end