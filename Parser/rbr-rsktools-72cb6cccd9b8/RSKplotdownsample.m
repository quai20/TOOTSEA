function varargout = RSKplotdownsample(RSK, varargin)

% RSKplotdownsample - Plot summaries of logger data downsample.
%
% Syntax:  [OPTIONS] = RSKplotdownsample(RSK, [OPTIONS])
% 
% Generates a summary plot of the downsample data in the RSK structure.
% 
% Inputs:
%    [Required] - RSK - Structure containing the logger metadata and
%                       downsample.
%
%    [Optional] - channel - Longname of channel to plots, can be multiple
%                           in a cell, if no value is given it will plot
%                           all channels. 
%
% Output:
%    [Optional] - handles - Line object of the plot.
%
%                 axes - Axes object of the plot.
%
% See also: RSKopen, RSKplotdata, RSKplotburstdata.
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


field = 'downsample';
if ~isfield(RSK,field)
    RSKwarning('Downsample field does not exist when dataset has less than 40960 samples per channel.');
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
