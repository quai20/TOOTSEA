function [RSK] = RSKderiveA0A(RSK)

% RSKderiveA0A - apply the RBRquartz³ BPR|zero internal barometer
% readings to correct for drift in the marine Digitquartz pressure
% readings using the A-zero-A method.
%
% Syntax:  [RSK] = RSKderiveA0A(RSK)
%
% RSKderiveA0A uses the A-zero-A technique to correct drift in the
% Digiquartz® pressure gauge(s). This is done by periodically
% switching the applied pressure that the gauge measures from seawater
% to the atmospheric conditions inside the housing. The drift in
% quartz sensors is proportional to the full-scale rating, so a
% reference barometer – with hundreds of times less drift than the
% marine gauge – is used to determine the behaviour of the marine
% pressure measurements.
%
% The A-zero-A technique, as implemented in RSKderiveA0A, works as
% follows.  The barometer pressure and the Digiquartz pressure(s) are
% averaged over the last 30 s of each internal pressure calibration
% cycle. Using the final 30 s ensures that the transient portion
% observed after the valve switches is not included in the drift
% calculation.  The averaged Digiquartz® pressures are subtracted from
% the averaged barometer pressure, and these values are linearly
% interpolated onto the original timestamps to form the pressure
% correction.  The drift-corrected pressure is the sum of the measured
% Digiquartz® pressure plus the drift correction.
%
% Inputs: [Required] - RSK - Structure containing the RBRQuartz³
%    BPR|zero calibrated Digiquartz® and barometer pressure values
%
% Outputs: RSK - Structure containing the drift-corrected Digiquartz®
%    pressure(s)
%
% See also: RSKderiveBPR
%
%
% Example:
%    rsk = RSKopen('BPR_AOA_file.rsk');
%    rsk = RSKreaddata(rsk);
%    rsk = RSKderiveBPR(rsk);
%    rsk = RSKderiveA0A(rsk);
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2020-06-26


p = inputParser;
addRequired(p, 'RSK', @isstruct);
parse(p, RSK)

RSK = p.Results.RSK;




%% extract the valve events timestamps.  start and end of Patm phase
tstart = rsktime2datenum([RSK.region.tstamp1]);
tend = rsktime2datenum([RSK.region.tstamp2]);



bpr_ind = find(strcmp({RSK.channels.shortName},'bpr_08'));

if isempty(bpr_ind),
    RSKerror('No derived Digitquartz pressure channel found.  See RSKderivePBR.m')
end


nbpr = length(bpr_ind);

n = 1; % for enumerating long names when instrument has multiple BPRs


% loop over Digiquartz pressure records (some A0As have two)

for j=1:nbpr,

 i0 = getchannelindex(RSK,'Barometer pressure');   
 i1 = bpr_ind(j);
 
 [p0,p1,t30] = deal(NaN(size(tend)));
 
 % get the mean pressure values from the 30 second window 
 for k=1:length(tend),
    
    kk = RSK.data.tstamp>=tend(k) - 31/86400 & ...
         RSK.data.tstamp<=tend(k) - 01/86400;
    
    t30(k)= min(RSK.data.tstamp(kk)) + 15/86400;
    p0(k) = mean(RSK.data.values(kk,i0));
    p1(k) = mean(RSK.data.values(kk,i1));
   
  end
  
  % pressure correction term to be added to measured pressure
  pcorr = interp1(t30,p0 - p1,RSK.data.tstamp);

 
  % NaN the Patm parts of the pressure correction (to match Ruskin)
  for k=1:length(tstart),
      kk = RSK.data.tstamp>=tstart(k) & RSK.data.tstamp<=tend(k);
      pcorr(kk) = NaN;
  end
  
  bpr_corr = RSK.data.values(:,i1) + pcorr;

  % channel long and short names for pressure drift
  drift_long_name = 'Pressure drift';
  drift_short_name= 'drft00';
  drift_units     = 'dbar';

  % channel long and short names for corrected pressure
  pres_long_name = 'BPR corrected pressure';
  pres_short_name= 'dbpr00';
  pres_units     = 'dbar';
  
  % enumerate the BPR long names when multiple sensors are present
  if nbpr>1,
      pres_long_name = strcat(pres_long_name,num2str(n));
      drift_long_name= strcat(drift_long_name,num2str(n));
      n = n + 1;
  end

  % add channel metadata to rsk
  RSK = addchannelmetadata(RSK,pres_short_name,pres_long_name,pres_units);
  RSK = addchannelmetadata(RSK,drift_short_name,drift_long_name,drift_units);

  [pcor_col,drift_col] = getchannelindex(RSK, {pres_long_name,drift_long_name});

  % insert pressure correction and corrected presure into data table
  RSK.data.values(:,pcor_col) = bpr_corr;
  RSK.data.values(:,drift_col) = pcorr;
  
end

logentry = ('BPR pressure(s) corrected for drift using barometer readings.');
RSK = RSKappendtolog(RSK, logentry);
