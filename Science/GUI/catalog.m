function varargout = catalog(varargin)
%
% MAIN MATLAB code for catalog.fig
% Last Modified by GUIDE v2.5 22-Nov-2017 14:42:18
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA-Science 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @catalog_OpeningFcn, ...
                   'gui_OutputFcn',  @catalog_OutputFcn, ...
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

% --- Executes just before catalog is made visible.
function catalog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
handles.output = hObject;
%GLOBAL VAR
global ParamList PARAMETERS MMetadata;  
%Disable some stuffs before importing data
%easier than to test all cases 
set(handles.plots,'enable','off'); 
set(handles.edit,'enable','off'); 
%LOGO
jh=java(findobj_java(handles.pushbutton_logo));
jh.setBorderPainted(false);    
jh.setContentAreaFilled(false);
%DISPLAY CATALOG LIST
list=dir('Science/Catalog/*.m');
for i=1:length(list)
    flist{i}=list(i).name;
end
set(handles.listbox1,'String',flist);
if(length(list)~=0)
    listbox1_Callback(hObject, eventdata, handles)
end
%INIT
ParamList={};
PARAMETERS=[];
MMetadata.Properties={};
MMetadata.Values={};
%UPDATE HANDLE
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = catalog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
varargout{1} = handles.output;
clearvars;

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
%GET FUNCTION
list=get(handles.listbox1,'String');
val=get(handles.listbox1,'Value');
%ADAPT DESCRIPTION
fid = fopen(['Science/Catalog/' list{val}]);
eod=0;
tline = fgetl(fid); desc{1}=tline;
i=2;
while(~eod)
    tline = fgetl(fid);
    if(strcmp(tline,''))
        break;
    end
    if(tline(1)=='%')
        desc{i}=tline;
        i=i+1;
    else
        eod=1;
    end
end
fclose(fid);
set(handles.text_details,'String',desc);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%       FILE      %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function inetcdf_Callback(hObject, eventdata, handles)
%IMPORT A NETCDF FILE
%GLOBAL VARS
global ParamList PARAMETERS MMetadata;  
%FILE SELECTION
[FileName,PathName,~] = uigetfile('*.nc','Select Data File');
%EMPTY FILENAME
if isequal(FileName,0) 
    return; 
end
fname=[PathName FileName]; 
%SET INPUTS FOR import_netcdf FUNCTION
varinp.fname=fname;
NN=sc_inetcdf(varinp);
%GET OUTPUT
ParamList = [ParamList; NN.ParamList_out];
PARAMETERS = [PARAMETERS NN.PARAMETERS_out];
MMetadata.Properties = [MMetadata.Properties(:);NN.MMetadata_out.Properties(:)];
MMetadata.Values = [MMetadata.Values(:);NN.MMetadata_out.Values(:)];
%GUI UPDATE
handles=update_catalog(hObject, eventdata, handles, ParamList, PARAMETERS, MMetadata);
%UPDATE HANDLE
guidata(hObject,handles);                   
%ENABLE SOM ITEMS IN MENU
set(handles.plots,'enable','on');
set(handles.edit,'enable','on');

% --------------------------------------------------------------------
function imat_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim MMetadata ;
[FileName,PathName] = uigetfile('*.mat');
if isequal(FileName,0) 
    return; 
end
HH=load([PathName FileName]);
ParamList = [ParamList; HH.ParamList];
PARAMETERS = [PARAMETERS HH.PARAMETERS];
MMetadata.Properties = [MMetadata.Properties(:);HH.MMetadata.Properties(:)];
MMetadata.Values = [MMetadata.Values(:);HH.MMetadata.Values(:)];
%GUI UPDATE
handles=update_catalog(hObject, eventdata, handles, ParamList, PARAMETERS, MMetadata);
%UPDATE HANDLE
guidata(hObject,handles);    
%ENABLE SOM ITEMS IN MENU
set(handles.plots,'enable','on');
set(handles.edit,'enable','on');

% --------------------------------------------------------------------
function exit_Callback(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
%
choice = questdlg('Quit ?', 'Quit', 'Yep','Oops, no !','Yep');
% Handle response
switch choice
    case 'Yep'    
    delete(handles.figure1);
    case 'Oops, no !'
    return;
end

%%%%%%%%%%%%%%%%%
% EDIT  REQUEST %
%%%%%%%%%%%%%%%%%
function edit_parameters_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MMetadata;
%SET INPUT FOR edit_param FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
NN=to_edit_param(varinp);
%GET OUTPUT
ParamList = NN.ParamList_out;
PARAMETERS = NN.PARAMETERS_out;
%GUI UPDATE
handles=update_catalog(hObject, eventdata, handles, ParamList, PARAMETERS, MMetadata);

%%%%%%%%%%%%%%%%%
% PLOT  REQUEST %
%%%%%%%%%%%%%%%%%
function plot_parameters_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS;
%SET INPUT FOR dispersion FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
varinp.MDim_in.FileName = 'Display';
ca_sedisp(varinp);

%%%%%%%%%%%%%%%%%
% APPLY REQUEST %
%%%%%%%%%%%%%%%%%------------------------------------------------------
function pushbutton_apply_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MMetadata;
%clear error log
set(handles.edit4,'String','Error log');
%ASSIGN VAR 
for i=1:length(PARAMETERS)
   eval([ParamList{i},'= PARAMETERS(i);']); 
end
%GET TEXT TO RUN
stred=get(handles.edit3,'String');
try
    ltev='';
    for i=1:length(stred)
    ltev=[ltev sprintf('\n') stred{i}];
    end
    %APPLY
    eval(ltev);            
    %Display        
    set(handles.edit4,'BackgroundColor','g');
    pause(0.5);
    set(handles.edit4,'BackgroundColor','w');
%IF ERROR, THROW MESSAGE IN MSGBOX    
catch ME
    set(handles.edit4,'String',ME.message);
    set(handles.edit4,'Backgroundcolor','r');
    pause(0.5);
    set(handles.edit4,'Backgroundcolor','w');
end

%%%%%%%%%%%%%%%%%
% CLOSE REQUEST %-- Executes when user attempts to close figure1.
%%%%%%%%%%%%%%%%%------------------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
%
choice = questdlg('Wanna quit ?', 'Exit', 'Yep','Oops, no !','Yep');
% Handle response
switch choice
    case 'Yep'    
    delete(handles.figure1);
    case 'Oops, no !'
    return;
end

