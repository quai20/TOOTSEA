function RSK = RSKopen(fname, varargin)

% RSKopen - Open an RBR RSK file and read metadata and downsample, if exists.
%
% Syntax:  RSK = RSKopen(fname, [OPTIONS])
% 
% Makes a connection to an RSK (SQLite format) database as obtained from an
% RBR logger and reads in the instrument metadata as well as downsample of
% the stored data. RSKopen assumes only a single instrument deployment is
% in the RSK file. The downsample table will not exist when the data
% contains less than 40960 samples per channel. It is a downsample of the
% full range of data, for a quick review of the original data.
%
% Requires a working mksqlite library. We have included a couple of
% versions here for Windows (32/64 bit), Linux (64 bit) and Mac (64 bit),
% but you might need to compile another version.  The mksqlite-src
% directory contains everything you need and some instructions from the
% original author. You can also find the source through Google.
%
% Inputs:
%    [Required] - fname - Filename of the RSK database.
%
%    [Optional] - readHiddenChannels - Read hidden channel when set as
%                                      true, default is false.
%
% Outputs:
%    RSK - Structure containing the logger metadata.
%
% Example: 
%    rsk = RSKopen('sample.rsk');  
%
% See also: RSKreaddata, RSKreadprofiles.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-07-30


rsksettings = RSKsettings;

p = inputParser;
addRequired(p,'fname',@ischar);
addParameter(p,'readHiddenChannels', false, @islogical)
parse(p, fname, varargin{:})

fname = p.Results.fname;
readHiddenChannels = p.Results.readHiddenChannels;


if isempty(dir(fname))
    RSKwarning('File cannot be found')
    RSK = [];
    return
end

RSK.toolSettings.filename = fname;
RSK.toolSettings.readHiddenChannels = readHiddenChannels;

RSK = readstandardtables(RSK);
RSK = readheader(RSK);
RSK = getprofiles(RSK);
RSK = readannotations(RSK);

logentry = [fname ' opened using RSKtools v' rsksettings.RSKtoolsVersion '.'];
RSK = RSKappendtolog(RSK, logentry);

end