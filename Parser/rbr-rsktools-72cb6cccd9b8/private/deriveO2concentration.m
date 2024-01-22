function RSK = deriveO2concentration(RSK, varargin)

% deriveO2concentration - Derive O2 concentration from measured O2 
% saturation using equation from R.F.Weiss 1970.
%
% Syntax: [RSK] = deriveO2concentration(RSK,[OPTIONS])
%
% Inputs: 
%    [Required] - RSK - Structure containing measured O2 saturation in unit
%                       of %.
%    
%    [Optional] - unit - Unit of derived O2 concentration. Valid inputs 
%                       include µmol/l, ml/l and mg/l. Default is µmol/l.
%
% Outputs:
%    RSK - Structure containing derived O2 concentration in specified unit.
%
% Example:
%    rsk = deriveO2concentration(rsk, 'unit', 'ml/l')
%
% See also: RSKderiveO2, deriveO2saturation.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-08-31


validUnits = {'µmol/l', 'ml/l','mg/l'};
checkUnit = @(x) any(validatestring(x,validUnits));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'unit', 'µmol/l', checkUnit);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
unit = p.Results.unit;


if ~any(strcmp({RSK.channels.longName}, 'Salinity'))
    RSKerror('RSKderiveO2concentration needs salinity channel. Use RSKderivesalinity...')
end

% Find temperature and salinity data column
TCol = getchannelindex(RSK,'Temperature');
SCol = getchannelindex(RSK,'Salinity');
O2SCol = find(strncmpi({RSK.channels.longName},'Dissolved O2',12) & strcmpi({RSK.channels.units},'%'));

if ~any(O2SCol)
    RSKerror('RSK file does not contain any O2 saturation channel.')
end

castidx = getdataindex(RSK);
for c = O2SCol    
    suffix = sum(strncmpi('Dissolved O2',{RSK.channels.longName},12)) + 1;
    RSK = addchannelmetadata(RSK, 'ddox00', ['Dissolved O2' num2str(suffix)], unit);
    O2CCol = getchannelindex(RSK, ['Dissolved O2' num2str(suffix)]);
    
    for ndx = castidx
        temp = RSK.data(ndx).values(:,TCol);
        sal = RSK.data(ndx).values(:,SCol);
        oxsat = RSK.data(ndx).values(:,c);   
        oxcon = sat2con_Weiss(oxsat, temp, sal, unit);
        RSK.data(ndx).values(:,O2CCol) = oxcon;
    end     
end

logentry = (['O2 concentration in unit of ' unit ' is derived from measured O2 saturation.']);
RSK = RSKappendtolog(RSK, logentry);

%% Nested function - derive concentration using Weiss equation
function oxcon = sat2con_Weiss(oxsat, temp, sal, unit)

    a1 = -173.42920; a2 = 249.63390; a3 = 143.34830; a4 = -21.84920;
    b1 = -0.0330960; b2 = 0.0142590; b3 = -0.00170;

    temp = (temp * 1.00024 + 273.15) /100.0;
    oxconmll = oxsat.* exp(a1 + a2 ./ temp + a3 * log(temp) + a4 * temp + sal.* (b1 + b2 * temp + b3 * temp .* temp)) /100.0;     
    switch unit
        case 'µmol/l'
            oxcon = 44.659 * oxconmll; % default, convert to µmol/l
        case 'ml/l'
            oxcon = oxconmll; % ml/l
        case 'mg/l'
            oxcon = 1.4276 * oxconmll; % convert to mg/l
    end        
end

end

