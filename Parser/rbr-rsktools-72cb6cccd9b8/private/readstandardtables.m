function RSK = readstandardtables(RSK)

% readstandardtables - Read standard tables that are populated in rsk files.
%
% Syntax:  [RSK] = readstandardtables(RSK)
%
% Opens standard tables that are populated in rsk file. These tables are
% channels, epochs, schedules, deployments and instruments.
%
% Inputs:
%    RSK - Structure opened using RSKopen.m.
%
% Outputs:
%    RSK - Structure containing the standard tables.
%
% See also: RSKopen.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-09-22


p = inputParser;
addRequired(p, 'RSK', @isstruct);
parse(p, RSK)

RSK = p.Results.RSK;


RSK.dbInfo = doSelect(RSK, 'select * from dbInfo');

if ~isfield(RSK.dbInfo,'type')
    RSK.dbInfo.type = 'full';
end

% check if instrumentID is present (old versions of RSK did not include
% instrumentID)


instrumentstblcolumns=doSelect(RSK,'PRAGMA table_info(''instruments'')');
if (isempty(find(strcmp({instrumentstblcolumns.name},'instrumentID')==1, 1)))
    RSK.instruments = doSelect(RSK, 'select * from instruments');
else
    RSK.instruments = doSelect(RSK, 'select * from instruments ORDER by instrumentID limit 1');
end

RSK = readchannels(RSK);

RSK.epochs = doSelect(RSK, 'select deploymentID,startTime/1.0 as startTime, endTime/1.0 as endTime from epochs');
if ~isempty(RSK.epochs)
    RSK.epochs.startTime = rsktime2datenum(RSK.epochs.startTime);
    RSK.epochs.endTime = rsktime2datenum(RSK.epochs.endTime);
else
    RSK.epochs = struct('startTime', datenum(1900,1,1,0,0,0),'endTime', datenum(2100,1,1,0,0,0));  
end

RSK.schedules = doSelect(RSK, 'select * from schedules');
RSK.deployments = doSelect(RSK, 'select * from deployments');
RSK = readpowertable(RSK);

%% Nested function reading power table
function RSK = readpowertable(RSK)
    if ~isempty(doSelect(RSK, 'SELECT name FROM sqlite_master WHERE type="table" AND name="power"')) && ...
       ~isempty(RSK.instruments) && isfield(RSK.instruments, 'firmwareType') && RSK.instruments.firmwareType > 103;
        RSK.power = doSelect(RSK, 'select * from power'); 
        if ~isempty(RSK.power) && RSK.power.internalBatteryType == -1; 
            RSK.power = rmfield(RSK.power, {'internalBatteryType','internalBatteryCapacity','internalEnergyUsed'}); 
        end
        if ~isempty(RSK.power) && RSK.power.externalBatteryType == -1; 
            RSK.power = rmfield(RSK.power, {'externalBatteryType','externalBatteryCapacity','externalEnergyUsed'}); 
        end
    end
end
end
