function Depouille_LM(UCUR, VCUR, WCUR, TIME, fname, Latitude, Longitude)
% Depouille des donnees de courant d'un ADCP
% Credit : Louis Marie
% Tweaked for TOOTSEA : K.BALEM 2017
% INPUT :   UCUR, VCUR, WCUR arrays 
%           TIME array 
%           fname : filename
%           Latitude, Longitude values
% OUTPUT : [] %plots only
%

% On prepare les filtres pour virer la maree.
Nfd=3;
[Bd , Ad]=cheby2(Nfd,20,2/pi*atan(cos(pi/2/Nfd)*tan(pi/2*(1/12.43)/(3/2))));  % Il y a un "pre-warping" des frequences e la noix dans cheby2...
[Bd2,Ad2]=cheby2(Nfd,20,2/pi*atan(cos(pi/2/Nfd)*tan(pi/2*(1/12   )/(3/2))));
liABd=max([length(Ad),length(Bd)])-1;

[ax ,ay ] = size(Ad);
[axb,ayb] = size(Ad2);

matA =full(spdiags(repmat(fliplr(Ad ),[ay 1]), -ay+1:0,ay ,ay ));
matB =full(spdiags(repmat(fliplr(Bd ),[ay 1]), -ay+1:0,ay ,ay ));
matA2=full(spdiags(repmat(fliplr(Ad2),[ay 1]),-ayb+1:0,ayb,ayb));
matB2=full(spdiags(repmat(fliplr(Bd2),[ay 1]),-ayb+1:0,ayb,ayb));

% On filtre la maree.
%Composante vers l'Est
D=UCUR';
%M2
m=mean(D(1:24*3));Zi=matA*repmat(m,[ay  1])-matB*D(1:ay ,1);Zi=Zi(1:liABd);
D=flipud(filter(Bd ,Ad ,D,Zi(1:liABd)));
m=mean(D(1:24*3));Zi=matA*repmat(m,[ay  1])-matB*D(1:ay ,1);Zi=Zi(1:liABd);
D=flipud(filter(Bd ,Ad ,D,Zi(1:liABd)));
%S2
m=mean(D(1:24*3));Zi=matA2*repmat(m,[ayb 1])-matB2*D(1:ayb,1);Zi=Zi(1:liABd);
D =flipud(filter(Bd2,Ad2,D,Zi(1:liABd)));
m=mean(D(1:24*3));Zi=matA2*repmat(m,[ayb 1])-matB2*D(1:ayb,1);Zi=Zi(1:liABd);
DE=flipud(filter(Bd2,Ad2,D,Zi(1:liABd)));

%Composante vers le Nord
D=VCUR';
%M2
m=mean(D(1:24*3));Zi=matA*repmat(m,[ay  1])-matB*D(1:ay ,1);Zi=Zi(1:liABd);
D=flipud(filter(Bd ,Ad ,D,Zi(1:liABd)));
m=mean(D(1:24*3));Zi=matA*repmat(m,[ay  1])-matB*D(1:ay ,1);Zi=Zi(1:liABd);
D=flipud(filter(Bd ,Ad ,D,Zi(1:liABd)));
%S2
m=mean(D(1:24*3));Zi=matA2*repmat(m,[ayb 1])-matB2*D(1:ayb,1);Zi=Zi(1:liABd);
D =flipud(filter(Bd2,Ad2,D,Zi(1:liABd)));
m=mean(D(1:24*3));Zi=matA2*repmat(m,[ayb 1])-matB2*D(1:ayb,1);Zi=Zi(1:liABd);
DN=flipud(filter(Bd2,Ad2,D,Zi(1:liABd)));

%Composante vers le haut
D=WCUR';
%M2
m=mean(D(1:24*3));Zi=matA*repmat(m,[ay  1])-matB*D(1:ay ,1);Zi=Zi(1:liABd);
D=flipud(filter(Bd ,Ad ,D,Zi(1:liABd)));
m=mean(D(1:24*3));Zi=matA*repmat(m,[ay  1])-matB*D(1:ay ,1);Zi=Zi(1:liABd);
D=flipud(filter(Bd ,Ad ,D,Zi(1:liABd)));
%S2
m=mean(D(1:24*3));Zi=matA2*repmat(m,[ayb 1])-matB2*D(1:ayb,1);Zi=Zi(1:liABd);
D =flipud(filter(Bd2,Ad2,D,Zi(1:liABd)));
m=mean(D(1:24*3));Zi=matA2*repmat(m,[ayb 1])-matB2*D(1:ayb,1);Zi=Zi(1:liABd);
DU=flipud(filter(Bd2,Ad2,D,Zi(1:liABd)));

VELF=[DE';DN';DU'];

figure(1);clf;
subplot(2,1,1);hold on;
plot(TIME,UCUR); plot(TIME,VELF(1,:),'r');
ylabel('U_E (m/s)','FontSize',14);
axis([TIME(1) TIME(end) -0.2 0.2]);
line([TIME(1) TIME(end)],[0 0],'Color','k','LineStyle',':');
dynamicDateTicks;
set(gca,'box','on','FontSize',14);
title(['Donnees brutes du courantometre ' fname],'FontSize',14,'interpreter','none');

subplot(2,1,2);hold on;
plot(TIME,VCUR); plot(TIME,VELF(2,:),'r');
ylabel('U_N (m/s)','FontSize',14);
axis([TIME(1) TIME(end) -0.2 0.2]);
line([TIME(1) TIME(end)],[0 0],'Color','k','LineStyle',':');
dynamicDateTicks;
set(gca,'box','on','FontSize',14);


figure(2);clf;
subplot(2,1,1);hold on;
plot(TIME,VELF(1,:),'r');
ylabel('U_E (m/s)','FontSize',14);
axis([TIME(1) TIME(end) -0.2 0.2]);
line([TIME(1) TIME(end)],[0 0],'Color','k','LineStyle',':');
dynamicDateTicks;
set(gca,'box','on','FontSize',14);
title(['Donnees filtrees du courantometre ' fname],'FontSize',14,'interpreter','none');

subplot(2,1,2);hold on;
plot(TIME,VELF(2,:),'r');
ylabel('U_N (m/s)','FontSize',14);
axis([TIME(1) TIME(end) -0.2 0.2]);
line([TIME(1) TIME(end)],[0 0],'Color','k','LineStyle',':');
dynamicDateTicks;
set(gca,'box','on','FontSize',14);

x=linspace(-0.20,0.20,37);
nE=histc(UCUR,x-(x(2)-x(1))/2);nE=nE/sum(nE)/(x(2)-x(1));mE=mean(UCUR);sE=std(UCUR);
nN=histc(VCUR,x-(x(2)-x(1))/2);nN=nN/sum(nN)/(x(2)-x(1));mN=mean(VCUR);sN=std(VCUR);
nEf=histc(UCUR,x-(x(2)-x(1))/2);nEf=nEf/sum(nEf)/(x(2)-x(1));mEf=mean(UCUR);sEf=std(UCUR);
nNf=histc(VCUR,x-(x(2)-x(1))/2);nNf=nNf/sum(nNf)/(x(2)-x(1));mNf=mean(VCUR);sNf=std(VCUR);

xf=linspace(-0.20,0.20,370);

figure(3);clf;
subplot(2,2,[1 2]);
ht=title(['Histogrammes des composantes de vitesse, courantometre ' fname],'FontSize',16,'interpreter','none');
set(gca,'Visible','off');set(ht,'Visible','on');drawnow;
ha1=subplot(2,2,3);
hold on;
hpE =plot(x,nE ,'b.-');hold on;plot(xf,1/sqrt(2*pi)/sE.*exp(-(xf-mE).^2/2/sE^2),'b:');
hpEf=plot(x,nEf,'r.-');hold on;plot(xf,1/sqrt(2*pi)/sEf.*exp(-(xf-mEf).^2/2/sEf^2),'r:');
axis([-0.2 0.2 0 25]);
xlabel('U_E (m/s)','FontSize',14);
ylabel('w(U_{E,N}) (s/m)','FontSize',14);
set(gca,'box','on','FontSize',14);
legend([hpE hpEf],{'U_E, brute','U_E, filtree'},'FontSize',14);
ht1 =text(0.05,20,{sprintf('<u_{Eb}> = %3.2f cm/s',100*mE),sprintf('    \\sigma_{Eb} = %3.2f cm/s',100*sE)},'FontSize',14);
ht1f=text(0.05,17,{sprintf('<u_{Ef}> = %3.2f cm/s',100*mEf),sprintf('    \\sigma_{Ef} = %3.2f cm/s',100*sEf)},'FontSize',14);

ha2=subplot(2,2,4);
hold on;
hpN =plot(x,nN ,'b.-');hold on;plot(xf,1/sqrt(2*pi)/sN.*exp(-(xf-mN).^2/2/sN^2),'b:');
hpNf=plot(x,nNf,'r.-');hold on;plot(xf,1/sqrt(2*pi)/sNf.*exp(-(xf-mNf).^2/2/sNf^2),'r:');
axis([-0.2 0.2 0 25]);
xlabel('U_N (m/s)','FontSize',14);
ylabel('w(U_{E,N}) (s/m)','FontSize',14);
set(gca,'box','on','FontSize',14);
legend([hpN hpNf],{'U_N, brute','U_N, filtree'},'FontSize',14);
ht2 =text(0.05,20,{sprintf('<u_{Nb}> = %3.2f cm/s',100*mN),sprintf('    \\sigma_{Nb} = %3.2f cm/s',100*sN)},'FontSize',14);
ht2f=text(0.05,17,{sprintf('<u_{Nf}> = %3.2f cm/s',100*mNf),sprintf('    \\sigma_{Nf} = %3.2f cm/s',100*sNf)},'FontSize',14);

set(ha1,'Position',[0.06 0.09 0.42 0.8]);
set(ha2,'Position',[0.56 0.09 0.42 0.8]);
drawnow;

[sE,f]=spectrum(UCUR,2048,1500,hanning(2048,'Periodic'),3);
[sN,f]=spectrum(VCUR,2048,1500,hanning(2048,'Periodic'),3);
[sU,f]=spectrum(WCUR,2048,1500,hanning(2048,'Periodic'),3);
[sEf,f]=spectrum(VELF(1,:),2048,1500,hanning(2048,'Periodic'),3);
[sNf,f]=spectrum(VELF(2,:),2048,1500,hanning(2048,'Periodic'),3);
[sUf,f]=spectrum(VELF(3,:),2048,1500,hanning(2048,'Periodic'),3);

Ti=1/(2/86400*sin((Latitude)/180*pi))/3600;

figure(4);clf;hold on;
subplot(2,2,[1 2]);
ht=title(['Spectres de puissance des composantes de vitesse, courantometre ' fname ' .'],'FontSize',16,'interpreter','none');
set(gca,'Visible','off');set(ht,'Visible','on');

ha1=subplot(2,2,3);
hold on;
hE=plot(f,sE(:,1),'b-');plot(f,sEf(:,1),'b:');
hN=plot(f,sN(:,1),'r-');plot(f,sNf(:,1),'r:');
hU=plot(f,sU(:,1),'k-');plot(f,sUf(:,1),'k:');
line(1/12.43*[1 1],[1e-5 10],'Color','k','LineStyle',':');text(1/12.43,0.4 ,'M2','FontSize',14);
line(1/12*[1 1]   ,[1e-5 10],'Color','k','LineStyle',':');text(1/12   ,0.45,'S2','FontSize',14);
line(1/Ti*[1 1]   ,[1e-5 10],'Color','k','LineStyle',':');text(1/Ti+0.001,0.35,'f','FontSize',14);
axis([0 0.25 0 0.5]);
xlabel('f (cph)','FontSize',14);
ylabel('PSD(U_{E,N,U}) (m^2/s^2/cph)','FontSize',14);
set(gca,'box','on','FontSize',14);
legend([hE hN hU],{'U_E','U_N','U_U'},'FontSize',14);

ha2=subplot(2,2,4);
hold on;
hE2=plot(1./f,sE(:,1),'b-');plot(1./f,sEf(:,1),'b:');
hN2=plot(1./f,sN(:,1),'r-');plot(1./f,sNf(:,1),'r:');
hU2=plot(1./f,sU(:,1),'k-');plot(1./f,sUf(:,1),'k:');
line(12.43*[1 1],[1e-5 10],'Color','k','LineStyle',':');text(12.43,0.4 ,'M2','FontSize',14);
line(12*[1 1]   ,[1e-5 10],'Color','k','LineStyle',':');text(12   ,0.45,'S2','FontSize',14);
line(Ti*[1 1]   ,[1e-5 10],'Color','k','LineStyle',':');text(17.2,0.35,'f','FontSize',14);
axis([0 30 0 0.5]);
xlabel('T (h)','FontSize',14);
ylabel('PSD(U_{E,N,U}) (m^2/s^2/cph)','FontSize',14);
set(gca,'box','on','FontSize',14);
legend([hE2 hN2 hU2],{'U_E','U_N','U_U'},'FontSize',14);

set(ha1,'Position',[0.06 0.09 0.42 0.8]);
set(ha2,'Position',[0.56 0.09 0.42 0.8]);
drawnow;
set(gcf,'Position',[3 50 1915 1008]);
set(ha1,'YScale','log');axis(ha1,[0 0.25 1e-5 10]);
set(ha2,'YScale','log');axis(ha2,[0 30  1e-5 10]);

% Un hodographe.
dx=cumtrapz(UCUR)*(TIME(2)-TIME(1))*86400/1000;
dy=cumtrapz(VCUR)*(TIME(2)-TIME(1))*86400/1000;
figure(5);clf;hold on;
plot(dx,dy);
axis equal;
set(gca,'FontSize',16,'box','on');
xlabel('\delta X (km)','FontSize',16);
ylabel('\delta Y (km)','FontSize',16);

Rmax=0.2;
% Une pdf en 2D des courants.
xe=linspace(-Rmax,Rmax,41);
ye=linspace(-Rmax,Rmax,41);
Cc=UCUR'+1i*VCUR';

Ncc=zeros(length(xe),length(ye));
[Nx,binx]=histc(real(Cc),xe);
for u=1:size(binx,1)
    temp=Cc(binx==u);
    if ~isempty(temp)
        [Ncc(u,:)]=histc(imag(temp),ye);
    end
end

Ncc=Ncc/sum(Ncc(:))/(xe(2)-xe(1))/(ye(2)-ye(1));

[yeg,xeg]=meshgrid(ye,xe);

c=contourc(xe,ye,Ncc');

figure(6);clf;
caxis([0 max(max(Ncc))]);hold on;
c=[0   Rmax*cos(linspace(0,2*pi,201)) c(1,:);...
   201 Rmax*sin(linspace(0,2*pi,201)) c(2,:)];

u=1;
while (u<size(c,2))
    X=c(1,(u+1):(u+c(2,u)));
    Y=c(2,(u+1):(u+c(2,u)));
    r=sqrt(X.^2+Y.^2);
    ind=find(r>Rmax);
    X(ind)=Rmax*X(ind)./r(ind);Y(ind)=Rmax*Y(ind)./r(ind);
    patch(X,Y,c(1,u));
    u=u+c(2,u)+1;
end

set(gca,'FontSize',14);
hxl=xlabel('U_E (m/s)','FontSize',14);
hyl=ylabel('U_N (m/s)','FontSize',14);
polar_LM(Rmax);
px=get(hxl,'Position');set(hxl,'Position',px-[0 0.004 0]);
py=get(hyl,'Position');set(hyl,'Position',py-[0.005 0 0]);
hc=colorbar;set(hc,'FontSize',14);set(hc,'Position',get(hc,'Position')+[0.1 0 0 0]);
ylabel(hc,'w(U) m^2/s^2','FontSize',14);

