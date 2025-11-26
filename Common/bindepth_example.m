%Access parameter his name (see list)
%Example : TEMP.Data

%Do not edit those variable names
NewParamName = 'DEPH_M';
NewParamTime = PRES_REL.Time; %TEMP.Time for example
for i=1:length(PRES_REL.Time)  
tmp(:,i)= DEPH.Data(i) - UCUR.Depth;  
end  
NewParamValue = tmp;
NewParamDepth = UCUR.Depth;
