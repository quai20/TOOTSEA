function RSK = RSKreadcalibrations(RSK)

% RSKreadcalibrations - Read the calibrations table of a .rsk file.
%
% Syntax:  RSK = RSKreadcalibrations(RSK)
%
% Adds the calibrations field and coefficients to the RSK structure. In
% version 1.13.4 of the RSK schema, the coefficients table is separate
% from the calibrations table. Here, we combine them into one table or
% simply open the calibrations table and adjust the timestamps.
%
% Inputs:
%    RSK - Structure containing the logger metadata returned by RSKopen.
%
% Output:
%    RSK - Structure containing previously present logger metadata as well
%          as calibrations including coefficients.
%
% See also: RSKopen.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-09-26


tables = doSelect(RSK, 'SELECT name FROM sqlite_master WHERE type="table"');

if ~any(strcmpi({tables.name}, 'calibrations'))
    RSKerror('The rsk file does not have calibration table.')
end

% As of RSK v1.13.4 coefficients is it's own table. We add it back into calibration to be consistent with previous versions.
RSK = coef2cal(RSK);
if ~iscompatibleversion(RSK, 1, 13, 4)
    RSK.calibrations = doSelect(RSK, 'select * from calibrations');
    tstampstruct = doSelect(RSK, 'select `tstamp`/1.0 as tstamp from calibrations');
    for ndx = 1:length(RSK.calibrations)
        RSK.calibrations(ndx).tstamp = rsktime2datenum(tstampstruct(ndx).tstamp);

        for k=0:23
            n = sprintf('c%d', k);
            
            if(~isfield(RSK.calibrations, n))
                RSK.calibrations(ndx).(n) = [];
            end
        end
    end
    
    if isfield(RSK.calibrations, 'instrumentID')
        RSK.calibrations = rmfield(RSK.calibrations, 'instrumentID');
    end
end

end
