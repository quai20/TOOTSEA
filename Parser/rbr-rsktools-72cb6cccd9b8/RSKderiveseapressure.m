function [RSK] = RSKderiveseapressure(RSK, varargin)

% RSKderiveseapressure - Calculate sea pressure.
%
% Syntax:  [RSK] = RSKderiveseapressure(RSK, [OPTIONS])
% 
% Derives sea pressure and fills all of data's elements and channel
% metadata. If sea pressure already exists, it recalculates it and
% overwrites that data column.  
%
% Inputs: 
%    [Required] - RSK - Structure containing the logger metadata and data
%
%    [Optional] - patm - Atmospheric Pressure. Default is 10.1325 dbar.
%                 It could be a constant number or vector. When the input
%                 is vector, input RSK must not have profile structure and
%                 the input vector should have the same length of the RSK
%                 samples.
%
% Outputs:
%    RSK - Structure containing the sea pressure data.
%
% See also: getseapressure, RSKplotprofiles.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-07-20


p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'patm', [], @isnumeric);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
patm = p.Results.patm;


checkDataField(RSK)

if isempty(patm)
    patm = getatmosphericpressure(RSK);
end

if isvector(patm) && length(patm) > 1
    if length(RSK.data) ~= 1
        RSKerror('Input atmosphere pressure is a vector, use RSKreaddata to flatten data into time series..')
    elseif length(RSK.data) == 1 && length(RSK.data.tstamp) ~= length(patm)
        RSKerror('Length of RSK data samples and input atmosphere pressure do not match, please shape input atmosphere pressure..')
    end
    patm = patm(:);
end

try
    Pcol = getchannelindex(RSK, 'Pressure');
catch
    try
        Pcol = getchannelindex(RSK, 'BPR pressure');
    catch
        RSKwarning('There is no pressure channel available, sea pressure is set to 0.')
        Pcol = 0;
    end
end

RSK = addchannelmetadata(RSK, 'pres08', 'Sea Pressure', 'dbar');
SPcol = getchannelindex(RSK, 'Sea Pressure');

castidx = getdataindex(RSK);
for ndx = castidx
    if Pcol == 0
        seapressure = zeros(size(RSK.data(ndx).values(:,1)));
    else
        seapressure = RSK.data(ndx).values(:, Pcol) - patm;
    end
    RSK.data(ndx).values(:,SPcol) = seapressure;
end

if isvector(patm) && length(patm) > 1
    logentry = 'Sea pressure calculated using an variable atmospheric pressure.';
else
    logentry = ['Sea pressure calculated using an atmospheric pressure of ' num2str(patm) ' dbar.'];
end
RSK = RSKappendtolog(RSK, logentry);

end

