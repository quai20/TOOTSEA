function varargout = to_subsample(varargin)
%
% SUBSERIE MATLAB code for subserie.fig
% Last Modified by GUIDE v2.5 06-Jan-2017 13:30:53
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_subsample_OpeningFcn, ...
                   'gui_OutputFcn',  @to_subsample_OutputFcn, ...
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

% --- Executes just before subserie is made visible.
function to_subsample_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% Choose default command line output for subserie
handles.output = hObject;
%GET INPUT PARAMETERS
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
UsDat.MDim = varargin{1}.MDim_in;
%SAVE IN FIGURE
set(handles.figure1,'UserData',UsDat);  
%SEARCh dT FOR SELECTED ARRAY
if(UsDat.PARAMETERS(1).dT ~= 0)
    set(handles.edit_cdt,'String',num2str(UsDat.PARAMETERS(1).dT));
else
    set(handles.edit_cdt,'String',['dT irregular (' num2str(UsDat.PARAMETERS(1).dTi) ')']);
end
%GUI STUFF
set(handles.edit_date,'String',datestr(UsDat.PARAMETERS(1).Time(1),'dd/mm/yyyy-HH:MM:SS'));
set(handles.popupmenu_param,'String',UsDat.ParamList);
set(handles.popupmenu_level,'String',num2str([1:size(UsDat.PARAMETERS(1).Data,1)]'));
set(handles.popupmenu_level,'Value',1);
%
plot(handles.axes1,UsDat.PARAMETERS(1).Time,UsDat.PARAMETERS(1).Data(1,:));
hold(handles.axes1,'on');
grid(handles.axes1,'on');
ylabel([UsDat.ParamList{1} '(' UsDat.PARAMETERS(1).Unit ')']); 
%dynamicDateTicks(handles.axes1);
dateNtick('x',20,'axes_handle',handles.axes1);  
%reverse axis
if(~isempty(strfind(UsDat.ParamList{1},'PRES')) || ~isempty(strfind(UsDat.ParamList{1},'DEPTH')) || ~isempty(strfind(UsDat.ParamList{1},'DEPH'))) 
    set(handles.axes1,'YDir','reverse');
else
    set(handles.axes1,'YDir','default');
end
%UPDATE HANDLE
guidata(hObject,handles);
% UIWAIT makes subserie wait for user response (see UIRESUME) INDISPENSABLE
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = to_subsample_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
%GET DATA AND SET OUTPUT
UsDat=get(hObject,'UserData');
varargout{1}.ParamList_out = UsDat.ParamList;
varargout{1}.PARAMETERS_out = UsDat.PARAMETERS;
varargout{1}.MDim_out = UsDat.MDim;
cla;
delete(hObject);

% --- Executes on selection change in popupmenu_param.
function popupmenu_param_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_param contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_param
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETER
val1 = get(hObject,'Value'); 
%SET POPUP LEVEL
set(handles.popupmenu_level,'String',num2str([1:size(UsDat.PARAMETERS(val1).Data,1)]'));
set(handles.popupmenu_level,'Value',1);
%SET DATE
set(handles.edit_date,'String',datestr(UsDat.PARAMETERS(val1).Time(1),'dd/mm/yyyy-HH:MM:SS'));
%PLOT PARAMETER
cla;
plot(handles.axes1,UsDat.PARAMETERS(val1).Time,UsDat.PARAMETERS(val1).Data(1,:));
hold(handles.axes1,'on');
grid(handles.axes1,'on');
ylabel([UsDat.ParamList{val1} '(' UsDat.PARAMETERS(val1).Unit ')']); 
%dynamicDateTicks(handles.axes1);
dateNtick('x',20,'axes_handle',handles.axes1);  
%reverse axis
if(~isempty(strfind(UsDat.ParamList{val1},'PRES')) || ~isempty(strfind(UsDat.ParamList{val1},'DEPTH')) || ~isempty(strfind(UsDat.ParamList{val1},'DEPH'))) 
    set(handles.axes1,'YDir','reverse');
else
    set(handles.axes1,'YDir','default');
end

% --- Executes on selection change in popupmenu_param.
function popupmenu_level_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETERS, hObject BEEING THE MENU
val1 = get(handles.popupmenu_param,'Value'); 
val2 = get(hObject,'Value'); 
%PLOT PARAMETER
cla;
plot(handles.axes1,UsDat.PARAMETERS(val1).Time,UsDat.PARAMETERS(val1).Data(val2,:));
hold(handles.axes1,'on');
grid(handles.axes1,'on');
ylabel([UsDat.ParamList{val1} '(' UsDat.PARAMETERS(val1).Unit ')']); 
%dynamicDateTicks(handles.axes1);
dateNtick('x',20,'axes_handle',handles.axes1);  
%reverse axis
if(~isempty(strfind(UsDat.ParamList{val1},'PRES')) || ~isempty(strfind(UsDat.ParamList{val1},'DEPTH')) || ~isempty(strfind(UsDat.ParamList{val1},'DEPH'))) 
    set(handles.axes1,'YDir','reverse');
else
    set(handles.axes1,'YDir','default');
end

% --- Executes on button press in pushbutton_eval.
function pushbutton_eval_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETERS
psel=get(handles.popupmenu_param,'Value');
lev=get(handles.popupmenu_level,'Value');
%GET NEW dT
ndt=str2num(get(handles.edit_dt,'String'));
%GET START DATE
start_date=get(handles.edit_date,'String');
%CHECK IF THERES A GOOD START DATE
if(regexp(start_date,'\d{2}/\d{2}/\d{4}-\d{2}:\d{2}:\d{2}'))
    realdate=datenum(start_date,'dd/mm/yyyy-HH:MM:SS');
    [~,tind1]=min(abs(UsDat.PARAMETERS(psel).Time-realdate));
else
    warndlg('Date Format incorrect, first time value used','First date');
    tind=1;
end
% CHECK METHOD
meth=[get(handles.radiobutton_m1,'Value') get(handles.radiobutton_m2,'Value')];
if(meth==[1 0]) % POINT
  TimeTemp=[UsDat.PARAMETERS(psel).Time(tind1):ndt/(24*3600):UsDat.PARAMETERS(psel).Time(end)];
  ValTemp=interp1(UsDat.PARAMETERS(psel).Time,UsDat.PARAMETERS(psel).Data(lev,:),TimeTemp,'nearest');
elseif(meth==[0 1]) % MEAN
  TimeTemp=[UsDat.PARAMETERS(psel).Time(tind1):ndt/(24*3600):UsDat.PARAMETERS(psel).Time(end)];
  %Retrieve indices from original time array
  IndTab=interp1(UsDat.PARAMETERS(psel).Time,1:length(UsDat.PARAMETERS(psel).Time),TimeTemp,'nearest');
  %Edge values
  ValTemp(1)=NaN;
  ValTemp(length(TimeTemp))=NaN;
  %Go for mean
  for i=2:length(TimeTemp)-1
     l1=IndTab(i-1);
     l2=IndTab(i+1);
     ValTemp(i)=mean(UsDat.PARAMETERS(psel).Data(lev,l1:l2));
  end
end
%PLOT
plot(handles.axes1,TimeTemp,ValTemp,'ro','markerfacecolor','r');

% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETERS
psel=get(handles.popupmenu_param,'Value');
lev = get(handles.popupmenu_level,'Value');
%GET NEW dT
ndt=str2num(get(handles.edit_dt,'String'));
%GET START DATE
start_date=get(handles.edit_date,'String');
%CHECK IF THERES A GOOD START DATE
if(regexp(start_date,'\d{2}/\d{2}/\d{4}-\d{2}:\d{2}:\d{2}'))
    realdate=datenum(start_date,'dd/mm/yyyy-HH:MM:SS');
    [~,tind1]=min(abs(UsDat.PARAMETERS(psel).Time-realdate));
elseif(strcmp(start_date,'dd/mm/yyyy-hh:mm:ss'))    
    tind1=1;
else
    warndlg('Date Format incorrect, first time value used','First date');
    tind=1;
end
% CHECK METHOD
meth=[get(handles.radiobutton_m1,'Value') get(handles.radiobutton_m2,'Value')];
if(meth==[1 0]) % POINT METHOD
  TimeTemp=[UsDat.PARAMETERS(psel).Time(tind1):ndt/(24*3600):UsDat.PARAMETERS(psel).Time(end)];
  %SINGLE OR MULTI ?
  if(min(size(UsDat.PARAMETERS(psel).Data))>1) %MULTILEVEL
    str = num2str([1:size(UsDat.PARAMETERS(psel).Data,1)]');
    [lsel,vok] = listdlg('PromptString',[UsDat.PARAMETERS(psel).Name 'Select level(s) to apply :'],...
                'SelectionMode','multi','ListString',str);  
    if(vok)
        TimeTemp=[UsDat.PARAMETERS(psel).Time(tind1):ndt/(24*3600):UsDat.PARAMETERS(psel).Time(end)];
        ValTemp=[];
        for i=1:length(lsel)
            ValTemp(i,:)=interp1(UsDat.PARAMETERS(psel).Time,UsDat.PARAMETERS(psel).Data(lsel(i),:),TimeTemp,'nearest');
        end
        if(~isempty(UsDat.PARAMETERS(psel).Depth))
            NDepth=UsDat.PARAMETERS(psel).Depth(lsel);
        else
            NDepth=UsDat.PARAMETERS(psel).Depth;
        end
    end
  else  %SINGLE LEVEL    
    ValTemp=interp1(UsDat.PARAMETERS(psel).Time,UsDat.PARAMETERS(psel).Data,TimeTemp,'nearest');  
    NDepth=UsDat.PARAMETERS(psel).Depth;
  end
%  
elseif(meth==[0 1]) % MEAN    
  TimeTemp=[UsDat.PARAMETERS(psel).Time(tind1):ndt/(24*3600):UsDat.PARAMETERS(psel).Time(end)];
  %Retrieve indices from original time array
  IndTab=interp1(UsDat.PARAMETERS(psel).Time,1:length(UsDat.PARAMETERS(psel).Time),TimeTemp,'nearest');
  %Edge values
  ValTemp(1)=NaN;
  ValTemp(length(TimeTemp))=NaN;
  %Go for mean
  %SINGLE OR MULTI ?
  if(min(size(UsDat.PARAMETERS(psel).Data))>1) %MULTILEVEL  
    str = num2str([1:size(UsDat.PARAMETERS(psel).Data,1)]');
    [lsel,vok] = listdlg('PromptString',[UsDat.PARAMETERS(psel).Name 'Select level(s) to apply :'],...
                'SelectionMode','multi','ListString',str);  
    if(vok)
        ValTemp=[];
        for i=2:length(TimeTemp)-1
            l1=IndTab(i-1);
            l2=IndTab(i+1); 
            for j=1:length(lsel)
                ValTemp(j,i)=mean(UsDat.PARAMETERS(psel).Data(lsel(j),l1:l2));
            end
        end
        if(~isempty(UsDat.PARAMETERS(psel).Depth))
            NDepth=UsDat.PARAMETERS(psel).Depth(lsel);
        else
            NDepth=UsDat.PARAMETERS(psel).Depth;
        end
    end
  else  %SINGLE LEVEL
    for i=2:length(TimeTemp)-1
            l1=IndTab(i-1);
            l2=IndTab(i+1); 
            ValTemp(i)=mean(UsDat.PARAMETERS(psel).Data(l1:l2));              
    end      
    NDepth=UsDat.PARAMETERS(psel).Depth;
  end
end
%NEW PARAM
NewParamName = [UsDat.ParamList{psel} get(handles.edit_suffix,'String')];
eval([NewParamName,'= TimeSerie(''',NewParamName,''',TimeTemp,ValTemp);']);   
UsDat.ParamList=[UsDat.ParamList;{NewParamName}];
eval(['UsDat.PARAMETERS=[UsDat.PARAMETERS ',NewParamName,'];']);
%Copy info
UsDat.PARAMETERS(end).Depth=NDepth;
UsDat.PARAMETERS(end).Unit=UsDat.PARAMETERS(psel).Unit;
UsDat.PARAMETERS(end).Long_name=UsDat.PARAMETERS(psel).Long_name;
UsDat.PARAMETERS(end).FillValue=UsDat.PARAMETERS(psel).FillValue;
UsDat.PARAMETERS(end).ValidMin=UsDat.PARAMETERS(psel).ValidMin;
UsDat.PARAMETERS(end).ValidMax=UsDat.PARAMETERS(psel).ValidMax;
%SAVE DATA
set(handles.figure1,'UserData',UsDat);  
guidata(hObject, handles);
% The GUI is still in UIWAIT, us UIRESUME
uiresume(handles.figure1);
%delete(handles.figure1);

%GUI FUNCTIONS
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
%delete(hObject);
uiresume(handles.figure1);


% --------------------------------------------------------------------
function uitoggletool8_ClickedCallback(hObject, eventdata, handles)
zoom;
% --------------------------------------------------------------------
function uitoggletool9_ClickedCallback(hObject, eventdata, handles)
zoom out;
% --------------------------------------------------------------------
function uitoggletool10_ClickedCallback(hObject, eventdata, handles)
pan;
