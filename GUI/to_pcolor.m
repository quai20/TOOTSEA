function varargout = to_pcolor(varargin)
%
% TO_PCOLOR MATLAB code for to_pcolor.fig
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2018
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_pcolor_OpeningFcn, ...
                   'gui_OutputFcn',  @to_pcolor_OutputFcn, ...
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

% --- Executes just before to_stickplot is made visible.
function to_pcolor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to to_stickplot (see VARARGIN)

% Choose default command line output for to_stickplot
handles.output = hObject;
%GET INPUT PARAMETERS
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
UsDat.MDim = varargin{1}.MDim_in;
%SAVE IN FIGURE
set(handles.figure1,'UserData',UsDat);
%GUI STUFF
set(handles.popupmenu1,'String',UsDat.ParamList);
set(handles.popupmenu1,'Value',1);
%INIT CHECK
if(size(UsDat.PARAMETERS(1).Data,1)==1)
    gp=warndlg('Single Level data, no pcolor needed');
    return;
end
%INIT PLOT
pstep=str2num(get(handles.edit1,'String'));
ind=1:pstep:length(UsDat.PARAMETERS(1).Time);

%aa=find(strcmp(UsDat.ParamList,'DEPTH'));
%bb=find(strcmp(UsDat.ParamList,'PRES'));
%cc=find(strcmp(UsDat.ParamList,'PRES_REL'));

%if(aa & size(UsDat.PARAMETERS(aa).Data(:,ind))==size(UsDat.PARAMETERS(1).Data(:,ind)))
%    pcolor(handles.axes1,UsDat.PARAMETERS(1).Time(ind),UsDat.PARAMETERS(aa).Data(:,ind),UsDat.PARAMETERS(1).Data(:,ind));
%    ylabel(handles.axes1,UsDat.ParamList{aa});
%elseif(bb & size(UsDat.PARAMETERS(bb).Data(:,ind))==size(UsDat.PARAMETERS(1).Data(:,ind)))
%    pcolor(handles.axes1,UsDat.PARAMETERS(1).Time(ind),UsDat.PARAMETERS(bb).Data(:,ind),UsDat.PARAMETERS(1).Data(:,ind));
%    ylabel(handles.axes1,UsDat.ParamList{bb});
%elseif(cc & size(UsDat.PARAMETERS(cc).Data(:,ind))==size(UsDat.PARAMETERS(1).Data(:,ind)))
%    pcolor(handles.axes1,UsDat.PARAMETERS(1).Time(ind),UsDat.PARAMETERS(cc).Data(:,ind),UsDat.PARAMETERS(1).Data(:,ind));
%    ylabel(handles.axes1,UsDat.ParamList{cc});
if(size(UsDat.PARAMETERS(1).Data,1)==size(UsDat.PARAMETERS(1).Depth,1)) 
    %Nanify bad data 
    ind_qc = (UsDat.PARAMETERS(1).QC_Serie(:,ind) > 3);
    array_to_plot = UsDat.PARAMETERS(1).Data(:,ind);
    array_to_plot(ind_qc)=NaN;
    pcolor(handles.axes1,UsDat.PARAMETERS(1).Time(ind),double(UsDat.PARAMETERS(1).Depth'),array_to_plot);
    ylabel(handles.axes1,'Distance along beams (m)');        
else
    %Nanify bad data 
    ind_qc = (UsDat.PARAMETERS(1).QC_Serie(:,ind) > 3);
    array_to_plot = UsDat.PARAMETERS(1).Data(:,ind);
    array_to_plot(ind_qc)=NaN;
    pcolor(handles.axes1,UsDat.PARAMETERS(1).Time(ind),1:size(UsDat.PARAMETERS(1).Data,1),array_to_plot);
    ylabel(handles.axes1,'Levels');
end
shading(handles.axes1,'interp');
try
  dateNtick;
catch
  datetick;
end
hh=colorbar;

cmin=floor(min(min(array_to_plot))*10)/10;
cmax=ceil(max(max(array_to_plot))*10)/10;

set(handles.edit2,'String',num2str(cmin));
set(handles.edit3,'String',num2str(cmax));
set(handles.axes1,'CLim',[cmin cmax]);

set(get(hh,'label'),'string',[UsDat.ParamList{1} ' (' UsDat.PARAMETERS(1).Unit ')'],'interpreter','none');
cmap=cmocean('balance');
colormap(cmap);
aa=get(handles.axes1,'ylim');
set(handles.axes1,'ylim',[aa(1)-1 aa(2)+1]);
% Update handles structure
guidata(hObject, handles);
%

% --- Outputs from this function are returned to the command line.
function varargout = to_pcolor_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in popupmenu_p1.
function popupmenu1_Callback(hObject, eventdata, handles)
%GET INPUT DATA
UsDat=get(handles.figure1,'UserData');
%Get value
val=get(hObject,'Value');
%CHECK SIZE
if(size(UsDat.PARAMETERS(val).Data,1)==1)
    gp=warndlg('Single Level data, no pcolor needed');
    return;
end
%PLOT
pstep=str2num(get(handles.edit1,'String'));
ind=1:pstep:length(UsDat.PARAMETERS(val).Time);

%aa=find(strcmp(UsDat.ParamList,'DEPTH'));
%bb=find(strcmp(UsDat.ParamList,'PRES'));
%cc=find(strcmp(UsDat.ParamList,'PRES_REL'));

%if(aa & size(UsDat.PARAMETERS(aa).Data(:,ind))==size(UsDat.PARAMETERS(val).Data(:,ind)))
%    pcolor(handles.axes1,UsDat.PARAMETERS(1).Time(ind),UsDat.PARAMETERS(aa).Data(:,ind),UsDat.PARAMETERS(val).Data(:,ind));
%    ylabel(handles.axes1,UsDat.ParamList{aa});
%elseif(bb & size(UsDat.PARAMETERS(bb).Data(:,ind))==size(UsDat.PARAMETERS(val).Data(:,ind)))
%    pcolor(handles.axes1,UsDat.PARAMETERS(1).Time(ind),UsDat.PARAMETERS(bb).Data(:,ind),UsDat.PARAMETERS(val).Data(:,ind));
%    ylabel(handles.axes1,UsDat.ParamList{bb});
%elseif(cc & size(UsDat.PARAMETERS(cc).Data(:,ind))==size(UsDat.PARAMETERS(val).Data(:,ind)))
%    pcolor(handles.axes1,UsDat.PARAMETERS(1).Time(ind),UsDat.PARAMETERS(cc).Data(:,ind),UsDat.PARAMETERS(val).Data(:,ind));
%    ylabel(handles.axes1,UsDat.ParamList{cc});    
if(size(UsDat.PARAMETERS(val).Data,1)==size(UsDat.PARAMETERS(val).Depth,1))
    %Nanify bad data 
    ind_qc = (UsDat.PARAMETERS(val).QC_Serie(:,ind) > 3);
    toto = UsDat.PARAMETERS(val).Data(:,ind);
    toto(ind_qc)=NaN;
    pcolor(handles.axes1,double(UsDat.PARAMETERS(val).Time(ind)),double(UsDat.PARAMETERS(val).Depth'),toto);
    %pcolor(handles.axes1,double(UsDat.PARAMETERS(val).Time(ind)),double(UsDat.PARAMETERS(val).Depth'),UsDat.PARAMETERS(val).Data(:,ind));
    ylabel(handles.axes1,'Distance along beams (m)');    
else
    %Nanify bad data 
    ind_qc = (UsDat.PARAMETERS(val).QC_Serie(:,ind) > 3);
    toto = UsDat.PARAMETERS(val).Data(:,ind);
    toto(ind_qc)=NaN;
    pcolor(handles.axes1,UsDat.PARAMETERS(val).Time(ind),1:size(UsDat.PARAMETERS(val).Data,1),toto);
    ylabel(handles.axes1,'Levels');
end

if(get(handles.checkbox1,'Value'))
    set(handles.axes1,'Ydir','rev');
end
    
shading(handles.axes1,'interp');
try
  dateNtick;
catch
  datetick;
end
hh=colorbar;
set(get(hh,'label'),'string',[UsDat.ParamList{val} ' (' UsDat.PARAMETERS(val).Unit ')'],'interpreter','none');
cmap=cmocean('balance');
colormap(cmap);

cmin=floor(min(min(toto))*10)/10;
cmax=ceil(max(max(toto))*10)/10;

set(handles.edit2,'String',num2str(cmin));
set(handles.edit3,'String',num2str(cmax));
set(handles.axes1,'CLim',[cmin cmax]);

aa=get(handles.axes1,'ylim');
set(handles.axes1,'ylim',[aa(1)-1 aa(2)+1]);
% Update handles structure
guidata(hObject, handles);

function editlims_Callback(hObject, eventdata, handles)
%New limits for the colorbar
set(handles.axes1,'CLim',[str2num(get(handles.edit2,'String')) str2num(get(handles.edit3,'String'))]);
% Update handles structure
guidata(hObject, handles);

function checkbox1_Callback(hObject, eventdata, handles)
%
if(get(hObject,'Value'))
    set(handles.axes1,'Ydir','rev');
else
    set(handles.axes1,'Ydir','default');
end
% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
val=get(handles.popupmenu1,'Value');
defaultName=[strrep(UsDat.MDim.FileName,'.','-') '-pcol-' UsDat.ParamList{val1} '-' UsDat.ParamList{val2}];   
%SAVE FIGURE
[FileName,PathName] = uiputfile({'*.pdf';'*.eps';'*.png';'*.tiff';'*.jpeg';'*.bmp'},'Save as',defaultName);
if isequal(FileName,0) 
    return; 
end
export_fig(handles.uipanel1,[PathName FileName]);

%GUI FUNCTION
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
%uiresume(hObject);
delete(hObject);
