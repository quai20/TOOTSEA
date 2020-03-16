%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
function plha=Plot(obj,paxes)
%
msii = size(obj.Data);
[msi,ind]=min(msii);
switch msi
    case 1
    %SINGLE LEVEL
    plha=plot(paxes,obj.Time,obj.Data,'-','DisplayName',[obj.Name ' : ' obj.Unit]);
    hold(paxes,'on');
    grid(paxes,'on');
    %dynamicDateTicks(paxes);
    dateNtick('x',20,'linked_axes','axes_handle',paxes);  
    set(gca,'Fontsize',8);
    otherwise
    %MULTILEVEL     
     for i=1:size(obj.Data,1)       
       plha(i)=plot(paxes,obj.Time,obj.Data(i,:)+(i-1)*obj.p2p,'DisplayName',[obj.Name '_' num2str(i) ' : ' obj.Unit]);
       hold(paxes,'on'); grid(paxes,'on');
       dynamicDateTicks(paxes);
       set(gca,'Fontsize',8);        
     end       
end
if(~isempty(strfind(obj.Name,'PRES')) || ~isempty(strfind(obj.Name,'DEPTH')) || ~isempty(strfind(obj.Name,'DEPH'))) 
    set(paxes,'YDir','reverse');
else
    set(paxes,'YDir','default');
end

end
