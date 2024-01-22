function RSKprintchannels(RSK)

% RSKprintchannels - Display instrument information, channel names,
% and units in the RSK structure
%
% Syntax:  RSKprintchannels(RSK)
%
% Inputs: 
%    RSK - Input RSK structure
%
% Outputs:
%    Printed channel names and units in MATLAB command window
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2020-05-21


if isfield(RSK,'instruments') && isfield(RSK.instruments,'serialID') && ...
   isfield(RSK.instruments,'model')

    fprintf('Model: %s\n',RSK.instruments.model);
    fprintf('Serial ID: %d\n',RSK.instruments.serialID);
    try
        [fastPeriod,slowPeriod] = readsamplingperiod(RSK);
        fprintf('Sampling period: fast %0.4f second, slow %0.4f second\n',fastPeriod,slowPeriod);
    catch
        fprintf('Sampling period: %0.3f second\n',readsamplingperiod(RSK));
    end
    
end

channelTable = struct2table(RSK.channels);

% drop channelID and shortname
channelTable = channelTable(:,2:end-1);

% add index for RSK.data.values
channelTable.index = (1:1:height(channelTable))';

% change names
channelTable.Properties.VariableNames = {'channel','unit','index'};

% re-order
channelTable = channelTable(:,[3 1 2]);

% print to screen
disp(channelTable)


end
