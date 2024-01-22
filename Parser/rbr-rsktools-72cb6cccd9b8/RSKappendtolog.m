function RSK = RSKappendtolog(RSK, logentry)

% RSKappendtolog - Append the entry and current time to the log field.
%
% Syntax:  [RSK] = RSKappendtolog(RSK, logentry)
% 
% Adds the current time and log entry to the log field in the RSK structure.
% If creates a field called log if none are existent. It only ever appends
% entries to 
% the end. 
%
% Inputs: 
%    RSK - Structure containing the logger metadata
%
%    logentry - Comment that will be added to the log. Must be a string. 
%
% Outputs:
%    RSK - Input structure with updated log field.
%
% See also: RSKopen, RSKalignchannel, RSKbinaverage.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-07-04

if isfield(RSK, 'log')
    nlog = size(RSK.log, 1);
else
    nlog = 0;
end

RSK.log(nlog+1,:) = {now, logentry};

end
