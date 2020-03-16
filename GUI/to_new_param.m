function varargout = to_new_param(varargin)
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
                   'gui_OpeningFcn', @to_new_param_OpeningFcn, ...
                   'gui_OutputFcn',  @to_new_param_OutputFcn, ...
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
function to_new_param_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% Choose default command line output for new_param
handles.output = hObject;
%GET DATA
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
UsDat.MMetadata = varargin{1}.MMetadata_in;
%SAVE
set(handles.figure1,'UserData',UsDat);  
%DISPLAY
set(handles.listbox1,'string',UsDat.ParamList);
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes filter wait for user response (see UIRESUME)
 uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = to_new_param_OutputFcn(hObject, eventdata, handles) 
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
    %CREATE NEW SERIE
    eval([NewParamName,'= TimeSerie(''',NewParamName,''',NewParamTime,NewParamValue);']);        
    UsDat.ParamList=[UsDat.ParamList;{NewParamName}];
    eval(['UsDat.PARAMETERS=[UsDat.PARAMETERS ',NewParamName,'];']);   
    %SAVE NEW DEPTH
    UsDat.PARAMETERS(end).Depth=NewParamDepth;
    %SEARCH OCEANSITE PROPERTIES BY NAME ONLY
    OSP=load('OC_params.mat');
    oinn=find(strcmp(OSP.PARAM,UsDat.ParamList{end}));
    if(~isempty(oinn))
        UsDat.PARAMETERS(end).Unit=OSP.UNIT{(oinn)};
        UsDat.PARAMETERS(end).Long_name=OSP.LONGNAME{(oinn)};
        UsDat.PARAMETERS(end).FillValue=OSP.FILLVALUE(oinn);
        UsDat.PARAMETERS(end).ValidMin=OSP.MIN(oinn);
        UsDat.PARAMETERS(end).ValidMax=OSP.MAX(oinn);
    end
    %        
    %SAVE CALCULATION IN PARAM STRUCT    
    UsDat.PARAMETERS(end).calc=stred;
    %Display    
    set(handles.listbox1,'Value',1);    
    set(handles.listbox1,'string',UsDat.ParamList);
    set(handles.listbox1,'BackgroundColor','g');
    pause(0.5);
    set(handles.listbox1,'BackgroundColor','w');
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

%Examples
function pushbutton_depth_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
if(~isempty(find(strcmp(UsDat.MMetadata.Properties,'Latitude'),1)))
   this_latitude=UsDat.MMetadata.Values{find(strcmp(UsDat.MMetadata.Properties,'Latitude'),1)};
else
   this_latitude='Latitude';
end
A1='%Access parameter with its name (see list)';
A2='%Example : TEMP.Data';
A3='%Do not edit those variable names';
A4='NewParamName = ''DEPTH'';';
A5='NewParamTime = PRES_REL.Time;';
A6=['NewParamValue = -gsw_z_from_p(PRES_REL.Data,' this_latitude ');'];
A7='NewParamDepth = [];';        
comm={A1,A2,'',A3,A4,A5,A6,A7}';
set(handles.edit_command,'String',comm);        

function pushbutton_psal_Callback(hObject, eventdata, handles)
A1='%Access parameter with its name (see list)';
A2='%Example : TEMP.Data';
A3='%Do not edit those variable names';
A4='NewParamName = ''PSAL'';';
A5='NewParamTime = TEMP.Time;';
A6='NewParamValue = gsw_SP_from_C(10.*CNDC.Data,TEMP.Data,PRES_REL.Data);';
A7='NewParamDepth = [];';
comm={A1,A2,'',A3,A4,A5,A6,A7}';        
set(handles.edit_command,'String',comm);

function pushbutton_cspd_Callback(hObject, eventdata, handles)
A1='%Access parameter with its name (see list)';
A2='%Example : TEMP.Data';
A3='%Do not edit those variable names';
A4='NewParamName = ''CSPD'';';
A5='NewParamTime = UCUR.Time;';
A6='NewParamValue = sqrt(UCUR.Data.^2 + VCUR.Data.^2);';
A7='NewParamDepth = UCUR.Depth;';
comm={A1,A2,'',A3,A4,A5,A6,A7}';        
set(handles.edit_command,'String',comm);    

function pushbutton_cdir_Callback(hObject, eventdata, handles)
A1='%Access parameter with its name (see list)';
A2='%Example : TEMP.Data';
A3='%Do not edit those variable names';
A4='NewParamName = ''CDIR'';';
A5='NewParamTime = UCUR.Time;';
A6='NewParamValue = mod(atan2d(UCUR.Data,VCUR.Data),360);';
A7='NewParamDepth = UCUR.Depth;';
comm={A1,A2,'',A3,A4,A5,A6,A7}';        
set(handles.edit_command,'String',comm);     

function pushbutton_other_Callback(hObject, eventdata, handles)
A1='%Access parameter with its name (see list)';
A2='%Example : TEMP.Data';
A3='%Do not edit those variable names';
A4='NewParamName = ''TempName'';';
A5='NewParamTime = []; %TEMP.Time for example';
A6='NewParamValue = []; %TEMP.Data.^2 for example';
A7='NewParamDepth = [];';        
comm={A1,A2,'',A3,A4,A5,A6,A7}';
set(handles.edit_command,'String',comm);

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



