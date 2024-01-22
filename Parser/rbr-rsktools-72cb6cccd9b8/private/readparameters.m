function RSK = readparameters(RSK)

%READPARAMETERS - Read the current parameters.
%
% Syntax:  [RSK] = READPARAMETERS(RSK)
%
% Reads the table that contains parameter information and adds it to the
% RSK structure. If there are many sets of parameters, it will select the
% most recent/current values. 
%
% Inputs:
%    RSK - Structure containing some logger metadata.
%
% Output:
%    RSK - Structure containing previously present logger metadata as well
%          as parameters.
%
% See also: readheaderfull.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-06-21

RSK.parameters = doSelect(RSK, 'select * from parameters');

tables = doSelect(RSK, 'SELECT name FROM sqlite_master WHERE type="table"');

if iscompatibleversion(RSK, 1, 13, 4) && any(strcmpi({tables.name}, 'parameterKeys'))
    RSK.parameterKeys = doSelect(RSK, 'select * from parameterKeys'); 
    if length(RSK.parameters) > 1
        [~, currentidx] = max([RSK.parameters.tstamp]);
        currentparamId = RSK.parameters(currentidx).parameterID;
        currentvalues = ([RSK.parameterKeys.parameterID] == currentparamId);
        RSK.parameterKeys = RSK.parameterKeys(currentvalues);
    end
else
    [~, currentidx] = max([RSK.parameters.tstamp]);
    RSK.parameters = RSK.parameters(currentidx);
end

end