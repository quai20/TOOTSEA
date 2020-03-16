function add_axes(hObject, eventdata, handles)
%
%Add axes to main figure 5 maximum
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
%HOW MANY AXES ON THE FIGURE ALREADY ?
nb_axes=length(findobj(handles.figure1,'type','axes'));

switch nb_axes
    case 1
    %relocate & resize axes1 & popups
    set(handles.axes1,'Position',[0.178 0.537 0.721 0.406]);
    aa=get(handles.axes1,'Position');    set(handles.popupmenu1,'Position',[aa(1)+aa(3)+0.01,aa(2)+aa(4)-0.04,0.08,0.04]);    
    %add axes2 & popup2 & buttons +/-
    handles.axes2=axes('Units','normalized','Position',[0.178 0.082 0.721 0.406],'FontSize',8,'XLim',get(handles.axes1,'XLim'));         
    linkaxes([handles.axes1,handles.axes2],'x');
    %linkaxes(ax,'option')
    bb=get(handles.axes2,'Position'); 
    ppos=[bb(1)+bb(3)+0.01,bb(2)+bb(4)-0.04,0.08,0.04];
    handles.popupmenu2=uicontrol('Style','popupmenu','String',get(handles.popupmenu1,'String'),'FontSize',8,'Unit','normalized','Position',...
                          ppos,'Callback',...
                          @(hObject,eventdata)main('popupmenu_Callback',hObject,eventdata,guidata(hObject),'axes2','1'));                     
    bpos=[ppos(1)+0.015 ppos(2)-0.03 0.021 0.03];                  
    handles.pushbutton_axes2_p=uicontrol('Style','pushbutton','String','+','Unit','normalized','Position',bpos,...
                    'Callback',@(hObject,eventdata)main('pushbutton_ap_Callback',hObject,eventdata,guidata(hObject),'axes2'),...
                    'UserData',2.0);
    bpos=[ppos(1)+0.040 ppos(2)-0.03 0.021 0.03];                  
    handles.pushbutton_axes2_m=uicontrol('Style','pushbutton','String','-','Unit','normalized','Position',bpos,...
                    'Callback',@(hObject,eventdata)main('pushbutton_am_Callback',hObject,eventdata,guidata(hObject),'axes2'),...
                    'UserData',2.0);
                
    guidata(handles.pushbutton_axes2_p,handles);   
    guidata(handles.pushbutton_axes2_m,handles);                  
    guidata(handles.axes2,handles);                                          
    guidata(handles.popupmenu2,handles);   
        
    %Enable "-" button
    set(handles.pushbutton2,'Enable','on');        
    %Disable other "-" button
    set(handles.pushbutton_axes2_m,'Enable','off');        
      
    case 2    
    %relocate & resize axes1,2 & popups & buttons +/-
    %Pour axe 1 pas besoin de descendre les menus
    set(handles.axes1,'Position',[0.178 0.687 0.721 0.256]);
    aa=get(handles.axes1,'Position');    set(handles.popupmenu1,'Position',[aa(1)+aa(3)+0.01,aa(2)+aa(4)-0.04,0.08,0.04]);
        
    %pour axe 2 :    
    set(handles.axes2,'Position',[0.178 0.370 0.721 0.256]);
    aa=get(handles.axes2,'Position');    set(handles.popupmenu2,'Position',[aa(1)+aa(3)+0.01,aa(2)+aa(4)-0.04,0.08,0.04]);    
    usd2 = get(handles.pushbutton_axes2_p,'UserData');    
    for i=2:usd2-1
      aa=get(handles.popupmenu2,'Position');
      bb=[aa(1) aa(2)-0.03*(i-1) aa(3) aa(4)];      
      eval(['set(handles.popupmenu_axes2_',num2str(i),',''Position'',[',num2str(bb),']);']);
    end
    bb=get(handles.popupmenu2,'Position');    
    set(handles.pushbutton_axes2_p,'Position',[bb(1)+0.015 bb(2)-0.03*(usd2-2)-0.023 0.021 0.03]);    
    set(handles.pushbutton_axes2_m,'Position',[bb(1)+0.040 bb(2)-0.03*(usd2-2)-0.023 0.021 0.03]);        
    
    %add axes3 & popup3
    handles.axes3=axes('Units','normalized','Position',[0.178 0.056 0.721 0.256],'FontSize',8,'XLim',get(handles.axes2,'XLim'));   
    linkaxes([handles.axes1,handles.axes2,handles.axes3],'x');
    bb=get(handles.axes3,'Position');    
    
    ppos=[bb(1)+bb(3)+0.01,bb(2)+bb(4)-0.04,0.08,0.04];
    handles.popupmenu3=uicontrol('Style','popupmenu','String',get(handles.popupmenu1,'String'),'FontSize',8,'Unit','normalized','Position',...
                          ppos,'Callback',...
                          @(hObject,eventdata)main('popupmenu_Callback',hObject,eventdata,guidata(hObject),'axes3','1'));
                      
    bpos=[ppos(1)+0.015 ppos(2)-0.03 0.021 0.03];                  
    handles.pushbutton_axes3_p=uicontrol('Style','pushbutton','String','+','Unit','normalized','Position',bpos,...
                    'Callback',@(hObject,eventdata)main('pushbutton_ap_Callback',hObject,eventdata,guidata(hObject),'axes3'),...
                    'UserData',2.0);
    bpos=[ppos(1)+0.040 ppos(2)-0.03 0.021 0.03];                  
    handles.pushbutton_axes3_m=uicontrol('Style','pushbutton','String','-','Unit','normalized','Position',bpos,...
                    'Callback',@(hObject,eventdata)main('pushbutton_am_Callback',hObject,eventdata,guidata(hObject),'axes3'),...
                    'UserData',2.0);
                
    guidata(handles.pushbutton_axes3_p,handles);   
    guidata(handles.pushbutton_axes3_m,handles);                        
                      
    guidata(handles.axes3,handles);                                                  
    guidata(handles.popupmenu3,handles);                            
    
    set(handles.pushbutton_axes3_m,'Enable','off');        
    
    case 3
    %relocate & resize axes1,2,3 & popups & buttons +/-
    %axes1 , pas besoin de descendre les menus
    set(handles.axes1,'Position',[0.178 0.767 0.721 0.176]);
    aa=get(handles.axes1,'Position');    set(handles.popupmenu1,'Position',[aa(1)+aa(3)+0.01,aa(2)+aa(4)-0.04,0.08,0.04]);
    %axes2
    set(handles.axes2,'Position',[0.178 0.532 0.721 0.176]);
    aa=get(handles.axes2,'Position');    set(handles.popupmenu2,'Position',[aa(1)+aa(3)+0.01,aa(2)+aa(4)-0.04,0.08,0.04]);    
    usd2 = get(handles.pushbutton_axes2_p,'UserData');    
    for i=2:usd2-1
      aa=get(handles.popupmenu2,'Position');
      bb=[aa(1) aa(2)-0.03*(i-1) aa(3) aa(4)];      
      eval(['set(handles.popupmenu_axes2_',num2str(i),',''Position'',[',num2str(bb),']);']);
    end
    bb=get(handles.popupmenu2,'Position');    
    set(handles.pushbutton_axes2_p,'Position',[bb(1)+0.015 bb(2)-0.03*(usd2-2)-0.023 0.021 0.03]);    
    set(handles.pushbutton_axes2_m,'Position',[bb(1)+0.040 bb(2)-0.03*(usd2-2)-0.023 0.021 0.03]);    
    %axes3     
    set(handles.axes3,'Position',[0.178 0.288 0.721 0.176]);
    aa=get(handles.axes3,'Position');    set(handles.popupmenu3,'Position',[aa(1)+aa(3)+0.01,aa(2)+aa(4)-0.04,0.08,0.04]);   
    usd3 = get(handles.pushbutton_axes3_p,'UserData');    
    for i=2:usd3-1
      aa=get(handles.popupmenu3,'Position');
      bb=[aa(1) aa(2)-0.03*(i-1) aa(3) aa(4)];      
      eval(['set(handles.popupmenu_axes3_',num2str(i),',''Position'',[',num2str(bb),']);']);
    end
    bb=get(handles.popupmenu3,'Position');    
    set(handles.pushbutton_axes3_p,'Position',[bb(1)+0.015 bb(2)-0.03*(usd3-2)-0.023 0.021 0.03]);    
    set(handles.pushbutton_axes3_m,'Position',[bb(1)+0.040 bb(2)-0.03*(usd3-2)-0.023 0.021 0.03]);    
  
    
    %add axes4 & popup4   
    handles.axes4=axes('Units','normalized','Position',[0.178 0.044 0.721 0.176],'FontSize',8,'XLim',get(handles.axes3,'XLim'));   
    linkaxes([handles.axes1,handles.axes2,handles.axes3,handles.axes4],'x');
    bb=get(handles.axes4,'Position');    
    
    ppos=[bb(1)+bb(3)+0.01,bb(2)+bb(4)-0.04,0.08,0.04];
    
    handles.popupmenu4=uicontrol('Style','popupmenu','String',get(handles.popupmenu1,'String'),'FontSize',8,'Unit','normalized','Position',...
                          ppos,'Callback',...
                          @(hObject,eventdata)main('popupmenu_Callback',hObject,eventdata,guidata(hObject),'axes4','1'));
                      
    bpos=[ppos(1)+0.015 ppos(2)-0.03 0.021 0.03];                  
    handles.pushbutton_axes4_p=uicontrol('Style','pushbutton','String','+','Unit','normalized','Position',bpos,...
                    'Callback',@(hObject,eventdata)main('pushbutton_ap_Callback',hObject,eventdata,guidata(hObject),'axes4'),...
                    'UserData',2.0);
    bpos=[ppos(1)+0.040 ppos(2)-0.03 0.021 0.03];                  
    handles.pushbutton_axes4_m=uicontrol('Style','pushbutton','String','-','Unit','normalized','Position',bpos,...
                    'Callback',@(hObject,eventdata)main('pushbutton_am_Callback',hObject,eventdata,guidata(hObject),'axes4'),...
                    'UserData',2.0);
                
    guidata(handles.pushbutton_axes4_p,handles);   
    guidata(handles.pushbutton_axes4_m,handles);    
                      
    guidata(handles.axes4,handles);                                                  
    guidata(handles.popupmenu4,handles);         
    
    set(handles.pushbutton_axes4_m,'Enable','off');        
    
    case 4    
    %relocate & resize axes1,2,3,4 & popups & buttons +/-
    %axes1
    set(handles.axes1,'Position',[0.178 0.820 0.721 0.122]);
    aa=get(handles.axes1,'Position');    set(handles.popupmenu1,'Position',[aa(1)+aa(3)+0.01,aa(2)+aa(4)-0.04,0.08,0.04]);
    %axes2
    set(handles.axes2,'Position',[0.178 0.634 0.721 0.122]);
    aa=get(handles.axes2,'Position');    set(handles.popupmenu2,'Position',[aa(1)+aa(3)+0.01,aa(2)+aa(4)-0.04,0.08,0.04]);    
    usd2 = get(handles.pushbutton_axes2_p,'UserData');    
    for i=2:usd2-1
      aa=get(handles.popupmenu2,'Position');
      bb=[aa(1) aa(2)-0.03*(i-1) aa(3) aa(4)];      
      eval(['set(handles.popupmenu_axes2_',num2str(i),',''Position'',[',num2str(bb),']);']);
    end
    bb=get(handles.popupmenu2,'Position');    
    set(handles.pushbutton_axes2_p,'Position',[bb(1)+0.015 bb(2)-0.03*(usd2-2)-0.023 0.021 0.03]);    
    set(handles.pushbutton_axes2_m,'Position',[bb(1)+0.040 bb(2)-0.03*(usd2-2)-0.023 0.021 0.03]);    
    %axes3
    set(handles.axes3,'Position',[0.178 0.444 0.721 0.122]);
    aa=get(handles.axes3,'Position');    set(handles.popupmenu3,'Position',[aa(1)+aa(3)+0.01,aa(2)+aa(4)-0.04,0.08,0.04]); 
    usd3 = get(handles.pushbutton_axes3_p,'UserData');    
    for i=2:usd3-1
      aa=get(handles.popupmenu3,'Position');
      bb=[aa(1) aa(2)-0.03*(i-1) aa(3) aa(4)];      
      eval(['set(handles.popupmenu_axes3_',num2str(i),',''Position'',[',num2str(bb),']);']);
    end
    bb=get(handles.popupmenu3,'Position');    
    set(handles.pushbutton_axes3_p,'Position',[bb(1)+0.015 bb(2)-0.03*(usd3-2)-0.023 0.021 0.03]);    
    set(handles.pushbutton_axes3_m,'Position',[bb(1)+0.040 bb(2)-0.03*(usd3-2)-0.023 0.021 0.03]);   
    %axes4
    set(handles.axes4,'Position',[0.178 0.256 0.721 0.122]);
    aa=get(handles.axes4,'Position');    set(handles.popupmenu4,'Position',[aa(1)+aa(3)+0.01,aa(2)+aa(4)-0.04,0.08,0.04]);  
    usd4 = get(handles.pushbutton_axes4_p,'UserData');    
    for i=2:usd4-1
      aa=get(handles.popupmenu4,'Position');
      bb=[aa(1) aa(2)-0.03*(i-1) aa(3) aa(4)];      
      eval(['set(handles.popupmenu_axes4_',num2str(i),',''Position'',[',num2str(bb),']);']);
    end
    bb=get(handles.popupmenu4,'Position');    
    set(handles.pushbutton_axes4_p,'Position',[bb(1)+0.015 bb(2)-0.03*(usd4-2)-0.023 0.021 0.03]);    
    set(handles.pushbutton_axes4_m,'Position',[bb(1)+0.040 bb(2)-0.03*(usd4-2)-0.023 0.021 0.03]);           
    
    %add axes5 & popup5   
    handles.axes5=axes('Units','normalized','Position',[0.178 0.067 0.721 0.122],'FontSize',8,'XLim',get(handles.axes4,'XLim'));   
    linkaxes([handles.axes1,handles.axes2,handles.axes3,handles.axes4,handles.axes5],'x');
    bb=get(handles.axes5,'Position');    
    
    ppos=[bb(1)+bb(3)+0.01,bb(2)+bb(4)-0.04,0.08,0.04];
    
    handles.popupmenu5=uicontrol('Style','popupmenu','String',get(handles.popupmenu1,'String'),'FontSize',8,'Unit','normalized','Position',...
                          ppos,'Callback',...
                          @(hObject,eventdata)main('popupmenu_Callback',hObject,eventdata,guidata(hObject),'axes5','1'));
                      
    bpos=[ppos(1)+0.015 ppos(2)-0.03 0.021 0.03];                  
    handles.pushbutton_axes5_p=uicontrol('Style','pushbutton','String','+','Unit','normalized','Position',bpos,...
                    'Callback',@(hObject,eventdata)main('pushbutton_ap_Callback',hObject,eventdata,guidata(hObject),'axes5'),...
                    'UserData',2.0);
    bpos=[ppos(1)+0.040 ppos(2)-0.03 0.021 0.03];                  
    handles.pushbutton_axes5_m=uicontrol('Style','pushbutton','String','-','Unit','normalized','Position',bpos,...
                    'Callback',@(hObject,eventdata)main('pushbutton_am_Callback',hObject,eventdata,guidata(hObject),'axes5'),...
                    'UserData',2.0);
                
    guidata(handles.pushbutton_axes5_p,handles);   
    guidata(handles.pushbutton_axes5_m,handles);                       
                      
    guidata(handles.axes5,handles);                                                  
    guidata(handles.popupmenu5,handles);         
    
    set(handles.pushbutton_axes2_m,'Enable','off');        
    
    %Disable "+" button
    set(handles.pushbutton1,'Enable','off');   
end

