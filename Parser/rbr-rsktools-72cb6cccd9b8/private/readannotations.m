function RSK = readannotations(RSK)

% readannotations - Read annotations from Ruskin.
%
% Syntax:  [RSK] = readannotations(RSK)
%
% Reads in GPS and comment start and end time by combining information 
% from region, regionGeoData and regionComment tables and adds it to the 
% RSK structure.
%
% Inputs:
%    RSK - Structure containing logger metadata.
%
% Outputs:
%    RSK - Structure containing populated annotations, if available.
%
% See also: getprofiles.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-09-17

tables = doSelect(RSK, 'SELECT name FROM sqlite_master WHERE type="table"');

if any(strcmpi({tables.name}, 'region')) && any(strcmpi({tables.name}, 'regionGeoData')) && any(strcmpi({tables.name}, 'regionComment'))
    RSK.regionGeoData = doSelect(RSK, 'select * from regionGeoData');
    RSK.regionComment = doSelect(RSK, 'select * from regionComment');
else
    return
end

if ~isempty(RSK.regionGeoData) && isfield(RSK,'geodata');
    RSK = rmfield(RSK, 'geodata'); % delete cell gps if annotation gps exists
end

if isempty(RSK.regionGeoData), RSK = rmfield(RSK,'regionGeoData'); end
if isempty(RSK.regionComment), RSK = rmfield(RSK,'regionComment'); end

if isfield(RSK,'region')

    if isfield(RSK.region,'description') && any(cellfun(@isempty,{RSK.region.description}))
        RSK.region = rmfield(RSK.region, 'description');
    end

    ProfileRegionID = find(strcmpi({RSK.region.type},'PROFILE') == 1);
    GPSRegionID = find(strcmpi({RSK.region.type},'GPS') == 1);
    CommentRegionID = find(strcmpi({RSK.region.type},'COMMENT') == 1);
    
    if ~isempty(GPSRegionID)
        GPSAssignID = zeros(length(GPSRegionID),1);
        for g = 1:length(GPSRegionID)
            for p = 1:length(ProfileRegionID)
                if RSK.region(GPSRegionID(g)).tstamp1 >= RSK.region(ProfileRegionID(p)).tstamp1 && ...
                   RSK.region(GPSRegionID(g)).tstamp1 <= RSK.region(ProfileRegionID(p)).tstamp2;
                   GPSAssignID(g) = ProfileRegionID(p);
                end
            end
        end
        k = 1;
        for ndx = 1:length(ProfileRegionID)
            if ismember(ProfileRegionID(ndx), GPSAssignID)
                RSK.profiles.GPS.latitude(ndx,1) = RSK.regionGeoData(k).latitude;
                RSK.profiles.GPS.longitude(ndx,1) = RSK.regionGeoData(k).longitude;
                k = k + 1;
            else
                RSK.profiles.GPS.latitude(ndx,1) = nan;
                RSK.profiles.GPS.longitude(ndx,1) = nan;
            end
        end
    end
    
    if ~isempty(CommentRegionID)
        CommentAssignID = zeros(length(CommentRegionID),1);
        for g = 1:length(CommentRegionID)
            for p = 1:length(ProfileRegionID)
                if RSK.region(CommentRegionID(g)).tstamp1 >= RSK.region(ProfileRegionID(p)).tstamp1 && ...
                   RSK.region(CommentRegionID(g)).tstamp1 <= RSK.region(ProfileRegionID(p)).tstamp2;
                   CommentAssignID(g) = ProfileRegionID(p);
                end
            end
        end
        k = 1;
        for ndx = 1:length(ProfileRegionID)
            if ismember(ProfileRegionID(ndx), CommentAssignID) && isfield(RSK.region,'description');       
                RSK.profiles.comment{ndx,1} = RSK.region(CommentRegionID(k)).description;
                k = k + 1;
            else
                RSK.profiles.comment{ndx,1} = nan;
            end
        end
    end
end
