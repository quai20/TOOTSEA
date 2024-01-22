function rsksettings = RSKsettings(rsksettings)
 
% RSKsettings - View and change RSKtools parameters.
%
% Syntax:  rsksettings = RSKsettings([OPTIONS])
%
% The function returns current RSKtools parameters when there is no input 
% argument. It updates RSKtools parameters when a structure of input 
% parameters is specified.
%
% Inputs: 
%    [Optional] -  rsksettings - structure that contains specified RSKtools
%                  parameters, for instance:
%
%                  rsksettings.latitude = 45;
%                  rsksettings.seawaterLibrary = 'TEOS-10';
%
% Outputs:
%    rsksettings - Structure containing current or updated RSKtools 
%                  parameters
%
% Examples:
%    rsksettings = RSKsettings; % get current setting parameters
%    rsksettings.seawaterLibrary = 'seawater'; % set default to CSIRO seawater
%    RSKsettings(rsksettings); % set parameters
%
% See also: RSKdefaultsettings
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2020-09-22


validSeawaterLibrary = {'TEOS-10','seawater'};
checkSeawaterLibrary = @(x) any(validatestring(x,validSeawaterLibrary));

validSoundSpeedAlgorithm = {'UNESCO', 'DelGrosso', 'Wilson'};
checkSoundSpeedAlgorithm = @(x) any(validatestring(x,validSoundSpeedAlgorithm));

if nargin == 0
    rsksettings = getappdata(0,'rsksettings'); % return current settings
    if isempty(rsksettings) 
        rsksettings = RSKdefaultsettings; % set default if empty
    end
else    
    p = inputParser;
    p.StructExpand = true;
    addParameter(p,'RSKtoolsVersion','3.5.3',@ischar);
    addParameter(p,'seawaterLibrary','TEOS-10',checkSeawaterLibrary);
    addParameter(p,'latitude',45,@isnumeric);
    addParameter(p,'atmosphericPressure',10.1325,@isnumeric);
    addParameter(p,'hydrostaticPressure',0,@isnumeric);
    addParameter(p,'salinity',35,@isnumeric);
    addParameter(p,'temperature',15,@isnumeric);           
    addParameter(p,'pressureThreshold',3,@isnumeric);
    addParameter(p,'conductivityThreshold',0.05,@isnumeric);
    addParameter(p,'loopThreshold',0.25,@isnumeric);
    addParameter(p,'soundSpeedAlgorithm',checkSoundSpeedAlgorithm);
       
    parse(p, rsksettings)

    rsksettings.RSKtoolsVersion = p.Results.RSKtoolsVersion;
    rsksettings.seawaterLibrary = p.Results.seawaterLibrary;
    rsksettings.latitude = p.Results.latitude;
    rsksettings.atmosphericPressure = p.Results.atmosphericPressure;
    rsksettings.hydrostaticPressure = p.Results.hydrostaticPressure;
    rsksettings.salinity = p.Results.salinity;
    rsksettings.temperature = p.Results.temperature;
    rsksettings.pressureThreshold = p.Results.pressureThreshold;
    rsksettings.conductivityThreshold = p.Results.conductivityThreshold;
    rsksettings.loopThreshold = p.Results.loopThreshold;
    rsksettings.soundSpeedAlgorithm = p.Results.soundSpeedAlgorithm;
    
    setappdata(0,'rsksettings',rsksettings)  
end


end
