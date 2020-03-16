function varargout = to_customQC(varargin)
%
% NEW_PARAM MATLAB code for new_param.fig
% Last Modified by GUIDE v2.5 23-Jan-2017 13:10:50
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_customQC_OpeningFcn, ...
                   'gui_OutputFcn',  @to_customQC_OutputFcn, ...
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

% --- Executes just before new_param is made visible.
function to_customQC_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% Choose default command line output for new_param
handles.output = hObject;
%GET DATA
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
%SAVE
set(handles.figure1,'UserData',UsDat);  
%DISPLAY
set(handles.listbox1,'string',UsDat.ParamList);
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes filter wait for user response (see UIRESUME)
 uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = to_customQC_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
%GET DATA AND OUTPUT
UsDat=get(hObject,'UserData');
varargout{1}.ParamList_out = UsDat.ParamList;
varargout{1}.PARAMETERS_out = UsDat.PARAMETERS;
%DELETE FIGURE
delete(hObject);

% --- Executes on button press in pushbutton_evaluate.
function pushbutton_evaluate_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
val=get(handles.listbox1,'Value');
PARAMETERS=UsDat.PARAMETERS;
%clear error log
set(handles.edit_error,'String','');
%ASSIGN VAR 
for i=1:length(PARAMETERS)
   eval([UsDat.ParamList{i},'= PARAMETERS(i);']); 
end
%GET TEXT TO RUN
stred=get(handles.edit_command,'String');
%EVAL OR DISPLAY ERROR
try
    ltev='';
    for i=1:length(stred)
    ltev=[ltev sprintf('\n') stred{i}];
    end
    set(findall(0,'Type','figure'), 'pointer', 'watch');    
    eval(ltev);
    set(findall(0,'Type','figure'), 'pointer', 'arrow');    
    %DEFINE QC        
    UsDat.PARAMETERS(val).QC_Serie = NewQCarray ;       
    %Display    
    set(handles.listbox1,'Value',1);    
    set(handles.listbox1,'string',UsDat.ParamList);
    set(handles.listbox1,'BackgroundColor','g');
    pause(0.5);
    set(handles.listbox1,'BackgroundColor','w');
%IF ERROR, THROW MESSAGE IN MSGBOX    
catch ME
    set(findall(0,'Type','figure'), 'pointer', 'arrow');  
    set(handles.edit_error,'String',ME.message);
    set(handles.edit_error,'Backgroundcolor','r');
    pause(0.5);
    set(handles.edit_error,'Backgroundcolor','w');
end
%SAVE DATA IN FIGURE
set(handles.figure1,'UserData',UsDat);  
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
%delete(hObject);
uiresume(handles.figure1);

