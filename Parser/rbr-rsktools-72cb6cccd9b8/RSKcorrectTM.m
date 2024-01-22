function RSK = RSKcorrectTM(RSK, varargin) 
    
% RSKcorrectTM - Apply a thermal mass correction to conductivity using
%                the model of Lueck and Picklo (1990).
%
% Syntax:  [RSK] = RSKcorrectTM(RSK,'alpha',alpha,'beta',beta,[OPTIONS])
%
% RSKcorrectTM applies the algorithm developed by Lueck and Picklo
% (1990) to minimize the effect of conductivity cell thermal mass on
% measured conductivity.  Conductivity cells exchange heat with the
% water as they travel through temperature gradients.  The heat
% transfer changes the water temperature and hence the measured
% conductivity.  This effect will impact the derived salinity and
% density in the form of sharp spikes and even a bias under certain
% conditions.
%
% References:
%    Lueck, R. G., 1990: Thermal inertia of conductivity cells: Theory.  
%           J. Atmos. Oceanic Technol., 7, pp. 741 - 755.
%           https://doi.org/10.1175/1520-0426(1990)007<0741:TIOCCT>2.0.CO;2    
%
%    Lueck, R. G. and J. J. Picklo, 1990: Thermal inertia of conductivity 
%           cells: Observations with a Sea-Bird cell. J. Atmos. Oceanic 
%           Technol., 7, pp. 756 - 768.  
%           https://doi.org/10.1175/1520-0426(1990)007<0756:TIOCCO>2.0.CO;2
%
% Inputs: 
%   [Required] - RSK - Structure containing the logger data.
%
%                alpha - Volume-weighted magnitude of the initial fluid 
%                        thermal anomaly.
%
%                beta - Inverse relaxation time of the adjustment.
%               
%   [Optional] - gamma - Temperature coefficient of conductivity (dC/dT). 
%                        Default is 1, which is suitable for waters with 
%                        "oceanographic" temperature and salinity and when
%                        conductivity is measured in mS/cm.    
%
%                profile - Profile number. Default is all available
%                      profiles.
% 
%                direction - 'up' for upcast, 'down' for downcast, or
%                      'both' for all. Default is all directions available.
% 
%                visualize - To give a diagnostic plot on specified
%                      profile number(s). Original and processed data will
%                      be plotted to illustrate the correction. Default is 0.
%
% Outputs:
%    RSK - Structure with processed values.
%
% Example: 
%    rsk = RSKcorrectTM(rsk,'alpha',0.04,'beta',0.1)
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-07-12


validDirections = {'down', 'up', 'both'};
checkDirection = @(x) any(validatestring(x,validDirections));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'alpha', [], @isnumeric);
addParameter(p, 'beta', [], @isnumeric);
addParameter(p, 'gamma', 1, @isnumeric);
addParameter(p, 'profile', [], @isnumeric);
addParameter(p, 'direction', [], checkDirection);
addParameter(p, 'visualize', 0, @isnumeric);
parse(p, RSK, varargin{:});

RSK = p.Results.RSK;
alpha = p.Results.alpha;
beta = p.Results.beta;
gamma = p.Results.gamma;
profile = p.Results.profile;
direction = p.Results.direction;
visualize = p.Results.visualize;


checkDataField(RSK)

if isempty(alpha)
    RSKwarning('Please specify alpha.')
    return
end

if isempty(beta)
    RSKwarning('Please specify beta.')
    return
end

fs = round(1/readsamplingperiod(RSK));
a = 4*fs/2*alpha/beta * 1/(1 + 4*fs/2/beta);
b = 1 - 2*a/alpha;

[Tcol,Ccol] = getchannelindex(RSK,{'Temperature','Conductivity'});
castidx = getdataindex(RSK, profile, direction);

if visualize ~= 0; 
    [raw, diagndx] = checkDiagPlot(RSK, visualize, direction, castidx); 
end

for ndx = castidx
    T = RSK.data(ndx).values(:,Tcol);
    C = RSK.data(ndx).values(:,Ccol);
    intime = RSK.data(ndx).tstamp;
    Ccor = correctTM(T, intime, a, b, gamma);     
    RSK.data(ndx).values(:,Ccol) = C + Ccor;
end

if visualize ~= 0      
    for d = diagndx;
        figure
        doDiagPlot(RSK,raw,'ndx',d,'channelidx',Ccol,'fn',mfilename); 
    end
end 

logentry = ['Thermal mass correction applied to conductivity with alpha = ' num2str(alpha) ', beta = ' num2str(beta) ' s^-1, and gamma = ' num2str(gamma) '.'];
RSK = RSKappendtolog(RSK, logentry);
    
%% Nested Functions
function Ccor = correctTM(T, intime, a, b, gamma)  
    ind = isfinite(T);   
    T_itp = interp1(intime(ind),T(ind),intime,'linear','extrap');        
    Ccor = zeros(size(T));
    for k = 2:length(T);
        Ccor(k) = -b*Ccor(k-1) + gamma*a*(T_itp(k) - T_itp(k-1));
    end
    Ccor(~ind) = NaN; 
end

end
