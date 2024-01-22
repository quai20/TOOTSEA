function RSK = RSKreadprofiles(RSK, varargin)

% RSKreadprofiles - Read individual casts from RSK SQLite database.
%
% Syntax:  [RSK] = RSKreadprofiles(RSK, [OPTIONS])
% 
% Reads profile, including upcasts, downcasts, or both from the events 
% contained in a .rsk file. Each cast is an element in the data field 
% matrix. The cast direction is indicated as 'up' or 'down' in 
% RSK.data.direction. The function will parse annotations (GPS, comment)
% and profile description/detail field available into the data structure.
%
% Note: RSKreadprofiles reads profiles directly from the RSK file (i.e. 
% from disk). If one wishes to organize existing time series data in RSK
% structure into profiles (i.e. from memory). Use RSKreaddata followed by
% RSKtimeseries2profiles.
%
% Inputs: 
%    [Required] - RSK - Structure containing metadata read from the RSK 
%                       file.
%
%    [Optional] - profile - Vector identifying the profile numbers to
%                       read. Can be used to read only a subset of all
%                       the profiles. Default is to read all the profiles. 
% 
%                 direction - 'up' for upcast, 'down' for downcast, or
%                       `both` for all. Default is 'both'.
%
% Outputs:
%    RSK - RSK structure containing individual casts as each element in the
%          data field.
%
% Examples:
%    rsk = RSKopen('profiles.rsk');
%
%    % read all profiles
%    rsk = RSKreadprofiles(rsk);
%    -OR-
%    % read selective upcasts
%    rsk = RSKreadprofiles(rsk, 'profile', [1 3 10], 'direction', 'up');
%
% See also: RSKfindprofiles, RSKtimeseries2profiles, RSKplotprofiles.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-04-12


validDirections = {'down', 'up', 'both'};
checkDirection = @(x) any(validatestring(x,validDirections));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'profile', [], @isnumeric);
addParameter(p, 'direction', 'both', checkDirection);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
profile = p.Results.profile;
direction = {p.Results.direction};


if ~isfield(RSK, 'profiles') 
    RSKerror('No profiles in this RSK, try RSKreaddata or RSKfindprofiles');
end
if strcmpi(direction{1}, 'both')
    if any(strcmpi({RSK.regionCast.type},'down')) && any(strcmpi({RSK.regionCast.type},'up'))        
        if find(strcmpi({RSK.regionCast.type},'down'),1) < find(strcmpi({RSK.regionCast.type},'up'),1)        
            direction = {'down', 'up'};
        else
            direction = {'up','down'}; 
        end
    elseif any(strcmpi({RSK.regionCast.type},'down'))==1 && any(strcmpi({RSK.regionCast.type},'up'))~=1
        direction = {'down'};    
    elseif any(strcmpi({RSK.regionCast.type},'down'))~=1 && any(strcmpi({RSK.regionCast.type},'up'))==1
        direction = {'up'};
    end
end

hasGPS = isfield(RSK.profiles,'GPS');
hasComment = isfield(RSK.profiles,'comment');
hasDescription = isfield(RSK.region,'description');
ProfileRegionID = strcmpi({RSK.region.type},'PROFILE') == 1;
CastRegionID = strcmpi({RSK.region.type},'CAST') == 1;

alltstart = [];
alltend = [];
for dir = direction
    castdir = [dir{1} 'cast'];
    alltstart = [alltstart; RSK.profiles.(castdir).tstart];
    alltend = [alltend; RSK.profiles.(castdir).tend];
end
alltstart = sort(alltstart);
alltend = sort(alltend);

RSK.profiles.order = direction;
profilecast = size(RSK.profiles.order, 2);

if ~isempty(profile)
    if max(profile) > round(length(alltstart)/profilecast)
        RSKwarning('The profile or cast selected does not exist in this file.');
        return
    end
    if profilecast == 2
        castidx = [(profile*2)-1 profile*2];
        castidx = sort(castidx);       
        % trim the last index if there is unequal number of up and downcast
        castidx = castidx(ismember(sort([3*profile - 1, 3*profile]),find(CastRegionID)));    
    else
        castidx = profile;
    end
else
    castidx = 1:length(alltstart);
end
RSK.profiles.originalindex = castidx;

dir2fill = cell(length(castidx),1); % append data.direction to each cast
pronum2fill = zeros(size(castidx));
if size(RSK.profiles.order, 2) == 1
    dir2fill(:) = direction;
    pronum2fill = castidx;
    if hasGPS
        lat2fill(:) = RSK.profiles.GPS.latitude(castidx);
        lon2fill(:) = RSK.profiles.GPS.longitude(castidx);
    end
    if hasComment
        comment2fill(:) = RSK.profiles.comment(castidx);
    end
    if hasDescription
        description2fill(:) = {RSK.region(ProfileRegionID).description};
    end
else
    dir2fill(1:2:end) = RSK.profiles.order(1);
    dir2fill(2:2:end) = RSK.profiles.order(2);
    
    pronum2fill(1:2:end) = 1:round(length(castidx)/2);   
    for j = 2:2:length(pronum2fill)
        pronum2fill(j) = pronum2fill(j-1);
    end  
        
    if hasGPS
        lat2fill = cell(length(castidx),1);
        lon2fill = cell(length(castidx),1);
        
        lat2fill(1:2:end) = RSK.profiles.GPS.latitude(round(castidx(1:2:end)/2));
        for j = 2:2:length(lat2fill)
            lat2fill(j) = lat2fill(j-1);    
        end
       
        lon2fill(1:2:end) = RSK.profiles.GPS.latitude(round(castidx(1:2:end)/2));
        for j = 2:2:length(lon2fill)
            lon2fill(j) = lon2fill(j-1);    
        end
    end
    if hasComment       
        comment2fill = cell(length(castidx),1);
        
        comment2fill(1:2:end) = RSK.profiles.comment(round(castidx(1:2:end)/2));
        for j = 2:2:length(comment2fill)
            comment2fill(j) = comment2fill(j-1);    
        end        
    end
    if hasDescription
        description2fill(:) = {RSK.region(CastRegionID).description};
    end
end

data(length(castidx)).tstamp = [];
data(length(castidx)).values = [];
data(length(castidx)).direction = [];
data(length(castidx)).profilenumber = [];

if hasGPS
    data(length(castidx)).latitude = [];
    data(length(castidx)).longitude = [];
end
if hasComment, 
    data(length(castidx)).comment = []; 
end
if hasDescription, 
    data(length(castidx)).description = []; 
end

k = 1;
for ndx = castidx
    tmp = RSKreaddata(RSK, 't1', alltstart(ndx), 't2', alltend(ndx));
    data(k).tstamp = tmp.data.tstamp;
    data(k).values = tmp.data.values;
    data(k).direction = dir2fill{k};
    data(k).profilenumber = pronum2fill(k);
    if hasGPS
        data(k).latitude = lat2fill(k);
        data(k).longitude = lon2fill(k);
    end
    if hasComment, 
        data(k).comment = comment2fill(k); 
    end
    if hasDescription, 
        data(k).description = description2fill(k); 
    end
    k = k + 1;
end

if ~isfield(RSK, 'data'), 
    RSK = readchannels(RSK); 
end
data(cellfun(@isempty,{data.tstamp})) = [];
RSK.data = data;

end