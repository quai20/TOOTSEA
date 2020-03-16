function varargout = to_tinterp(varargin)
%
% TINTERP MATLAB code for tinterp.fig
% Last Modified by GUIDE v2.5 27-Feb-2017 13:58:09
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_tinterp_OpeningFcn, ...
                   'gui_OutputFcn',  @to_tinterp_OutputFcn, ...
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

% --- Executes just before tinterp is made visible.
function to_tinterp_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for drift_cor
handles.output = hObject;
%GET INPUT DATA
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
UsDat.MDim = varargin{1}.MDim_in;
%TEMP ARRAY
UsDat.TimTemp = UsDat.PARAMETERS(1).Time;
UsDat.SerTemp = UsDat.PARAMETERS(1).Data;
UsDat.TLIM=[];
%SAVE IN FIGURE
set(handles.figure1,'UserData',UsDat);  
%DISPLAY
set(handles.popupmenu1,'String',UsDat.ParamList);
set(handles.popupmenu2,'String',num2str([1:size(UsDat.PARAMETERS(1).Data,1)]'));
plot(handles.axes1,UsDat.PARAMETERS(1).Time,UsDat.PARAMETERS(1).Data(1,:),'.','DisplayName',UsDat.PARAMETERS(1).Name);
hold(handles.axes1,'on'); grid(handles.axes1,'on'); set(handles.axes1,'Fontsize',8);
%dynamicDateTicks(handles.axes1);
dateNtick('x',20,'axes_handle',handles.axes1);  
ylabel([UsDat.ParamList{1} '(' UsDat.PARAMETERS(1).Unit ')']); 
%reverse axis
if(~isempty(strfind(UsDat.ParamList{1},'PRES')) || ~isempty(strfind(UsDat.ParamList{1},'DEPTH')) || ~isempty(strfind(UsDat.ParamList{1},'DEPH'))) 
    set(handles.axes1,'YDir','reverse');
else
    set(handles.axes1,'YDir','default');
end
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes drift_cor wait for user response (see UIRESUME)
 uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = to_tinterp_OutputFcn(hObject, eventdata, handles) 
%GET THE DATA AND OUTPUT IT
UsDat=get(hObject,'UserData');
varargout{1}.ParamList_out = UsDat.ParamList;
varargout{1}.PARAMETERS_out = UsDat.PARAMETERS;
varargout{1}.MDim_out = UsDat.MDim;
%CLEAR AND DELETE FIGURE
cla;
delete(hObject);

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETERS, hObject BEEING THE MENU
val1 = get(hObject,'Value'); 
%TEMP ARRAY
UsDat.TimTemp = UsDat.PARAMETERS(val1).Time;
UsDat.SerTemp = UsDat.PARAMETERS(val1).Data(1,:);
%
set(handles.popupmenu2,'String',num2str([1:size(UsDat.PARAMETERS(val1).Data,1)]'));
set(handles.popupmenu2,'Value',1);
%PLOT PARAMETER
cla(handles.axes1,'reset');
plot(handles.axes1,UsDat.PARAMETERS(val1).Time,UsDat.PARAMETERS(val1).Data(1,:),'.','DisplayName',UsDat.PARAMETERS(val1).Name);
hold(handles.axes1,'on'); grid(handles.axes1,'on'); set(handles.axes1,'Fontsize',8);
%dynamicDateTicks(handles.axes1);
dateNtick('x',20,'axes_handle',handles.axes1);  
ylabel([UsDat.ParamList{val1} '(' UsDat.PARAMETERS(val1).Unit ')']); 
%reverse axis
if(~isempty(strfind(UsDat.ParamList{val1},'PRES')) || ~isempty(strfind(UsDat.ParamList{val1},'DEPTH')) || ~isempty(strfind(UsDat.ParamList{val1},'DEPH'))) 
    set(handles.axes1,'YDir','reverse');
else
    set(handles.axes1,'YDir','default');
end
%SAVE
set(handles.figure1,'UserData',UsDat);
guidata(hObject,handles);

% --- Executes on selection change in popupmenu1.
function popupmenu2_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETERS, hObject BEEING THE MENU
val1 = get(handles.popupmenu1,'Value');
val2 = get(hObject,'Value'); 
%TEMP ARRAY
UsDat.TimTemp = UsDat.PARAMETERS(val1).Time;
UsDat.SerTemp = UsDat.PARAMETERS(val1).Data(val2,:);
%
%PLOT PARAMETER
cla(handles.axes1,'reset');
plot(handles.axes1,UsDat.PARAMETERS(val1).Time,UsDat.PARAMETERS(val1).Data(val2,:),'.','DisplayName',UsDat.PARAMETERS(val1).Name);
hold(handles.axes1,'on'); grid(handles.axes1,'on'); set(handles.axes1,'Fontsize',8);
%dynamicDateTicks(handles.axes1);
dateNtick('x',20,'axes_handle',handles.axes1);  
ylabel([UsDat.ParamList{val1} '(' UsDat.PARAMETERS(val1).Unit ')']); 
%reverse axis
if(~isempty(strfind(UsDat.ParamList{val1},'PRES')) || ~isempty(strfind(UsDat.ParamList{val1},'DEPTH')) || ~isempty(strfind(UsDat.ParamList{val1},'DEPH'))) 
    set(handles.axes1,'YDir','reverse');
else
    set(handles.axes1,'YDir','default');
end
%SAVE
set(handles.figure1,'UserData',UsDat);
guidata(hObject,handles);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETER
val1 = get(handles.popupmenu1,'Value');
val2 = get(handles.popupmenu2,'Value');
%DRAW RECTANGLE TO SELECT POINTS INSIDE
rec=getrect(handles.axes1);
pa1=rec(1); pa2=rec(1)+rec(3);
%
xq=pa1:UsDat.PARAMETERS(val1).dTi/(3600*24):pa2;
vq=interp1(UsDat.PARAMETERS(val1).Time(~isnan(UsDat.PARAMETERS(val1).Data(val2,:))),UsDat.PARAMETERS(val1).Data(val2,~isnan(UsDat.PARAMETERS(val1).Data(val2,:))),xq,'linear');
plot(handles.axes1,xq,vq,'g.')
%Add xq et vq to temp array if validated by user
[VA,Ind] = sort([UsDat.TimTemp(:)' xq]);
VB = [UsDat.SerTemp(:)' vq];
VB = VB(Ind);
UsDat.TimTemp = VA;
UsDat.SerTemp = VB;
%FOR QC AUTO A 8
UsDat.TLIM=[UsDat.TLIM;pa1 pa2];
%SAVE
set(handles.figure1,'UserData',UsDat);
guidata(hObject,handles);

% --- Executes on button press in pushbutton3.
function pushbutton4_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETER
val1 = get(handles.popupmenu1,'Value');
val2 = get(handles.popupmenu2,'Value');
%
xq=UsDat.PARAMETERS(val1).Time(1):UsDat.PARAMETERS(val1).dTi/(3600*24):UsDat.PARAMETERS(val1).Time(end);
vq=interp1(UsDat.PARAMETERS(val1).Time(~isnan(UsDat.PARAMETERS(val1).Data(val2,:))),UsDat.PARAMETERS(val1).Data(val2,~isnan(UsDat.PARAMETERS(val1).Data(val2,:))),xq,'linear');
plot(handles.axes1,xq,vq,'go')
%Add xq et vq to temp array if validated by user
UsDat.TimTemp = xq;
UsDat.SerTemp = vq;
%QC à 8
UsDat.TLIM=[UsDat.TimTemp(1) UsDat.TimTemp(end)];
%SAVE
set(handles.figure1,'UserData',UsDat);
guidata(hObject,handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
%THINKING
set(handles.figure1, 'pointer', 'watch');
drawnow;
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETER
val1 = get(handles.popupmenu1,'Value');
val2 = get(handles.popupmenu2,'Value');
%
%GET SUFFIX IN edit_suffix
NewParamName = [UsDat.ParamList{val1} get(handles.edit1,'String')];
%SERIE
%LData(1:size(UsDat.PARAMETERS(val1).Data,1),length(UsDat.TimTemp))=NaN;
%LData(val2,:)=UsDat.SerTemp;
eval([NewParamName,'= TimeSerie(''',NewParamName,''',UsDat.TimTemp,UsDat.SerTemp);']);     
UsDat.ParamList=[UsDat.ParamList;{NewParamName}];
eval(['UsDat.PARAMETERS=[UsDat.PARAMETERS ',NewParamName,'];']);
%Copy info
if(length(UsDat.PARAMETERS(val1).Depth)>=val2)
    UsDat.PARAMETERS(end).Depth=UsDat.PARAMETERS(val1).Depth(val2);
else
    UsDat.PARAMETERS(end).Depth=UsDat.PARAMETERS(val1).Depth;
end
UsDat.PARAMETERS(end).Unit=UsDat.PARAMETERS(val1).Unit;
UsDat.PARAMETERS(end).Long_name=UsDat.PARAMETERS(val1).Long_name;
UsDat.PARAMETERS(end).FillValue=UsDat.PARAMETERS(val1).FillValue;
UsDat.PARAMETERS(end).ValidMin=UsDat.PARAMETERS(val1).ValidMin;
UsDat.PARAMETERS(end).ValidMax=UsDat.PARAMETERS(val1).ValidMax;
%QC
QCTemp=UsDat.PARAMETERS(end).QC_Serie;
for i=1:size(UsDat.TLIM,1)
   %rg1=find(UsDat.TimTemp==UsDat.TLIM(i,1));
   [~, rg1]=min(abs(UsDat.TimTemp-UsDat.TLIM(i,1)));
   %rg2=find(UsDat.TimTemp==UsDat.TLIM(i,2));
   [~, rg2]=min(abs(UsDat.TimTemp-UsDat.TLIM(i,2)));
   QCTemp(rg1:rg2)=8;
end
UsDat.PARAMETERS(end).QC_Serie=QCTemp;
%SAVE DATA
set(handles.figure1,'UserData',UsDat);
guidata(hObject,handles);
%
%DONE
uiresume(handles.figure1);
set(handles.figure1, 'pointer', 'arrow');
drawnow;

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
