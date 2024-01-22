function  [lat,lon] = getGeo(RSK,ndx,latitude,longitude)
    if ~isempty(latitude) && length(latitude) > 1 
        lat = latitude(ndx);  
    elseif isempty(latitude) && isfield(RSK.data,'latitude')
        lat = RSK.data(ndx).latitude; 
    else
        lat = latitude;    
    end
    
    if ~isempty(longitude) && length(longitude) > 1 
        lon = longitude(ndx);  
    elseif isempty(longitude) && isfield(RSK.data,'longitude')
        lon = RSK.data(ndx).longitude; 
    else
        lon = longitude;    
    end
end