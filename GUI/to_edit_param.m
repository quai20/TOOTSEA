function varargout = edit_param(varargin)
%
% EDIT_PARAM MATLAB code for edit_param.fig
% Last Modified by GUIDE v2.5 16-Jan-2017 09:50:17
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_edit_param_OpeningFcn, ...
                   'gui_OutputFcn',  @to_edit_param_OutputFcn, ...
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


% --- Executes just before edit_param is made visible.
function to_edit_param_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for edit_param
handles.output = hObject;
%GET INPUT PARAMETERS
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
%LOAD OSP DATA
UsDat.OSP=load('OC_params.mat');
%SAVE IT TO FIGURE
set(handles.figure1,'UserData',UsDat);  
%UPDATE HANDLE
guidata(hObject, handles);
%DISPLAY
set(handles.listbox1,'String',UsDat.ParamList);
set(handles.popupmenu_name,'String',[UsDat.OSP.PARAM ; {'Other'}]);
listbox1_Callback(hObject, eventdata, handles);
% UIWAIT makes edit_param wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = to_edit_param_OutputFcn(hObject, eventdata, handles) 
%GET DATA TO OUTPUT
UsDat=get(hObject,'UserData');
varargout{1}.ParamList_out = UsDat.ParamList;
varargout{1}.PARAMETERS_out = UsDat.PARAMETERS;
%DELETE FIGURE
delete(hObject);

% --- Executes on button press in listbox1
function listbox1_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETERS
rg=get(handles.listbox1,'Value');
%INIT
set(handles.edit_name,'Enable','off');    
set(handles.edit_longname,'Enable','off');    
set(handles.edit_comment,'Enable','off');  
set(handles.edit_unit,'Enable','off');
set(handles.edit_fillv,'Enable','off');
set(handles.edit_vmin,'Enable','off');
set(handles.edit_vmax,'Enable','off');    
set(handles.checkbox1,'Value',0);
%DISLAY EXISTING PROPERTIES
set(handles.edit_name,'String',UsDat.PARAMETERS(rg).Name);
set(handles.edit_longname,'String',UsDat.PARAMETERS(rg).Long_name);
set(handles.edit_comment,'String',UsDat.PARAMETERS(rg).Comment);
set(handles.edit_unit,'String',UsDat.PARAMETERS(rg).Unit);
set(handles.edit_fillv,'String',num2str(UsDat.PARAMETERS(rg).FillValue));
set(handles.edit_vmin,'String',num2str(UsDat.PARAMETERS(rg).ValidMin));
set(handles.edit_vmax,'String',num2str(UsDat.PARAMETERS(rg).ValidMax));
%CALC BUTTON
if isempty(UsDat.PARAMETERS(rg).calc)
    set(handles.pushbutton_calc,'Enable','off');
else
    set(handles.pushbutton_calc,'Enable','on');
end
%PLACE POPUPMENU
oinn=find(strcmp(UsDat.OSP.PARAM,UsDat.PARAMETERS(rg).Name));
if(~isempty(oinn))
    set(handles.popupmenu_name,'Value',oinn);
%     set(handles.edit_name,'String',UsDat.OSP.PARAM(oinn));
%     set(handles.edit_longname,'String',UsDat.OSP.LONGNAME(oinn));    
%     set(handles.edit_unit,'String',UsDat.OSP.UNIT(oinn));
%     set(handles.edit_fillv,'String',num2str(UsDat.OSP.FILLVALUE(oinn)));
%     set(handles.edit_vmin,'String',num2str(UsDat.OSP.MIN(oinn)));
%     set(handles.edit_vmax,'String',num2str(UsDat.OSP.MAX(oinn)));        
    %
else
    set(handles.popupmenu_name,'Value',length(UsDat.OSP.PARAM)+1);
    set(handles.checkbox1,'Value',1);
    set(handles.edit_name,'Enable','on');
    set(handles.edit_longname,'Enable','on');  
    set(handles.edit_comment,'Enable','on');  
    set(handles.edit_unit,'Enable','on');
    set(handles.edit_fillv,'Enable','on');
    set(handles.edit_vmin,'Enable','on');
    set(handles.edit_vmax,'Enable','on');    
end
%

% --- Executes on button press in pushbutton_unit.
function popupmenu_name_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED NAME
rgn=get(handles.popupmenu_name,'Value');
%IF "OTHERS" :
if(rgn~=length(UsDat.OSP.PARAM)+1)
    %SET CORRESPONDING PROPERTIES
    set(handles.checkbox1,'Value',0);
    set(handles.edit_name,'Enable','off');    
    set(handles.edit_longname,'Enable','off');    
    set(handles.edit_comment,'Enable','off');
    set(handles.edit_unit,'Enable','off');
    set(handles.edit_fillv,'Enable','off');
    set(handles.edit_vmin,'Enable','off');
    set(handles.edit_vmax,'Enable','off');    
    %
    set(handles.edit_name,'String',UsDat.OSP.PARAM{rgn});
    set(handles.edit_longname,'String',UsDat.OSP.LONGNAME{rgn});        
    set(handles.edit_unit,'String',UsDat.OSP.UNIT{rgn});
    set(handles.edit_fillv,'String',num2str(UsDat.OSP.FILLVALUE(rgn)));
    set(handles.edit_vmin,'String',num2str(UsDat.OSP.MIN(rgn)));
    set(handles.edit_vmax,'String',num2str(UsDat.OSP.MAX(rgn)));
    %    
else         
    set(handles.checkbox1,'Value',1);
    set(handles.edit_name,'Enable','on');       set(handles.edit_name,'String','');
    set(handles.edit_longname,'Enable','on');   set(handles.edit_longname,'String','');  
    set(handles.edit_unit,'Enable','on');       set(handles.edit_unit,'String','');
    set(handles.edit_fillv,'Enable','on');      set(handles.edit_fillv,'String','');
    set(handles.edit_vmin,'Enable','on');       set(handles.edit_vmin,'String','');
    set(handles.edit_vmax,'Enable','on');       set(handles.edit_vmax,'String','');
    set(handles.edit_vomment,'Enable','on');    set(handles.edit_comment,'String',''); 
end
%

function checkbox1_Callback(hObject, eventdata, handles)
%GET DATA
if (get(hObject,'Value') == get(hObject,'Max'))
    set(handles.edit_name,'Enable','on');
    set(handles.edit_longname,'Enable','on');
    set(handles.edit_comment,'Enable','on');
    set(handles.edit_unit,'Enable','on');
    set(handles.edit_fillv,'Enable','on');
    set(handles.edit_vmin,'Enable','on');
    set(handles.edit_vmax,'Enable','on');    
else
    set(handles.edit_name,'Enable','off');
    set(handles.edit_longname,'Enable','off');
    set(handles.edit_comment,'Enable','off');
    set(handles.edit_unit,'Enable','off');
    set(handles.edit_fillv,'Enable','off');
    set(handles.edit_vmin,'Enable','off');
    set(handles.edit_vmax,'Enable','off');    
end

% --- Executes on button press in pushbutton_unit.
function pushbutton_ok_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETERS
rg=get(handles.listbox1,'Value');
%LECTURE PROPERTIES 
UsDat.PARAMETERS(rg).Name=get(handles.edit_name,'String');
UsDat.ParamList{rg}=get(handles.edit_name,'String');
%
UsDat.PARAMETERS(rg).Long_name=get(handles.edit_longname,'String');    
%
UsDat.PARAMETERS(rg).Unit=get(handles.edit_unit,'String');
%
UsDat.PARAMETERS(rg).FillValue=str2num(get(handles.edit_fillv,'String'));
UsDat.PARAMETERS(rg).ValidMin=str2num(get(handles.edit_vmin,'String'));
UsDat.PARAMETERS(rg).ValidMax=str2num(get(handles.edit_vmax,'String'));

if(isempty(UsDat.PARAMETERS(rg).FillValue))||(isempty(UsDat.PARAMETERS(rg).ValidMin))||(isempty(UsDat.PARAMETERS(rg).ValidMax))
    warndlg('FillValue and ValidMin/Max should be numeric');
else
%
UsDat.PARAMETERS(rg).Comment=get(handles.edit_comment,'String');    
%
%SAVE DATA
set(handles.figure1,'UserData',UsDat);  
%COLOR VALIDATION THING
  set(handles.listbox1,'BackgroundColor','g');
  pause(0.3);
  set(handles.listbox1,'BackgroundColor','w');
%DISPLAY
set(handles.listbox1,'String',UsDat.ParamList);
%UPDATE HANDLE
guidata(hObject, handles);
end

% --- Executes on button press in pushbutton_del.
function pushbutton_del_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETERS
rg=get(handles.listbox1,'Value');
%DELETE WITH CONFIRMATION
areyousure = questdlg(['Delete ' UsDat.ParamList{rg} ' ?']);
switch areyousure
    case 'Yes'
    shiftv=zeros([1 length(UsDat.ParamList)]);    shiftv(rg)=1;
    shiftv=logical(shiftv);
    UsDat.ParamList(shiftv) = [] ;
    UsDat.PARAMETERS(shiftv) = [] ;
    case 'No'
        %
    case 'Cancel'
        %
end
%DISPLAY
DispSt=[];
set(handles.listbox1,'Value',1); 
set(handles.listbox1,'String',UsDat.ParamList);
%SAVE DATA
set(handles.figure1,'UserData',UsDat);  
%UPDATE HANDLE
guidata(hObject, handles);

% --- Executes on button press in pushbutton_calc.
function pushbutton_calc_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETERS
rg=get(handles.listbox1,'Value');
%SET INPUT FOR edit calculation
varinp.ParamList_in = UsDat.ParamList;
varinp.PARAMETERS_in = UsDat.PARAMETERS;
varinp.rga_in = rg;
NN=to_edit_calculation(varinp);
%GET OUTPUT
UsDat.PARAMETERS = NN.PARAMETERS_out;
%SAVE DATA
set(handles.figure1,'UserData',UsDat);  
%UPDATE HANDLE
guidata(hObject, handles);

%GUI FUNCTIONS
% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
uiresume(handles.figure1);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
%delete(hObject);
uiresume(handles.figure1);




