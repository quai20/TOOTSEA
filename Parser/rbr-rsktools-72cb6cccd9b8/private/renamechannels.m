function RSK = renamechannels(RSK)

%RENAMECHANNELS - Renames channels that require a more descriptive
% name, enumerates duplicate channel long names, and replaces the
% subscript 2 in dissolved oxygen with a normal 2.
%
% Syntax: [RSK] = RENAMECHANNELS(RSK)
%
% Checks for shortNames that correspond to channels that require a
% more descriptive name and replaces the longName. These are doxy,
% temp04, temp05, temp10, temp11, temp13 and pres08. Enumerates
% duplicate longNames.  Replaces the subscript '2' in dissolved oxygen
% with a normal '2'.
%    
% Inputs:
%    RSK - Structure containing metadata.
%
% Outputs:
%    RSK - Structure with modified channel long names. 
%
% See also: RSKopen.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-11-01

shortName = {RSK.channels.shortName};

idx = (strcmpi(shortName, 'temp05') | strcmpi(shortName, 'temp10') | strcmpi(shortName, 'temp29'));
if any(idx)
    [RSK.channels(idx).longName] = deal('Pressure Gauge Temperature');
end

idx = (strcmpi(shortName, 'temp11') | strcmpi(shortName, 'temp22'));
if any(idx)
    [RSK.channels(idx).longName] = deal('CT Cell Temperature');
end

idx = strcmpi(shortName, 'temp13');
if any(idx)
    [RSK.channels(idx).longName] = deal('External Cabled Temperature');
end

idx = (strcmpi(shortName, 'temp16') | strcmpi(shortName, 'temp24'));
if any(idx)
    [RSK.channels(idx).longName] = deal('Optode Temperature');
end

idx = strncmpi(shortName, 'doxy', 4) | strncmpi(shortName, 'ddox', 4);
if any(idx)
    [RSK.channels(idx).longName] = deal('Dissolved O2');
end

idx = strcmpi(shortName, 'pres08');
if any(idx)
    [RSK.channels(idx).longName] = deal('Sea Pressure');
end



% Enumerate duplicate longnames.
longname = {RSK.channels.longName};
[~, ~, channameidx] = unique(longname, 'stable');
idx = find(hist(channameidx, unique(channameidx))>1);

for ndup = 1:length(idx)
    k = 1;
    duplicates = find(channameidx==idx(ndup));
    for ndx = duplicates'
        RSK.channels(ndx).longName = [RSK.channels(ndx).longName '' num2str(k)];
        k = k+1;
    end
end

end