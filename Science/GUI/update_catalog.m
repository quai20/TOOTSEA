function handles = update_catalog(hObject, eventdata, handles, ParamList, PARAMETERS, MMetadata)
%
% Update some elements of the catalog figure
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%

%UPDATE TREE
%%%%%
if(isfield(handles,'myctree'))
    delete(handles.myctree.Root)
    handles=create_catalogtree(hObject, eventdata, handles, PARAMETERS);
else
    handles=create_catalogtree(hObject, eventdata, handles, PARAMETERS);
end

%METADATA
TDisp={};
for i=1:length(MMetadata.Properties)
TDisp{i}=['# ',MMetadata.Properties{i},' : ',MMetadata.Values{i}];
end
set(handles.edit2,'string',TDisp);

%UPDATE HANDLE   
guidata(hObject,handles);
end

