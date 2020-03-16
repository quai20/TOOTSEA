function varargout = to_global_stats(varargin)
%
% GLOBAL_STATS MATLAB code for global_stats.fig
% Last Modified by GUIDE v2.5 13-Feb-2017 16:03:49
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_global_stats_OpeningFcn, ...
                   'gui_OutputFcn',  @to_global_stats_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before global_stats is made visible.
function to_global_stats_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for global_stats
handles.output = hObject;
%GET INPUT DATA
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
UsDat.MDim = varargin{1}.MDim_in;
%SAVE IN FIGURE
set(handles.figure1,'UserData',UsDat);  
% Update handles structure
guidata(hObject, handles);
% Display
set(handles.listbox1,'String',UsDat.ParamList);

% --- Outputs from this function are returned to the command line.
function varargout = to_global_stats_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton_stat.
function pushbutton_stat_Callback(hObject, eventdata, handles)
%POINTER THINKING
set(findall(0,'Type','figure'), 'pointer', 'watch'); drawnow;
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETERS
PSel=get(handles.listbox1,'Value');
%GET OPTIONS
r1=get(handles.radiobutton1,'Value');
r2=get(handles.radiobutton2,'Value');
r3=get(handles.radiobutton3,'Value');
%
UsDat.OSTP={};
%WRITE PARAMETERS STATS
k=1;
for i=1:length(PSel)
    for lev=1:size(UsDat.PARAMETERS(PSel(i)).Data,1)
      %  
      if(size(UsDat.PARAMETERS(PSel(i)).Data,1)==1)
        UsDat.OSTP{1,k} = UsDat.ParamList{PSel(i)};
      else
        UsDat.OSTP{1,k} = [UsDat.ParamList{PSel(i)} ' Lv' num2str(lev)];
      end
      UsDat.OSTP{2,k} = UsDat.PARAMETERS(PSel(i)).Unit;
      UsDat.OSTP{3,k} = num2str(UsDat.PARAMETERS(PSel(i)).dT);
      UsDat.OSTP{4,k} = num2str(UsDat.PARAMETERS(PSel(i)).dTi);
      %             
      %Array for calculations             
      indq=(~isnan(UsDat.PARAMETERS(PSel(i)).Data(lev,:)));
      if(r1==1)
        ind=(~isnan(UsDat.PARAMETERS(PSel(i)).Data(lev,:)));
        Arr2sty = UsDat.PARAMETERS(PSel(i)).Data(lev,ind);
        Tir2sty = UsDat.PARAMETERS(PSel(i)).Time(ind);
        QC2sty= UsDat.PARAMETERS(PSel(i)).QC_Serie(lev,indq);
      elseif(r2==1)
        if(max(UsDat.PARAMETERS(PSel(i)).QC_Serie(lev,:))==0)
            rg_pr=find(strcmp(UsDat.ParamList,'PRES_REL'));
            ind=ismember(UsDat.PARAMETERS(rg_pr).QC_Serie(lev,:),[1,2,3]);
        else
            ind=ismember(UsDat.PARAMETERS(PSel(i)).QC_Serie(lev,:),[1,2,3]);
        end
        Arr2sty= UsDat.PARAMETERS(PSel(i)).Data(lev,ind);
        Tir2sty= UsDat.PARAMETERS(PSel(i)).Time(ind);
        QC2sty= UsDat.PARAMETERS(PSel(i)).QC_Serie(lev,indq);
        
        
      else
        ind=ismember(UsDat.PARAMETERS(PSel(i)).QC_Serie(lev,:),[4]);
        Arr2sty= UsDat.PARAMETERS(PSel(i)).Data(lev,ind);
        Tir2sty= UsDat.PARAMETERS(PSel(i)).Time(ind);
        QC2sty= UsDat.PARAMETERS(PSel(i)).QC_Serie(lev,indq);
      end      
      %Generate stats      
      UsDat.OSTP{5,k} = datestr(min(Tir2sty));
      UsDat.OSTP{6,k} = datestr(max(Tir2sty));
      UsDat.OSTP{7,k} = num2str(min(Arr2sty));
      UsDat.OSTP{8,k} = num2str(max(Arr2sty));
      UsDat.OSTP{9,k} = num2str(length(Arr2sty));      
      UsDat.OSTP{10,k} = num2str(mean(Arr2sty));
      UsDat.OSTP{11,k} = num2str(median(Arr2sty));
      UsDat.OSTP{12,k} = num2str(mode(Arr2sty));
      UsDat.OSTP{13,k} = num2str(std(Arr2sty));
      UsDat.OSTP{14,k} = num2str(var(Arr2sty));   
      UsDat.OSTP{15,k} = num2str(skewnessm(Arr2sty));
      UsDat.OSTP{16,k} = num2str(length(UsDat.PARAMETERS(PSel(i)).Data(lev,~isnan(UsDat.PARAMETERS(PSel(i)).Data(lev,:))))*100/length(UsDat.PARAMETERS(PSel(i)).Time));               
      UsDat.OSTP{17,k} = num2str(length(QC2sty(ismember(QC2sty,[1,2,3])))*100/length(QC2sty));                     
      UsDat.OSTP{18,k} = num2str(length(QC2sty(ismember(QC2sty,4)))*100/length(QC2sty));                     
      UsDat.OSTP{19,k} = num2str(length(QC2sty(ismember(QC2sty,0)))*100/length(QC2sty));       
      %    
      k=k+1;
    end
end

%Display
set(handles.uitable1,'RowName',{'Name','Unit','dT','mode(dT)','min date','max date','min','max',...
    'nb points','mean','median','mode','std','var','skewness','% return','% Good data','% Bad data','% No qc'});
%set(handles.edit1,'String',UsDat.OSTP);
set(handles.uitable1,'Data',UsDat.OSTP);
%SAVE IN FIGURE
set(handles.figure1,'UserData',UsDat);  
% Update handles structure
guidata(hObject, handles);
%POINTER THINKING STOP
set(findall(0,'Type','figure'), 'pointer', 'arrow'); drawnow;

function pushbutton_print_Callback(hObject, eventdata, handles)
%Sortie imprimable des stats
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET OUTPUT
defaultName=strrep(UsDat.MDim.FileName,'.','-');
[FileName,PathName] = uiputfile({'*.csv'},'Save as',defaultName);
if isequal(FileName,0) 
    return; 
end
UsDat.OSTP=[{'Name','Unit','dT','mode(dT)','min date','max date','min','max',...
    'nb points','mean','median','mode','std','var','skewness','Return','Good data','Bad data','No qc'}' UsDat.OSTP];
fid=fopen([PathName FileName],'w');
for i=1:size(UsDat.OSTP,1)
    for j=1:size(UsDat.OSTP,2)
        fprintf(fid,'%s;',UsDat.OSTP{i,j});
    end
    fprintf(fid,'\n');
end
fclose(fid);
delete(handles.figure1);

% --- Executes when user attempts to resize figure1.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
figPos=get(hObject,'Position');
tablePos=get(handles.uitable1,'Position');
NewPos=[tablePos(1) tablePos(2) figPos(3)-464 tablePos(4)];
set(handles.uitable1,'Position',NewPos);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
%uiresume(hObject);
delete(hObject);

