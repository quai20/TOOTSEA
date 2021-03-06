function varargout = to_qcdisp(varargin)
%
% QC_MANUAL MATLAB code for QC_Manual.fig
% Last Modified by GUIDE v2.5 08-Sep-2017 14:52:27
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_qcdisp_OpeningFcn, ...
                   'gui_OutputFcn',  @to_qcdisp_OutputFcn, ...
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

% --- Executes just before to_qcdisp is made visible.
function to_qcdisp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% Choose default command line output for dispersion
handles.output = hObject;
%GET INPUT PARAMETERS
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
UsDat.MDim = varargin{1}.MDim_in;
%
%cla(handles.axes1,'reset');
set(handles.popupmenu_param,'String',UsDat.ParamList,'Max',length(UsDat.ParamList));
set(handles.popupmenu_param,'Value',1);
set(handles.popupmenu_lev,'String',num2str([1:size(UsDat.PARAMETERS(1).Data,1)]'));
set(handles.popupmenu_lev,'Value',1);

%SAVE IN FIGURE
set(handles.figure1,'UserData',UsDat);  

clearax_Callback(handles.cha, eventdata, handles);

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = to_qcdisp_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

function clearax_Callback(hObject, eventdata, handles)
cla(handles.axes1); ylabel(handles.axes1,'');
set(handles.cha,'Value',1);
checkall_Callback(handles.cha, eventdata, handles);

% --- Executes on button press in checkbox_all.
function checkall_Callback(hObject, eventdata, handles)
sv=get(hObject,'Value');
if(sv==1)
   set(handles.ch0,'Value',1); set(handles.ch1,'Value',1);
   set(handles.ch2,'Value',1); set(handles.ch3,'Value',1);
   set(handles.ch4,'Value',1); set(handles.ch5,'Value',1);
   set(handles.ch6,'Value',1); set(handles.ch7,'Value',1);
   set(handles.ch8,'Value',1); set(handles.ch9,'Value',1);
   checkbox_Callback(hObject, eventdata, handles);
else
   set(handles.ch0,'Value',0); set(handles.ch1,'Value',0);
   set(handles.ch2,'Value',0); set(handles.ch3,'Value',0);
   set(handles.ch4,'Value',0); set(handles.ch5,'Value',0);
   set(handles.ch6,'Value',0); set(handles.ch7,'Value',0);
   set(handles.ch8,'Value',0); set(handles.ch9,'Value',0); 
   checkbox_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in checkbox.
function checkbox_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of checkbox_a
%GET DATA
UsDat=get(handles.figure1,'UserData');
p1=get(handles.popupmenu_param,'Value');
l1=get(handles.popupmenu_lev,'Value');
%
set(handles.popupmenu_lev,'String',num2str([1:size(UsDat.PARAMETERS(p1).Data,1)]'))
if(l1>size(UsDat.PARAMETERS(p1).Data,1))
	l1=size(UsDat.PARAMETERS(p1).Data,1);
	set(handles.popupmenu_lev,'Value',size(UsDat.PARAMETERS(p1).Data,1));
end
%
%GET CHK STATE
cstate=[get(handles.ch0,'Value'),get(handles.ch1,'Value'),get(handles.ch2,'Value'),get(handles.ch3,'Value'),...
        get(handles.ch4,'Value'),get(handles.ch5,'Value'),get(handles.ch6,'Value'),get(handles.ch7,'Value'),...
        get(handles.ch8,'Value'),get(handles.ch9,'Value')];
%HANDLING THE "ALL"    
if(sum(cstate)~=10) 
    set(handles.cha,'Value',0);
else
    set(handles.cha,'Value',1);
end
%PRINT EXISTING QC ARRAY FOR THIS PARAMETER
tcolors=[0 0 1 ; 0 1 0 ; 0.95 0.5 0 ; 1 1 0 ; ...
        1 0 0 ; 0.75 0.0 0.79 ; 0.6 0.2 0 ; ... 
        0.1 0.4 0 ; 0.55 0.85 0.91 ; 0.49 0.49 0.49];
cla(handles.axes1,'reset');
for j=0:9
  if(cstate(j+1)==1)
    plot(handles.axes1,UsDat.PARAMETERS(p1).Time(UsDat.PARAMETERS(p1).QC_Serie(l1,:)==j),...
      UsDat.PARAMETERS(p1).Data(l1,UsDat.PARAMETERS(p1).QC_Serie(l1,:)==j),'.','Color',tcolors(j+1,:));
    hold(handles.axes1,'on');  grid(handles.axes1,'on');  
    if(~isempty(UsDat.PARAMETERS(p1).Time(UsDat.PARAMETERS(p1).QC_Serie(l1,:)==j)))
      dateNtick('x',20,'axes_handle',handles.axes1);  
    end
  
  end
end
ylabel([UsDat.ParamList{p1} '(' UsDat.PARAMETERS(p1).Unit ')']); 
%reverse axis
if(~isempty(strfind(UsDat.ParamList{p1},'PRES')) || ~isempty(strfind(UsDat.ParamList{p1},'DEPTH')) || ~isempty(strfind(UsDat.ParamList{p1},'DEPH'))) 
    set(handles.axes1,'YDir','reverse');
else
    set(handles.axes1,'YDir','default');
end


%GUI STUFF
% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
p1=get(handles.popupmenu_param,'Value');
defaultName=[strrep(UsDat.MDim.FileName,'.','-') '-QC-' UsDat.ParamList{p1}];
%SAVE FIGURE
[FileName,PathName] = uiputfile({'*.pdf';'*.eps';'*.png';'*.tiff';'*.jpeg';'*.bmp'},'Save as',defaultName);
if isequal(FileName,0) 
    return; 
end
export_fig(handles.axes1,[PathName FileName]);
