function varargout = to_export_nc(varargin)
%
% EXPORT_NC MATLAB code for export_nc.fig
% Last Modified by GUIDE v2.5 08-Feb-2017 13:18:54
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_export_nc_OpeningFcn, ...
                   'gui_OutputFcn',  @to_export_nc_OutputFcn, ...
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

% --- Executes just before export_nc is made visible.
function to_export_nc_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% Choose default command line output for export_nc
handles.output = hObject;
%GET INPUT DATA
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
UsDat.MDim = varargin{1}.MDim_in;
UsDat.MMetadata = varargin{1}.MMetadata_in;
%INIT
UsDat.ParamList_sel = {};
UsDat.PARAMETERS_sel = [];
UsDat.QC_Choice = [];
% Display PARAM list
for i=1:length(UsDat.ParamList)
   DispSt{i}=[UsDat.ParamList{i},' (',UsDat.PARAMETERS(i).Unit,') '];
end
set(handles.listbox1,'String',DispSt);
%Check Mandatory Meta
%SHOULD BE DEFINED IN A CONF FILE
%mandato={'Latitude';'Longitude';'Nominal_depth';'Site_code';'Project_name';'Serial'};   %DEFINI PLUS BAS EGALEMENT !
mandato={'Latitude';'Longitude'};
%%%
for i=1:length(mandato)
  ind=find(strcmp(UsDat.MMetadata.Properties,mandato{i}));
  if ind>0 %if meta is defined
    toDisp{i}=['<html><body style="background-color:#66FF33;">' mandato{i} '</body></html>']; %html for color background
    UsDat.MDim.validMand(i)=1;
  else %if meta is not defined
    toDisp{i}=['<html><body style="background-color:#FF0033;">' mandato{i} '</body></html>']; %html for color background
    UsDat.MDim.validMand(i)=0;
  end
end
%display
set(handles.uitable1,'Data',toDisp');
%Save
set(handles.figure1,'UserData',UsDat);  
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes export_nc wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = to_export_nc_OutputFcn(hObject, eventdata, handles) 
%GET DATA AND OUTPUT
UsDat=get(hObject,'UserData');
varargout{1}.ParamList_out = UsDat.ParamList;
varargout{1}.PARAMETERS_out = UsDat.PARAMETERS;
varargout{1}.MDim_out = UsDat.MDim;
varargout{1}.MMetadata_out = UsDat.MMetadata;
%DELETE FIGURE
delete(hObject);

% --- Executes on button press in pushbutton_edit.
function pushbutton_edit_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
svarinp.ParamList_in = UsDat.ParamList;
svarinp.PARAMETERS_in = UsDat.PARAMETERS;
%CALL EDIT_PARAM (GUI FUNC) with svarinp INPUT
sNN=to_edit_param(svarinp);
%GET OUPUT
UsDat.ParamList = sNN.ParamList_out;
UsDat.PARAMETERS = sNN.PARAMETERS_out;
%
% Display PARAM list
for i=1:length(UsDat.ParamList)
   DispSt{i}=[UsDat.ParamList{i},' (',UsDat.PARAMETERS(i).Unit,') '];
end
set(handles.listbox1,'String',DispSt);
%SAVE IN FIGURE
set(handles.figure1,'UserData',UsDat);  
% Update handles structure
guidata(hObject, handles);

function pushbutton_meta_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
svarinp.MMetadata_in = UsDat.MMetadata;
%CALL EDIT_META (GUI FUNC) with svarinp INPUT
sNN=to_edit_meta(svarinp);
%GET OUTPUT
UsDat.MMetadata = sNN.MMetadata_out;
%Check Mandatory Meta
%SHOULD BE DEFINED IN A CONF FILE TO AVOID ISSUES
%mandato={'Latitude';'Longitude';'Nominal_depth';'Site_code';'Project_name';'Serial'};
mandato={'Latitude';'Longitude'};
for i=1:length(mandato)
  ind=find(strcmp(UsDat.MMetadata.Properties,mandato{i})); %if meta is defined
  if ind>0
    toDisp{i}=['<html><body style="background-color:#66FF33;">' mandato{i} '</body></html>']; %html to color background
    UsDat.MDim.validMand(i)=1;
  else %if meta is not defined
    toDisp{i}=['<html><body style="background-color:#FF0033;">' mandato{i} '</body></html>']; %html to color background 
    UsDat.MDim.validMand(i)=0;
  end
end
%Display
set(handles.uitable1,'Data',toDisp');
%Save data in figure
set(handles.figure1,'UserData',UsDat);  
% Update handles structure
guidata(hObject, handles);

function pushbutton_add_Callback(hObject, eventdata, handles) 
%Get data
UsDat=get(handles.figure1,'UserData');
%Get selected parameters
PSel=get(handles.listbox1,'Value');
PSel=PSel(1);
%Some checkings ...
ind=find(strcmp(UsDat.ParamList_sel,UsDat.ParamList{PSel}));
if ind>0
    warndlg('Parameter already selected');
    return;
else
    if(min(size(UsDat.PARAMETERS(PSel).Data))>1)   
    %MULTILEVEL HANDLING
    if(~isempty(UsDat.PARAMETERS(PSel).Depth))
        schoice = questdlg('Vertical dimension detected, Use it or define new one ?','','Yes','Define new one','Yes');
        switch schoice
        case 'Yes'
            if(length(UsDat.PARAMETERS(PSel).Depth)~=min(size(UsDat.PARAMETERS(PSel).Data)))
                warndlg('Dimension length does not match number of parameters in variable'); 
                return; 
            else
                UsDat.MDim.VerticalDim=UsDat.PARAMETERS(PSel).Depth;
            end
        case 'Define new one'
            InputVDim = inputdlg('Enter space-separated depth :','New Vertical Dimension', [1 100]);
            InputVDim = str2num(InputVDim{:});
            if(issorted(InputVDim)==0)
                warndlg('Not ascending'); 
            return; 
            end
            if(length(InputVDim)~=min(size(UsDat.PARAMETERS(PSel).Data)))
               warndlg('Dimension length does not match number of parameters in variable'); 
               return; 
            end
            UsDat.MDim.VerticalDim=InputVDim;
        end
    else
        InputVDim = inputdlg('Enter space-separated depth :','New Vertical Dimension', [1 100]);
        InputVDim = str2num(InputVDim{:});
        if(issorted(InputVDim)==0)
           warndlg('Not ascending'); 
           return; 
        end
        if(length(InputVDim)~=min(size(UsDat.PARAMETERS(PSel).Data)))
           warndlg('Dimension length does not match number of parameters in variable'); 
           return; 
        end
        UsDat.MDim.VerticalDim=InputVDim; 
    end
    end
    %
    qc_choice = questdlg('Export QC ?', 'QC Export','Yes','No','Yes');    
    switch qc_choice
    case 'Yes'
        UsDat.QC_Choice = [UsDat.QC_Choice 1];        
    case 'No'
        UsDat.QC_Choice = [UsDat.QC_Choice 0];        
    end
    %
    UsDat.ParamList_sel = [UsDat.ParamList_sel;UsDat.ParamList{PSel}];
    UsDat.PARAMETERS_sel = [UsDat.PARAMETERS_sel UsDat.PARAMETERS(PSel)];       
end
% Display PARAM list
for i=1:length(UsDat.ParamList_sel)
   if(UsDat.QC_Choice(i)==1) 
    DispSt{i}=[UsDat.ParamList_sel{i},' (',UsDat.PARAMETERS_sel(i).Unit,') + QC'];
   else
    DispSt{i}=[UsDat.ParamList_sel{i},' (',UsDat.PARAMETERS_sel(i).Unit,')'];    
   end
end
set(handles.listbox2,'String',DispSt);
%Save
set(handles.figure1,'UserData',UsDat);  
% Update handles structure
guidata(hObject, handles);
disp('|');
%

function pushbutton_rem_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETERS
PSel=get(handles.listbox2,'Value');
%REMOVE PARAMETERS FROM STRUCTS
shiftv=zeros([1 length(UsDat.ParamList_sel)]);    shiftv(PSel)=1;
shiftv=logical(shiftv);
UsDat.ParamList_sel(shiftv) = [] ; 
UsDat.PARAMETERS_sel(shiftv) = [] ; 
UsDat.QC_Choice(shiftv) = [] ;

% Display PARAM list
set(handles.listbox2,'Value',1);
DispSt={};
for i=1:length(UsDat.ParamList_sel)
   if(UsDat.QC_Choice(i)==1) 
    DispSt{i}=[UsDat.ParamList_sel{i},' (',UsDat.PARAMETERS_sel(i).Unit,') + QC'];
   else
    DispSt{i}=[UsDat.ParamList_sel{i},' (',UsDat.PARAMETERS_sel(i).Unit,')'];    
   end
end
set(handles.listbox2,'String',DispSt);

%Save
set(handles.figure1,'UserData',UsDat);  
% Update handles structure
guidata(hObject, handles);

function pushbutton_save_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%Check if parameters are present
if(isempty(UsDat.ParamList_sel))
    warndlg('Nothing to save'); 
    return; 
end
%Check Parameters Dimensions
for i=1:length(UsDat.ParamList_sel)
    lgth(i)=length(UsDat.PARAMETERS_sel(i).Time);
end
if(std(lgth) == 0)
    %Si tous les Time sont identiques
    %On reaffecte le Time global de la structure à écrire
    UsDat.MDim.Time=UsDat.PARAMETERS_sel(1).Time;
else
    warndlg('Parameters time dimension not identical');
    return; 
end
%
%Check vertical dim is the same for all multilevel parameters
lvert=[];
for i=1:length(UsDat.ParamList_sel)
  if(min(size(UsDat.PARAMETERS_sel(i).Data))>1)
      lvert=[lvert min(size(UsDat.PARAMETERS_sel(i).Data))];  
  end
end
if ((std(lvert) ~= 0) && (~isempty(lvert)))
    warndlg('Multilevel Parameters vertical dimensions not identical');
    return;
end
%
%Check mandatory metadata
if(sum(UsDat.MDim.validMand)/length(UsDat.MDim.validMand)==1)
    set(gcf, 'pointer', 'watch');
    to_write_ncfile(UsDat);
    set(findall(0,'Type','figure'), 'pointer', 'arrow');
    drawnow;
else
    warndlg('Mandatory metadata not complete');
    return; 
end
uiresume(handles.figure1);
%

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
%delete(hObject);
uiresume(handles.figure1);

