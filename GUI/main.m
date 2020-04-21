function varargout = main(varargin)
%
% MAIN MATLAB code for main.fig
% Last Modified by GUIDE v2.5 23-Jan-2017 10:28:30
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
%
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
%
global ParamList PARAMETERS MDim MMetadata;
% Choose default command line output for main
handles.output = hObject;
%Disable some stuffs before importing data
%easier than to test all cases 
set(handles.pushbutton1,'enable','off'); set(handles.pushbutton2,'enable','off');
set(handles.pushbutton_axes1_m,'enable','off'); set(handles.pushbutton_axes1_p,'enable','off');
set(handles.edit,'enable','off'); set(handles.preprocess,'enable','off');
set(handles.plots,'enable','off'); set(handles.qualification,'enable','off');
set(handles.export,'enable','off');
%LOGO
%jh=java(findobj_java(handles.pushbutton9));
%jh.setBorderPainted(false);    
%jh.setContentAreaFilled(false);
%INIT
ParamList={};
set(handles.param_list, 'Value', []);
PARAMETERS=[];
MMetadata.Properties={};
MMetadata.Values={};
MDim.WhereToSave='';
%UPDATE HANDLE
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
%
clearvars;

%%%%%%%%%%%%%%%%%
% FILE MENU     %
%%%%%%%%%%%%%%%%%------------------------------------------------------

%%%%%%%%%%%%%%%%%
% IMPORT FILE   %
%%%%%%%%%%%%%%%%%-------------------------------------------------------
function import_Callback(hObject, eventdata, handles)
%IMPORT A DATA FILE
%
%GLOBAL VARS
global ParamList PARAMETERS MDim MMetadata;
%SELECT A PARSER
str = {'Aquadopp_Parser','Aquapro_Parser','RCM_Parser','SBE3x_Parser','SBE37SM_Parser','SBE56_Parser','WH_Parser','Continental_Parser','Signature_Parser'};
[s,v] = listdlg('PromptString','Select a Parser:','SelectionMode','single','ListString',str);
if(v==1)
ParserName=str{s};
else
    set(findall(0,'Type','figure'), 'pointer', 'arrow');    
    return;
end

try
eval(['[MDim, MData, MMetadata]=',ParserName,';']); %RUN PARSER
catch ME %IF ERRORS
    warndlg(ME.message,'Parser Error');
    set(findall(0,'Type','figure'), 'pointer', 'arrow');    
    return;
end    
%SET FIGURE TITLE
set(handles.figure1,'Name',['TOOTSEA : Tools for Time Series Exploration and Analysis : ' MDim.FileName]);
%SET PARAMLIST
Param_input_List=fieldnames(MData);
%
PARAMETERS=[];
ParamList=[];
MDim.WhereToSave='';
for i=1:length(Param_input_List)
  %CHECK SIZE OF PARAMETER
  eval(['msii = size(MData.',Param_input_List{i},');']);
  %[msi,ind]=min(msii);
  msa=max(msii);   %HyPOTHESE QUE LE NOMBRE DE PAS DE TPS > NOMBRE DE NIVEAUX
  %HAS TO BE THE SAME LENGTH THAN TIME VECTOR
  if(msa==length(MDim.Time)) 
    eval(['PARAMETERS = [PARAMETERS TimeSerie(Param_input_List{i},MDim.Time,MData.',Param_input_List{i},')];']);
    ParamList=[ParamList;Param_input_List(i)];
     if(isfield(MDim,'BinDepth'))
       if(length(MDim.BinDepth)==min(size(PARAMETERS(end).Data)))
           PARAMETERS(end).Depth=MDim.BinDepth;
       else
           %do nothing
       end     
     end
  end
end
%SEARCH DB PROPERTIES BY NAME ONLY
OSP=load('OC_params.mat');
for k=1:length(ParamList)
  oinn=find(strcmp(OSP.PARAM,ParamList{k}));
  if(~isempty(oinn))
  PARAMETERS(k).Unit=OSP.UNIT{(oinn)};
  PARAMETERS(k).Long_name=OSP.LONGNAME{(oinn)};
  PARAMETERS(k).FillValue=OSP.FILLVALUE(oinn);
  PARAMETERS(k).ValidMin=OSP.MIN(oinn);
  PARAMETERS(k).ValidMax=OSP.MAX(oinn);
  end
end
%
%GUI UPDATE
handles=update_main(hObject, eventdata, handles, ParamList, PARAMETERS, MDim, MMetadata);

%DISPLAY
handles.pl_axes1_1=PARAMETERS(1).Plot(handles.axes1);
l=legend(handles.axes1,'show');
set(l,'Interpreter', 'none');

%UPDATE HANDLE
guidata(hObject,handles);
             
%BUTTONS CHANGE
set(handles.pushbutton1,'enable','on');
set(handles.pushbutton_axes1_p,'enable','on');
set(handles.import,'enable','off');
%set(handles.import_netcdf,'enable','off');
set(handles.loadsession,'enable','off');
%ENABLE SOME ITEMS IN MENU
set(handles.edit,'enable','on');
set(handles.preprocess,'enable','on');
set(handles.plots,'enable','on');
set(handles.qualification,'enable','on');
set(handles.export,'enable','on');

%%%%%%%%%%%%%%%%%
% IMPORT NETCDF %
%%%%%%%%%%%%%%%%%-------------------------------------------------------
function import_netcdf_Callback(hObject, eventdata, handles)
%IMPORT A NETCDF FILE
%GLOBAL VARS
global ParamList PARAMETERS MMetadata MDim;
%FILE SELECTION
[FileName,PathName,~] = uigetfile('*.nc','Select Data File');
%EMPTY FILENAME
if isequal(FileName,0) 
    return; 
end
fname=[PathName FileName]; 
%SET FIGURE TITLE
set(handles.figure1,'Name',['TOOTSEA : Tools for Time Series Exploration and Analysis : ' FileName]);
%SET INPUTS FOR import_netcdf FUNCTION
varinp.fname=fname;
NN=to_import_netcdf(varinp);
%GET OUTPUT
% ParamList = NN.ParamList_out;
% PARAMETERS = NN.PARAMETERS_out;
% MMetadata = NN.MMetadata_out;
% MDim = NN.MDim_out;
MDim.FileName=FileName;
MDim.WhereToSave='';
%
ParamList = [ParamList; NN.ParamList_out];
PARAMETERS = [PARAMETERS NN.PARAMETERS_out];
MMetadata.Properties = [MMetadata.Properties(:);NN.MMetadata_out.Properties(:)];
MMetadata.Values = [MMetadata.Values(:);NN.MMetadata_out.Values(:)];
%GUI UPDATE
handles=update_main(hObject, eventdata, handles, ParamList, PARAMETERS, MDim, MMetadata);
%DISPLAY
if(isempty(get(handles.axes1,'Children')))
    handles.pl_axes1_1=PARAMETERS(1).Plot(handles.axes1);
    l=legend(handles.axes1,'show');
    set(l,'Interpreter', 'none');
end

%UPDATE HANDLE
guidata(hObject,handles);                   
%BUTTONS CHANGE
set(handles.pushbutton1,'enable','on');
set(handles.pushbutton_axes1_p,'enable','on');
set(handles.import,'enable','off');
%set(handles.import_netcdf,'enable','off');
set(handles.loadsession,'enable','off');
%ENABLE SOM ITEMS IN MENU
set(handles.edit,'enable','on');
set(handles.preprocess,'enable','on');
set(handles.plots,'enable','on');
set(handles.qualification,'enable','on');
set(handles.export,'enable','on');

%%%%%%%%%%%%%%%%%
% EXPORT TO NC  %
%%%%%%%%%%%%%%%%%---------------------------------------------------------

function export_nc_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim MMetadata ;
%SET INPUT FOR export_nc function
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
varinp.MDim_in = MDim;
varinp.MMetadata_in = MMetadata;
NN=to_export_nc(varinp);

%GET OUTPUT
ParamList = NN.ParamList_out;
PARAMETERS = NN.PARAMETERS_out;
MDim = NN.MDim_out;
MMetadata = NN.MMetadata_out;

%UPDATE FIGURE IF META OR PARAM MODIFIED IN EXPORT PROCESS
handles=update_main(hObject, eventdata, handles, ParamList, PARAMETERS, MDim, MMetadata);

%%%%%%%%%%%%%%%%%%%%
% EXPORT TO ASCII  %
%%%%%%%%%%%%%%%%%%%%------------------------------------------------------

function export_ascii_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim;
[s,v] = listdlg('PromptString','Select series to export :','ListString',ParamList);
if(v==0)
    return;
else
   [FileName,PathName] = uiputfile('*.txt','Export to ascii file',strrep(MDim.FileName,'.','-'));
   if isequal(FileName,0) 
    return; 
   end
   fid = fopen([PathName FileName],'w');
   for i=s
     fprintf(fid,'Time(dec_days) %10s (%d lines)\n',ParamList{i},length(PARAMETERS(i).Data));    
     msiz=size(PARAMETERS(i).Data,1);
     %SINGLE LEVEL
     if msiz==1
        fprintf(fid,'%9.4f %10.5f\n',[PARAMETERS(i).Time(:)'; PARAMETERS(i).Data(msiz,:)']);    
     %MULTILEVEL 
     else
        mform='%9.4f';
        for k=1:msiz
            mform=[mform ' %10.5f'];
        end
        mform=[mform '\n'];        
        fprintf(fid,mform,[PARAMETERS(i).Time(:)'; PARAMETERS(i).Data(:,:)]);              
     end
     % ENDING SEPARATOR
     fprintf(fid,'*************\n');    
     fprintf(fid,'\n');    
   end
   fclose(fid)
   h = msgbox(['File ' FileName ' created']);
end

%%%%%%%%%%%%%%%%%
% SAVE SESSION  %
%%%%%%%%%%%%%%%%%--------------------------------------------------------
function savesession_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim MMetadata ;
[FileName,PathName] = uiputfile('*.mat','Export session to .mat file',strrep(MDim.FileName,'.','-'));
%EMPTY FILENAME
if isequal(FileName,0) 
    return; 
end
set(gcf, 'pointer', 'watch');
save([PathName FileName],'ParamList','PARAMETERS','MDim','MMetadata','-v7.3');
set(findall(0,'Type','figure'), 'pointer', 'arrow');
drawnow;
MDim.WhereToSave = [PathName FileName];
%

%%%%%%%%%%%%%%%%%
% LOAD SESSION  %
%%%%%%%%%%%%%%%%%--------------------------------------------------------
function loadsession_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim MMetadata ;
[FileName,PathName] = uigetfile('*.mat');

if isequal(FileName,0) 
    return; 
end
set(gcf, 'pointer', 'watch');

MDim.FileName=FileName;
load([PathName FileName]);
MDim.WhereToSave = [PathName FileName];
%SET FIGURE TITLE
set(handles.figure1,'Name',['TOOTSEA : Tools for Time Series Exploration and Analysis : ' FileName]);

%CREATE COMMENT IF NOT THERE %TEMPORARY
for i=1:length(ParamList)
    if(~isprop(PARAMETERS(i),'Comment'))
        PARAMETERS(i).Comment='/';
    end
end

%UPDATE FIGURE
handles=update_main(hObject, eventdata, handles, ParamList, PARAMETERS, MDim, MMetadata);
%
%DISPLAY
cla(gca,'reset');
handles.pl_axes1_1=PARAMETERS(1).Plot(handles.axes1);
l=legend(handles.axes1,'show');
set(l,'Interpreter', 'none');

set(findall(0,'Type','figure'), 'pointer', 'arrow');
drawnow;
%UPDATE HANDLE
guidata(hObject,handles);                   
%BUTTONS CHANGE
set(handles.pushbutton1,'enable','on');
set(handles.pushbutton_axes1_p,'enable','on');
set(handles.import,'enable','off');
%set(handles.import_netcdf,'enable','off');
set(handles.loadsession,'enable','off');
%ENABLE SOM ITEMS IN MENU
set(handles.edit,'enable','on');
set(handles.preprocess,'enable','on');
set(handles.plots,'enable','on');
set(handles.qualification,'enable','on');
set(handles.export,'enable','on');

%%%%%%%%%%%%%%%%%
% RESET GUI     %
%%%%%%%%%%%%%%%%%--------------------------------------------------------
function reset_gui_Callback(hObject, eventdata, handles)
choice = questdlg('Save session before quiting ?', 'Quit', 'Yes please','No thank you','Yes please');
% Handle response
switch choice
    case 'Yes please'
    savesession_Callback(hObject, eventdata, handles)      
    delete(handles.figure1);
    main();        
    case 'No thank you'
    delete(handles.figure1);
    main();
end


%%%%%%%%%%%%%%%%%
% EDIT MENU     %
%%%%%%%%%%%%%%%%%--------------------------------------------------------

% EDIT PARAMETERS %
%-----------------------------------------------------------------------
function edit_parameters_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim MMetadata;
%SET INPUT FOR edit_param FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
NN=to_edit_param(varinp);
%GET OUTPUT
ParamList = NN.ParamList_out;
PARAMETERS = NN.PARAMETERS_out;
%UPDATE FIGURE
handles=update_main(hObject, eventdata, handles, ParamList, PARAMETERS, MDim, MMetadata);

% NEW PARAMETER %
% --------------------------------------------------------------------
function newparam_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim MMetadata;
%SET INPUT FOR new_param FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
varinp.MMetadata_in = MMetadata;
NN=to_new_param(varinp);
%GET OUTPUT
ParamList = NN.ParamList_out;
PARAMETERS = NN.PARAMETERS_out;
%UPDATE FIGURE
handles=update_main(hObject, eventdata, handles, ParamList, PARAMETERS, MDim, MMetadata);

% EDIT METADATA %
% --------------------------------------------------------------------
function edit_metadata_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global MMetadata;
%SET INPUT FOR edit_meta FUNCTION
varinp.MMetadata_in = MMetadata;
NN=to_edit_meta(varinp);
%GET OUTPUT
MMetadata = NN.MMetadata_out;
%DISPLAY
TDisp={};
for i=1:length(MMetadata.Properties)
TDisp{i}=['# ',MMetadata.Properties{i},' : ',MMetadata.Values{i}];
end
set(handles.text2,'string',TDisp);

% MERGE PARAMETER %
% --------------------------------------------------------------------
function merge_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim MMetadata;
%SET INPUT FOR new_param FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
NN=to_merge(varinp);
%GET OUTPUT
ParamList = NN.ParamList_out;
PARAMETERS = NN.PARAMETERS_out;
%UPDATE FIGURE
handles=update_main(hObject, eventdata, handles, ParamList, PARAMETERS, MDim, MMetadata);

%%%%%%%%%%%%%%%%%%%
% CORRECTION MENU %
%%%%%%%%%%%%%%%%%%%------------------------------------------------------

% SUBSERIE %
% --------------------------------------------------------------------
function magdec_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim MMetadata;
%Check lat,lon,depth to calculate declination
tocheck={'Latitude';'Longitude';'Nominal_depth'};
ind=0;
for i=1:length(tocheck)
   if(find(strcmp(MMetadata.Properties,tocheck{i}))>0) 
       ind=ind+1; 
   end    
end
if(ind==3)
    %SET INPUT FOR magdec FUNCTION
    varinp.ParamList_in = ParamList;
    varinp.PARAMETERS_in = PARAMETERS;
    varinp.MMetadata_in = MMetadata;
    NN=to_magdec(varinp);
    %GET OUTPUT
    ParamList = NN.ParamList_out;
    PARAMETERS = NN.PARAMETERS_out;
    MMetadata = NN.MMetadata_out;
    %UPDATE FIGURE
    handles=update_main(hObject, eventdata, handles, ParamList, PARAMETERS, MDim, MMetadata);
else
    warndlg('"Latitude", "Longitude" & "Nominal_depth" are mandatory to calculate declination, Please edit metadata');
    return;
end

% SUBSERIE %
% --------------------------------------------------------------------
function subserie_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim MMetadata;
%SET INPUT FOR subserie FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
NN=to_subserie(varinp);
%GET OUTPUT
ParamList = NN.ParamList_out;
PARAMETERS = NN.PARAMETERS_out;
%UPDATE FIGURE
handles=update_main(hObject, eventdata, handles, ParamList, PARAMETERS, MDim, MMetadata);

% MEDIAN FILTER %
% --------------------------------------------------------------------
function medianfilter_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim MMetadata;
%SET INPUT FOR mfilter FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
NN=to_omedianfilter(varinp);
%GET OUTPUT
ParamList = NN.ParamList_out;
PARAMETERS = NN.PARAMETERS_out;
%UPDATE FIGURE
handles=update_main(hObject, eventdata, handles, ParamList, PARAMETERS, MDim, MMetadata);

% INTERPOLATE %
% --------------------------------------------------------------------
function interpolate_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim MMetadata;
%SET INPUT FOR tinterp FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
varinp.MDim_in = MDim;
NN=to_tinterp(varinp);
%GET OUTPUT
ParamList = NN.ParamList_out;
PARAMETERS = NN.PARAMETERS_out;
MDim = NN.MDim_out;
%UPDATE FIGURE
handles=update_main(hObject, eventdata, handles, ParamList, PARAMETERS, MDim, MMetadata);

% DRIFT CORRECTION %
% --------------------------------------------------------------------
function drift_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim MMetadata;
%SET INPUT FOR drift_cor FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
varinp.MDim_in = MDim;
NN=to_drift_cor(varinp);
%GET OUTPUT
ParamList = NN.ParamList_out;
PARAMETERS = NN.PARAMETERS_out;
MDim = NN.MDim_out;
%UPDATE FIGURE
handles=update_main(hObject, eventdata, handles, ParamList, PARAMETERS, MDim, MMetadata);

% TEMPO DRIFT CORRECTION %
% --------------------------------------------------------------------
function drift_tempo_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim MMetadata;
%SET INPUT FOR drift_cor FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
varinp.MDim_in = MDim;
NN=to_drift_tempo_cor(varinp);
%GET OUTPUT
ParamList = NN.ParamList_out;
PARAMETERS = NN.PARAMETERS_out;
MDim = NN.MDim_out;
%
%UPDATE FIGURE
handles=update_main(hObject, eventdata, handles, ParamList, PARAMETERS, MDim, MMetadata);


% SUBSAMPLE %
% --------------------------------------------------------------------
function subsample_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MUnits MDim MMetadata MLgnames;
%SET INPUT FOR subserie FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
varinp.MDim_in = MDim;
NN=to_subsample(varinp);
%GET OUTPUT
ParamList = NN.ParamList_out;
PARAMETERS = NN.PARAMETERS_out;
MDim = NN.MDim_out;
%UPDATE FIGURE
handles=update_main(hObject, eventdata, handles, ParamList, PARAMETERS, MDim, MMetadata);

%%%%%%%%%%%%%%%%%
% PLOT & STATS  %
%%%%%%%%%%%%%%%%%--------------------------------------------------------

% HISTOGRAM %
% --------------------------------------------------------------------
function histogram_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim;
%SET INPUT FOR t_histogram FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
varinp.MDim_in = MDim;
to_histogram(varinp);

% DISPERSION %
% --------------------------------------------------------------------
function dispersion_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim;
%SET INPUT FOR dispersion FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
varinp.MDim_in = MDim;
to_dispersion(varinp);

% SPECTRUM %
% --------------------------------------------------------------------
function spectrum_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim;
%SET INPUT FOR spectrum FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
varinp.MDim_in = MDim;
to_spectrum(varinp);

% STICKPLOT %
% --------------------------------------------------------------------
function stickplot_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim;
%SET INPUT FOR dispersion FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
varinp.MDim_in = MDim;
to_stickplot(varinp);

% PCOLOR %
% --------------------------------------------------------------------
function mpcolor_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim;
%SET INPUT FOR dispersion FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
varinp.MDim_in = MDim;
to_pcolor(varinp);

% GLOBAL STATS %
% --------------------------------------------------------------------
function globalstats_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim MMetadata;
assignin('base','PARAMETERS',PARAMETERS);
assignin('base','ParamList',ParamList);
assignin('base','MDim',MDim);
assignin('base','MMetadata',MMetadata);
% SET INPUT FOR global_stats FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
varinp.MDim_in = MDim;
to_global_stats(varinp);

%%%%%%%%%%%%%%%%%
% QUALIFICATION %
%%%%%%%%%%%%%%%%%--------------------------------------------------------

% AUTOMATIC QC %
% --------------------------------------------------------------------
function automatic_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim MMetadata;
%SET INPUT FOR QC_Manual FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
varinp.MMetadata_in = MMetadata;
NN=to_automatic_qc(varinp);
%GET OUTPUT
PARAMETERS = NN.PARAMETERS_out;
MMetadata = NN.MMetadata_out;
%UPDATE FIGURE
handles=update_main(hObject, eventdata, handles, ParamList, PARAMETERS, MDim, MMetadata);

% MANUAL QC %
% --------------------------------------------------------------------
function manual_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim MMetadata;
%SET INPUT FOR QC_Manual FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
NN=to_QC_Manual(varinp);
%GET OUTPUT
PARAMETERS = NN.PARAMETERS_out;
%UPDATE FIGURE
handles=update_main(hObject, eventdata, handles, ParamList, PARAMETERS, MDim, MMetadata);

% CUSTOM QC %
% --------------------------------------------------------------------
function customQC_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim MMetadata;
%SET INPUT FOR new_param FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
NN=to_customQC(varinp);
%GET OUTPUT
ParamList = NN.ParamList_out;
PARAMETERS = NN.PARAMETERS_out;
%UPDATE FIGURE
handles=update_main(hObject, eventdata, handles, ParamList, PARAMETERS, MDim, MMetadata);

% DISPLAY QC %
% --------------------------------------------------------------------
function qcdisplay_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim;
%SET INPUT FOR dispersion FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
varinp.MDim_in = MDim;
to_qcdisp(varinp);

% DISPLAY QC SERIE%
% --------------------------------------------------------------------
function qcserieplot_Callback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim;
%SET INPUT FOR dispersion FUNCTION
varinp.ParamList_in = ParamList;
varinp.PARAMETERS_in = PARAMETERS;
varinp.MDim_in = MDim;
to_qcserieplot(varinp);

%%%%%%%%%%%%%%%%%
% ABOUT MENU    %
%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function help_Callback(hObject, eventdata, handles)
%check os
osh=[ispc isunix ismac];
if osh == [1 0 0]    
    winopen docs/TOOTSEA.pdf;    
elseif osh == [0 1 0]    
    system('xdg-open docs/TOOTSEA.pdf');   
elseif osh == [0 0 1]
    system('open docs/TOOTSEA.pdf');        
end

% --------------------------------------------------------------------
function contacts_Callback(hObject, eventdata, handles)
str={'';...
'Toolbox for Time Series Exploration and Analysis';...
'';...
'Please report issues on github.com/quai20/TOOTSEA';...
'Laboratoire d''Océanographie Physique et Spatiale (LOPS)';...
'IFREMER - ZI de la pointe du diable ';...
'CS 10070 - 29280 PLOUZANE';...
''};
msgbox(str,'About','modal');

%%%%%%%%%%%%%%%%%
% CLOSE REQUEST %-- Executes when user attempts to close figure1.
%%%%%%%%%%%%%%%%%------------------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
%
choice = questdlg('Save session before quiting ?', 'Quit', 'Yes please','No thank you','Yes please');
% Handle response
switch choice
    case 'Yes please'
    savesession_Callback(hObject, eventdata, handles)  
    delete(handles.figure1);
    case 'No thank you'
    delete(handles.figure1);
end

%%%%%%%%%%%%%%%%%
% SAVE FIGURE   %
%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function uipushtool3_ClickedCallback(hObject, eventdata, handles)
global MDim;
%SAVE FIGURE
[FileName,PathName] = uiputfile({'*.pdf';'*.eps';'*.png';'*.tiff';'*.jpeg';'*.bmp'},'Save as',[strrep(MDim.FileName,'.','-') '-main']);
if isequal(FileName,0) 
    return; 
end
%NUMBER OF AXES IN FIGURE
prax=isfield(handles,'axes1')+isfield(handles,'axes2')+isfield(handles,'axes3')+isfield(handles,'axes4')+isfield(handles,'axes5');
%EXPORT AXES
switch prax
    case 1
    export_fig(handles.axes1,[PathName FileName]);    
    case 2    
    export_fig([handles.axes1 handles.axes2],[PathName FileName]); 
    case 3
    export_fig([handles.axes1 handles.axes2 handles.axes3],[PathName FileName]);     
    case 4
    export_fig([handles.axes1 handles.axes2 handles.axes3 handles.axes4],[PathName FileName]);     
    case 5
    export_fig([handles.axes1 handles.axes2 handles.axes3 handles.axes4 handles.axes5],[PathName FileName]);     
end

%%%%%%%%%%%%%%%%%
% SAVE SESSION  %
%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function uipushtool_t_ClickedCallback(hObject, eventdata, handles)
%GLOBAL VARS
global ParamList PARAMETERS MDim MMetadata ;
if(~strcmp(MDim.WhereToSave,''))
    answer = questdlg(['Overwrite ' MDim.WhereToSave],'Save session','Yes','No','Yes');
    % Handle response
    switch answer
        case 'Yes'
            set(gcf, 'pointer', 'watch');
            save(MDim.WhereToSave,'ParamList','PARAMETERS','MDim','MMetadata','-v7.3');
            set(findall(0,'Type','figure'), 'pointer', 'arrow');
            drawnow;
        case 'No'
            [FileName,PathName] = uiputfile('*.mat','Export session to .mat file',strrep(MDim.FileName,'.','-'));
            %EMPTY FILENAME
            if isequal(FileName,0) 
                return; 
            end
            set(gcf, 'pointer', 'watch');
            save([PathName FileName],'ParamList','PARAMETERS','MDim','MMetadata','-v7.3');
            set(findall(0,'Type','figure'), 'pointer', 'arrow');
            drawnow;
            MDim.WhereToSave = [PathName FileName];         
    end 
else
    [FileName,PathName] = uiputfile('*.mat','Export session to .mat file',strrep(MDim.FileName,'.','-'));
    %EMPTY FILENAME
    if isequal(FileName,0) 
        return; 
    end
    set(gcf, 'pointer', 'watch');
    save([PathName FileName],'ParamList','PARAMETERS','MDim','MMetadata','-v7.3');
    set(findall(0,'Type','figure'), 'pointer', 'arrow');
    drawnow;
    MDim.WhereToSave = [PathName FileName];
end

%%%%%%%%%%%%%%%%%
% AXIS HANDLING %
%%%%%%%%%%%%%%%%%
% --- Add axes to the figure
function pushbutton1_Callback(hObject, eventdata, handles)
add_axes(hObject, eventdata, handles);  

% --- remove axes from figure
function pushbutton2_Callback(hObject, eventdata, handles)
rem_axes(hObject, eventdata, handles);

% --- PLOT WHEN SELECTING PARAMETER
function popupmenu_Callback(hObject, eventdata, handles, xaxes, rang)
%GLOBAL VARS
global ParamList PARAMETERS;
%GET SELECTED PARAMETERS
val = get(hObject,'Value');

try %DELETE ANY EXISTING PLOT
  eval(['delete(handles.pl_',xaxes,'_',rang,');']); 
catch
  %do nothing
end
%PLOT
eval(['handles.pl_',xaxes,'_',rang,'=','PARAMETERS(val).Plot(handles.',xaxes,');']);    
eval(['legend(handles.',xaxes,',''off'');']);
eval(['l=legend(handles.',xaxes,',''show'');']);
set(l,'Interpreter', 'none');
% 
%DATE TICK ON ALL AXES PRESENT
try    
%     dynamicDateTicks([handles.axes1 handles.axes2],'linked');
      dateNtick('x',20,'linked_axes','axes_handle',[handles.axes1 handles.axes2]);  
%     dynamicDateTicks([handles.axes1 handles.axes2 handles.axes3],'linked');
      dateNtick('x',20,'linked_axes','axes_handle',[handles.axes1 handles.axes2 handles.axes3]);  
%     dynamicDateTicks([handles.axes1 handles.axes2 handles.axes3 handles.axes4],'linked');
      dateNtick('x',20,'linked_axes','axes_handle',[handles.axes1 handles.axes2 handles.axes3 handles.axes4]);    
%     dynamicDateTicks([handles.axes1 handles.axes2 handles.axes3 handles.axes4 handles.axes5],'linked');
      dateNtick('x',20,'linked_axes','axes_handle',[handles.axes1 handles.axes2 handles.axes3 handles.axes4 handles.axes5]);  
catch 
    %
end
% Save the handles structure.
guidata(hObject,handles);

% --- add a plot on same axes
function pushbutton_ap_Callback(hObject, eventdata, handles, xaxes)
%move "+" and "-" 
usd=get(hObject,'UserData');
eval(['aa=get(handles.popupmenu',xaxes(end),',''Position'');']);
bb1=[aa(1) aa(2)-0.036*(usd-1) aa(3) aa(4)];
bb2=[aa(1) aa(2)-0.036*(usd-1) aa(3) aa(4)];
cc=[bb1(1)+0.015 bb1(2)-0.03 0.021 0.03];
dd=[bb1(1)+0.040 bb1(2)-0.03 0.021 0.03];
%Button rank
rang=num2str(get(hObject,'UserData'));
prang=num2str(get(hObject,'UserData')+1);
eval(['set(handles.pushbutton_',xaxes,'_p,''Position'',[',num2str(cc),']);']);
eval(['set(handles.pushbutton_',xaxes,'_m,''Position'',[',num2str(dd),']);']);
%add popupmenu
eval(['handles.popupmenu_',xaxes,'_',rang,'=uicontrol(''Style'',''popupmenu'',''String'',get(handles.popupmenu1,''String''),',...
                          '''Unit'',''normalized'',''FontSize'',8,''Position'',[',num2str(bb2),'],''Callback'',',...
                          '@(hObject,eventdata)main(''popupmenu_Callback'',hObject,eventdata,guidata(hObject),','''',xaxes,'''',',','''',rang,'''','));']);                                            
eval(['guidata(handles.popupmenu_',xaxes,'_',rang,',handles);']);            
%set Buttons.UserData to +1
eval(['set(handles.pushbutton_',xaxes,'_p,''UserData'',',prang,');']);
eval(['set(handles.pushbutton_',xaxes,'_m,''UserData'',',prang,');'])
%enable or disable buttons
eval(['set(handles.pushbutton_',xaxes,'_m,''Enable'',''on'');']);

if (get(hObject,'UserData')+1) == 7
   eval(['set(handles.pushbutton_',xaxes,'_p,''Enable'',''off'');']);
else
   eval(['set(handles.pushbutton_',xaxes,'_p,''Enable'',''on'');']); 
end

%Save buttons
eval(['guidata(handles.pushbutton_',xaxes,'_p,handles);']);            
eval(['guidata(handles.pushbutton_',xaxes,'_m,handles);']);            

% --- remove a plot from same axis
function pushbutton_am_Callback(hObject, eventdata, handles, xaxes)
%delete popupmenu
prang=num2str(get(hObject,'UserData')-1);
try
    eval(['delete(handles.pl_',xaxes,'_',prang,');']); 
    eval(['l=legend(handles.',xaxes,',''off'');']);
    eval(['l=legend(handles.',xaxes,',''show'');']);
    set(l,'interpreter','none');
catch 
    %do nothing
end
eval(['delete(handles.popupmenu_',xaxes,'_',prang,');']);
%move up buttons
aa=get(hObject,'Position');
eval(['set(handles.pushbutton_',xaxes,'_p,''Position'',[aa(1)-0.025 aa(2)+0.036 aa(3) aa(4)]);']);
eval(['set(handles.pushbutton_',xaxes,'_m,''Position'',[aa(1) aa(2)+0.036 aa(3) aa(4)]);']);
%set Buttons.UserData to -1
eval(['set(handles.pushbutton_',xaxes,'_p,''UserData'',',prang,');']);
eval(['set(handles.pushbutton_',xaxes,'_m,''UserData'',',prang,');']);
%enable or disable buttons
eval(['set(handles.pushbutton_',xaxes,'_p,''Enable'',''on'');']);
if (get(hObject,'UserData')-1) == 1
   eval(['set(handles.pushbutton_',xaxes,'_m,''Enable'',''off'');']);
else
   eval(['set(handles.pushbutton_',xaxes,'_m,''Enable'',''on'');']);
end
%save buttons
eval(['guidata(handles.pushbutton_',xaxes,'_p,handles);']);            
eval(['guidata(handles.pushbutton_',xaxes,'_m,handles);']); 

