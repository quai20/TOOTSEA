% U_ortho_U_paral_Fischer_rose.m
% ---------------------------------
% representation des series temporelles reechantillonnees des composantes
% perpendiculaires et paralleles a la section dans le temps et dans l'
% espace:
% cf figure 6 de l'article 
% Circulation and Transport at the Southeast Tip of Greenland
% Daniault et al, JPO, 2011.
% ---> fait le 10/02/2009
% Fonctions appelées: rose_nd et compass_nd
% ------------------------------------------------------------------------
clear ;close all;
rep_d = '/net/pisces/exports/userdata/home/daniault/matlab/OVIDE/EULER/';

% ----> Initialisations
mouillage=input('  quel mouillage (A, AA, B, C, Cb ou D )? ','s');
nfic=[rep_d 'EULER_' mouillage];
load (nfic);
if strcmp(deblank(mouillage),'B')
   U_c8_24h(:,end)= U_24h_new;% ---> voir B_ralenti;
   V_c8_24h(:,end)= V_24h_new;
end

d_biais=datenum(2004,6,1);
date_c8=d_biais+base_temps_c8_24h;
d1=datenum(2004,06,01);d2=datenum(2006,06,31);
xtic=[datenum(2004,07:12,01), ...
   datenum(2005,1:12,01),...
   datenum(2006,1:6,01)];
if ~exist('depth_c8_nd','var')
   depth_c8_nd=depth_c8;
end
display(depth_c8_nd);
D_m= depth_c8_nd;
if strcmp(mouillage,'Cb')
   U_c8_paral(:,3)=[];U_c8_ortho(:,3)=[];
   depth_c8(3)=[];P_c8_24h(:,3)=[];D_m(3)=[];
end
[bid, n_mouil]=size(P_c8_24h); % Nbre de courantos sur la verticale
% --->  Deux figures par mouillage (mean, ellipse var)
if strcmp(mouillage(1),'C')
   n_mouil=n_mouil+1;
   D_m= [D_m depth_a];
   date_a=d_biais+base_temps_a_24h;
end
figp;
% ---> Organisation des fenetres du subplot
n_fig=n_mouil*5;
A_t=(1:n_fig);B_t=reshape(A_t,5,n_mouil)';
Yls=[-80 40];
for ii=n_mouil:-1:1
   jj=n_mouil-ii+1;
   if strcmp(mouillage(1),'C') && ii==n_mouil
      ux=-U_a_ortho(:,1)/10; % cm/s
      vx=U_a_paral(:,1)/10; % cm/s
      uux(:,ii)=[U_a_24h(:,1)/10; ...
         zeros(length(base_temps_c8_24h)-length(base_temps_a_24h),1)]; % cm/s
      vvx(:,ii)=[V_a_24h(:,1)/10; ...
         zeros(length(base_temps_c8_24h)-length(base_temps_a_24h),1)]; % cm/s
      date_s=date_a;
      U_bar(ii)=mean(U_a_24h(:,1)/10);
      V_bar(ii)=mean(V_a_24h(:,1)/10);
   else
      ux=-U_c8_ortho(:,ii)/10; % cm/s
      vx=U_c8_paral(:,ii)/10; % cm/s
      uux(:,ii)=U_c8_24h(:,ii)/10; % cm/s
      vvx(:,ii)=V_c8_24h(:,ii)/10; % cm/s
      date_s=date_c8;
      U_bar(ii)=mean(U_c8_24h(:,ii)/10);
      V_bar(ii)=mean(V_c8_24h(:,ii)/10);
   end
   CP_bar(ii)=nanmean(abs(ux+1i*vx)); % mean
   CP_std(ii)=nanstd(abs(ux+1i*vx));
   subplot(n_mouil,5,B_t(jj,1:3));
   plot(date_s,ux,'Color',[0 0 0]);set(gca,'Xtick',xtic);
   set(gca,'xticklabel',[]);   hold on;
	if exist('Amp','var') %&& ii==n_mouil,
		T=365;w=2*pi/T;
		xdata=base_temps_c8_24h;
		y_LS=mean(ux)-Amp(ii)*sin(w.*xdata+Phase(ii));
		plot(date_s,y_LS,'Color',[0 0 0],'linestyle','-.');
	end
   Tb=-40;Th=80;
   if jj>=3,Tb=-20;Th=40;end
   set(gca,'Ylim',[Tb Th]);
   plot(date_s,vx,'Color',[0.6 0.6 0.6]);set(gca,'Xlim',[d1 d2]);
   plot([d1 d2],[0 0],'k.-');
   Xl=get(gca,'Xlim');Yl=get(gca,'Ylim');
   txt= [num2str(D_m(ii)) 'm'];
   text(Xl(end),Yl(end),txt,'HorizontalAlignment','right',...
      'VerticalAlignment','top','FontWeight','bold');
   if ii==n_mouil
      ylabel('cm/s')
      % ---> Deuxieme axe en haut
      posi=get(gca,'Position');
      xL=get(gca,'Xlim');
      ax2=axes('Position',[posi(1) posi(2)+posi(4) posi(3) 0.000000001 ]);
      set(ax2,'XLim', xL,'YScale','linear',...
         'YGrid','off','XAxisLocation','top');
      datetick('x','yyyy','keeplimits');
      set(ax2,'fontsize',12,'fontweight','bold');
   else
      ylabel(' ')
   end
   hold off;
end
% Reset the bottom subplot to have xticks
set(gca,'Xtick',xtic);
datetick('x','m','keeplimits','keepticks')
switch mouillage
   case 'A'
      ProfM=1894;
   case 'AA'
      ProfM=2113;
   case 'B'
      ProfM=1732;
   case 'C'
      ProfM=1030;
   case 'Cb'
      ProfM=1122;
   case 'E'
      ProfM= 192;
   case 'Eb'
      ProfM=188;
   case 'D'
      ProfM=518;
end
Vmax=ceil(max(abs(U_bar+1i*V_bar))/10)*10;
P_lim=ceil(abs(U_bar+1i*V_bar)/10)*10;
for ii=n_mouil:-1:1
   UV=uux(:,ii)+1i*vvx(:,ii);
   P_lim=ceil(max(abs(UV))/10)*10;
   jj=n_mouil-ii+1;
   subplot(n_mouil,5,B_t(jj,4));
   h=polar([pi/3+pi/2 pi/3+3*pi/2],[ P_lim P_lim]);
   set(h,'Color','k','linewidth',2);hold on;
   h=compass_nd(UV(abs(UV)>1.4));
   set(h,'Color',[0.6 0.6 0.6]);
   h=compass_nd(U_bar(ii)+1i*V_bar(ii));
   set(h,'LineWidth',2,'Color','r');
   rose_nd(8);
end
subplot(n_mouil,5,B_t(:,end)');
plot(CP_bar,D_m,'ko-');
set(gca,'Ylim',[0 1900]);hold on;Yl=get(gca,'Ylim');
set(gca,'Ydir','reverse');
xl1=(CP_bar-CP_std/2)' ;xl2=(CP_bar+CP_std/2)';
h=line([xl1 xl2]',[D_m' D_m']');set(h,'Color','k');
plot([CP_bar(1) CP_bar(1)],[D_m(1) ProfM],'k--')
plot([CP_bar(end) CP_bar(end)],[D_m(end) Yl(1)],'k--')
set(gca,'Xlim',[0 50]);grid on;Xl=get(gca,'Xlim');
plot(Xl,[ProfM ProfM],'k-.','linewidth',2);
set(gca,'YAxisLocation','right');ylabel('Depth (m)');
set(gca,'xtick',[0 10 20 30 40 50]);
switch mouillage
   case {'C','Cb'}
      i_bon=faux(U_aa,i_nan_a);M=i_bon;lM=length(M);
      date=d_biais+base_temps_a_24h;
      z=sw_dpth(mean(P_a_24h)-(24:16:568)',lat_mooring)';
      Dpth=-z(M(1:5:end));
      D_m=-round(Dpth);
      display(D_m);
      [bid, n_mouil_a]=size(Dpth); % Nbre de courantos
      for ii=n_mouil_a:-1:1
         ux=U_a_ortho(:,ii)/10; % cm/s
         vx=U_a_paral(:,ii)/10; % cm/s
         [CP_bar(ii), CP_std(ii)]=meannan(abs(ux+1i*vx),1); % mean
      end
      plot(CP_bar,D_m,'o-');
      xl1=(CP_bar-CP_std/2)' ;xl2=(CP_bar+CP_std/2)';
      h=line([xl1 xl2]',[D_m' D_m']');
end
r_tr=input('Sauvegarde du trace?','s');
if strcmp(r_tr,'o')
   set(gcf,'InvertHardcopy','off');set(gcf,'color',[1 1 1]);
   eval(['print -dpng -r150 ../papier190309/U_ortho_U_paral_' mouillage '.png;'])
	scrsz = get(0,'ScreenSize');set(gcf,'Position',scrsz );
	eval([...
		'print -depsc /home/daniault/matlab/OVIDE/papier190309/PAPER_Rwv/U_ortho_U_paral_'...
		mouillage '.eps;'])
	
end

