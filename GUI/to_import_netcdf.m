function varargout = to_import_netcdf(varargin)
%
% IMPORT_NETCDF MATLAB code for import_netcdf.fig
% Last Modified by GUIDE v2.5 11-Jan-2017 15:44:49
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_import_netcdf_OpeningFcn, ...
                   'gui_OutputFcn',  @to_import_netcdf_OutputFcn, ...
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

% --- Executes just before import_netcdf is made visible.
function to_import_netcdf_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% Choose default command line output for import_netcdf
handles.output = hObject;
%GET FILENAME
fname = varargin{1}.fname;
%GET INFO FROM NC FILE
finfo = ncinfo(fname);
%BUILD PARAMLIST
for i=1:length(finfo.Variables)
ParamList{i}=finfo.Variables(i).Name;
end
%BUILD DATA STRUCT
UsDat.fname = fname;
UsDat.ParamList = ParamList;
%SAVE IN FIGURE
set(handles.figure1,'UserData',UsDat);  
% Update handles structure
guidata(hObject, handles);
%GUI STUFF
set(handles.listbox1,'String',ParamList);
% UIWAIT makes import_netcdf wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = to_import_netcdf_OutputFcn(hObject, eventdata, handles) 
%GET DATA AND OUTPUT
UsDat=get(hObject,'UserData');
varargout{1}.ParamList_out = UsDat.ParamList2;
varargout{1}.PARAMETERS_out = UsDat.PARAMETERS;
varargout{1}.MMetadata_out = UsDat.MMetadata;
varargout{1}.MDim_out = UsDat.MDim;
%DELETE FIGURE
delete(hObject);

% --- Executes on button press in pushbutton1.
function pushbutton_import_Callback(hObject, eventdata, handles)
%POINTER THINKING
set(handles.figure1, 'pointer', 'watch')
drawnow;
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETER
psel=get(handles.listbox1,'Value');
%
v=ncinfo(UsDat.fname);
TIMECHAR=[];
for i=1:length(v.Dimensions)
   if(strcmpi(v.Dimensions(i).Name,'time'))
       TIMECHAR=v.Dimensions(i).Name;
       break;
   end
end
itime=ncread(UsDat.fname,TIMECHAR);

origin_time=datenum(get(handles.edit_date,'String'),'dd/mm/yyyy HH:MM:SS');
if(get(handles.radiobutton1,'Value')==1)
    dom=1;
else
    dom=1/24;
end
UsDat.MDim.Time = itime*dom + origin_time;

%DT CALCULATION
for i=1:length(itime)-1
dTime(i)=etime(datevec(itime(i+1)),datevec(itime(i)));
end
if(std(dTime) == 0) %Si pas de temps constant dT = pas de temps
    UsDat.MDim.dT=etime(datevec(itime(2)),datevec(itime(1)));
    UsDat.MDim.dTi=UsDat.MDim.dT;
else %Sinon dT=0 et il faudra le rentrer à la main pour certaines fonctions
    UsDat.MDim.dT=0;
    UsDat.MDim.dTi=mode(dTime);
end
%
finfo = ncinfo(UsDat.fname);
%LOAD PARAMETERS
UsDat.ParamList2={};
UsDat.PARAMETERS=[];
for i=1:length(psel)         
    idata=ncread(UsDat.fname,UsDat.ParamList{psel(i)});
    msii = size(idata);    
    %Test si même longueur que le temps
    msa=max(msii);
    if(msa==length(UsDat.MDim.Time))
        %
        UsDat.PARAMETERS = [UsDat.PARAMETERS TimeSerie(UsDat.ParamList{psel(i)},UsDat.MDim.Time,idata)];
        UsDat.ParamList2=[UsDat.ParamList2;UsDat.ParamList{psel(i)}];
        %associated QC values        
        for k=1:length(UsDat.ParamList)            
            if strcmp(UsDat.ParamList{k},[UsDat.ParamList{psel(i)} '_QC'])==1 
            QC_values=ncread(UsDat.fname,UsDat.ParamList{k});
            if(size(QC_values,1)>size(QC_values,2))
                QC_values = QC_values';
            end
            UsDat.PARAMETERS(end).QC_Serie=QC_values;            
            end    
        end
        %Units        
        for k=1:length(finfo.Variables(psel(i)).Attributes)
            if strcmp(finfo.Variables(psel(i)).Attributes(k).Name,'units')==1
            UsDat.PARAMETERS(end).Unit = finfo.Variables(psel(i)).Attributes(k).Value;
            break;
            end
        end
        %Long names
        for k=1:length(finfo.Variables(psel(i)).Attributes)
            if strcmp(finfo.Variables(psel(i)).Attributes(k).Name,'long_name')==1
            UsDat.PARAMETERS(end).Long_name = finfo.Variables(psel(i)).Attributes(k).Value;
            break;
            end
        end 
        %Fill Value
        for k=1:length(finfo.Variables(psel(i)).Attributes)
            if strcmp(finfo.Variables(psel(i)).Attributes(k).Name,'_FillValue')==1
            UsDat.PARAMETERS(end).FillValue = finfo.Variables(psel(i)).Attributes(k).Value;
            break;
            end
        end           
        %Valid Min
        for k=1:length(finfo.Variables(psel(i)).Attributes)
            if strcmp(finfo.Variables(psel(i)).Attributes(k).Name,'valid_min')==1
            UsDat.PARAMETERS(end).ValidMin = finfo.Variables(psel(i)).Attributes(k).Value;
            break;
            end
        end      
        %Valid Max
        for k=1:length(finfo.Variables(psel(i)).Attributes)
            if strcmp(finfo.Variables(psel(i)).Attributes(k).Name,'valid_max')==1
            UsDat.PARAMETERS(end).ValidMax = finfo.Variables(psel(i)).Attributes(k).Value;
            break;
            end
        end      
        
    end
end

%FILL METADATA STRUCT
for i=1:length(finfo.Attributes)    
    UsDat.MMetadata.Properties{i}=finfo.Attributes(i).Name;
    UsDat.MMetadata.Values{i}=finfo.Attributes(i).Value;
end
%SAVE IN FIGURE
set(handles.figure1,'UserData',UsDat);  
%UPDATE HANDLE
guidata(hObject, handles);

% The GUI is still in UIWAIT, us UIRESUME
uiresume(handles.figure1);
set(handles.figure1, 'pointer', 'arrow')
