function  rose_nd(t_size)
ch=findall(gca,'HandleVisibility','Off','-and','Type','Text');

h0  =ch(strcmp('0'  ,get(ch,'String')));
h30 =ch(strcmp('30' ,get(ch,'String')));
h60 =ch(strcmp('60' ,get(ch,'String')));
h90 =ch(strcmp('90' ,get(ch,'String')));
h120=ch(strcmp('120',get(ch,'String')));
h150=ch(strcmp('150',get(ch,'String')));
h180=ch(strcmp('180',get(ch,'String')));
h210=ch(strcmp('210',get(ch,'String')));
h240=ch(strcmp('240',get(ch,'String')));
h270=ch(strcmp('270',get(ch,'String')));
h300=ch(strcmp('300',get(ch,'String')));
h330=ch(strcmp('330',get(ch,'String')));
% 
set(h330,'String','120','color','w');
set(h300,'String','150','color','w');
set(h270,'String','S','FontSize',t_size,'FontWeight','bold','color','k');
set(h240,'String','210','color','w');
set(h210,'String','240','color','w');
set(h180,'String','W','FontSize',t_size,'FontWeight','bold','color','k');
set(h150,'String','300','color','w');
set(h120,'String','330','color','w');
set(h90,'String','N','FontSize',t_size,'FontWeight','bold','color','k');
set(h60,'String','30','color','w');
set(h30,'String','60','color','w');
set(h0,'String','E','FontSize',t_size,'FontWeight','bold','color','k');


