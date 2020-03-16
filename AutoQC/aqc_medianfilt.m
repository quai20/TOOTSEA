%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
function QC_Serie = aqc_medianfilt(sconf,ParamList,PARAMETERS,val,levl)
%
% Calculation of mediafilt QC
% test passed if value < x1*std(median)
% test semipassed if value < x2*std(median)
% test error if value > x2*std(median)
%
sData0=PARAMETERS(val).Data(levl,:);
sTime0=PARAMETERS(val).Time;

ind=find(~isnan(sData0));
sTime=sTime0(~isnan(sData0));
sData=sData0(~isnan(sData0));
QC_Serie=zeros([1 length(sTime0)])*NaN;
%

wind=2*floor(sconf.parm(1)/2);      %to be sure to have even window

%1st halfwindow
ymed = median(sData(1:wind/2));  
ystd = std(sData(1:wind/2));
for i=2:wind/2
  if(sData(i) >= min([ymed-sconf.parm(2)*ystd ymed+sconf.parm(2)*ystd]) && sData(i) <= max([ymed-sconf.parm(2)*ystd ymed+sconf.parm(2)*ystd]))
        QC_Serie(ind(i))=sconf.val(1);
  elseif(sData(i) >= min([ymed-sconf.parm(3)*ystd ymed+sconf.parm(3)*ystd]) && sData(i) <= max([ymed-sconf.parm(3)*ystd ymed+sconf.parm(3)*ystd]))
        QC_Serie(ind(i))=sconf.val(2);
  elseif(abs(sData(i)-sData(i-1))>=sconf.parm(4))
        QC_Serie(ind(i))=sconf.val(3);
  else 
	QC_Serie(ind(i))=sconf.val(2);	
  end    
end
%%%%%%%%%%%%%%%%

%ALL SERIE
for i=wind/2+1:length(sTime)-wind/2-1
  ymed = median(sData(i-wind/2:i+wind/2));  
  ystd = std(sData(i-wind/2:i+wind/2));
  if(sData(i) >= min([ymed-sconf.parm(2)*ystd ymed+sconf.parm(2)*ystd]) && sData(i) <= max([ymed-sconf.parm(2)*ystd ymed+sconf.parm(2)*ystd]))
        QC_Serie(ind(i))=sconf.val(1);
  elseif(sData(i) >= min([ymed-sconf.parm(3)*ystd ymed+sconf.parm(3)*ystd]) && sData(i) <= max([ymed-sconf.parm(3)*ystd ymed+sconf.parm(3)*ystd]))
        QC_Serie(ind(i))=sconf.val(2);
  elseif(abs(sData(i)-sData(i-1))>=sconf.parm(4))
        QC_Serie(ind(i))=sconf.val(3);
  else 
	QC_Serie(ind(i))=sconf.val(2);	
  end    
end

%Last half window
ymed = median(sData(length(sTime)-wind/2:end));  
ystd = std(sData(length(sTime)-wind/2:end));
for i=length(sTime)-wind/2:length(sTime)
  if(sData(i) >= min([ymed-sconf.parm(2)*ystd ymed+sconf.parm(2)*ystd]) && sData(i) <= max([ymed-sconf.parm(2)*ystd ymed+sconf.parm(2)*ystd]))
        QC_Serie(ind(i))=sconf.val(1);
  elseif(sData(i) >= min([ymed-sconf.parm(3)*ystd ymed+sconf.parm(3)*ystd]) && sData(i) <= max([ymed-sconf.parm(3)*ystd ymed+sconf.parm(3)*ystd]))
        QC_Serie(ind(i))=sconf.val(2);
  elseif(abs(sData(i)-sData(i-1))>=sconf.parm(4))
        QC_Serie(ind(i))=sconf.val(3);
  else 
	QC_Serie(ind(i))=sconf.val(2);	
  end    
end
%%%%%%%%%%%%%%%%


%
% yy2 = medfilt1(double(sData),wind);
% yL1 = sconf.parm(2)*std(sData);
% yL2 = sconf.parm(3)*std(sData);
%
% for i=1:length(sTime)
%     if(sData(i)>=min([yy2(i)-yL1*yy2(i) yy2(i)+yL1*yy2(i)]) && sData(i)<=max([yy2(i)-yL1*yy2(i) yy2(i)+yL1*yy2(i)]))
%         QC_Serie(i)=sconf.val(1);
%     elseif(sData(i)>=min([yy2(i)-yL2*yy2(i) yy2(i)+yL2*yy2(i)]) && sData(i)<=max([yy2(i)-yL2*yy2(i) yy2(i)+yL2*yy2(i)]))
%         QC_Serie(i)=sconf.val(2);
%     else
%         QC_Serie(i)=sconf.val(3);
%     end  
% end

