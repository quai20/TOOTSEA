function rsksettings = RSKdefaultsettings
 
% RSKdefaultsettings - Set RSKtools parameters to default values.
%
% Syntax: rsksettings = RSKdefaultsettings
%
% See also: RSKsettings
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2021-09-22

rsksettings.RSKtoolsVersion = '3.5.3';
rsksettings.seawaterLibrary = 'TEOS-10'; 
rsksettings.latitude = 45;
rsksettings.atmosphericPressure = 10.1325;
rsksettings.hydrostaticPressure = 0;
rsksettings.salinity = 35;
rsksettings.temperature = 15;
rsksettings.pressureThreshold = 3;
rsksettings.conductivityThreshold = 0.05;
rsksettings.loopThreshold = 0.25;
rsksettings.soundSpeedAlgorithm = 'UNESCO';
 
RSKwarning('Setting default values for all RSKtools parameters')
RSKsettings(rsksettings);

end
