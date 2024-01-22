function SA = deriveSA(S,SP,lat,lon)
    if isempty(lat) || isempty(lon)
        SA = gsw_SR_from_SP(S); % Assume SA ~= SR
    else
        SA = gsw_SA_from_SP(S,SP,lon,lat);
    end
end

