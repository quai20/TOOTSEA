function varargout = to_magdec(varargin)
%
% EXPORT_NC MATLAB code for export_nc.fig
% Last Modified by GUIDE v2.5 30-May-2017 10:35:00
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_magdec_OpeningFcn, ...
                   'gui_OutputFcn',  @to_magdec_OutputFcn, ...
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

% --- Executes just before to_magdec is made visible.
function to_magdec_OpeningFcn(hObject, eventdata, handles, varargin)
%
%GET INPUT DATA
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
UsDat.MMetadata = varargin{1}.MMetadata_in;
%CALCULATE DECLINATION
la=str2num(UsDat.MMetadata.Values{find(strcmp(UsDat.MMetadata.Properties,'Latitude'))});
lo=str2num(UsDat.MMetadata.Values{find(strcmp(UsDat.MMetadata.Properties,'Longitude'))});
dep=str2num(UsDat.MMetadata.Values{find(strcmp(UsDat.MMetadata.Properties,'Nominal_depth'))});
%max depth for geomag is 1000m
if(dep>1000)
    dep=-1000;
else
    dep=-dep;
end
%calculation
[dec,~,~,~,~,~] = geomag70(la,lo,dep,UsDat.PARAMETERS(1).Time(floor(end/2)));
%display
set(handles.edit_dec,'String',num2str(dec));
UsDat.dec=dec;
%SAVE
set(handles.figure1,'UserData',UsDat);  
%DISPLAY
set(handles.listbox1,'string',UsDat.ParamList);
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes filter wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = to_magdec_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
%GET DATA AND OUTPUT
UsDat=get(handles.figure1,'UserData');
varargout{1}.ParamList_out = UsDat.ParamList;
varargout{1}.PARAMETERS_out = UsDat.PARAMETERS;
varargout{1}.MMetadata_out = UsDat.MMetadata;
%DELETE FIGURE
delete(hObject);

% --- Executes on button press in pushbutton_eval.
function pushbutton_eval_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
PARAMETERS=UsDat.PARAMETERS;
%clear error log
set(handles.edit_err,'String','');
%ASSIGN VAR 
for i=1:length(PARAMETERS)
   eval([UsDat.ParamList{i},'= PARAMETERS(i);']); 
end
dec=UsDat.dec;
%GET TEXT TO RUN
stred=get(handles.edit_com,'String');
%EVAL OR DISPLAY ERROR
try
    ltev='';
    for i=1:length(stred)
    ltev=[ltev sprintf('\n') stred{i}];
    end    
    eval(ltev);
    %CREATE NEW SERIES
    for k=1:4 %floor((length(stred)-6)/3)        
        %test exist variable Name and Data
        ae=exist(['var' num2str(k) 'Name'],'var')+exist(['var' num2str(k) 'Time'],'var')+exist(['var' num2str(k) 'Data'],'var');
        if(ae~=3)
            break;
        end
        eval(['NewParamName = var',num2str(k),'Name;']);
        eval(['NewParamTime = var',num2str(k),'Time;']);
        eval(['NewParamData = var',num2str(k),'Data;']);
        eval(['NewParamDepth = var',num2str(k),'Depth;']);
        eval([NewParamName,'= TimeSerie(''',NewParamName,''',NewParamTime,NewParamData);']);        
        UsDat.ParamList=[UsDat.ParamList;{NewParamName}];
        eval(['UsDat.PARAMETERS=[UsDat.PARAMETERS ',NewParamName,'];']);       
        %SAVE DEPTH
        UsDat.PARAMETERS(end).Depth=NewParamDepth;
        %SEARCH OCEANSITE PROPERTIES BY NAME ONLY
        OSP=load('OC_params.mat');
        oinn=find(strcmp(OSP.PARAM,UsDat.ParamList{end}));
        if(~isempty(oinn))
            UsDat.PARAMETERS(end).Unit=OSP.UNIT{(oinn)};
            UsDat.PARAMETERS(end).Long_name=OSP.LONGNAME{(oinn)};
            UsDat.PARAMETERS(end).FillValue=OSP.FILLVALUE(oinn);
            UsDat.PARAMETERS(end).ValidMin=OSP.MIN(oinn);
            UsDat.PARAMETERS(end).ValidMax=OSP.MAX(oinn);
        end
    % 
    end
    %ADD SERIES TO LISTBOX1       
    set(handles.listbox1,'Value',1);
    set(handles.listbox1,'String',UsDat.ParamList);
    set(handles.listbox1,'BackgroundColor','g');
    pause(0.5);
    set(handles.listbox1,'BackgroundColor','w');
%IF ERROR, THROW MESSAGE IN MSGBOX    
catch ME
    set(handles.edit_err,'String',ME.message);
    set(handles.edit_err,'Backgroundcolor','r');
    pause(0.5);
    set(handles.edit_err,'Backgroundcolor','w');
end
%SAVE DATA IN FIGURE
set(handles.figure1,'UserData',UsDat);  
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
%delete(hObject);
uiresume(handles.figure1);
