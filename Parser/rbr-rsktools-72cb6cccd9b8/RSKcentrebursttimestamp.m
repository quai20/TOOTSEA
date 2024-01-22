function RSK = RSKcentrebursttimestamp(RSK)

% RSKcentrebursttimestamp - Modify wave/BPR file time stamp in data field
% from beginning to middle of the burst.
%
% Syntax:  [RSK] = RSKcentrebursttimestamp(RSK)
% 
% For wave or BPR loggers, Ruskin stores the raw high frequency values in 
% the burstData field. The data field is composed of one sample for each 
% burst with time stamp set to be the first value of each burst period; 
% the sample is the average of the values during the corresponding burst.
% For users' convenience, this function modifies the time stamp from 
% beginning of each burst to be the middle or it.
% 
% Inputs: 
%    RSK - Structure containing the logger metadata and data.
%
% Outputs:
%    RSK - Structure containing the logger metadata, and data with 
%          corrected time stamp.
%
% Example: 
%    rsk = RSKcentrebursttimestamp(rsk);
%
% See also: RSKreaddata, RSKreadburstdata.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-02-25


p = inputParser;
addRequired(p, 'RSK', @isstruct);
parse(p, RSK)

RSK = p.Results.RSK;


checkDataField(RSK)

if ~isfield(RSK,'burstData')
    RSK = RSKreadburstdata(RSK);
    if ~isfield(RSK,'burstData')
        return
    else
        RSK = rmfield(RSK,'burstData');
    end
end

dt = (RSK.schedules.samplingCount/2)*readsamplingperiod(RSK)/86400;
RSK.data.tstamp = RSK.data.tstamp + dt;

end
