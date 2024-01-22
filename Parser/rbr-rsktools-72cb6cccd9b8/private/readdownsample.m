function RSK = readdownsample(RSK)

% readdownsample - Read downsample data from an opened RSK file. 
%
% Syntax:  [RSK] = readdownsample(RSK)
% 
% Reads downsample data from an opened RSK SQLite file, called from
% within RSKopen.
%
% Inputs:
%    RSK - Structure containing the logger metadata and downsamples
%          returned by RSKopen.
%
% Output:
%    RSK - Structure containing previously present logger metadata as well
%          as downsamples data.
%
% See also: RSKopen, RSKplotdownsample.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-01-17

p = inputParser;
addRequired(p, 'RSK', @isstruct);
parse(p, RSK);

RSK = p.Results.RSK;

temp = doSelect(RSK, 'select ratio from downsample_caches');
if max([temp.ratio]) == 1
    return
else
    sql = ['select tstamp/1.0 as tstamp, * from downsample' num2str(max([temp.ratio])) ' order by tstamp'];
    results = doSelect(RSK, sql);
    if isempty(results)
        return
    end
    
    results = removeunuseddatacolumns(results);
    results = arrangedata(results);

    results.tstamp = rsktime2datenum(results.tstamp');
    results.ratio = max([temp.ratio]);
    
    isCoda = isfield(RSK,'instruments') && isfield(RSK.instruments,'model') && strcmpi(RSK.instruments.model,'RBRcoda');
    isBPR = isfield(RSK,'instruments') && isfield(RSK.instruments,'model') && strncmpi(RSK.instruments.model,'RBRquartz',9);
    if ~strcmpi(RSK.dbInfo(end).type, 'EPdesktop') && ~isCoda && ~isBPR && isfield(RSK,'instrumentChannels')      
        instrumentChannels = RSK.instrumentChannels;
        if isfield(instrumentChannels,'channelStatus')
            ind = logical(bitget([instrumentChannels.channelStatus],3));
            instrumentChannels(ind) = [];
            isHidden = logical(bitget([instrumentChannels.channelStatus],1));          
            if ~RSK.toolSettings.readHiddenChannels
                results.values = results.values(:,~isHidden);
            end
        end
    end
        
    RSK.downsample = results;
end


end
