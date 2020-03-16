function rem_axes(hObject, eventdata, handles)
%
% Remove axes from main figure et Redraw all axes
% 
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%

nb_axes=length(findobj(handles.figure1,'type','axes'));

switch nb_axes
    case 2
    %remove axes2 & popups & buttons +/-   
    usd=get(handles.pushbutton_axes2_p,'UserData');
    for i=2:usd-1
       eval(['delete(handles.popupmenu_axes2_',num2str(i),');']); 
    end
    delete(handles.axes2); delete(handles.popupmenu2); delete(handles.pushbutton_axes2_p); delete(handles.pushbutton_axes2_m);        
    
    %resize & relocate axes1 & popup
    set(handles.axes1,'Position',[0.178 0.537 0.721 0.406]);
    aa=get(handles.axes1,'Position');    set(handles.popupmenu1,'Position',[aa(1)+aa(3)+0.01,aa(2)+aa(4)-0.04,0.08,0.04]);
    %Disable "-" button
    set(handles.pushbutton2,'Enable','off'); 
        
    case 3
    %remove axes3 & popup3
    usd=get(handles.pushbutton_axes3_p,'UserData');
    for i=2:usd-1
       eval(['delete(handles.popupmenu_axes3_',num2str(i),');']); 
    end       
    delete(handles.axes3); delete(handles.popupmenu3); delete(handles.pushbutton_axes3_p); delete(handles.pushbutton_axes3_m);   
    
    %resize & relocate axes1,2 & popups & buttons +/-
    %axes1
    set(handles.axes1,'Position',[0.178 0.537 0.721 0.406]);
    aa=get(handles.axes1,'Position');    set(handles.popupmenu1,'Position',[aa(1)+aa(3)+0.01,aa(2)+aa(4)-0.04,0.08,0.04]);    
    usd1 = get(handles.pushbutton_axes1_p,'UserData');    
    for i=2:usd1-1
      aa=get(handles.popupmenu1,'Position');
      bb=[aa(1) aa(2)-0.03*(i-1) aa(3) aa(4)];      
      eval(['set(handles.popupmenu_axes1_',num2str(i),',''Position'',[',num2str(bb),']);']);
    end    
    %axes2
    set(handles.axes2,'Position',[0.178 0.082 0.721 0.406]);
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
        
    case 4
    %remove axes4 & popup4
    usd=get(handles.pushbutton_axes4_p,'UserData');
    for i=2:usd-1
       eval(['delete(handles.popupmenu_axes4_',num2str(i),');']); 
    end
    delete(handles.axes4); delete(handles.popupmenu4); delete(handles.pushbutton_axes4_p); delete(handles.pushbutton_axes4_m);   
    %resize & relocate axes1,2,3 & popups
    %axes1
    set(handles.axes1,'Position',[0.178 0.687 0.721 0.256]);
    aa=get(handles.axes1,'Position');    set(handles.popupmenu1,'Position',[aa(1)+aa(3)+0.01,aa(2)+aa(4)-0.04,0.08,0.04]);
    usd1 = get(handles.pushbutton_axes1_p,'UserData');    
    for i=2:usd1-1
      aa=get(handles.popupmenu1,'Position');
      bb=[aa(1) aa(2)-0.03*(i-1) aa(3) aa(4)];      
      eval(['set(handles.popupmenu_axes1_',num2str(i),',''Position'',[',num2str(bb),']);']);
    end    
    %axes2
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
    %axes3
    set(handles.axes3,'Position',[0.178 0.056 0.721 0.256]);
    aa=get(handles.axes3,'Position');    set(handles.popupmenu3,'Position',[aa(1)+aa(3)+0.01,aa(2)+aa(4)-0.04,0.08,0.04]);    
    usd3 = get(handles.pushbutton_axes3_p,'UserData');    
    for i=2:usd3-1
      aa=get(handles.popupmenu3,'Position');
      bb=[aa(1) aa(2)-0.03*(i-1) aa(3) aa(4)];      
      eval(['set(handles.popupmenu_axes3_',num2str(i),',''Position'',[',num2str(bb),']);']);
    end            
    bb=get(handles.popupmenu3,'Position');    
    set(handles.pushbutton_axes3_p,'Position',[bb(1)+0.015 bb(2)-0.03*(usd2-2)-0.023 0.021 0.03]);    
    set(handles.pushbutton_axes3_m,'Position',[bb(1)+0.040 bb(2)-0.03*(usd2-2)-0.023 0.021 0.03]);    
        
    case 5    
    %remove axes5 & popup5
    usd=get(handles.pushbutton_axes5_p,'UserData');
    for i=2:usd-1
       eval(['delete(handles.popupmenu_axes5_',num2str(i),');']); 
    end
    delete(handles.axes4); delete(handles.popupmenu4); delete(handles.pushbutton_axes5_p); delete(handles.pushbutton_axes5_m); 
    %resize & relocate axes1,2,3,4 & popups
    %axes1
    set(handles.axes1,'Position',[0.178 0.767 0.721 0.176]);
    aa=get(handles.axes1,'Position');    set(handles.popupmenu1,'Position',[aa(1)+aa(3)+0.01,aa(2)+aa(4)-0.04,0.08,0.04]);
    usd1 = get(handles.pushbutton_axes1_p,'UserData');    
    for i=2:usd1-1
      aa=get(handles.popupmenu1,'Position');
      bb=[aa(1) aa(2)-0.03*(i-1) aa(3) aa(4)];      
      eval(['set(handles.popupmenu_axes1_',num2str(i),',''Position'',[',num2str(bb),']);']);
    end    
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
    set(handles.pushbutton_axes3_p,'Position',[bb(1)+0.015 bb(2)-0.03*(usd2-2)-0.023 0.021 0.03]);    
    set(handles.pushbutton_axes3_m,'Position',[bb(1)+0.040 bb(2)-0.03*(usd2-2)-0.023 0.021 0.03]);  
    %axes4
    set(handles.axes4,'Position',[0.178 0.044 0.721 0.176]);
    aa=get(handles.axes4,'Position');    set(handles.popupmenu4,'Position',[aa(1)+aa(3)+0.01,aa(2)+aa(4)-0.04,0.08,0.04]);   
    usd4 = get(handles.pushbutton_axes4_p,'UserData');    
    for i=2:usd4-1
      aa=get(handles.popupmenu4,'Position');
      bb=[aa(1) aa(2)-0.03*(i-1) aa(3) aa(4)];      
      eval(['set(handles.popupmenu_axes4_',num2str(i),',''Position'',[',num2str(bb),']);']);
    end            
    bb=get(handles.popupmenu4,'Position');    
    set(handles.pushbutton_axes4_p,'Position',[bb(1)+0.015 bb(2)-0.03*(usd2-2)-0.023 0.021 0.03]);    
    set(handles.pushbutton_axes4_m,'Position',[bb(1)+0.040 bb(2)-0.03*(usd2-2)-0.023 0.021 0.03]);  
       
    %Enable "+" button
    set(handles.pushbutton1,'Enable','on');
    
end

end

