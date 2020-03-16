%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
function QC_Serie = aqc_globalrange(sconf,ParamList,PARAMETERS,val,levl)
%
% Calculation of globalrange QC
% test passed if min < value < max
%
sData0=PARAMETERS(val).Data(levl,:);
sTime0=PARAMETERS(val).Time;

QC_Serie=zeros([1 length(sTime0)])*NaN;
ind1=(~isnan(sData0));
QC_Serie(ind1)=sconf.val(1); 

ind2=(ind1 & (sData0<sconf.parm(1) | sData0>sconf.parm(2)));
QC_Serie(ind2)=sconf.val(2); 

