function stickplot_2(tt,x,y,tlen,step,parent)
%PERSO STICKPLOT
%
tt=tt(:);
x=x(:);
y=y(:);
%
if(isempty(step))
    step=1;
end
%
if(isempty(tlen))
  tlen=max(tt)-min(tt);
  isub=1;
else
  isub=floor((max(tt)-min(tt))/tlen)+1;
end
%
maxmag=max(max(sqrt(x.*x+y.*y)));
sc=tlen/maxmag/15;
wx=x*sc;
wy=y*sc;
%
% Now plot
for i=1:isub    
    subplot(isub,1,i,'parent',parent);
    [~,k1]=min(abs(tt-min(tt)-(i-1)*tlen));
    [~,k2]=min(abs(tt-min(tt)-i*tlen));
    xp=[tt(k1:step:k2)       tt(k1:step:k2)+wx(k1:step:k2)]';   xp=xp(:); 
    yp=[wy(k1:step:k2).*0    wy(k1:step:k2)]';                  yp=yp(:);
    plot(double(xp),double(yp),'k-');    
    hold on;    
    line([min(double(xp)) max(double(xp))],[0 0],'linewidth',1,'color','b')     
    
    leg=(floor(maxmag/0.25))*0.25;
    line([min(double(xp))+5 min(double(xp))+5],[0 leg*sc],'linewidth',2,'color','b')
    text(min(double(xp))+5.6,leg*0.75*sc,[num2str(leg) ' m/s'],'Color','blue','FontWeight','bold')
    
    xticks(xp(1):tlen/6:xp(end));
    
    datetick('x',20,'keepticks');        
    if(maxmag*tlen/isub < 0.25*sc)
        set(gca,'YLim',[-0.25*sc 0.25*sc]);
    else
        set(gca,'YLim',[-maxmag*sc maxmag*sc]);
    end
    set(gca,'YTick',[]);    
    set(gca,'XLim',[min(double(xp)) tt(k1)+tlen]);                            
end

