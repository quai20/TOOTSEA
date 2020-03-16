function DephComp(DAT1,desc1,DAT2,desc2,THEO)
% Compare 2 DEPH Series 
%
% INPUTS :  2 TimeSeries class structures
%           2 description strings
%           1 theoritical value 
% OUTPUTS : plot only

id1=find(DAT1.QC_Serie<=3);
id2=find(DAT2.QC_Serie<=3);

figure('Position',[50 50 1200 500]); clf; hold on; grid on;
plot(DAT1.Time(id1),DAT1.Data(id1),'b');
plot(DAT2.Time(id2),DAT2.Data(id2),'k');
plot([DAT2.Time(1),DAT2.Time(end)],[THEO THEO],'r','linewidth',2);
dateNtick; 
ylabel('Depth (m)');
legend(desc1,desc2);

end
