function hh=hodograph_KB(UCUR, VCUR, TIME, NN)
% Un hodographe 
% Credit : Kevin Balem
% Created for TOOTSEA : K.BALEM 2017
% INPUT :   UCUR, VCUR current arrays
%           TIME array          
%           NN integer to plot a point every NN days      
% OUTPUT : [] %plots only
%
crrx=0;
crry=0;
lti=1;
dxN=[];
dyN=[];
for i=1:length(UCUR)-1
    dx(i)=crrx+UCUR(i)*(TIME(i+1)-TIME(i))*86400/1000;
    crrx=dx(i);    
    dy(i)=crry+VCUR(i)*(TIME(i+1)-TIME(i))*86400/1000;
    crry=dy(i);    
    %Plot one point every N Days
    if((TIME(i)-TIME(lti))>NN)
        dxN=[dxN dx(i)];
        dyN=[dyN dy(i)];
        lti=i;
    end
end

hh=plot(dx,dy,'linewidth',2); hold on;
plot(dxN,dyN,'k.');
axis equal; grid on;
set(gca,'FontSize',8,'box','on');
xlabel('\delta X (km)','FontSize',9);
ylabel('\delta Y (km)','FontSize',9);

end

