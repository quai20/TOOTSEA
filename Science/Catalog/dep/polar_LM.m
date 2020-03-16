function polar_LM(range_max)

cax=gca;

% get x-axis text color so grid is in same color
tc = get(cax,'xcolor');
ls = get(cax,'gridlinestyle');

% Hold on to current Text defaults, reset them to the
% Axes' font attributes so tick marks use them.
fAngle  = get(cax, 'DefaultTextFontAngle');
fName   = get(cax, 'DefaultTextFontName');
fSize   = get(cax, 'DefaultTextFontSize');
fWeight = get(cax, 'DefaultTextFontWeight');
fUnits  = get(cax, 'DefaultTextUnits');
set(cax, 'DefaultTextFontAngle',  get(cax, 'FontAngle'), ...
    'DefaultTextFontName',   get(cax, 'FontName'), ...
    'DefaultTextFontSize',   get(cax, 'FontSize'), ...
    'DefaultTextFontWeight', get(cax, 'FontWeight'), ...
    'DefaultTextUnits','data')

hold(cax,'on');
hhh=line([-range_max -range_max range_max range_max],[-range_max range_max range_max -range_max],'parent',cax);
set(cax,'dataaspectratio',[1 1 1],'plotboxaspectratiomode','auto')
v = [get(cax,'xlim') get(cax,'ylim')];
ticks = sum(get(cax,'ytick')>=0);
delete(hhh);set(cax,'xtick',[],'ytick',[]);
set(cax,'Visible','off');


% check radial limits and ticks
rmin = 0; rmax = v(4); rticks = max(ticks-1,2);
if rticks > 5   % see if we can reduce the number
    if rem(rticks,2) == 0
        rticks = rticks/2;
    elseif rem(rticks,3) == 0
        rticks = rticks/3;
    end
end

% define a circle
th = 0:pi/50:2*pi;
xunit = cos(th);
yunit = sin(th);
% now really force points on x/y axes to lie on them exactly
inds = 1:(length(th)-1)/4:length(th);
xunit(inds(2:2:4)) = zeros(2,1);
yunit(inds(1:2:5)) = zeros(3,1);


% draw radial circles
c82 = cos(82*pi/180);
s82 = sin(82*pi/180);
rinc = (rmax-rmin)/rticks;
for i=(rmin+rinc):rinc:rmax
    hhh = line(xunit*i,yunit*i,'linestyle',ls,'color',tc,'linewidth',1,...
               'handlevisibility','off','parent',cax);
    text((i+rinc/20)*c82,(i+rinc/20)*s82, ...
        ['  ' num2str(i)],'verticalalignment','bottom',...
        'handlevisibility','off','parent',cax)
end
set(hhh,'linestyle','-') % Make outer circle solid

% plot spokes
th = (1:6)*2*pi/12;
cst = cos(th); snt = sin(th);
cs = [-cst; cst];
sn = [-snt; snt];
line(rmax*cs,rmax*sn,'linestyle',ls,'color',tc,'linewidth',1,...
     'handlevisibility','off','parent',cax)

% annotate spokes in degrees
rt = 1.1*rmax;
for i = 1:length(th)
    an =90-i*30;
    text(rt*cst(i),rt*snt(i),int2str(mod(an,360)),...
         'horizontalalignment','center',...
         'handlevisibility','off','parent',cax);
    text(-rt*cst(i),-rt*snt(i),int2str(mod(180+an,360)),'horizontalalignment','center',...
         'handlevisibility','off','parent',cax)
end

% set view to 2-D
view(cax,2);
% set axis limits
axis(cax,rmax*[-1 1 -1.15 1.15]);


set(get(cax,'xlabel'),'visible','on')
set(get(cax,'ylabel'),'visible','on')

