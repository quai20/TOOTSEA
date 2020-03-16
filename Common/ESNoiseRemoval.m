function qc_out = ESNoiseRemoval(TOST,nbin,seuil_variance)
%
% Flag area with ESNoise on surface adcp 75k

XX=TOST.Time(TOST.QC_Serie(nbin,:)<4); 
YY=TOST.Data(nbin,TOST.QC_Serie(nbin,:)<4);

qc_out=TOST.QC_Serie;
QC2=qc_out(nbin,:);

NX=XX(1):1/8:XX(end);
for i=1:length(NX)-1
    VY(i)=var(YY(XX>NX(i) & XX<NX(i+1)));    
    if(VY(i)>seuil_variance)        
        QC2(TOST.Time>NX(i) & TOST.Time<NX(i+1))=4;
    end
end

figure()
plot(XX,YY,'.');
dateNtick; grid on; hold on;
plot(TOST.Time(QC2<4),TOST.Data(nbin,QC2<4),'r.');

choice = questdlg('Save new QC ?','Save','Yes','No','Yes');

switch choice
    case 'Yes'
        qc_out(nbin,:)=QC2;
    case 'No'
        %
end
end

