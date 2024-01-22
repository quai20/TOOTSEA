function [RSK] = RSKderiveBPR(RSK)

% RSKderiveBPR - convert bottom pressure recorder frequencies to
% temperature and pressure using calibration coefficients.
%
% Syntax:  [RSK] = RSKderiveBPR(RSK)
% 
% Loggers with bottom pressure recorder (BPR) channels are equipped
% with one or more Paroscientific, Inc. pressure transducers. The
% logger records the temperature and pressure output frequencies from
% the transducer.  When RSKtools reads an RSK file of type 'full' from
% a BPR, only the BPR frequency measurements are read.  'EPdesktop'
% RSK files contain the transducer frequencies for pressure and
% temperature, as well as the derived pressure and temperature.
% RSKderiveBPR derives temperature and pressure from the transducer
% frequency channels for 'full' files.
% 
% RSKderiveBPR implements the calibration equations developed by
% Paroscientific, Inc. to derive pressure and temperature. The
% function RSKreadcalibrations to retrieve the calibration table if
% has not been read previously.
%
% Note: When RSK data type is set to 'EPdesktop', Ruskin will import
% both the original signal and the derived pressure and temperature
% data.  However, the converted data can not achieve the highest
% resolution available.  Using the 'full' data type and deriving
% temperature and pressure with RSKtools will result in data with the
% full resolution.
%
% Inputs: 
%    [Required] - RSK - Structure containing the logger metadata and data
%
% Outputs:
%    RSK - Structure containing the derived BPR pressure and temperature
%
% See also: RSKderiveseapressure, RSKderivedepth.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2020-05-29


p = inputParser;
addRequired(p, 'RSK', @isstruct);
parse(p, RSK)

RSK = p.Results.RSK;


checkDataField(RSK)

if ~strcmp(RSK.dbInfo(end).type, 'full')
    RSKerror('Only files of type "full" need derivation for BPR pressure and temperature');
end


% read calibration table
if ~isfield(RSK,'calibrations') || ~isstruct(RSK.calibrations)
    RSK = RSKreadcalibrations(RSK);
end


%% loop over sensors that require application of calibration coefficients
% each Paros has two channels, P and T.  BPRderive (nested function)
% computes both T and P for each sensor

% find Paros sensors in calibration table using the calibration equation
paros_p = find(strcmp('deri_bprpres',{RSK.calibrations.equation}'));
paros_t = find(strcmp('deri_bprtemp',{RSK.calibrations.equation}'));

% total number of Paros sensors (BPR and barometer)
n_paros = length(paros_p);

% total number of BPRs (updates in loop)
n_bpr = 1;

for k=1:n_paros,
    
    % extract the calibration coefficients
    Pcal_table = RSK.calibrations(paros_p(k));
    Tcal_table = RSK.calibrations(paros_t(k));
    
    % calibration coefficients for both T and P (required by BPRderive)
    coeffs = struct;

    coeffs.u0 = Tcal_table.x0;
    coeffs.y1 = Tcal_table.x1;
    coeffs.y2 = Tcal_table.x2;
    coeffs.y3 = Tcal_table.x3;
    
    coeffs.c1 = Pcal_table.x1;
    coeffs.c2 = Pcal_table.x2;
    coeffs.c3 = Pcal_table.x3;
    coeffs.d1 = Pcal_table.x4;
    coeffs.d2 = Pcal_table.x5;
    coeffs.t1 = Pcal_table.x6;
    coeffs.t2 = Pcal_table.x7;
    coeffs.t3 = Pcal_table.x8;
    coeffs.t4 = Pcal_table.x9;
    coeffs.t5 = Pcal_table.x10;
    
    % find indices into RSK.data.values using channelIDs
    pind1 = Pcal_table.n0 == [RSK.channels.channelID];
    pind2 = Pcal_table.n1 == [RSK.channels.channelID];

    % measured periods for T and P 
    pres_period = RSK.data.values(:,pind1);
    temp_period = RSK.data.values(:,pind2);
    
    % derive T and P with periods and cal coefficients
    [temp, pres] = BPRderive(temp_period, pres_period, coeffs);
    
    % define short names, long names, and units of new derived channels
    switch RSK.channels(pind1).shortName
      case 'peri00'
        pres_short_name = 'bpr_08';
        pres_long_name  = 'BPR pressure';
        pres_units      = 'dbar';
      case 'baro00'
        pres_short_name = 'baro02';
        pres_long_name  = 'Barometer pressure';
        pres_units      = 'dbar';
    end

    switch RSK.channels(pind2).shortName
      case 'peri01'
        temp_short_name = 'bpr_09';
        temp_long_name  = 'BPR temperature';
        temp_units      = '°C';
      case 'baro01'
        temp_short_name = 'baro03';
        temp_long_name  = 'Barometer temperature';
        temp_units      = '°C';
    end

    % enumerate the BPR long names when multiple sensors are present
    if n_paros>1 & strncmp(pres_short_name,'bpr',3),
      pres_long_name = strcat(pres_long_name,num2str(n_bpr));
      temp_long_name = strcat(temp_long_name,num2str(n_bpr));
      n_bpr = n_bpr + 1;
    end
    
    
    % add channel metadata to RSK
    RSK = addchannelmetadata(RSK,pres_short_name,pres_long_name,pres_units);
    RSK = addchannelmetadata(RSK,temp_short_name,temp_long_name,temp_units);
    
    [BPRPrescol,BPRTempcol] = getchannelindex(RSK, {pres_long_name,temp_long_name});
    
    % insert temperature and pressure into data table
    RSK.data.values(:,BPRPrescol) = pres;
    RSK.data.values(:,BPRTempcol) = temp;

end



logentry = ('BPR temperature and pressure derived from period data.');
RSK = RSKappendtolog(RSK, logentry);


    %% Nested Functions
    function [temp, pres] = BPRderive(temp_period, pres_period,coeffs)
    
    % Equations for deriving BPR temperature and pressure, 
    % period unit convert from picoseconds to microseconds (/1e6)
    
    u0 = coeffs.u0;
    y1 = coeffs.y1;
    y2 = coeffs.y2;
    y3 = coeffs.y3;
    c1 = coeffs.c1;
    c2 = coeffs.c2;
    c3 = coeffs.c3;
    d1 = coeffs.d1;
    d2 = coeffs.d2;
    t1 = coeffs.t1;
    t2 = coeffs.t2;
    t3 = coeffs.t3;
    t4 = coeffs.t4;
    t5 = coeffs.t5;
        
    U = (temp_period/(1e6)) - u0;
    temp = y1 .* U + y2 .* U .*U + y3 .* U .* U .* U;

    C = c1 + c2 .* U + c3 .* U .* U;
    D = d1 + d2 .* U;
    T0 = t1 + t2 .* U + t3 .* U .* U + t4 .* U .* U .* U + t5 .* U .* U .* U .* U;
    Tsquare = (pres_period/(1e6)) .* (pres_period/(1e6));
    Pres = C .* (1 - ((T0 .* T0) ./ (Tsquare))) .* (1 - D .* (1 - ((T0 .* T0) ./ (Tsquare))));
    pres = Pres* 0.689476; % convert from PSI to dbar
    
    end


end
