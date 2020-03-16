function varargout = to_drift_tempo_cor(varargin)
%
% DRIFT_TEMPO_COR MATLAB code for drift_tempo_cor.fig
% Last Modified by GUIDE v2.5 03-Apr-2017 10:52:09
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_drift_tempo_cor_OpeningFcn, ...
                   'gui_OutputFcn',  @to_drift_tempo_cor_OutputFcn, ...
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


% --- Executes just before drift_cor is made visible.
function to_drift_tempo_cor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% Choose default command line output for drift_cor
handles.output = hObject;
%GET INPUT DATA
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
UsDat.MDim = varargin{1}.MDim_in;
%SAVE IN FIGURE
set(handles.figure1,'UserData',UsDat);
%LISTBOX INIT
set(handles.listbox_param,'String',UsDat.ParamList);
%FILL START/END INSTRUMENT
set(handles.edit_ins1,'String',datestr(UsDat.MDim.Time(1),'dd/mm/yyyy-HH:MM:SS'));
set(handles.edit_ins2,'String',datestr(UsDat.MDim.Time(end),'dd/mm/yyyy-HH:MM:SS'));
set(handles.edit_real1,'String',datestr(UsDat.MDim.Time(1),'dd/mm/yyyy-HH:MM:SS'));
set(handles.edit_real2,'String',datestr(UsDat.MDim.Time(end),'dd/mm/yyyy-HH:MM:SS'));
%PLOT TIME
plot(handles.axes1,1:length(UsDat.MDim.Time),UsDat.MDim.Time);    
hold(handles.axes1,'on'); grid(handles.axes1,'on');
%CHANGE TICKS
set(handles.axes1,'Xtickmode','auto');
drawnow;
%dynamicDateTicksY(handles.axes1);
dateNtick('y',20,'axes_handle',handles.axes1);  
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes drift_cor wait for user response (see UIRESUME)
 uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = to_drift_tempo_cor_OutputFcn(hObject, eventdata, handles) 
%GET THE DATA AND OUTPUT IT
UsDat=get(hObject,'UserData');
varargout{1}.ParamList_out = UsDat.ParamList;
varargout{1}.PARAMETERS_out = UsDat.PARAMETERS;
varargout{1}.MDim_out = UsDat.MDim;
%CLEAR AND DELETE FIGURE
cla;
delete(hObject);

% --- Executes on button press in pushbutton_eval.
function pushbutton_eval_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET DATES
dins1=get(handles.edit_ins1,'String'); 
dins2=get(handles.edit_ins2,'String'); 
dreal1=get(handles.edit_real1,'String'); 
dreal2=get(handles.edit_real2,'String');
%CALCULATION
co_a=datenum(dreal1,'dd/mm/yyyy-HH:MM:SS')-datenum(dins1,'dd/mm/yyyy-HH:MM:SS');
co_b1=(datenum(dreal2,'dd/mm/yyyy-HH:MM:SS')-datenum(dreal1,'dd/mm/yyyy-HH:MM:SS'))/(UsDat.MDim.Time(end)-UsDat.MDim.Time(1));
co_b2=(datenum(dins2,'dd/mm/yyyy-HH:MM:SS')-datenum(dins1,'dd/mm/yyyy-HH:MM:SS'))/(UsDat.MDim.Time(end)-UsDat.MDim.Time(1));
DriftT=co_a + (UsDat.MDim.Time-UsDat.MDim.Time(1)).*(co_b1-co_b2) + UsDat.MDim.Time;
plot(handles.axes1,1:length(UsDat.MDim.Time),DriftT);      

% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETERS
psel=get(handles.listbox_param,'Value');
%GET DATES
dins1=get(handles.edit_ins1,'String'); 
dins2=get(handles.edit_ins2,'String'); 
dreal1=get(handles.edit_real1,'String'); 
dreal2=get(handles.edit_real2,'String');
%CALCULATION
co_a=datenum(dreal1,'dd/mm/yyyy-HH:MM:SS')-datenum(dins1,'dd/mm/yyyy-HH:MM:SS');
co_b1=(datenum(dreal2,'dd/mm/yyyy-HH:MM:SS')-datenum(dreal1,'dd/mm/yyyy-HH:MM:SS'))/(UsDat.MDim.Time(end)-UsDat.MDim.Time(1));
co_b2=(datenum(dins2,'dd/mm/yyyy-HH:MM:SS')-datenum(dins1,'dd/mm/yyyy-HH:MM:SS'))/(UsDat.MDim.Time(end)-UsDat.MDim.Time(1));
%NEW PARAMETERS 
for i=1:length(psel)      
   NewParamName = [UsDat.ParamList{psel(i)} get(handles.edit_suffix,'String')];
   eval([NewParamName,'= TimeSerie(''',NewParamName,''',co_a + (UsDat.PARAMETERS(psel(i)).Time-UsDat.MDim.Time(1)).*(co_b1-co_b2) + UsDat.PARAMETERS(psel(i)).Time,UsDat.PARAMETERS(psel(i)).Data);']);       
   UsDat.ParamList=[UsDat.ParamList;{NewParamName}];
   eval(['UsDat.PARAMETERS=[UsDat.PARAMETERS ',NewParamName,'];']);
   %Copy info
    UsDat.PARAMETERS(end).Depth=UsDat.PARAMETERS(psel(i)).Depth;
    UsDat.PARAMETERS(end).Unit=UsDat.PARAMETERS(psel(i)).Unit;
    UsDat.PARAMETERS(end).Long_name=UsDat.PARAMETERS(psel(i)).Long_name;
    UsDat.PARAMETERS(end).FillValue=UsDat.PARAMETERS(psel(i)).FillValue;
    UsDat.PARAMETERS(end).ValidMin=UsDat.PARAMETERS(psel(i)).ValidMin;
    UsDat.PARAMETERS(end).ValidMax=UsDat.PARAMETERS(psel(i)).ValidMax;   
end
%Save
set(handles.figure1,'UserData',UsDat);  
%Update handle
guidata(hObject, handles);
%resume
uiresume(handles.figure1);

%GUI FUNCTIONS
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
%delete(hObject);
uiresume(handles.figure1);

% --------------------------------------------------------------------
function uitoggletool1_ClickedCallback(hObject, eventdata, handles)
zoom;

% --------------------------------------------------------------------
function uipushtool2_ClickedCallback(hObject, eventdata, handles)
zoom out;

% --------------------------------------------------------------------
function uitoggletool2_ClickedCallback(hObject, eventdata, handles)
pan;

function checkdate_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETERS
psel=get(handles.listbox_param,'Value');
%
inpdate=get(hObject,'String');
ck=regexp(inpdate,'\d\d/\d\d/\d\d\d\d-\d\d:\d\d:\d\d');
if(ck==1)
    if(datenum(inpdate,'dd/mm/yyyy-HH:MM:SS')>=UsDat.MDim.Time(1))
        set(hObject,'BackgroundColor','g');
    else
        set(hObject,'BackgroundColor','r');
    end
else
    set(hObject,'BackgroundColor','r');
end
