%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
function tspectrum(obj,dt,WINDOW,NOVERL,NFFT,CONFL,lev,qcone)

%x=obj.Data(lev,~isnan(obj.Data(lev,:)));
if(qcone==1)
    %qc à 1 et interpolation
    rgqc=(obj.QC_Serie(lev,:)<4);
    if(max(rgqc)>0)
        x1=obj.Data(lev,rgqc);    
        t1=obj.Time(rgqc);        
        x=interp1(t1(~isnan(x1)),x1(~isnan(x1)),obj.Time,'linear');
        x=x(~isnan(x));
    else
        cla;
        helpdlg('No good value detected');
    end
elseif(qcone==0)
    %tous les qc et interpolation        
    x=interp1(obj.Time(~isnan(obj.Data(lev,:))),obj.Data(lev,~isnan(obj.Data(lev,:))),obj.Time,'linear');
    x=x(~isnan(x));
end
    
%vars
fs = 1/dt; %dt
if(license('test','signal_toolbox'))
    [pxx,f,pxxc]=pwelch(x,WINDOW,NOVERL,NFFT,fs,'ConfidenceLevel',CONFL);
    %
    cla;
    plot(1./(3600.*f),pxx);
    hold on; grid on;
    plot(1./(3600.*f),pxxc,'r-.');
    %set(gca,'yscale','log');
    %set(gca,'xscale','log');
    set(gca,'XDir','reverse');
    xlabel('Period (Hrs)'); ylabel('PSD');
    assignin('base','pxx',pxx);
    assignin('base','f',f);
else
    f=fs*(0:(WINDOW/2))/WINDOW;
    pxx1=fft(x,WINDOW);
    pxx=abs(pxx1/WINDOW);    
    cla;
    plot(1./(3600.*f),pxx(1:WINDOW/2+1));
    hold on; grid on;
    %set(gca,'yscale','log');
    %set(gca,'xscale','log');
    set(gca,'XDir','reverse');
    xlabel('Period (Hrs)'); ylabel('PSD');
end

end

