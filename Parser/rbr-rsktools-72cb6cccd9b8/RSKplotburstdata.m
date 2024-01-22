function varargout = RSKplotburstdata(RSK, varargin)

% RSKplotburstdata - Plot summaries of logger burst data.
%
% Syntax:  [OPTIONS] = RSKplotburstdata(RSK, [OPTIONS])
% 
% Generates a plot for the burstdata.
% 
% Inputs:
%    [Required] - RSK - Structure containing the logger metadata and
%                       burstData.
%
%    [Optional] - channel - Longname of channel to plots, can be multiple
%                       in a cell, if no value is given it will plot all
%                       channels. 
%
% Output:
%    [Optional] - handles - Line object of the plot.
%
%                 axes - Axes object of the plot.
%
% Example: 
%    rsk = RSKreadburstdata(rsk, 'channel', {'Conductivity', 'Temperature', 'Pressure'});  
%    RSKplotburstdata(rsk);  
%
% See also: RSKreadburstdata, RSKplotdata, RSKplotdownsample.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-09-13


p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'channel', 'all');
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
channel = p.Results.channel;


field = 'burstData';
if ~isfield(RSK, field)
    RSKwarning('You must read a section of burst data in first!');
    RSKwarning('Use RSKreadburstdata...')
    return
end

chanCol = [];
if ~strcmp(channel, 'all')
    channels = cellchannelnames(RSK, channel);
    for chan = channels
        chanCol = [chanCol getchannelindex(RSK, chan{1})];
    end
end


[handles,axes] = channelsubplots(RSK, field, 'chanCol', chanCol);

if nargout == 0
    varargout = {};
else
    varargout{1} = handles;
    varargout{2} = axes;
end

end