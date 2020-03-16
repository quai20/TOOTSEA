function QC_out = surfAdcpQualif(DATA,DEPH)
%disp('toto');
QC_out=DATA.QC_Serie;
for lev=1:size(DATA.Data,1)
	ind1=~isnan(DATA.Data(lev,:));
	ind2=(DEPH.Data-DATA.Depth(lev))<DEPH.Data*(1-cosd(20));
	ind=ind1 & ind2;
	QC_out(lev,ind)=4;
end

