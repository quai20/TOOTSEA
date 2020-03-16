function varargout = to_merge(varargin)
%
% FISIONAR code for fusionar.fig
% Last Modified by GUIDE v2.5 18-May-2017 10:12:33
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_merge_OpeningFcn, ...
                   'gui_OutputFcn',  @to_merge_OutputFcn, ...
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

% --- Executes just before to_fusionar is made visible.
function to_merge_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for to_fusionar
handles.output = hObject;
%GET DATA
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
%INIT
UsDat.FusList = {};
UsDat.FusPARAM= [];
%SAVE
set(handles.figure1,'UserData',UsDat);  
%DISPLAY
for i=1:length(UsDat.ParamList)
   DispSt{i}=[UsDat.ParamList{i},' (',num2str(size(UsDat.PARAMETERS(i).Data,1)),')'];
end
set(handles.listbox1,'string',DispSt);
% Update handles structure
guidata(hObject, handles);
%wait
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = to_merge_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
%GET DATA AND OUTPUT
UsDat=get(handles.figure1,'UserData');
varargout{1}.ParamList_out = UsDat.ParamList;
varargout{1}.PARAMETERS_out = UsDat.PARAMETERS;
%DELETE FIGURE
delete(hObject);

% --- Executes on button press in pushbutton_add.
function pushbutton_add_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%ADD SELECTED PARAMETER TO END OF TEMP ARRAY (LIST & PARAM)
PSel=get(handles.listbox1,'Value');
%Some checkings ...
ind=find(strcmp(UsDat.FusList,UsDat.ParamList{PSel}));
if ind>0
    warndlg('Parameter already selected');
    return;
else
    UsDat.FusList=[UsDat.FusList ; UsDat.ParamList{PSel}];
    UsDat.FusPARAM=[UsDat.FusPARAM UsDat.PARAMETERS(PSel)]; 
end
% Display PARAM list
for i=1:length(UsDat.FusList)
   DispSt{i}=[UsDat.FusList{i},' (',num2str(size(UsDat.FusPARAM(i).Data,1)),')'];
end
set(handles.listbox2,'String',DispSt);
%Save
set(handles.figure1,'UserData',UsDat);  
% Update handles structure
guidata(hObject, handles);
%

% --- Executes on button press in pushbutton_rem.
function pushbutton_rem_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETER
PSel=get(handles.listbox2,'Value');
%REMOVE PARAMETER FROM STRUCT
shiftv=zeros([1 length(UsDat.FusList)]);    shiftv(PSel)=1;
shiftv=logical(shiftv);
UsDat.FusList(shiftv) = [] ; 
UsDat.FusPARAM(shiftv) = [] ; 

% Display PARAM list
set(handles.listbox2,'Value',1);
DispSt={};
for i=1:length(UsDat.FusList)
   DispSt{i}=[UsDat.FusList{i},' (',num2str(size(UsDat.FusPARAM(i).Data,1)),')'];
end
set(handles.listbox2,'String',DispSt);
%Save
set(handles.figure1,'UserData',UsDat);  
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton_up.
function pushbutton_up_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%UP THE SELECTED PARAMETER
PSel=get(handles.listbox2,'Value');
TempL=UsDat.FusList{PSel-1};
TempP=UsDat.FusPARAM(PSel-1);
UsDat.FusList{PSel-1}=UsDat.FusList{PSel};
UsDat.FusPARAM(PSel-1)=UsDat.FusPARAM(PSel);
UsDat.FusList{PSel}=TempL;
UsDat.FusPARAM(PSel)=TempP;
% Display PARAM list
set(handles.listbox2,'Value',1);
DispSt={};
for i=1:length(UsDat.FusList)
   DispSt{i}=[UsDat.FusList{i},' (',num2str(size(UsDat.FusPARAM(i).Data,1)),')'];
end
set(handles.listbox2,'String',DispSt);
%Save
set(handles.figure1,'UserData',UsDat);  
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton_down.
function pushbutton_down_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%UP THE SELECTED PARAMETER
PSel=get(handles.listbox2,'Value');
TempL=UsDat.FusList{PSel+1};
TempP=UsDat.FusPARAM(PSel+1);
UsDat.FusList{PSel+1}=UsDat.FusList{PSel};
UsDat.FusPARAM(PSel+1)=UsDat.FusPARAM(PSel);
UsDat.FusList{PSel}=TempL;
UsDat.FusPARAM(PSel)=TempP;
% Display PARAM list
set(handles.listbox2,'Value',1);
DispSt={};
for i=1:length(UsDat.FusList)
   DispSt{i}=[UsDat.FusList{i},' (',num2str(size(UsDat.FusPARAM(i).Data,1)),')'];
end
set(handles.listbox2,'String',DispSt);
%Save
set(handles.figure1,'UserData',UsDat);  
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%CHECK TIME
chz=[];
for i=1:length(UsDat.FusList)
    chz(i)=size(UsDat.FusPARAM(i).Data,2);
end
if(std(chz)~=0)
    warndlg('Selected parameters have different sizes');
    return;
end
%NEW DATA ARRAY
NewData=[];
NewTime=UsDat.FusPARAM(1).Time;
for i=1:length(UsDat.FusList)
    NewData(i,:)=UsDat.FusPARAM(i).Data;
end
%ASK FOR DEPTH
schoice = questdlg('Define Depth ?','','Yes','No','Yes');
switch schoice
    case 'Yes'
        InputVDim = inputdlg(['Enter ',length(UsDat.FusList),' space-separated depths :'],'New Vertical Dimension', [1 100]);
        InputVDim = str2num(InputVDim{:});
        if(issorted(InputVDim)==0)
            warndlg('Not ascending'); 
            return; 
        end
        %size
        if(length(InputVDim)~=length(UsDat.FusList))
            warndlg('Length of depth does not match number of parameters selected'); 
            return; 
        end        
    case 'No'
        InputVDim=[];
end
%NEW PARAM
NewParamName = get(handles.edit_name,'String');
eval([NewParamName,'= TimeSerie(''',NewParamName,''',NewTime,NewData);']);   
UsDat.ParamList=[UsDat.ParamList;{NewParamName}];
eval(['UsDat.PARAMETERS=[UsDat.PARAMETERS ',NewParamName,'];']);
%Copy info
UsDat.PARAMETERS(end).Depth=InputVDim;
UsDat.PARAMETERS(end).Unit=UsDat.FusPARAM(1).Unit;
UsDat.PARAMETERS(end).Long_name=UsDat.FusPARAM(1).Long_name;
UsDat.PARAMETERS(end).FillValue=UsDat.FusPARAM(1).FillValue;
UsDat.PARAMETERS(end).ValidMin=UsDat.FusPARAM(1).ValidMin;
UsDat.PARAMETERS(end).ValidMax=UsDat.FusPARAM(1).ValidMax;
%SAVE DATA
set(handles.figure1,'UserData',UsDat);  
guidata(hObject, handles);
% The GUI is still in UIWAIT, us UIRESUME
uiresume(handles.figure1);
%delete(handles.figure1);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
%delete(hObject);
uiresume(handles.figure1);
