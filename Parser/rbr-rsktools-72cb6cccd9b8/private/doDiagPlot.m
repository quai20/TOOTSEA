function [] = doDiagPlot(RSK, raw, varargin)

% doDiagPlot - Plot diagnostic plots to show difference before and after
% data process.
%
% Syntax:  [handles] = doDiagPlot(RSK, raw, [OPTIONS])
% 
% Current RSKtools (v2.3.1) have functions below that could alter the data:
% - RSKalignchannel
% - RSKbinaverage
% - RSKcorrecthold
% - RSKdespike
% - RSKremoveloops
% - RSKsmooth
% - RSKtrim
% The function generates a plot to show original data, processed data and 
% flagged data (if exists) against Sea Pressure or Time.
%
% Inputs:
%    [Required] - RSK - RSK structure containing processed data.
%
%                 raw - RSK structure containing raw data.
%
%    [Optional] - index - flagged data index (i.e. RSK.data.values(index,:))
%
%                 ndx - data structure index (i.e. RSK.data(ndx).values)
%
%                 channelidx - channel index (i.e. RSK.data.values(:,channelidx))
%
%                 fn - name of the function for data process
%
% Output:
%     handles - Line object of the plot.
%
% See also: RSKdespike, RSKremoveloops, RSKcorrecthold, RSKtrim.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-06-29

p = inputParser;
addRequired(p,'RSK', @isstruct);
addRequired(p,'raw', @isstruct);
addParameter(p,'index', [], @isnumeric);
addParameter(p,'ndx', 1, @isnumeric);
addParameter(p,'channelidx', 1, @isnumeric);
addParameter(p,'fn', '', @ischar);
parse(p, RSK, raw, varargin{:})

RSK = p.Results.RSK;
raw = p.Results.raw;
index = p.Results.index;
ndx = p.Results.ndx;
channelidx = p.Results.channelidx;
fn = p.Results.fn;

try
    presCol = getchannelindex(RSK,'Sea Pressure');
catch
    RSK = RSKderiveseapressure(RSK);
    raw = RSKderiveseapressure(raw);
    presCol = getchannelindex(RSK,'Sea Pressure');
end

n = 1;
for chan = channelidx
    subplot(1,length(channelidx),n)
    
    if strcmp(fn,'RSKcorrecthold') || strcmp(fn,'RSKalignchannel')
        t = raw.data(ndx).tstamp;
        plot(t,raw.data(ndx).values(:,chan),'-c','linewidth',2);
        hold on
        plot(t,RSK.data(ndx).values(:,chan),'--k'); 
        hold on
        plot(t(index),raw.data(ndx).values(index,chan),...
            'or','MarkerEdgeColor','r','MarkerSize',5);
        datetick('x','mmm-dd HH:MM','keeplimits');
        xlabel('Time');
        ylabel([RSK.channels(chan).longName ' (' RSK.channels(chan).units ')']);  
    else
        plot(raw.data(ndx).values(:,chan),raw.data(ndx).values(:,presCol),'-c','linewidth',2);
        hold on
        plot(RSK.data(ndx).values(:,chan),RSK.data(ndx).values(:,presCol),'--k'); 
        hold on
        plot(raw.data(ndx).values(index,chan),raw.data(ndx).values(index,presCol),...
            'or','MarkerEdgeColor','r','MarkerSize',5);
        ax = findall(gcf,'type','axes');
        set(ax, 'ydir', 'reverse');
        linkaxes(ax,'y');
        xlabel([RSK.channels(chan).longName ' (' RSK.channels(chan).units ')']);
        ylabel([RSK.channels(presCol).longName ' (' RSK.channels(presCol).units ')']);    
    end
    
    if n == 1;
        if isfield(RSK.data,'profilenumber') && isfield(RSK.data,'direction')
            title(['Profile ' num2str(RSK.data(ndx).profilenumber) ' ' RSK.data(ndx).direction 'cast ' fn]);
        else
            title(fn);
        end
    end
    
    if isempty(index)
        legend('Original data','Processed data','Location','Best');
    else
        legend('Original data','Processed data','Flagged data','Location','Best');
    end
    n = n + 1;
end
end