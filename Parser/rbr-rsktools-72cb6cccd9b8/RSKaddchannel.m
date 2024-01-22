function [RSK] = RSKaddchannel(RSK, varargin)

% RSKaddchannel - Add a new channel with defined channel name and
% unit. If the new channel already exists in the RSK structure, it
% will overwrite the old one.
%
% Syntax:  [RSK] = RSKaddchannel(RSK,'data',data,[OPTIONS])
% 
% Inputs: 
%    [Required] - RSK - Structure containing the logger metadata and data. 
%    
%                 data - Structure containing the data to be added. The 
%                        data for the new channel must be stored in a field
%                        called "values" (i.e., data.values).  If the data 
%                        is arranged as profiles in the RSK structure, then
%                        data must be a 1xN array of structures of where 
%                        N = length(RSK.data).
% 
%    [Optiona] -  channel - name of the added channel, default is 'unknown'
%
%                 unit - unit of the added channel, default is 'unknown'
%
% Outputs:
%    RSK - Updated structure containing the new channel.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-12-18


p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'data', [], @isstruct);
addParameter(p, 'channel', 'unknown', @ischar);
addParameter(p, 'unit', 'unknown', @ischar);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
data = p.Results.data;
channel = p.Results.channel;
unit = p.Results.unit;


if isempty(data)
    RSKwarning('Please specify data to add.')
    return
end

shortName = getchannelshortname(channel);
RSK = addchannelmetadata(RSK, shortName{:}, channel, unit); 
Ncol = getchannelindex(RSK, channel);
castidx = getdataindex(RSK);
    
for ndx = castidx
   if ~isequal(size(data(ndx).values), size(RSK.data(ndx).tstamp));
       RSKerror('The dimensions of the new channel data structure must be consistent with RSK structure.')
   else
       RSK.data(ndx).values(:,Ncol) = data(ndx).values(:);
   end
end

logentry = [channel ' (' unit ') added to data table by RSKaddchannel'];
RSK = RSKappendtolog(RSK, logentry);

end