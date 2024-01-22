function lag = RSKcalculateCTlag(RSK, varargin)

% RSKcalculateCTlag - Calculate a conductivity lag.
% 
% Syntax: [lag] = RSKcalculateCTlag(RSK, [OPTIONS])
%
% Calculates the optimal conductivity time shift relative to temperature to
% minimize salinity spiking. Determines the optimal lag by smoothing the
% calculated salinity by running it through a boxcar filter, then comparing
% the standard deviations of the residuals for a range of lags, from -20 to
% +20 samples. A sea pressure range can be determined to align over a certain
% range of values (used to avoid large effects from surface anomalies). 
%
% Note: Requires the TEOS-10 GSW toobox to compute salinity.
%
% Inputs:
%    [Required] - RSK - Structure, with profiles as read using
%                       RSKreadprofiles.
%
%    [Optional] - seapressureRange - Limits of the sea pressure range used
%                       to obtain the lag. Specify as a two-element vector,
%                       [seapressureMin, seapressureMax]. Default is [0,
%                       max(seapressure)].
%
%                 profile - Profile number. Default is all available
%                       profiles.
%
%                 direction - 'up' for upcast, 'down' for downcast, or
%                       'both' for all. Default all directions available.
%
%                 windowLength - Length of the filter window used for the
%                       reference salinity. Default is 21 samples.
%
% Outputs:
%    lag - Optimal lag of conductivity for each profile.  These
%          can serve as inputs into RSKalignchannel.m.
%
% Examples:
%    rsk = RSKopen('file.rsk');
%    rsk = RSKreadprofiles(rsk, 'profile', 1:10, 'direction', 'down'); % read first 10 downcasts
%
%   1. All downcast profiles with default smoothing
%    lag = RSKcalculateCTlag(rsk);
%
%   2. Specified profiles (first 4), reference salinity found with 13 pt boxcar.
%    lag = RSKcalculateCTlag(rsk, 'profile',1:4, 'windowLength',13);
%
% See also: RSKalignchannel.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-02-01


validDirections = {'down', 'up', 'both'};
checkDirection = @(x) any(validatestring(x,validDirections));

p = inputParser;
addRequired(p,'RSK', @isstruct);
addParameter(p, 'seapressureRange', [], @isvector);
addParameter(p,'profile', [], @isnumeric) 
addParameter(p, 'direction', [], checkDirection);
addParameter(p,'windowLength', 21, @isnumeric)
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
seapressureRange = p.Results.seapressureRange;
profile = p.Results.profile;
direction = p.Results.direction;
windowLength = p.Results.windowLength;


hasTEOS = ~isempty(which('gsw_SP_from_C'));
if ~hasTEOS
    RSKerror('Must install TEOS-10 toolbox. Download it from here: http://www.teos-10.org/software.htm');
end

checkDataField(RSK)

Ccol = getchannelindex(RSK, 'conductivity');
Tcol = getchannelindex(RSK, 'temperature');
[RSKsp, SPcol] = getseapressure(RSK);

bestlag = [];
castidx = getdataindex(RSK, profile, direction);
for ndx = castidx
    C = RSK.data(ndx).values(:, Ccol);
    T = RSK.data(ndx).values(:, Tcol);
    SP = RSKsp.data(ndx).values(:, SPcol);
    
    if ~isempty(seapressureRange)
        selectValues = (SP >= seapressureRange(1) & SP <= seapressureRange(2)); 
        C = C(selectValues);
        T = T(selectValues);
        SP = SP(selectValues);
    end
    
    lags = -20:20;
    dSsd = [];
    for l = lags
        Cshift = shiftarray(C, l, 'nan');
        SS = gsw_SP_from_C(Cshift, T, SP);
        Ssmooth = runavg(SS, windowLength, 'nan');
        dS = SS - Ssmooth;
        dSsd = [dSsd std(dS(isfinite(dS)))];
    end
    minlag = min(abs(lags(dSsd == min(dSsd))));
    bestlag = [bestlag minlag];
end
lag = bestlag;

end


