%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
function QC_Serie = aqc_stationary(sconf,ParamList,PARAMETERS,val,levl)
%
% Calculation of stationnary test QC
% test passed if N successive values vary
%
sData0=PARAMETERS(val).Data(levl,:);
sTime0=PARAMETERS(val).Time;

ind=find(~isnan(sData0));
sTime=sTime0(~isnan(sData0));
sData=sData0(~isnan(sData0));
QC_Serie=zeros([1 length(sTime0)])*NaN;

for i=1:length(sTime)-sconf.parm(1)
    if(std(sData(i:i+sconf.parm(1)))==0)
       QC_Serie(ind(i):ind(i)+sconf.parm(1))=sconf.val(2);
    else
       QC_Serie(ind(i):ind(i)+sconf.parm(1))=sconf.val(1);
    end
end

