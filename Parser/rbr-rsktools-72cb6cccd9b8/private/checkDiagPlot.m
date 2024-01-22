function [raw, diagndx] = checkDiagPlot(RSK, diagnostic, direction, castidx)

if length(RSK.data) == 1 && ~isfield(RSK.data,'direction')
    RSKerror('Visualization mode only supports profiles, use RSKreadprofiles...')
end

raw = RSK; 
diagndx = getdataindex(RSK, diagnostic, direction);

if any(strcmp({RSK.data.direction} ,'down')) && any(strcmp({RSK.data.direction} ,'up')) && (strcmp('both',direction) || isempty(direction))
    diagndx = getdataindex(RSK, diagnostic, 'down');
end

if any(~ismember(diagndx, castidx))
    RSKerror('Requested profile for diagnostic plot is not processed.')
end

end