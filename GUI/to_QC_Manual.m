function varargout = to_QC_Manual(varargin)
%
% QC_MANUAL MATLAB code for QC_Manual.fig
% Last Modified by GUIDE v2.5 17-Jan-2017 15:59:08
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_QC_Manual_OpeningFcn, ...
                   'gui_OutputFcn',  @to_QC_Manual_OutputFcn, ...
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


% --- Executes just before QC_Manual is made visible.
function to_QC_Manual_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% Choose default command line output for QC_Manual
handles.output = hObject;
%GET INPUT PARAMETERS
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
%GUI STUFF
set(handles.popupmenu_param,'String',UsDat.ParamList);
set(handles.popupmenu_param,'Value',1);
set(handles.popupmenu_lev,'String',num2str([1:size(UsDat.PARAMETERS(1).Data,1)]'));
set(handles.popupmenu_lev,'Value',1);
%
plot(handles.axes1,UsDat.PARAMETERS(1).Time,UsDat.PARAMETERS(1).Data(1,:),'.');
hold(handles.axes1,'on'); grid(handles.axes1,'on'); set(handles.axes1,'Fontsize',8);
%dynamicDateTicks(handles.axes1);
dateNtick('x',20,'axes_handle',handles.axes1);  
ylabel([UsDat.ParamList{1} '(' UsDat.PARAMETERS(1).Unit ')']); 
%
guidata(hObject,handles);
%PRINT EXISTING QC ARRAY FOR THIS PARAMETER
tcolors=[0 0 1 ; 0 1 0 ; 0.95 0.5 0 ; 1 1 0 ; ...
        1 0 0 ; 0.75 0.0 0.79 ; 0.6 0.2 0 ; ... 
        0.1 0.4 0 ; 0.55 0.85 0.91 ; 0.49 0.49 0.49];
for j=1:10    
  plot(handles.axes1,UsDat.PARAMETERS(1).Time(UsDat.PARAMETERS(1).QC_Serie(1,:)==j-1),UsDat.PARAMETERS(1).Data(1,UsDat.PARAMETERS(1).QC_Serie(1,:)==j-1),'.','Color',tcolors(j,:));
end  
%reverse axis
if(~isempty(strfind(UsDat.ParamList{1},'PRES')) || ~isempty(strfind(UsDat.ParamList{1},'DEPTH')) || ~isempty(strfind(UsDat.ParamList{1},'DEPH'))) 
    set(handles.axes1,'YDir','reverse');
else
    set(handles.axes1,'YDir','default');
end
%REINIT QC
UsDat.QCTemp = UsDat.PARAMETERS(1).QC_Serie(1,:);
%SAVE IN FIGURE USER DATA
set(handles.figure1,'UserData',UsDat);  
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes QC_Manual wait for user response (see UIRESUME)
 uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = to_QC_Manual_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
%GET DATA TO OUTPUT THE UIFUNCTION
UsDat=get(hObject,'UserData');
varargout{1}.PARAMETERS_out = UsDat.PARAMETERS;
cla;
delete(hObject);

% --- Executes on selection change in popupmenu_param.
function popupmenu_param_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_param contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_param
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETERS
val = get(hObject,'Value'); 
%
set(handles.popupmenu_lev,'String',num2str([1:size(UsDat.PARAMETERS(val).Data,1)]'));
set(handles.popupmenu_lev,'Value',1);
%DISPLAY SERIE
cla(handles.axes1);
plot(handles.axes1,UsDat.PARAMETERS(val).Time,UsDat.PARAMETERS(val).Data(1,:),'.');
hold(handles.axes1,'on'); grid(handles.axes1,'on'); set(handles.axes1,'Fontsize',8);
%dynamicDateTicks(handles.axes1);
dateNtick('x',20,'axes_handle',handles.axes1);  
ylabel([UsDat.ParamList{val} '(' UsDat.PARAMETERS(val).Unit ')']); 
%CHECK FOR EXISTING QC ARRAY FOR THIS PARAMETER
tcolors=[0 0 1 ; 0 1 0 ; 0.95 0.5 0 ; 1 1 0 ; ...
        1 0 0 ; 0.75 0.0 0.79 ; 0.6 0.2 0 ; ... 
        0.1 0.4 0 ; 0.55 0.85 0.91 ; 0.49 0.49 0.49];
for j=1:10    
  plot(handles.axes1,UsDat.PARAMETERS(val).Time(UsDat.PARAMETERS(val).QC_Serie(1,:)==j-1),UsDat.PARAMETERS(val).Data(1,UsDat.PARAMETERS(val).QC_Serie(1,:)==j-1),'.','Color',tcolors(j,:));
end
%reverse axis
if(~isempty(strfind(UsDat.ParamList{val},'PRES')) || ~isempty(strfind(UsDat.ParamList{val},'DEPTH')) || ~isempty(strfind(UsDat.ParamList{val},'DEPH'))) 
    set(handles.axes1,'YDir','reverse');
else
    set(handles.axes1,'YDir','default');
end
%REINIT QC
UsDat.QCTemp = UsDat.PARAMETERS(val).QC_Serie(1,:);
%SAVE
set(handles.figure1,'UserData',UsDat);
guidata(hObject,handles);

function popupmenu_lev_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_param contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_param
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETERS
val = get(handles.popupmenu_param,'Value'); 
lev = get(hObject,'Value'); 
%DISPLAY SERIE
cla(handles.axes1);
plot(handles.axes1,UsDat.PARAMETERS(val).Time,UsDat.PARAMETERS(val).Data(lev,:),'.');
hold(handles.axes1,'on'); grid(handles.axes1,'on'); set(handles.axes1,'Fontsize',8);
%dynamicDateTicks(handles.axes1);
dateNtick('x',20,'axes_handle',handles.axes1);  
ylabel([UsDat.ParamList{val} '(' UsDat.PARAMETERS(val).Unit ')']); 
%CHECK FOR EXISTING QC ARRAY FOR THIS PARAMETER
tcolors=[0 0 1 ; 0 1 0 ; 0.95 0.5 0 ; 1 1 0 ; ...
        1 0 0 ; 0.75 0.0 0.79 ; 0.6 0.2 0 ; ... 
        0.1 0.4 0 ; 0.55 0.85 0.91 ; 0.49 0.49 0.49];
for j=1:10    
  plot(handles.axes1,UsDat.PARAMETERS(val).Time(UsDat.PARAMETERS(val).QC_Serie(lev,:)==j-1),UsDat.PARAMETERS(val).Data(lev,UsDat.PARAMETERS(val).QC_Serie(lev,:)==j-1),'.','Color',tcolors(j,:));
end
%reverse axis
if(~isempty(strfind(UsDat.ParamList{val},'PRES')) || ~isempty(strfind(UsDat.ParamList{val},'DEPTH')) || ~isempty(strfind(UsDat.ParamList{val},'DEPH'))) 
    set(handles.axes1,'YDir','reverse');
else
    set(handles.axes1,'YDir','default');
end
%REINIT QC
UsDat.QCTemp = UsDat.PARAMETERS(val).QC_Serie(lev,:);
%SAVE
set(handles.figure1,'UserData',UsDat);
guidata(hObject,handles);


%%% QC BUTTONS %%%%
%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
define_qc(hObject, eventdata, handles, 1);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
define_qc(hObject, eventdata, handles, 2);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
define_qc(hObject, eventdata, handles, 3);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
define_qc(hObject, eventdata, handles, 4);

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
define_qc(hObject, eventdata, handles, 5);

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
define_qc(hObject, eventdata, handles, 6);

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
define_qc(hObject, eventdata, handles, 7);

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
define_qc(hObject, eventdata, handles, 8);

% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
define_qc(hObject, eventdata, handles, 9);

% --- Executes on button press in pushbutton00.
function pushbutton00_Callback(hObject, eventdata, handles)
define_qc(hObject, eventdata, handles, 00);

% SAVE NEW SERIE OF QC VALUES
% --- Executes on button press in pushbutton_apply.
function pushbutton_apply_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETER
rg=get(handles.popupmenu_param,'Value');
lev=get(handles.popupmenu_lev,'Value');
%SAVE NEW QC PARAMETER
UsDat.PARAMETERS(rg).QC_Serie(lev,:) = UsDat.QCTemp;
%FILL HISTORY
str=get(handles.edit1,'String');
set(handles.edit1,'String',[str;UsDat.PARAMETERS(rg).Name '_' num2str(lev)]);
%SAVE DATA
set(handles.figure1,'UserData',UsDat);
guidata(hObject,handles);

% --- Executes on button press in pushbutton_q.
function pushbutton_q_Callback(hObject, eventdata, handles)
%AIDE QC OCEANSITES
s=sprintf('0 : no qc performed \n1 : good data \n2 : probably good data \n3 : bad data that are potentially correctable \n4 : bad data \n5 : value changed \n6 : not used \n7 : nominal value \n8 : interpolated value \n9 : missing value');
msgbox(s,'OceanSites QC');

function define_qc(hObject, eventdata, handles, qc)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETER
rg=get(handles.popupmenu_param,'Value');
lev=get(handles.popupmenu_lev,'Value');
%DRAW RECTANGLE TO SELECT POINTS INSIDE
rec=getrect(handles.axes1);
xv=[rec(1) rec(1)+rec(3) rec(1)+rec(3) rec(1) rec(1)];
yv=[rec(2) rec(2) rec(2)+rec(4) rec(2)+rec(4) rec(2)];
in = inpolygon(UsDat.PARAMETERS(rg).Time,UsDat.PARAMETERS(rg).Data(lev,:),xv,yv);
%COLORE POINTS INSIDE RECTANGLE
coul=get(hObject,'BackgroundColor');
plot(UsDat.PARAMETERS(rg).Time(in),UsDat.PARAMETERS(rg).Data(lev,in),'.','Color',coul);
%SAVE TEMP QC VECTOR
UsDat.QCTemp(in)=qc;
set(handles.figure1,'UserData',UsDat);
%UPDATE HANDLE
guidata(hObject,handles);

%GUI FUNCTIONS
% --- Executes on button press in pushbutton_close.
function pushbutton_close_Callback(hObject, eventdata, handles)
uiresume(handles.figure1);
%delete(hObject);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
%delete(hObject);
uiresume(handles.figure1);


% --------------------------------------------------------------------
function uitoggletool4_ClickedCallback(hObject, eventdata, handles)
zoom;

% --------------------------------------------------------------------
function uipushtool2_ClickedCallback(hObject, eventdata, handles)
zoom out;

% --------------------------------------------------------------------
function uitoggletool5_ClickedCallback(hObject, eventdata, handles)
pan;
