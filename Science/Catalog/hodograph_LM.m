function hodograph_LM(UCUR, VCUR, TIME)
% Un hodographe 
% Credit : Louis Marie
% Tweaked for TOOTSEA : K.BALEM 2017
% INPUT :   UCUR, VCUR arrays
%           TIME            
% OUTPUT : [] %plots only
%
dx=cumtrapz(UCUR)*(TIME(2)-TIME(1))*86400/1000;
dy=cumtrapz(VCUR)*(TIME(2)-TIME(1))*86400/1000;
plot(dx,dy);
axis equal; grid on;
set(gca,'FontSize',16,'box','on');
xlabel('\delta X (km)','FontSize',16);
ylabel('\delta Y (km)','FontSize',16);

%ONE POINT EVERY WEEK


end

