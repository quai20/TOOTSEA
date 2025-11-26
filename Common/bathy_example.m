%Access parameter his name (see list)
%Example : TEMP.Data
aaa = argmax;
for i=2:length(argmax)
if((ABSIC1.Depth(argmax(i))<-300)&&(ABSIC1.Depth(argmax(i))>-400))
aaa(i)=ABSIC1.Depth(argmax(i));
else
aaa(i)=ABSIC1.Depth(round(mean(argmax)));
end
end
%Do not edit those variable names
NewParamName = 'BATHY';
NewParamTime = PRES.Time; %TEMP.Time for example
NewParamValue = aaa;
NewParamDepth = [];


