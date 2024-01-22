function RSK = RSKderiveO2(RSK, varargin)

% RSKderiveO2 - Derives dissolved oxygen concentration or saturation.
%
% Syntax: [RSK] = RSKderiveO2(RSK,[OPTIONS])
%
% The function derives dissolved O2 concentration from measured dissolved 
% O2 saturation using R.F. Weiss (1970), or conversely, derives dissolved 
% O2 saturation from measured dissolved O2 concentration using Garcia and 
% Gordon (1992).  The new oxygen variable is stored in a new column in the 
% data table. 
%
% References:
% R.F. Weiss, The solubility of nitrogen, oxygen and argon in water and 
% seawater, Deep-Sea Res., 17 (1970), pp. 721-735
%
% H.E. García, L.I. Gordon, Oxygen solubility in seawater: Better fitting 
% equations, Limnol. Oceanogr., 37 (6) (1992), pp. 1307-1312
%
% Inputs: 
%    [Required] - RSK - Structure containing measured O2 saturation or
%                       concentration.
%
%    [Optional] - toDerive - O2 variable to derive, should only be
%                       'saturation' or 'concentration', default is 
%                       'concentration'.
%    
%                 unit - Unit of derived O2 concentration. Valid inputs 
%                       include µmol/l, ml/l and mg/l. Default is µmol/l.
%                       Only effective when toDerive is concentration.
%
% Outputs:
%    RSK - Structure containing derived O2 concentration or saturation.
%
% Example:
%    rsk = RSKderiveO2(rsk, 'toDerive', 'concentration', 'unit', 'ml/l')
%
% See also: deriveO2concentration, deriveO2saturation.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-08-31


validToDerive = {'concentration','saturation'};
checkToDerive = @(x) any(validatestring(x,validToDerive));

validUnits = {'µmol/l', 'ml/l','mg/l'};
checkUnit = @(x) any(validatestring(x,validUnits));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'toDerive', 'concentration', checkToDerive);
addParameter(p, 'unit', 'µmol/l', checkUnit);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
toDerive = p.Results.toDerive;
unit = p.Results.unit;


checkDataField(RSK)

if strcmp(toDerive,'concentration')
    RSK = deriveO2concentration(RSK,'unit',unit);
else
    RSK = deriveO2saturation(RSK);
end

end

