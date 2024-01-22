function [RSK] = RSKaddstationdata(RSK, varargin)

% RSKaddstationdata - Add station data information for specified profile(s).
%
% Syntax:  [RSK] = RSKaddstationdata(RSK, [OPTIONS])
% 
% Append station data to data structure with profiles, including latitude, 
% longitude, station, cruise, vessel, depth, date, weather, crew, comment 
% and description. The function is vectorized, which allows multiple 
% station data inputs for multiple profiles. But when there is only one 
% station data input for multiple profiles, all profiles will be assigned 
% with the same value.
%
% Inputs: 
%   [Required] - RSK - Structure containing data. 
% 
%   [Optional] - One or more of the following:
%
%                profile - Profile number(s) to which station data should
%                          be assigned. Defaults to all profiles             
%                latitude - must be of data type numerical
%                longitude - must be of data type numerical
%                station - Nx1 character array or cell array of strings with
%                          length equal to the number of profiles 
%                cruise - character array or cell array of strings
%                vessel - character array or cell array of strings
%                depth - must be of data type numerical
%                date - character array or cell array of strings
%                weather - character array or cell array of strings
%                crew - character array or cell array of strings
%                comment - character array or cell array of strings
%                description - character array or cell array of strings
%        
%
% Outputs:
%    RSK - Updated structure containing station data for specified profile(s).
%
% Example:
%    rsk = RSKaddstationdata(rsk,'latitude',45,'longitude',-25,...
%                             'station',{'SK1'},'vessel',{'R/V RBR'},...
%                             'cruise',{'Skootamatta Lake 1'})
%    -OR-
%    rsk = RSKaddstationdata(rsk,'profile',4:6,'latitude',[45,44,46],...
%          'longitude',[-25,-24,-23],'comment',{'Comment1','Comment2','Comment3'});
% 
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-07-10


p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'profile', [], @isnumeric);
addParameter(p, 'latitude', [], @isnumeric);
addParameter(p, 'longitude', [], @isnumeric);
addParameter(p, 'station', '');
addParameter(p, 'cruise', '');
addParameter(p, 'vessel', '');
addParameter(p, 'depth', [], @isnumeric);
addParameter(p, 'date', '');
addParameter(p, 'weather', '');
addParameter(p, 'crew', '');
addParameter(p, 'comment', '');
addParameter(p, 'description', '');
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
profile = p.Results.profile;
latitude = p.Results.latitude;
longitude = p.Results.longitude;
station = p.Results.station;
cruise = p.Results.cruise;
vessel = p.Results.vessel;
depth = p.Results.depth;
date = p.Results.date;
weather = p.Results.weather;
crew = p.Results.crew;
comment = p.Results.comment;
description = p.Results.description;

station = checkcell(station);
cruise = checkcell(cruise);
vessel = checkcell(vessel);
date = checkcell(date);
weather = checkcell(weather);
crew = checkcell(crew);
comment = checkcell(comment);
description = checkcell(description);


if isempty([latitude longitude station comment description])
    RSKerror('No station data input is found. Please specify at least one station data field.')
end
  
checkDataField(RSK)

isProfile = length(RSK.data) ~= 1 && isfield(RSK.data,'profilenumber') && isfield(RSK.data,'direction');

if ~isProfile && ~isempty(profile)
    RSKerror('Can not specify profiles when rsk has time series only, use RSKreadprofiles or RSKtimeseries2profiles...');
end

castidx = getdataindex(RSK, profile);
directions = 1;
if isProfile && isfield(RSK.profiles,'order') && length(RSK.profiles.order) ~= 1 
    directions = 2;
end

k = 1;
for i = 1:directions:length(castidx);    
    RSK = assign_stationdata(RSK, latitude, castidx, i, directions, k, 'latitude');
    RSK = assign_stationdata(RSK, longitude, castidx, i, directions, k, 'longitude');
    RSK = assign_stationdata(RSK, station, castidx, i, directions, k, 'station');
    RSK = assign_stationdata(RSK, cruise,  castidx, i, directions, k,'cruise');
    RSK = assign_stationdata(RSK, vessel,  castidx, i, directions, k,'vessel');
    RSK = assign_stationdata(RSK, depth,   castidx, i, directions, k,'depth');
    RSK = assign_stationdata(RSK, date,    castidx, i, directions, k,'date');
    RSK = assign_stationdata(RSK, weather, castidx, i, directions, k,'weather');
    RSK = assign_stationdata(RSK, crew,    castidx, i, directions, k,'crew');
    RSK = assign_stationdata(RSK, comment, castidx, i, directions, k, 'comment');
    RSK = assign_stationdata(RSK, description, castidx, i, directions, k, 'description');
    k = k + 1;    
end

if isProfile;
    % Update region, regionGeoData and regionComment field
    RSK.region(strcmp({RSK.region.type},'GPS')) = [];
    RSK.region(strcmp({RSK.region.type},'COMMENT')) = [];

    if isfield(RSK, 'regionGeoData')
        RSK = rmfield(RSK, 'regionGeoData');
    end
    if isfield(RSK, 'regionComment')
        RSK = rmfield(RSK, 'regionComment');
    end

    initialregionL = length(RSK.region);
    if isfield(RSK.data,'latitude') || isfield(RSK.data,'longitude')
        k = 0;
        for i = 1:length(RSK.data)     
            if (~isempty(RSK.data(i).latitude) && ~isnan(RSK.data(i).latitude)) || (~isempty(RSK.data(i).longitude) && ~isnan(RSK.data(i).longitude))          
                str = [RSK.data(i).direction 'cast ' num2str(RSK.data(i).profilenumber)];
                midtstamp = round(datenum2rsktime((RSK.data(i).tstamp(1) + RSK.data(i).tstamp(end))/2));
                k = k + 1;
                RSK.region(initialregionL + k).datasetID = 1;
                RSK.region(initialregionL + k).regionID = initialregionL + k;
                RSK.region(initialregionL + k).type = 'GPS';
                RSK.region(initialregionL + k).tstamp1 = midtstamp;
                RSK.region(initialregionL + k).tstamp2 = midtstamp;
                RSK.region(initialregionL + k).label = 'GPS';
                RSK.region(initialregionL + k).description = str;  

                RSK.regionGeoData(k).regionID = initialregionL + k;
                RSK.regionGeoData(k).latitude = RSK.data(i).latitude;
                RSK.regionGeoData(k).longitude = RSK.data(i).longitude;
            end       
        end   
    end

    initialregionL2 = length(RSK.region);
    if isfield(RSK.data,'comment')
        k = 0;
        for i = 1:length(RSK.data)     
            if ~isempty(RSK.data(i).comment) && any(~isnan(RSK.data(i).comment{:}))    
                midtstamp = round(datenum2rsktime((RSK.data(i).tstamp(1) + RSK.data(i).tstamp(end))/2));
                k = k + 1;
                RSK.region(initialregionL2 + k).datasetID = 1;
                RSK.region(initialregionL2 + k).regionID = initialregionL2 + k;
                RSK.region(initialregionL2 + k).type = 'COMMENT';
                RSK.region(initialregionL2 + k).tstamp1 = midtstamp;
                RSK.region(initialregionL2 + k).tstamp2 = midtstamp;
                RSK.region(initialregionL2 + k).label = 'Comment-Title';
                RSK.region(initialregionL2 + k).description = char(RSK.data(i).comment);

                RSK.regionComment(k).regionID = initialregionL2 + k;
                RSK.regionComment(k).content = 'NULL';
            end       
        end   
    end
end

    %% Nested Functions
    function out = checkcell(in) 
        if isempty(in) || (~isempty(in) && iscell(in))
            out = in;
        else
            out = {in};    
        end
    end

    %% Nested Functions
    function RSK = assign_stationdata(RSK, meta, castidx, i, directions, k, name)
    % Assign station data to data structure
    if ~isempty(meta) && length(meta) == 1; 
        RSK.data(castidx(i)).(name) = meta;
        if directions == 2
            RSK.data(castidx(i+1)).(name) = meta;
        end        
    elseif ~isempty(meta) && length(meta) ~= 1 && length(meta) == length(castidx)/directions;
        RSK.data(castidx(i)).(name) = meta(k);
        if directions == 2
            RSK.data(castidx(i+1)).(name) = meta(k);
        end
    elseif isempty(meta)
        % do nothing
    else
        RSKerror('Input vectors must be either single value or the same length with profile.');
    end
    
    end
end