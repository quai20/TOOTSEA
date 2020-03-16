%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
function QC_Serie = aqc_impossibledate(sconf,ParamList,PARAMETERS,val,levl)
%
% Calculation of impossible date QC
% test passed if min < time < max
%
sData0=PARAMETERS(val).Data(levl,:);
sTime0=PARAMETERS(val).Time;

QC_Serie=zeros([1 length(sTime0)])*NaN;
ind1=(~isnan(sData0));
QC_Serie(ind1)=sconf.val(1); 

ind2=(ind1 & (sTime0 <= datenum(sconf.parm(1),sconf.parm(2),sconf.parm(3),sconf.parm(4),sconf.parm(5),sconf.parm(6)) | sTime0 >= datenum(sconf.parm(7),sconf.parm(8),sconf.parm(9),sconf.parm(10),sconf.parm(11),sconf.parm(12))));
QC_Serie(ind2)=sconf.val(2); 
