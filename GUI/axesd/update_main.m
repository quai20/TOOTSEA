function handles = update_main(hObject, eventdata, handles, ParamList, PARAMETERS, MDim, MMetadata)
%
% Update some elements of the main figure of TOOTSEA
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%

%First plotbox
set(handles.popupmenu1,'string',ParamList);

%UPDATE TREE
%%%%%
if(isfield(handles,'mytree'))
    delete(handles.mytree.Root)
    handles=create_maintree(hObject, eventdata, handles, PARAMETERS);
else
    handles=create_maintree(hObject, eventdata, handles, PARAMETERS);
end

%CHECK UNICITY OF PARAMLIST
if(length(ParamList)~=length(unique(ParamList)))
   warndlg('Some of your parameters have the same name, carefull !'); 
end

%METADATA
TDisp={};
for i=1:length(MMetadata.Properties)
    try
TDisp{i}=['# ',MMetadata.Properties{i},' : ',MMetadata.Values{i}];
    catch
    end
end
set(handles.text2,'string',TDisp);

try set(handles.popupmenu_axes1_2,'string',ParamList); catch ; end
try set(handles.popupmenu_axes1_3,'string',ParamList); catch ; end
try set(handles.popupmenu_axes1_4,'string',ParamList); catch ; end
try set(handles.popupmenu_axes1_5,'string',ParamList); catch ; end
try set(handles.popupmenu_axes1_6,'string',ParamList); catch ; end
    
try set(handles.popupmenu2,'string',ParamList); catch ; end
try set(handles.popupmenu_axes2_2,'string',ParamList); catch ; end
try set(handles.popupmenu_axes2_3,'string',ParamList); catch ; end
try set(handles.popupmenu_axes2_4,'string',ParamList); catch ; end
try set(handles.popupmenu_axes2_5,'string',ParamList); catch ; end
try set(handles.popupmenu_axes2_6,'string',ParamList); catch ; end
    
try set(handles.popupmenu3,'string',ParamList); catch ; end
try set(handles.popupmenu_axes3_2,'string',ParamList); catch ; end
try set(handles.popupmenu_axes3_3,'string',ParamList); catch ; end
try set(handles.popupmenu_axes3_4,'string',ParamList); catch ; end
try set(handles.popupmenu_axes3_5,'string',ParamList); catch ; end
try set(handles.popupmenu_axes3_6,'string',ParamList); catch ; end
        
try set(handles.popupmenu4,'string',ParamList); catch ; end
try set(handles.popupmenu_axes4_2,'string',ParamList); catch ; end
try set(handles.popupmenu_axes4_3,'string',ParamList); catch ; end
try set(handles.popupmenu_axes4_4,'string',ParamList); catch ; end
try set(handles.popupmenu_axes4_5,'string',ParamList); catch ; end
try set(handles.popupmenu_axes4_6,'string',ParamList); catch ; end
    
try set(handles.popupmenu5,'string',ParamList); catch ; end
try set(handles.popupmenu_axes5_2,'string',ParamList); catch ; end
try set(handles.popupmenu_axes5_3,'string',ParamList); catch ; end
try set(handles.popupmenu_axes5_4,'string',ParamList); catch ; end
try set(handles.popupmenu_axes5_5,'string',ParamList); catch ; end
try set(handles.popupmenu_axes5_6,'string',ParamList); catch ; end
   
guidata(hObject,handles);
end

