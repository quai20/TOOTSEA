function pdf2d_LM(UCUR, VCUR, Rmax)
% Une pdf en 2D des courants.
% Credit : Louis Marie
% Tweaked for TOOTSEA : K.BALEM 2017
% INPUT :   UCUR array, VCUR array 
%           Rmax value
% OUTPUT : [] %plots only
%
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

figure('name','pdf2d_LM');clf;
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
set(hyl,'Position',get(hyl,'Position')-[0.005 0 0]);
polar_LM(Rmax);
px=get(hxl,'Position');set(hxl,'Position',px-[0 0.004 0]);
py=get(hyl,'Position');set(hyl,'Position',py-[0.005 0 0]);
hc=colorbar;set(hc,'FontSize',14);set(hc,'Position',get(hc,'Position')+[0.1 0 0 0]);
ylabel(hc,'w(U) m^2/s^2','FontSize',14);

end

