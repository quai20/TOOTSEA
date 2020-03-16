function varargout = to_edit_meta(varargin)
%
% EDIT_META MATLAB code for edit_meta.fig
% Last Modified by GUIDE v2.5 07-Feb-2017 15:05:23
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_edit_meta_OpeningFcn, ...
                   'gui_OutputFcn',  @to_edit_meta_OutputFcn, ...
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

% --- Executes just before edit_meta is made visible.
function to_edit_meta_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for edit_meta
handles.output = hObject;
%GET InPUT DATA
UsDat.MMetadata = varargin{1}.MMetadata_in;
%SAVE IN FIGURE
set(handles.figure1,'UserData',UsDat);  
%DISPLAY
set(handles.uitable1,'Data',[UsDat.MMetadata.Properties(:) UsDat.MMetadata.Values(:)]);
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes edit_meta wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = to_edit_meta_OutputFcn(hObject, eventdata, handles) 
%GET DATA
UsDat=get(hObject,'UserData');
%SET OUTPUT
varargout{1}.MMetadata_out = UsDat.MMetadata;
%DELETE FIGURE
delete(hObject);

% --- Executes on button press in pushbutton_import.
function pushbutton_import_Callback(hObject, eventdata, handles)
%IMPORT FILE
[FileName,PathName,~] = uigetfile({'*.txt'},'Select Data File');
%EMPTY FILENAME
if isequal(FileName,0) 
    return; 
end
fname=[PathName FileName]; 
%[~,~,raw] = xlsread(fname);
raw=readtable(fname,'Delimiter',',','ReadVariableNames',false);
raw=raw{:,:};
%GET DATA
UsDat=get(handles.figure1,'UserData');
%FILL META WITH XLSREAD OUTPUT
for i=1:length(raw)
   UsDat.MMetadata.Properties = [UsDat.MMetadata.Properties(:); num2str(raw{i,1})];
   UsDat.MMetadata.Values = [UsDat.MMetadata.Values(:); num2str(raw{i,2})];
end
%SAVE
set(handles.figure1,'UserData',UsDat);  
%DISPLAY
set(handles.uitable1,'Data',[UsDat.MMetadata.Properties(:) UsDat.MMetadata.Values(:)]);
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton2.
function pushbutton_save_Callback(hObject, eventdata, handles)
uiresume(handles.figure1);

function pushbutton_plus_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%ADD EMPTY LINE TO META
UsDat.MMetadata.Properties = [' ';UsDat.MMetadata.Properties(:)];
UsDat.MMetadata.Values = [' ';UsDat.MMetadata.Values(:)];
%DISPLAY
set(handles.uitable1,'Data',[UsDat.MMetadata.Properties(:) UsDat.MMetadata.Values(:)]);
%SET VIEW ON LAST CELL ?

%SAVE
set(handles.figure1,'UserData',UsDat);  
%UPDATE
guidata(hObject, handles);

function pushbutton_min_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%DELETER CURRENT ROW IF SELECTED
if(isfield(UsDat,'CurrentRow'))    
    ind=UsDat.CurrentRow;
    shiftv=zeros([1 length(UsDat.MMetadata.Properties)]);    shiftv(ind)=1;
    shiftv=logical(shiftv);
    UsDat.MMetadata.Properties(shiftv) = [] ;
    UsDat.MMetadata.Values(shiftv) = [] ;
    %DISPLAY
    set(handles.uitable1,'Data',[UsDat.MMetadata.Properties(:) UsDat.MMetadata.Values(:)]);
    %SAVE
    set(handles.figure1,'UserData',UsDat);
    %UPDATE HANDLE
    guidata(hObject, handles);
else
    return;
end

function uitable1_CellEditCallback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET DATA FROM TABLE
inpdat=get(hObject,'Data');
UsDat.MMetadata.Properties=inpdat(:,1);
UsDat.MMetadata.Values=inpdat(:,2);
%SAVE IT TO FIGURE
set(handles.figure1,'UserData',UsDat);  
%UPDATE  HANDLE
guidata(hObject, handles);

function uitable1_CellSelectionCallback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET DATA FROM TABLE
if(~isempty(eventdata.Indices))
UsDat.CurrentRow=eventdata.Indices(1);
%SAVE IT TO FIGURE
set(handles.figure1,'UserData',UsDat);  
%UPDATE  HANDLE
guidata(hObject, handles);
end

%GUI FUNCTION
function figure1_CloseRequestFcn(hObject, eventdata, handles)
%delete(hObject);
uiresume(handles.figure1);

