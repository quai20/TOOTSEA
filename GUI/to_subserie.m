function varargout = to_subserie(varargin)
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
                   'gui_OpeningFcn', @to_subserie_OpeningFcn, ...
                   'gui_OutputFcn',  @to_subserie_OutputFcn, ...
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
function to_subserie_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% Choose default command line output for subserie
handles.output = hObject;
%GET INPUT PARAMETERS
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
%SAVE IN FIGURE
set(handles.figure1,'UserData',UsDat);  
%GUI STUFF
set(handles.listbox1,'String',UsDat.ParamList,'Max',length(UsDat.ParamList));
set(handles.popupmenu_param,'String',UsDat.ParamList);
handles.pl_axes1_1=UsDat.PARAMETERS(1).Plot(handles.axes1);
ylabel([UsDat.ParamList{1} '(' UsDat.PARAMETERS(1).Unit ')']); 
%UPDATE HANDLE
guidata(hObject,handles);
% UIWAIT makes subserie wait for user response (see UIRESUME) INDISPENSABLE
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = to_subserie_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
%GET DATA AND SET OUTPUT
UsDat=get(hObject,'UserData');
varargout{1}.ParamList_out = UsDat.ParamList;
varargout{1}.PARAMETERS_out = UsDat.PARAMETERS;
cla;
delete(hObject);

% --- Executes on selection change in popupmenu_param.
function popupmenu_param_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_param contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_param
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET LIM
x1=get(handles.edit_L1,'UserData');
x2=get(handles.edit_L2,'UserData');
%GET SELECTED PARAMETER
val = get(hObject,'Value'); 
%DISPLAY
cla(handles.axes1);
UsDat.PARAMETERS(val).Plot(handles.axes1);         
ylabel([UsDat.ParamList{val} '(' UsDat.PARAMETERS(val).Unit ')']); 
try %IF LIMs DEFINED, PLOT THEM
    plot(handles.axes1,[x1 x1],get(handles.axes1,'YLim'),'r','linewidth',3); 
    plot(handles.axes1,[x2 x2],get(handles.axes1,'YLim'),'r','linewidth',3); 
catch
    %do nothing
end       

% --- Executes on button press in edit_L1.
function edit_L1_Callback(hObject, eventdata, handles)
%SET AND SAVE 1st LIM
[x1 y1]=getpts(handles.axes1);
x1=x1(end);
set(hObject,'UserData',x1);
%UPDATE HANDLES
guidata(hObject, handles);
%DISPLAY LIM IN TEXT AND AXES
set(handles.text1,'String',datestr(x1,'dd/mm/yy-HH:MM'));
val = get(handles.popupmenu_param,'Value'); 
plot(handles.axes1,[x1 x1],get(handles.axes1,'YLim'),'r','linewidth',3);

% --- Executes on button press in edit_L2.
function edit_L2_Callback(hObject, eventdata, handles)
%SET AND SAVE 2nd LIM
[x2 y2]=getpts(handles.axes1);
x2=x2(end);
set(hObject,'UserData',x2);
%UPDATE HANDLES
guidata(hObject, handles);
%DISPLAY LIM IN TEXT AND AXES
set(handles.text2,'String',datestr(x2,'dd/mm/yy-HH:MM'));
val = get(handles.popupmenu_param,'Value'); 
plot(handles.axes1,[x2 x2],get(handles.axes1,'YLim'),'r','linewidth',3); 

% --- Executes on text1
function text1_Callback(hObject, eventdata, handles)
%GET DATE
tx1=get(hObject,'String');
if(regexp(tx1,'\d\d/\d\d/\d\d-\d\d:\d\d'))
    x1=datenum(tx1,'dd/mm/yy-HH:MM');
    set(handles.edit_L1,'UserData',x1);
    plot(handles.axes1,[x1 x1],get(handles.axes1,'YLim'),'g','linewidth',3);
end
%UPDATE HANDLES
guidata(hObject, handles);

% --- Executes on text1
function text2_Callback(hObject, eventdata, handles)
%GET DATE
tx2=get(hObject,'String');
if(regexp(tx2,'\d\d/\d\d/\d\d-\d\d:\d\d'))
    x2=datenum(tx2,'dd/mm/yy-HH:MM');
    set(handles.edit_L2,'UserData',x2);
    plot(handles.axes1,[x2 x2],get(handles.axes1,'YLim'),'g','linewidth',3);
end
%UPDATE HANDLES
guidata(hObject, handles);

% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET LIMS
x1=get(handles.edit_L1,'UserData');
x2=get(handles.edit_L2,'UserData');
%GET SELECTED PARAMETERS
psel=get(handles.listbox1,'Value');
%CREATE NEW SERIE CALLING TimeSerie.Subserie()
hwb = waitbar(0,'');
for i=1:length(psel)
   waitbar((i-1)/length(psel),hwb,UsDat.PARAMETERS(psel(i)).Name);
   %INDEX
   [c1 ind1]=min(abs(UsDat.PARAMETERS(psel(i)).Time-x1));
   [c2 ind2]=min(abs(UsDat.PARAMETERS(psel(i)).Time-x2)) ;  
   % SINGLE OR MULTI ? 
   if(min(size(UsDat.PARAMETERS(psel(i)).Data))>1) %MULTILEVEL
     str = num2str([1:size(UsDat.PARAMETERS(psel(i)).Data,1)]');
     [sel,vok] = listdlg('PromptString',[UsDat.PARAMETERS(psel(i)).Name ': Select level(s) to apply :'],...
                'SelectionMode','multi','ListString',str,'InitialValue',[1:size(UsDat.PARAMETERS(psel(i)).Data,1)]);
     if(vok)
       NewParamName = [UsDat.ParamList{psel(i)} get(handles.edit_suffix,'String')];
       eval([NewParamName,'= UsDat.PARAMETERS(psel(i)).Subserie(''',NewParamName,''',ind1,ind2,sel);']);   
       UsDat.ParamList=[UsDat.ParamList;{NewParamName}];
       eval(['UsDat.PARAMETERS=[UsDat.PARAMETERS ',NewParamName,'];']);    
     else
        %do nothing 
     end
   %    
   else %SINGLE LEVEL         
     NewParamName = [UsDat.ParamList{psel(i)} get(handles.edit_suffix,'String')];
     eval([NewParamName,'= UsDat.PARAMETERS(psel(i)).Subserie(''',NewParamName,''',ind1,ind2,1);']);   
     UsDat.ParamList=[UsDat.ParamList;{NewParamName}];
     eval(['UsDat.PARAMETERS=[UsDat.PARAMETERS ',NewParamName,'];']);
   end
   waitbar(i/length(psel),hwb,UsDat.PARAMETERS(psel(i)).Name);
end
delete(hwb)
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
