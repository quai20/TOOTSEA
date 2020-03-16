function handles = create_maintree(hObject, eventdata, handles, PARAMETERS)
import uiextras.jTree.*
mposit=get(handles.uipanel1,'Position');
handles.mytree = Tree('Parent',handles.figure1);
set(handles.mytree,'Units','normalized','Position',mposit);
handles.mytree.RootVisible = false;
for i=1:length(PARAMETERS)
   %Node = TreeNode('Name',PARAMETERS(i).Name,'Parent',mytree.Root); 
   eval(['Node_' num2str(i) ' = TreeNode(''Name'',PARAMETERS(i).Name,''Parent'',handles.mytree.Root); ']);
   lsfie=fieldnames(PARAMETERS(i));
   for j=1:length(lsfie)
     alh=getfield(PARAMETERS(i),lsfie{j});          
     if iscell(alh) %Pour les formules des parametres calculés
       %Unode = TreeNode('Name',[lsfie{j} ' : ' 1],'Parent',Node); 
       eval(['Unode_' num2str(i) '_' num2str(j) ' = TreeNode(''Name'',[lsfie{j} '' : 1''],''Parent'',Node_' num2str(i) '); ']);         
     elseif ~isnumeric(alh) || isempty(alh) 
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