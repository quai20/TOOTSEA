function handles = create_catalogtree(hObject, eventdata, handles, PARAMETERS)
%
import uiextras.jTree.*
mposit=get(handles.uipanel_dat,'Position');
handles.myctree = Tree('Parent',handles.figure1);
set(handles.myctree,'Units','normalized','Position',mposit);
handles.myctree.RootVisible = false;
for i=1:length(PARAMETERS)
   %Node = TreeNode('Name',PARAMETERS(i).Name,'Parent',mytree.Root); 
   eval(['Node_' num2str(i) ' = TreeNode(''Name'',PARAMETERS(i).Name,''Parent'',handles.myctree.Root); ']);
   lsfie=fieldnames(PARAMETERS(i));
   for j=1:length(lsfie)
     alh=getfield(PARAMETERS(i),lsfie{j});
     if ~isnumeric(alh) || isempty(alh) 
       %Unode = TreeNode('Name',[lsfie{j} ' : ' alh],'Parent',Node); 
       eval(['Unode_' num2str(i) '_' num2str(j) ' = TreeNode(''Name'',[lsfie{j} '' : '' alh],''Parent'',Node_' num2str(i) '); ']);
     elseif length(alh)==1
       %Unode = TreeNode('Name',[lsfie{j} ' : ' num2str(alh)],'Parent',Node); 
       eval(['Unode_' num2str(i) '_' num2str(j) ' = TreeNode(''Name'',[lsfie{j} '' : '' num2str(alh)],''Parent'',Node_' num2str(i) '); ']);
     else      
       %Unode = TreeNode('Name',[lsfie{j} ' : [' num2str(size(alh,1)) 'x' num2str(size(alh,2)) ']'],'Parent',Node);  
       eval(['Unode_' num2str(i) '_' num2str(j) '= TreeNode(''Name'',[lsfie{j} '' : ['' num2str(size(alh,1)) ''x'' num2str(size(alh,2)) '']''],''Parent'',Node_' num2str(i) ');']);
     end
   end
end
guidata(hObject,handles);
end