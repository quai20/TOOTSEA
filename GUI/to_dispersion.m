function varargout = dispersion(varargin)
%
% DISPERSION MATLAB code for dispersion.fig
% Last Modified by GUIDE v2.5 20-Jan-2017 14:53:12
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_dispersion_OpeningFcn, ...
                   'gui_OutputFcn',  @to_dispersion_OutputFcn, ...
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

% --- Executes just before dispersion is made visible.
function to_dispersion_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% Choose default command line output for dispersion
handles.output = hObject;

%GET INPUT PARAMETERS
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
UsDat.MDim = varargin{1}.MDim_in;
%SAVE IN FIGURE
set(handles.figure1,'UserData',UsDat);  
%GUI STUFF
set(handles.popupmenu_param1,'String',UsDat.ParamList,'Max',length(UsDat.ParamList));
set(handles.popupmenu_param1,'Value',1);
set(handles.popupmenu_lev1,'String',num2str([1:size(UsDat.PARAMETERS(1).Data,1)]'));
if length(UsDat.ParamList)>1
    set(handles.popupmenu_param2,'String',UsDat.ParamList,'Max',length(UsDat.ParamList));
    set(handles.popupmenu_param2,'Value',2);
    set(handles.popupmenu_lev2,'String',num2str([1:size(UsDat.PARAMETERS(2).Data,1)]'));
    set(handles.popupmenu_lev2,'Value',1);
end
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = to_dispersion_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function popupmenu_param1_Callback(hObject, eventdata, handles)
%GET INPUT DATA
UsDat=get(handles.figure1,'UserData');
%Get value
val=get(hObject,'Value');
%SET POPUP LEVEL
set(handles.popupmenu_lev1,'String',num2str([1:size(UsDat.PARAMETERS(val).Data,1)]'));
set(handles.popupmenu_lev1,'Value',1);

% --- Executes on button press in pushbutton1.
function popupmenu_param2_Callback(hObject, eventdata, handles)
%GET INPUT DATA
UsDat=get(handles.figure1,'UserData');
%Get value
val=get(hObject,'Value');
%SET POPUP LEVEL
set(handles.popupmenu_lev2,'String',num2str([1:size(UsDat.PARAMETERS(val).Data,1)]'));
set(handles.popupmenu_lev2,'Value',1);

% --- Executes on button press in pushbutton1.
function pushbutton_plot_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET 2 PARAMETERS TO PLOT
val1=get(handles.popupmenu_param1,'Value');
val2=get(handles.popupmenu_param2,'Value');
%GET LEVELS
lev1=get(handles.popupmenu_lev1,'Value');
lev2=get(handles.popupmenu_lev2,'Value');
%GET OPTIONS
r3=get(handles.radiobutton3,'Value');
r4=get(handles.radiobutton4,'Value');
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
%plot(UsDat.PARAMETERS(val1).Data(lev1,:),UsDat.PARAMETERS(val2).Data(lev2,:),'.');
scatter(Arr2Plot_1,Arr2Plot_2,8,Arr2Plot_T,'filled');
hh=colorbar('AxisLocation','in');
colormap(jet);
hticks=get(hh,'Ticks');
set(hh,'TickLabels',datestr(hticks,'dd/mm/yy'));
%LABELS
l=xlabel([UsDat.ParamList{val1} ' (' UsDat.PARAMETERS(val1).Unit ')']);
set(l,'interpreter','none');
l=ylabel([UsDat.ParamList{val2} ' (' UsDat.PARAMETERS(val2).Unit ')']);
set(l,'interpreter','none');
grid on;

%GUI STUFF
% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
p1=get(handles.popupmenu_param1,'Value');
p2=get(handles.popupmenu_param2,'Value');
defaultName=[strrep(UsDat.MDim.FileName,'.','-') '-disp-' UsDat.ParamList{p1} '-' UsDat.ParamList{p2}];
%SAVE FIGURE
[FileName,PathName] = uiputfile({'*.pdf';'*.eps';'*.png';'*.tiff';'*.jpeg';'*.bmp'},'Save as',defaultName);
if isequal(FileName,0) 
    return; 
end
export_fig(handles.axes1,[PathName FileName]);