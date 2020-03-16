%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
function QC_Serie = aqc_changerate(sconf,ParamList,PARAMETERS,val,levl)
%
% Calculation of changerate QC
% test passed if |Vn - Vn-1| + |Vn - Vn+1| <= 2*threshold
%
sData0=PARAMETERS(val).Data(levl,:);
sTime0=PARAMETERS(val).Time;

ind=find(~isnan(sData0));
sTime=sTime0(~isnan(sData0));
sData=sData0(~isnan(sData0));
QC_Serie=zeros([1 length(sTime0)])*NaN;

for i=2:length(sTime)-1
   if( (abs(sData(i)-sData(i-1)) + abs(sData(i)-sData(i+1))) <= 2 * sconf.parm(1)) 
   QC_Serie(ind(i)) = sconf.val(1);       
   else
   QC_Serie(ind(i)) = sconf.val(2);     
   end
end

