function RSK = deriveO2saturation(RSK)

% deriveO2saturation - Derive O2 saturation from measured O2 concentration 
% using equation from Garcia and Gordon, 1992.
%
% Syntax: [RSK] = deriveO2saturation(RSK)
%
% Inputs: 
%    RSK - Structure containing measured O2 concentration in unit of
%          µmol/l, ml/l or mg/l.
%
% Outputs:
%    RSK - Structure containing derived O2 saturation in unit of %.
%
% Example:
%    rsk = deriveO2saturation(rsk)
%
% See also: RSKderiveO2, deriveO2concentration.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-08-31


p = inputParser;
addRequired(p, 'RSK', @isstruct);
parse(p, RSK)

RSK = p.Results.RSK;


if ~any(strcmp({RSK.channels.longName}, 'Salinity'))
    RSKerror('RSKderiveO2saturation needs salinity channel. Use RSKderivesalinity...')
end

% Find temperature and salinity data column
TCol = getchannelindex(RSK,'Temperature');
SCol = getchannelindex(RSK,'Salinity');
O2CCol = find(strncmpi({RSK.channels.longName},'Dissolved O2',12) & ...
         ismember({RSK.channels.units},{'µmol/l', 'ml/l','mg/l'}));

if ~any(O2CCol)
    RSKerror('RSK file does not contain any O2 concentration channel.')
end

castidx = getdataindex(RSK);
for c = O2CCol    
    suffix = sum(strncmpi('Dissolved O2',{RSK.channels.longName},12)) + 1;
    RSK = addchannelmetadata(RSK, 'ddox01', ['Dissolved O2' num2str(suffix)], '%');
    O2SCol = getchannelindex(RSK, ['Dissolved O2' num2str(suffix)]);
    
    for ndx = castidx
        temp = RSK.data(ndx).values(:,TCol);
        sal = RSK.data(ndx).values(:,SCol);
        oxcon = RSK.data(ndx).values(:,c); 
        unit = RSK.channels(c).units;
        oxsat = con2sat_GG(oxcon, temp, sal, unit);
        RSK.data(ndx).values(:,O2SCol) = oxsat;
    end     
end

logentry = ('O2 saturation in unit of % is derived from measured O2 concentration.');
RSK = RSKappendtolog(RSK, logentry);

%% Nested function - derive saturation using Gorcia and Gordon equation
function oxsat = con2sat_GG(oxcon, temp, sal, unit)

    ga0 = 2.00856; ga1 = 3.22400; ga2 = 3.99063; ga3 = 4.80299; ga4 = 9.78188e-1; ga5 = 1.71069;
    gb0 = -6.24097e-3; gb1 = -6.93498e-3; gb2 = -6.90358e-3; gb3 = -4.29155e-3;
    gc0 = -3.11680e-7;

    temp = log((298.15 - temp) ./ (273.15 + temp));
    coef = ga0 + temp .* (ga1 + temp .* (ga2 + temp .* (ga3 + temp .* (ga4 + ga5 * temp)))) ...
           + sal .* (gb0 + temp .* (gb1 + temp .* (gb2 + temp * gb3))) ...
           + sal .* sal * gc0;
    coef = exp(coef);

    switch unit
        case 'µmol/l'
            oxsat = (2.2414) * oxcon ./ coef; 
        case 'ml/l'
            oxsat = (2.2414/44.659) * oxcon ./ coef; 
        case 'mg/l'
            oxsat = (1.4276 * 2.2414/44.659) * oxcon ./ coef;
        otherwise
            RSKerror('O2 concentration channel must be in unit of µmol/l, ml/l or mg/l.')
    end        
end

end

