function [samplingperiod, samplingperiodSlow] = readsamplingperiod(RSK)

% readsamplingperiod - Returns the sampling period information.
%
% Syntax1:  samplingperiod = readsamplingperiod(RSK)
%
% To return the sampling period of continous mode or fast sampling period
% of DD (directional dependent) mode
%
% Syntax2: [samplingperiod, samplingperiodSlow] = readsamplingperiod(RSK)
%
% To return the fast and slow sampling period of DD mode
% 
% Inputs:
%    RSK - Structure containing the logger metadata.
%
% Output:
%    samplingperiod - In seconds.
%
%    samplingperiodSlow [optional] - In seconds.
%
% See also: readfirmwarever, returnversion.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2020-04-08

mode = RSK.schedules.mode;

if strcmpi(mode, 'ddsampling')
    samplingperiod = RSK.directional.fastPeriod/1000;
    if nargout == 2
        samplingperiodSlow = RSK.directional.slowPeriod/1000;
    end
elseif strcmpi(mode, 'fetching')
    RSKerror('"Fetching" files do not have a sampling period');
else
    try
        samplingperiod = RSK.(mode).samplingPeriod/1000;
    catch
        samplingperiod = RSK.schedules.samplingPeriod/1000;
    end
    if nargout == 2
        RSKerror('Only DD mode supports two sampling rates, please specify one output only.')
    end
end

end