function castdir = getcastdirection(pressure, direction)

% getcastdirection - Check if pressure array that is in the given direction.
%
% Syntax:  [castdir] = getcastdirection(pressure, direction)
%
% Inputs:
%    pressure - Time series of pressure
%
%    direction - 'up' or 'down'.
%
% Outputs:
%    castdir - Logical index.
%
% See also: RSKpreserveupcast, RSKpreservedowncast.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-09-17

if strcmpi(direction, 'up') && isUpcast(pressure)
    castdir = 1;
elseif strcmpi(direction, 'down') && isDowncast(pressure)
    castdir = 1;
else
    castdir = 0;
end 


    function up = isUpcast(pressure)
    % Returns true if pressure decreases. False is pressure increases.
        pressure = (pressure(~isnan(pressure)));
        if pressure(1) > pressure(end)
            up = 1;
        else
            up = 0;
        end

    end


    function down = isDowncast(pressure)
    % Returns true if pressure increases. False is pressure decreases.
        pressure = (pressure(~isnan(pressure)));
        if pressure(1) < pressure(end)
            down = 1;
        else
            down = 0;
        end

    end
end
