function [RSK] = RSKderivesoundspeed(RSK, varargin)

% RSKderivesoundspeed - Calculate speed of sound.
%
% Syntax:  [RSK] = RSKderivesoundspeed(RSK, [OPTIONS])
%
% This function computes the speed of sound using temprature, salinity and
% pressure data. It provides three methods: UNESCO (Chen and Millero), 
% Del Grosso and Wilson, among which UNESCO is default.
% 
% Special thanks to Andrew J. Moodie for initiating the idea of the
% function.
%    
% Inputs: 
%    [Required] - RSK - Structure containing the logger metadata and data. 
%
%    [Optional] - soundSpeedAlgorithm - UNESCO (default), DelGrosso or Wilson
%
% Outputs:
%    RSK - Updated structure containing a new channel for speed of sound.
%
% References:
%
%    C-T. Chen and F.J. Millero, Speed of sound in seawater at high pressures (1977) 
%    J. Acoust. Soc. Am. 62(5) pp 1129-1135
%    
%    V.A. Del Grosso, New equation for the speed of sound in natural waters 
%    (with comparisons to other equations) (1974) J. Acoust. Soc. Am 56(4) pp 1084-1091
% 
%    W. D. Wilson, ?Equations for the computation of the speed of sound in sea water,? 
%    Naval Ordnance Report 6906, US Naval Ordnance Laboratory, White Oak, Maryland, 1962.
%
% See also: RSKderivesalinity.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-12-09


rsksettings = RSKsettings;

validSoundSpeedAlgorithm = {'UNESCO', 'DelGrosso', 'Wilson'};
checkSoundSpeedAlgorithm = @(x) any(validatestring(x,validSoundSpeedAlgorithm));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'soundSpeedAlgorithm', rsksettings.soundSpeedAlgorithm, checkSoundSpeedAlgorithm);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
soundSpeedAlgorithm = p.Results.soundSpeedAlgorithm;


checkDataField(RSK)

[Tcol,Scol,SPcol] = getchannel_T_S_SP_index(RSK);

RSK = addchannelmetadata(RSK, 'sos_00', 'Speed of Sound', 'm/s');
SScol = getchannelindex(RSK, 'Speed of Sound');

castidx = getdataindex(RSK);
for ndx = castidx
    S = RSK.data(ndx).values(:,Scol);
    T = RSK.data(ndx).values(:,Tcol);   
    SP = RSK.data(ndx).values(:,SPcol);
    
    if strcmpi(soundSpeedAlgorithm,'UNESCO')    
        SS = derive_SS_UNESCO(S,T,SP);   
    elseif strcmpi(soundSpeedAlgorithm,'DelGrosso')
        SS = derive_SS_DG(S,T,SP);
    else
        SS = derive_SS_WS(S,T,SP);
    end
    
    RSK.data(ndx).values(:,SScol) = SS;
end

logentry = (['Speed of sound derived using ' soundSpeedAlgorithm ' method.']);
RSK = RSKappendtolog(RSK, logentry);

%% Nested functions
function [Tcol,Scol,SPcol] = getchannel_T_S_SP_index(RSK)
    Tcol = getchannelindex(RSK, 'Temperature');
    try
        Scol = getchannelindex(RSK, 'Salinity');
    catch
        RSKerror('RSKderivesoundspeed requires practical salinity. Use RSKderivesalinity...');
    end
    try
        SPcol = getchannelindex(RSK, 'Sea Pressure');
    catch
        RSKerror('RSKderivesoundspeed requires sea pressure. Use RSKderiveseapressure...');
    end
end

function SS = derive_SS_UNESCO(S,T,SP) 
    a = [1.389, -1.262E-2, 7.166E-5, 2.008E-6, -3.21E-8;
         9.4742E-5, -1.2583E-5, -6.4928E-8, 1.0515E-8, -2.0142E-10;
         -3.9064E-7, 9.1061E-9, -1.6009E-10, 7.994E-12, 0.0;
         1.100E-10, 6.651E-12, -3.391E-13, 0.0, 0.0];

    b = [-1.922E-2, -4.42E-5;
        7.3637E-5, 1.7950E-7];

    c = [1402.388, 5.03830, -5.81090E-2, 3.3432E-4, -1.47797E-6, 3.1419E-9;
         0.153563, 6.8999E-4, -8.1829E-6, 1.3632E-7, -6.1260E-10, 0.0;
         3.1260E-5, -1.7111E-6, 2.5986E-8, -2.5353E-10, 1.0415E-12, 0.0;
         -9.7729E-9, 3.8513E-10, -2.3654E-12, 0.0, 0.0, 0.0];

    d00 = 1.727E-3; d10 = -7.9836E-6;
    [x0, x1, x2, x3] = deal(0);

    for i = 6:-1:1
        x0 = x0 .* T + c(1,i);
    end

    for i = 5:-1:1
        x1 = x1 .* T + c(2,i);
    end

    for i = 5:-1:1
        x2 = x2 .* T + c(3,i);
    end

    for i = 3:-1:1
        x3 = x3 .* T + c(4,i);
    end

    SP = SP / 10.0; % convert dbar to bar
    cw = x0 + (x1 + (x2 + x3 .* SP) .* SP) .* SP;
    [x0, x1, x2, x3] = deal(0);

    for i = 5:-1:1
        x0 = x0 .* T + a(1,i);
    end

    for i = 5:-1:1
        x1 = x1 .* T + a(2,i);
    end

    for i = 4:-1:1
        x2 = x2 .* T + a(3,i);
    end

    for i = 3:-1:1
        x3 = x3 .* T + a(4,i);
    end

    atp = x0 + (x1 + (x2 + x3 .* SP) .* SP) .* SP;
    btp = b(1,1) + b(1,2) .* T + (b(2,1) + b(2,2) .* T) .* SP;
    dtp = d00 + d10 .* SP;
    SS = cw + atp .* S + btp .* S.^(3/2)  + dtp .* S.^2;
end

function SS = derive_SS_DG(S,T,SP)
    SP = SP * 1.019716 / 10.0; % convert dbar to 1000kg/cm^2
    ct = 5.012285 * T - 5.51184E-2 * T.^2 + 2.21649E-4 * T.^3;
    cs = 1.329530 * S + 1.288598E-4 * S.^2;
    cp = 0.1560592 * SP + 2.449993E-5 * SP.^2 - 8.833959E-9 * SP.^3;

    cstp = 6.353509E-3 * T .* SP - 4.383615E-7 * T.^3 .* SP - 1.593895E-6 * T .* SP.^2 + ...
           2.656174E-8 * T.^2 .* SP.^2 + 5.222483E-10 * T .* SP.^3 - 1.275936E-2 * S .* T + ...
           9.688441E-5 * S .* T.^2 - 3.406824E-4 * S .* T .* SP + ...
           4.857614E-6 * S.^2 .* T .* SP - 1.616745E-9 * S.^2 .* SP.^2;

    SS = 1402.392 + ct + cs + cp + cstp;
end

function SS = derive_SS_WS(S,T,SP)
    T = T * 1.00024; % convert t90 to t68
    SP = SP / 100.0; % convert dbar to MPa

    ct = 4.5721 * T - 4.4532E-2 * T.^2 - 2.6045E-4 * T.^3 + 7.9851E-6 * T.^4;
    cs = (1.39799 - 1.69202E-3 * (S - 35.0)) .* (S - 35.0);
    cp = 1.63432 * SP - 1.06768E-3 * SP.^2 + 3.73403E-6 * SP.^3 - 3.6332E-8 * SP.^4;
    
    cstp = -1.1244E-10 * T + 7.7711E-7 * T.^2 + 7.85344E-4 * SP - 1.3458E-5 * SP.^2 + 3.2203E-7 * SP .* T + 1.6101E-8 * T.^2 .* SP;
    cstp = cstp .* (S - 35.0);
    cstp = cstp + SP .* (-1.8974E-3 * T + 7.6287E-5 * T.^2 + 4.6176E-7 * T.^3) + ...
           SP.^2 .* (-2.6301E-5 * T + 1.9302E-7 * T.^2) - 2.0831E-7 * SP.^3 .* T;

    SS = 1449.14 + ct + cs + cp + cstp;
end

end
