function RSK = correcttau60(RSK, varargin)

% correcttau60 - Apply SCI-22 algorithm to correct conductivity for
%                the "tau60" thermal dynamic error.
%
% Syntax:  RSK = correcttau60(RSK,'CTcoef',CTcoef,[OPTIONS])
%    
% Inputs:
%   [Required] - RSK - Structure containing logger data.
%
%                CTcoef - CTcoef
%
%   [Optional] - profile - Profile number. Default is all available 
%                       profiles.
%
%                direction - 'up' for upcast, 'down' for downcast, or
%                      'both' for all. Default is all directions available.
%
%                visualize - To give a diagnostic plot on specified profile 
%                      number(s). Original and processed data will be 
%                      plotted to show users how the algorithm works. 
%                      Default is 0.
%
% Outputs:
%    RSK - Structure with corrected conductivity 
%
% Example: 
%    rsk = correcttau60(rsk,'CTcoef',2.4e-4)
%
% See also: RSKcorrecttau.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2020-02-10


validDirections = {'down', 'up', 'both'};
checkDirection = @(x) any(validatestring(x,validDirections));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'CTcoef', [], @isnumeric);
addParameter(p, 'profile', [], @isnumeric);
addParameter(p, 'direction', [], checkDirection);
addParameter(p, 'visualize', 0, @isnumeric);
parse(p, RSK, varargin{:});

RSK = p.Results.RSK;
CTcoef = p.Results.CTcoef;
profile = p.Results.profile;
direction = p.Results.direction;
visualize = p.Results.visualize;


checkDataField(RSK)

if isempty(CTcoef)
    RSKwarning('Please specify CTcoef.')
    return
end

[Tcol,CTcol,Ccol] = getchannelindex(RSK,{'Temperature','CT Cell Temperature','Conductivity'});
castidx = getdataindex(RSK, profile, direction);

if visualize ~= 0; 
    [raw, diagndx] = checkDiagPlot(RSK, visualize, direction, castidx); 
end

for ndx = castidx
    T =  RSK.data(ndx).values(:,Tcol);
    CT = RSK.data(ndx).values(:,CTcol);
    C =  RSK.data(ndx).values(:,Ccol);
    Ccor = C./ (1 + CTcoef* (CT - T));
    RSK.data(ndx).values(:,Ccol) = Ccor;
end

if visualize ~= 0      
    for d = diagndx;
        figure
        doDiagPlot(RSK,raw,'ndx',d,'channelidx',Ccol,'fn',mfilename); 
    end
end 

logentry = ['Long term dynamic correction applied to conductivity with CTcoef = ' num2str(CTcoef) '.'];
RSK = RSKappendtolog(RSK, logentry);

end