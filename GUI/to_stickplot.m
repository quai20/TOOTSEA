function varargout = to_stickplot(varargin)
%
% TO_STICKPLOT MATLAB code for to_stickplot.fig
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_stickplot_OpeningFcn, ...
                   'gui_OutputFcn',  @to_stickplot_OutputFcn, ...
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

% --- Executes just before to_stickplot is made visible.
function to_stickplot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to to_stickplot (see VARARGIN)

% Choose default command line output for to_stickplot
handles.output = hObject;
%GET INPUT PARAMETERS
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
UsDat.MDim = varargin{1}.MDim_in;
%SAVE IN FIGURE
set(handles.figure1,'UserData',UsDat);
%GUI STUFF
set(handles.popupmenu_p1,'String',UsDat.ParamList);
set(handles.popupmenu_p1,'Value',1);
set(handles.popupmenu_l1,'String',num2str([1:size(UsDat.PARAMETERS(1).Data,1)]'));
set(handles.popupmenu_l1,'Value',1);
set(handles.popupmenu_p2,'String',UsDat.ParamList);
set(handles.popupmenu_p2,'Value',2);
set(handles.popupmenu_l2,'String',num2str([1:size(UsDat.PARAMETERS(1).Data,1)]'));
set(handles.popupmenu_l2,'Value',1);
% Update handles structure
guidata(hObject, handles);
%

% --- Outputs from this function are returned to the command line.
function varargout = to_stickplot_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in popupmenu_p1.
function popupmenu_p1_Callback(hObject, eventdata, handles)
%GET INPUT DATA
UsDat=get(handles.figure1,'UserData');
%Get value
val=get(hObject,'Value');
%SET POPUP LEVEL
set(handles.popupmenu_l1,'String',num2str([1:size(UsDat.PARAMETERS(val).Data,1)]'));
set(handles.popupmenu_l1,'Value',1);

% --- Executes on selection change in popupmenu_p2.
function popupmenu_p2_Callback(hObject, eventdata, handles)
%GET INPUT DATA
UsDat=get(handles.figure1,'UserData');
%Get value
val=get(hObject,'Value');
%SET POPUP LEVEL
set(handles.popupmenu_l2,'String',num2str([1:size(UsDat.PARAMETERS(val).Data,1)]'));
set(handles.popupmenu_l2,'Value',1);

% --- Executes on button press in pushbutton_plot.
function pushbutton_plot_Callback(hObject, eventdata, handles)
%
delete(findobj(handles.figure1,'type','axes'));
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET 2 PARAMETERS TO PLOT
val1=get(handles.popupmenu_p1,'Value');
val2=get(handles.popupmenu_p2,'Value');
%GET LEVELS
lev1=get(handles.popupmenu_l1,'Value');
lev2=get(handles.popupmenu_l2,'Value');
%GET OPTIONS
r3=get(handles.radiobutton3,'Value');
r4=get(handles.radiobutton4,'Value');
%GET NDAYS & STEP
ndays=str2num(get(handles.edit_days,'String'));
step=str2num(get(handles.edit_step,'String'));
%CHECK SIZES
if(length(UsDat.PARAMETERS(val1).Data(lev1,:)) ~= length(UsDat.PARAMETERS(val2).Data(lev2,:)))
   warndlg('Size problem');
   return;
end
%OPTION
    if(r3==1)
        Arr2Plot_1=UsDat.PARAMETERS(val1).Data(lev1,:);
        Arr2Plot_2=UsDat.PARAMETERS(val2).Data(lev2,:);
        Arr2Plot_T=UsDat.PARAMETERS(val1).Time;
    else
        ind=ismember(UsDat.PARAMETERS(val1).QC_Serie(lev1,:),[1 2 3]).*ismember(UsDat.PARAMETERS(val2).QC_Serie(lev2,:),[1 2 3]);        
        ind=boolean(ind);
        Arr2Plot_1=UsDat.PARAMETERS(val1).Data(lev1,ind);
        Arr2Plot_2=UsDat.PARAMETERS(val2).Data(lev2,ind);
        Arr2Plot_T=UsDat.PARAMETERS(val1).Time(ind);
    end
%MAKE THE PLOT
stickplot_2(double(Arr2Plot_T),double(Arr2Plot_1),double(Arr2Plot_2),ndays,step,handles.uipanel1);
%

% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
val1=get(handles.popupmenu_p1,'Value');
val2=get(handles.popupmenu_p2,'Value');
defaultName=[strrep(UsDat.MDim.FileName,'.','-') '-stick-' UsDat.ParamList{val1} '-' UsDat.ParamList{val2}];   
%SAVE FIGURE
[FileName,PathName] = uiputfile({'*.pdf';'*.eps';'*.png';'*.tiff';'*.jpeg';'*.bmp'},'Save as',defaultName);
if isequal(FileName,0) 
    return; 
end
export_fig(handles.uipanel1,[PathName FileName]);

%GUI FUNCTION
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
%uiresume(hObject);
delete(hObject);