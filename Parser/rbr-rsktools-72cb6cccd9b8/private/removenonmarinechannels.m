function [RSK, isDerived] = removenonmarinechannels(RSK)

% removenonmarinechannels - Remove hidden or derived channels.
%
% Syntax:  [RSK, isDerived] = removenonmarinechannels(RSK)
%
% Removes the hidden or derived channels from the channels table and
% returns a logical index vector. They are also removed from
% instrumentChannels if the field exists. 
%
% Inputs:
%    RSK - Structure
%
% Outputs:
%    RSK - Structure with only marine channels.
%
%    isDerived - Logical index describing which channels are non-marine.
%
% See also: RSKopen, readheaderfull.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-11-07


p = inputParser;
addRequired(p, 'RSK', @isstruct);
parse(p, RSK)

RSK = p.Results.RSK;


isCoda = isfield(RSK,'instruments') && isfield(RSK.instruments,'model') && ~isempty(RSK.instruments) && strcmpi(RSK.instruments.model,'RBRcoda');
isBPR = isfield(RSK,'instruments') && isfield(RSK.instruments,'model') && strncmpi(RSK.instruments.model,'RBRquartz',9);

if ~strcmpi(RSK.dbInfo(end).type, 'EPdesktop') && ~isCoda && isfield(RSK,'instrumentChannels')     
    instrumentChannels = RSK.instrumentChannels;
    if isfield(instrumentChannels,'channelStatus')              
        isDerived = logical(bitget([instrumentChannels.channelStatus],3));       
        isHidden = logical(bitget([instrumentChannels.channelStatus],1));          
        if RSK.toolSettings.readHiddenChannels || isBPR
            isRemoved = isDerived;
        else
            isRemoved = isDerived | isHidden;
        end  
        RSK.channels(isRemoved) = [];
    end
end

end


