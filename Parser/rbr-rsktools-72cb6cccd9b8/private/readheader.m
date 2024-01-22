function RSK = readheader(RSK)

% readheader - Read non-standard tables that are populated in rsk files.
%
% Syntax:  [RSK] = readheader(RSK)
%
% Opens the non-standard populated tables of rsk files, including the
% appSettings, parameters, parameterKeys, geodata, downsample, ranging and
% instrumentSensors, if exists.
%
% Inputs:
%    RSK - Structure of rskopened using RSKopen.m.
%
% Outputs:
%    RSK - Structure containing logger metadata and downsample, if exists.
%
% See also: RSKopen.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-07-30


tables = doSelect(RSK, 'SELECT name FROM sqlite_master WHERE type="table"');

if any(strcmpi({tables.name}, 'schedules'))
    RSK = readsamplingdetails(RSK);
end

if any(strcmpi({tables.name}, 'parameters'))
    RSK = readparameters(RSK);
end

if any(strcmpi({tables.name}, 'geodata'))
    RSK = readgeodata(RSK);
end

if any(strcmpi({tables.name}, 'appSettings'))
    RSK.appSettings = doSelect(RSK, 'select * from appSettings');  
end

if any(strcmpi({tables.name}, 'downsample_caches'))
    RSK = readdownsample(RSK);
end

if any(strcmpi({tables.name}, 'ranging'))
    RSK.ranging = doSelect(RSK, 'select * from ranging');
end

if any(strcmpi({tables.name}, 'instrumentSensors'))
    RSK.instrumentSensors = doSelect(RSK, 'select * from instrumentSensors'); 
end

end

