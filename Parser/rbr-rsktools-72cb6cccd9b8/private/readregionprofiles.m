function RSK = readregionprofiles(RSK)

% readregionprofiles - Read profiles start and end times from regions table.
%
% Syntax:  [RSK] = readregionprofiles(RSK)
%
% Reads in profiles start and end time by combining information in the
% region and regionCast tables and adds it to the RSK structure.
%
% Inputs:
%    RSK - Structure containing logger metadata.
%
% Outputs:
%    RSK - Structure containing populated profiles, if available.
%
% See also: getprofiles.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-10-03


tables = doSelect(RSK, 'SELECT name FROM sqlite_master WHERE type="table"');

if any(strcmpi({tables.name}, 'region'))
    RSK.region = doSelect(RSK, 'select * from region');
end

if any(strcmpi({tables.name}, 'regionCast'))
    RSK.regionCast = doSelect(RSK, 'select * from regionCast');
end

if isfield(RSK,'region') && isempty(RSK.region)
    RSK = rmfield(RSK,'region');
    if isfield(RSK,'regionCast')
        RSK = rmfield(RSK,'regionCast');
    end
    return
elseif isfield(RSK,'regionCast') && isempty(RSK.regionCast)
    RSK = rmfield(RSK, 'regionCast');
    return
elseif ~isfield(RSK,'region') 
    return
end

d = 0; u = 0;
for ndx = 1:length(RSK.regionCast)
    regionID = RSK.regionCast(ndx).regionID;
    if strcmpi(RSK.regionCast(ndx).type,'down') && ismember(regionID,[RSK.region.regionID]); 
        d = d + 1; 
        RSK.profiles.('downcast').tstart(d,1) = rsktime2datenum(RSK.region([RSK.region.regionID] == regionID).tstamp1); 
        RSK.profiles.('downcast').tend(d,1) = rsktime2datenum(RSK.region([RSK.region.regionID] == regionID).tstamp2);
    end
    if strcmpi(RSK.regionCast(ndx).type,'up') && ismember(regionID,[RSK.region.regionID]); 
        u = u + 1; 
        RSK.profiles.('upcast').tstart(u,1) = rsktime2datenum(RSK.region([RSK.region.regionID] == regionID).tstamp1); 
        RSK.profiles.('upcast').tend(u,1) = rsktime2datenum(RSK.region([RSK.region.regionID] == regionID).tstamp2);
    end  
end

end
