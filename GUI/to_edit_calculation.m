function varargout = to_edit_calculation(varargin)
%
% EDIT_PARAM MATLAB code for edit_param.fig
% Last Modified by GUIDE v2.5 11-Sep-2017 11:14:00
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_edit_calculation_OpeningFcn, ...
                   'gui_OutputFcn',  @to_edit_calculation_OutputFcn, ...
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

% --- Executes just before to_edit_calculation is made visible.
function to_edit_calculation_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for edit_param
handles.output = hObject;
%GET INPUT PARAMETERS
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
UsDat.rga = varargin{1}.rga_in;
%SAVE IT TO FIGURE
set(handles.figure1,'UserData',UsDat);  
%UPDATE HANDLE
guidata(hObject, handles);
%DISPLAY
set(handles.edit_command,'String',UsDat.PARAMETERS(UsDat.rga).calc);
% UIWAIT makes edit_param wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = to_edit_calculation_OutputFcn(hObject, eventdata, handles) 
%GET DATA TO OUTPUT
UsDat=get(hObject,'UserData');
varargout{1}.PARAMETERS_out = UsDat.PARAMETERS;
%DELETE FIGURE
delete(hObject);

% --- Executes on button press in pushbutton_eval.
function pushbutton_eval_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
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
    eval(ltev);
    %OVERWRITE NEW SERIE DATA    
    UsDat.ParamList{UsDat.rga}=NewParamName;
    UsDat.PARAMETERS(UsDat.rga).Name=NewParamName;
    UsDat.PARAMETERS(UsDat.rga).Time=NewParamTime;
    UsDat.PARAMETERS(UsDat.rga).Data=NewParamValue;        
    %SAVE CALCULATION IN PARAM STRUCT    
    UsDat.PARAMETERS(UsDat.rga).calc=stred;
    %Display        
    set(handles.edit_error,'BackgroundColor','g');
    pause(0.5);
    set(handles.edit_error,'BackgroundColor','w');
    set(handles.edit_error,'String','Error Log');
%IF ERROR, THROW MESSAGE IN MSGBOX    
catch ME
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
uiresume(handles.figure1);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
%delete(hObject);
uiresume(handles.figure1);
