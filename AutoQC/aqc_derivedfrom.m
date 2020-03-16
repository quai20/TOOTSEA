%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
function QC_Serie = aqc_derivedfrom(sconf,ParamList,PARAMETERS,val,levl)
%
% QC is derived from QC from other parameter(s)
%
sData0=PARAMETERS(val).Data(levl,:);
sTime0=PARAMETERS(val).Time;

ind=find(~isnan(sData0));
sTime=sTime0(~isnan(sData0));
sData=sData0(~isnan(sData0));
QC_Serie=zeros([1 length(sTime0)])*NaN;
QC_Serie(ind)=0;
%
npa=length(sconf.parm);
npp=length(sTime);

for k=1:npa
    alp=find(strcmp(sconf.parm{k},ParamList));
    %TESTS SUR EXISTANCE ET LONGUEUR
    if(alp)        
       if(size(PARAMETERS(alp).QC_Serie,1)>1)        
            QC_Serie(ind)=max(QC_Serie(ind),PARAMETERS(alp).QC_Serie(levl,ind));	
       else
            QC_Serie(ind)=max(QC_Serie(ind),PARAMETERS(alp).QC_Serie(1,ind));	
       end       
    else
       warndlg('Reference parameter not found ');
    end
end
% %




