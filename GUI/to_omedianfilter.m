function varargout = to_omedianfilter(varargin)
%
% OMEDIANFILTER MATLAB code for omedianfilter.fig
% Last Modified by GUIDE v2.5 24-Feb-2017 13:41:05
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_omedianfilter_OpeningFcn, ...
                   'gui_OutputFcn',  @to_omedianfilter_OutputFcn, ...
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

% --- Executes just before omedianfilter is made visible.
function to_omedianfilter_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for omedianfilter
handles.output = hObject;
%GET INPUT DATA
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
%SAVE IN FIGURE
set(handles.figure1,'UserData',UsDat);  
% Update handles structure
guidata(hObject, handles);
%DISPLAY
set(handles.popupmenu_param,'String',UsDat.ParamList);
set(handles.popupmenu_level,'String',num2str([1:size(UsDat.PARAMETERS(1).Data,1)]'));
set(handles.popupmenu_level,'Value',1);
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
% UIWAIT makes drift_cor wait for user response (see UIRESUME)
 uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = to_omedianfilter_OutputFcn(hObject, eventdata, handles) 
%GET THE DATA AND OUTPUT IT
UsDat=get(hObject,'UserData');
varargout{1}.ParamList_out = UsDat.ParamList;
varargout{1}.PARAMETERS_out = UsDat.PARAMETERS;
%CLEAR AND DELETE FIGURE
cla;
delete(hObject);

% --- Executes on selection change in popupmenu_param.
function popupmenu_param_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETERS, hObject BEEING THE MENU
val1 = get(hObject,'Value'); 
%SET POPUP LEVEL
set(handles.popupmenu_level,'String',num2str([1:size(UsDat.PARAMETERS(val1).Data,1)]'));
set(handles.popupmenu_level,'Value',1);
cla(handles.axes1,'reset');
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
%GET SELECTED PARAMETER
val1 = get(handles.popupmenu_param,'Value');
val2 = get(handles.popupmenu_level,'Value');
%MEDIAN FILTER
fwl=str2num(get(handles.edit_wl,'String'));
if(license('test','signal_toolbox'))
    yy2 = medfilt1(double(UsDat.PARAMETERS(val1).Data(val2,:)),fwl);
else
    yy2 = medfilt1_perso(double(UsDat.PARAMETERS(val1).Data(val2,:)),fwl);    
end
yy2(1) = UsDat.PARAMETERS(val1).Data(val2,1);
%PLOT FILTERED SERIE
plot(handles.axes1,UsDat.PARAMETERS(val1).Time,yy2,'.');    
%dynamicDateTicks(handles.axes1);
dateNtick('x',20,'axes_handle',handles.axes1);  

% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
%THINKING
set(handles.figure1, 'pointer', 'watch');
drawnow;
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETER
val1 = get(handles.popupmenu_param,'Value');
val2 = get(handles.popupmenu_level,'Value');
%GET WINDOW SIZE
fwl=str2num(get(handles.edit_wl,'String'));
%GET SUFFIX IN edit_suffix
NewParamName = [UsDat.ParamList{val1} get(handles.edit_suffix,'String')];
%SINGLE OR MULTI ?
if(min(size(UsDat.PARAMETERS(val1).Data))>1) %MULTILEVEL
    %LEVELS SELECTION
    str = num2str([1:size(UsDat.PARAMETERS(val1).Data,1)]');
    [sel,vok] = listdlg('PromptString',[UsDat.PARAMETERS(val1).Name 'Select level(s) to apply :'],...
                'SelectionMode','multi','ListString',str);
     if(vok)
        for i=1:length(sel) 
        %FILTER
        if(license('test','signal_toolbox'))
            yy2 = medfilt1(double(UsDat.PARAMETERS(val1).Data(sel(i),:)),fwl);
        else
            yy2 = medfilt1_perso(double(UsDat.PARAMETERS(val1).Data(sel(i),:)),fwl);
        end
        yy2(1) = UsDat.PARAMETERS(val1).Data(sel(i),1);
        LData(i,:)=yy2;
        end      
        %SERIE
        eval([NewParamName,'= TimeSerie(''',NewParamName,''',UsDat.PARAMETERS(val1).Time,LData);']);     
        UsDat.ParamList=[UsDat.ParamList;{NewParamName}];
        eval(['UsDat.PARAMETERS=[UsDat.PARAMETERS ',NewParamName,'];']);
        if(~isempty(UsDat.PARAMETERS(val1).Depth))
        UsDat.PARAMETERS(end).Depth=UsDat.PARAMETERS(val1).Depth(sel);   
        else
        UsDat.PARAMETERS(end).Depth=UsDat.PARAMETERS(val1).Depth;       
        end
     end                      
else %SINGLE LEVEL
    %FILTER
    if(license('test','signal_toolbox'))
        yy2 = medfilt1(double(UsDat.PARAMETERS(val1).Data),fwl);
    else
        yy2 = medfilt1_perso(double(UsDat.PARAMETERS(val1).Data),fwl);
    end
    yy2(1) = UsDat.PARAMETERS(val1).Data(1);    
    %SERIE
    eval([NewParamName,'= TimeSerie(''',NewParamName,''',UsDat.PARAMETERS(val1).Time,yy2);']);     
    UsDat.ParamList=[UsDat.ParamList;{NewParamName}];
    eval(['UsDat.PARAMETERS=[UsDat.PARAMETERS ',NewParamName,'];']);
    UsDat.PARAMETERS(end).Depth=UsDat.PARAMETERS(val1).Depth;        
end
%Copy info
UsDat.PARAMETERS(end).Unit=UsDat.PARAMETERS(val1).Unit;
UsDat.PARAMETERS(end).Long_name=UsDat.PARAMETERS(val1).Long_name;
UsDat.PARAMETERS(end).FillValue=UsDat.PARAMETERS(val1).FillValue;
UsDat.PARAMETERS(end).ValidMin=UsDat.PARAMETERS(val1).ValidMin;
UsDat.PARAMETERS(end).ValidMax=UsDat.PARAMETERS(val1).ValidMax;
%Save
set(handles.figure1,'UserData',UsDat);  
%Update handle
guidata(hObject, handles);
%
set(handles.figure1, 'pointer', 'arrow');
drawnow;
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
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
zoom out;

% --------------------------------------------------------------------
function uitoggletool2_ClickedCallback(hObject, eventdata, handles)
pan ;

%
