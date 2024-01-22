function [handles,axes] = channelsubplots(RSK, field, varargin)

% CHANNELSUBPLOTS - Plot each channel specified in a different subplot.
%
% Syntax:  [handles,axes] = CHANNELSUBPLOT(RSK, field, [OPTIONS])
% 
% Generates subplots and plots each channel in the chosen data element.
% If data has many fields and none are specified, the first one is
% selected.  
%
% Inputs:
%   [Required] - RSK - Structure created by a .rsk file
%
%                field - Source of the data to plot. Can be
%                      'burstData', 'data' or 'downsample'.
%
%   [Optional] - chanCol - Column number of the channels to plot.
%                      Default is to plot all channels.
%
%                castidx - Data element that will be used to make
%                      the plot. The default is 1. Note: To compare data
%                      elements use RSKplotprofiles. 
%
% Outputs:
%    handles - Line object of the plot.
%
%    axes - Axes object of the plot.
%
% See also: RSKplotdata, RSKplotdownsample, RSKplotburstdata.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-09-26


validFields = {'burstData','data','downsample'};
checkField = @(x) any(validatestring(x,validFields));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addRequired(p, 'field', checkField);
addParameter(p, 'chanCol', [], @isnumeric);
addParameter(p, 'castidx', 1);
parse(p, RSK, field, varargin{:});

RSK = p.Results.RSK;
field = p.Results.field;
chanCol = p.Results.chanCol;
castidx = p.Results.castidx;


if isempty(chanCol)
    chanCol = 1:size(RSK.(field)(castidx).values,2);
end
numchannels = length(chanCol);

n = 1;
for chan = chanCol
    subplot(numchannels,1,n)
    handles(n) = plot(RSK.(field)(castidx).tstamp, RSK.(field)(castidx).values(:,chan),'-');
    title(RSK.channels(chan).longName);
    ylabel(RSK.channels(chan).units);
    axes(n)=gca;
    
    % reverse YDir for depth channel
    if strcmpi(RSK.channels(chan).longName,'Depth')
        set(axes(n),'YDir','reverse')
    end
    
    datetick('x');    
    n = n+1;
end

linkaxes(axes,'x');
yl = ylim; 
axis tight  
ylim(yl); 
shg

end