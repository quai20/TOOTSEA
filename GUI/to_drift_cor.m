function varargout = to_drift_cor(varargin)
%
% DRIFT_COR MATLAB code for drift_cor.fig
% Last Modified by GUIDE v2.5 16-Feb-2017 16:07:50
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_drift_cor_OpeningFcn, ...
                   'gui_OutputFcn',  @to_drift_cor_OutputFcn, ...
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
function to_drift_cor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% Choose default command line output for drift_cor
handles.output = hObject;
%GET INPUT DATA
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
UsDat.MDim = varargin{1}.MDim_in;
%SAVE IN FIGURE
set(handles.figure1,'UserData',UsDat);  
%DISPLAY
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
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes drift_cor wait for user response (see UIRESUME)
 uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = to_drift_cor_OutputFcn(hObject, eventdata, handles) 
%GET THE DATA AND OUTPUT IT
UsDat=get(hObject,'UserData');
varargout{1}.ParamList_out = UsDat.ParamList;
varargout{1}.PARAMETERS_out = UsDat.PARAMETERS;
varargout{1}.MDim_out = UsDat.MDim;
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
%
cla(handles.axes1,'reset');
%PLOT PARAMETER
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
%GET DRIFT CORRECTION COEF A & B
co_a=str2num(get(handles.edit_offset,'String'));
co_b=str2num(get(handles.edit_drift,'String'));
%PLOT CORRECTED SERIE
nser=co_a + (UsDat.PARAMETERS(val1).Time-UsDat.PARAMETERS(val1).Time(1)).*co_b + UsDat.PARAMETERS(val1).Data(val2,:);
plot(handles.axes1,UsDat.PARAMETERS(val1).Time,nser);
hold(handles.axes1,'on');
grid(handles.axes1,'on');
%dynamicDateTicks(handles.axes1);
dateNtick('x',20,'axes_handle',handles.axes1);  

% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETER
val1 = get(handles.popupmenu_param,'Value');
val2 = get(handles.popupmenu_level,'Value');
%GET DRIFT CORRECTION COEF A & B
co_a=str2num(get(handles.edit_offset,'String'));
co_b=str2num(get(handles.edit_drift,'String'));
%GET SUFFIX IN edit_suffix
NewParamName = [UsDat.ParamList{val1} get(handles.edit_suffix,'String')];
%SINGLE OR MULTI
if(min(size(UsDat.PARAMETERS(val1).Data))>1) %MULTILEVEL
   %LEVELS SELECTION
    str = num2str([1:size(UsDat.PARAMETERS(val1).Data,1)]');
    [sel,vok] = listdlg('PromptString',[UsDat.PARAMETERS(val1).Name ' : Select level(s) to apply :'],...
                'SelectionMode','multi','ListString',str);
    if(vok)
       for i=1:length(sel) 
       %CORRECTION CALLING
       LData(i,:)=co_a + (UsDat.PARAMETERS(val1).Time-UsDat.PARAMETERS(val1).Time(1)).*co_b + UsDat.PARAMETERS(val1).Data(sel(i),:);
       end
       eval([NewParamName,'= TimeSerie(''',NewParamName,''',UsDat.PARAMETERS(val1).Time,LData);']);        
       UsDat.ParamList=[UsDat.ParamList;{NewParamName}];
       eval(['UsDat.PARAMETERS=[UsDat.PARAMETERS ',NewParamName,'];']);
       if(~isempty(UsDat.PARAMETERS(val1).Depth))
       UsDat.PARAMETERS(end).Depth=UsDat.PARAMETERS(val1).Depth(sel);   
       else
       UsDat.PARAMETERS(end).Depth=UsDat.PARAMETERS(val1).Depth;       
       end
    end 
%
else
    %CORRECTION CALLING
    LData(1,:)=co_a + (UsDat.PARAMETERS(val1).Time-UsDat.PARAMETERS(val1).Time(1)).*co_b + UsDat.PARAMETERS(val1).Data;
    eval([NewParamName,'= TimeSerie(''',NewParamName,''',UsDat.PARAMETERS(val1).Time,LData);']);        
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

function uipushtool3_ClickedCallback(hObject, eventdata, handles)
%ADD POINT
prompt = {'x array :','y array :'};
dlg_title = 'Add points';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines);
xa=str2num(answer{1});
ya=str2num(answer{2});
if(length(xa)==length(ya))
   plot(handles.axes1,xa,ya,'ro','markerfacecolor','r','markeredgecolor','k'); 
else
    warning('Size problem');
    return;
end




