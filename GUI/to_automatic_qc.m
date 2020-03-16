function varargout = to_automatic_qc(varargin)
%
% Last Modified by GUIDE v2.5 06-Mar-2017 10:16:01
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_automatic_qc_OpeningFcn, ...
                   'gui_OutputFcn',  @to_automatic_qc_OutputFcn, ...
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

% --- Executes just before automatic_qc is made visible.
function to_automatic_qc_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for automatic_qc
handles.output = hObject;
%GET INPUT PARAMETERS
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
UsDat.MMetadata = varargin{1}.MMetadata_in;
%GUI STUFF
set(handles.popupmenu_param,'String',UsDat.ParamList);
set(handles.popupmenu_param,'Value',1);
set(handles.listbox_lev,'String',num2str([1:size(UsDat.PARAMETERS(1).Data,1)]'));
set(handles.listbox_lev,'Value',1);
%PLOT
plot(handles.axes1,UsDat.PARAMETERS(1).Time,UsDat.PARAMETERS(1).Data(1,:),'.');

hold(handles.axes1,'on'); grid(handles.axes1,'on'); set(handles.axes1,'Fontsize',8);
%dynamicDateTicks(handles.axes1);
dateNtick('x',20,'axes_handle',handles.axes1);  
ylabel([UsDat.ParamList{1} '(' UsDat.PARAMETERS(1).Unit ')']); 
guidata(hObject,handles);
%PRINT EXISTING QC ARRAY FOR THIS PARAMETER
tcolors=[0 0 1 ; 0 1 0 ; 0.95 0.5 0 ; 1 1 0 ; ...
        1 0 0 ; 0.75 0.0 0.79 ; 0.6 0.2 0 ; ... 
        0.1 0.4 0 ; 0.55 0.85 0.91 ; 0.49 0.49 0.49];
for j=1:10    
  plot(handles.axes1,UsDat.PARAMETERS(1).Time(UsDat.PARAMETERS(1).QC_Serie(1,:)==j-1),UsDat.PARAMETERS(1).Data(1,UsDat.PARAMETERS(1).QC_Serie(1,:)==j-1),'.','Color',tcolors(j,:));
end  
%reverse axis
if(~isempty(strfind(UsDat.ParamList{1},'PRES')) || ~isempty(strfind(UsDat.ParamList{1},'DEPTH')) || ~isempty(strfind(UsDat.ParamList{1},'DEPH'))) 
    set(handles.axes1,'YDir','reverse');
else
    set(handles.axes1,'YDir','default');
end
%SAVE IN FIGURE USER DATA
set(handles.figure1,'UserData',UsDat);  
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes QC_Manual wait for user response (see UIRESUME)
 uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = to_automatic_qc_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
%GET DATA TO OUTPUT THE UIFUNCTION
UsDat=get(hObject,'UserData');
varargout{1}.PARAMETERS_out = UsDat.PARAMETERS;
varargout{1}.MMetadata_out = UsDat.MMetadata;
cla;
delete(hObject);

% --- Executes on selection change in popupmenu_param.
function popupmenu_param_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETERS
val = get(hObject,'Value'); 
%
set(handles.listbox_lev,'String',num2str([1:size(UsDat.PARAMETERS(val).Data,1)]'));
set(handles.listbox_lev,'Value',1);
%DISPLAY SERIE
cla(handles.axes1);
plot(handles.axes1,UsDat.PARAMETERS(val).Time,UsDat.PARAMETERS(val).Data(1,:),'.');
hold(handles.axes1,'on'); grid(handles.axes1,'on'); set(handles.axes1,'Fontsize',8);
%dynamicDateTicks(handles.axes1);
dateNtick('x',20,'axes_handle',handles.axes1);  
ylabel([UsDat.ParamList{val} '(' UsDat.PARAMETERS(val).Unit ')']); 
%PRINT EXISTING QC ARRAY FOR THIS PARAMETER
tcolors=[0 0 1 ; 0 1 0 ; 0.95 0.5 0 ; 1 1 0 ; ...
        1 0 0 ; 0.75 0.0 0.79 ; 0.6 0.2 0 ; ... 
        0.1 0.4 0 ; 0.55 0.85 0.91 ; 0.49 0.49 0.49];
for j=1:10    
  plot(handles.axes1,UsDat.PARAMETERS(val).Time(UsDat.PARAMETERS(val).QC_Serie(1,:)==j-1),UsDat.PARAMETERS(val).Data(1,UsDat.PARAMETERS(val).QC_Serie(1,:)==j-1),'.','Color',tcolors(j,:));
end  
%reverse axis
if(~isempty(strfind(UsDat.ParamList{val},'PRES')) || ~isempty(strfind(UsDat.ParamList{val},'DEPTH')) || ~isempty(strfind(UsDat.ParamList{val},'DEPH'))) 
    set(handles.axes1,'YDir','reverse');
else
    set(handles.axes1,'YDir','default');
end
%SAVE
set(handles.figure1,'UserData',UsDat);
guidata(hObject,handles);

function listbox_lev_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETERS
val = get(handles.popupmenu_param,'Value'); 
lev = get(hObject,'Value'); 
%
%DISPLAY SERIE
cla(handles.axes1);
for i=1:length(lev)
    plot(handles.axes1,UsDat.PARAMETERS(val).Time,UsDat.PARAMETERS(val).Data(lev(i),:)+(i-1)*UsDat.PARAMETERS(val).p2p,'.'); %avec test level up
    hold(handles.axes1,'on'); 
    %PRINT EXISTING QC ARRAY FOR THIS PARAMETER
tcolors=[0 0 1 ; 0 1 0 ; 0.95 0.5 0 ; 1 1 0 ; ...
        1 0 0 ; 0.75 0.0 0.79 ; 0.6 0.2 0 ; ... 
        0.1 0.4 0 ; 0.55 0.85 0.91 ; 0.49 0.49 0.49];
    for j=1:10    
        plot(handles.axes1,UsDat.PARAMETERS(val).Time(UsDat.PARAMETERS(val).QC_Serie(lev(i),:)==j-1),...
            UsDat.PARAMETERS(val).Data(lev(i),UsDat.PARAMETERS(val).QC_Serie(lev(i),:)==j-1)+(i-1)*UsDat.PARAMETERS(val).p2p,'.','Color',tcolors(j,:));  %test levelup
    end  
end
grid(handles.axes1,'on'); 
set(handles.axes1,'Fontsize',8);
%dynamicDateTicks(handles.axes1);
dateNtick('x',20,'axes_handle',handles.axes1);  
ylabel([UsDat.ParamList{val} '(' UsDat.PARAMETERS(val).Unit ')']); 
%reverse axis
if(~isempty(strfind(UsDat.ParamList{val},'PRES')) || ~isempty(strfind(UsDat.ParamList{val},'DEPTH')) || ~isempty(strfind(UsDat.ParamList{val},'DEPH'))) 
    set(handles.axes1,'YDir','reverse');
else
    set(handles.axes1,'YDir','default');
end
%SAVE
set(handles.figure1,'UserData',UsDat);
guidata(hObject,handles);

% --- Executes on button press in pushbutton_apply.
function pushbutton_apply_Callback(hObject, eventdata, handles)
set(0, 'DefaulttextInterpreter', 'none');
%GET DATA
UsDat=get(handles.figure1,'UserData');
%COLORS
tcolors=[0 0 1 ; 0 1 0 ; 0.95 0.5 0 ; 1 1 0 ; ...
        1 0 0 ; 0.75 0.0 0.79 ; 0.6 0.2 0 ; ... 
        0.1 0.4 0 ; 0.55 0.85 0.91 ; 0.49 0.49 0.49];
%GET SELECTED PARAMETERS
val = get(handles.popupmenu_param,'Value'); 
lev = get(handles.listbox_lev,'Value'); 
% GET AUTOMATIC QC LIST 
QC_list=[get(handles.checkbox1,'Value') get(handles.checkbox2,'Value') ...
         get(handles.checkbox3,'Value') get(handles.checkbox4,'Value') ...
         get(handles.checkbox5,'Value') get(handles.checkbox6,'Value')]; 
% READ CONFIGURATION FILE
fid=fopen('Common/autoqc_conf.txt','r');
for i=1:6 %QC NuMBER   
   line=fgetl(fid); %--------------------
   line=fgetl(fid); %#QC TITLE
   qc_conf(i).file=fgetl(fid); %filename
   if(i==5)
    qc_conf(i).parm=sscanf(fgetl(fid),'%d/%d/%d-%d:%d:%d %d/%d/%d-%d:%d:%d'); %test conf   
   elseif (i==6)
    qc_conf(i).parm=textscan(fgetl(fid),'%s'); %test conf
    qc_conf(i).parm=qc_conf(i).parm{1};
   else
    qc_conf(i).parm=str2num(fgetl(fid)); %test conf
   end   
   qc_conf(i).val=str2num(fgetl(fid)); %QC values
end
fclose(fid);
%
if(sum(QC_list)>0)
multiWaitbar('Level',0);
multiWaitbar('QC',0);
FinalQC=UsDat.PARAMETERS(val).QC_Serie;    
UsDat.qc_conf=[];
for nv=1:length(lev)    
% LOOP APPLY QC FUNCTION     
    multiWaitbar('Level',nv/(length(lev)+1));
    for i=1:6  %QC NUMBER
        if(QC_list(i)==1)  
            %waitbar(i/6,hw,qc_file{i});    
            multiWaitbar('QC',i/7);
            %set(findall(hw,'type','text'),'Interpreter','none');
            hQC_Serie = [];
            eval(['hQC_Serie = ' qc_conf(i).file ...
            '(qc_conf(i),UsDat.ParamList,UsDat.PARAMETERS,val,lev(nv));']);                 
            % QC CHANGE ONLY IF HIGHER    
            FinalQC(lev(nv),:)=max(FinalQC(lev(nv),:),hQC_Serie);   
            if(i~=6) %not saving "derived from"
            UsDat.qc_conf=[UsDat.qc_conf, qc_conf(i)]; %Save Conf for filling metadata
            end
        end
    end    
    multiWaitbar('QC',1);     
    % PLOT SERIE COLORED
    for i=1:10    
        plot(handles.axes1,UsDat.PARAMETERS(val).Time(FinalQC(lev(nv),:)==i-1),UsDat.PARAMETERS(val).Data(lev(nv),...
            FinalQC(lev(nv),:)==i-1)+(nv-1)*UsDat.PARAMETERS(val).p2p,'.','Color',tcolors(i,:));   %LEVEL UP
    end
end
multiWaitbar('Level',1);
multiWaitbar( 'CloseAll' );
% SAVE QUALIFIED SERIE IN TEMP ARRAY
UsDat.currentQC=FinalQC;
set(handles.figure1,'UserData',UsDat);
guidata(hObject,handles);
end

% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETER
val=get(handles.popupmenu_param,'Value');
%SAVE NEW QC PARAMETER
UsDat.PARAMETERS(val).QC_Serie = UsDat.currentQC;
% FILL METADATA
for i=1:length(UsDat.qc_conf)
   id=find(strcmp(UsDat.MMetadata.Properties,UsDat.qc_conf(i).file));
   if(isempty(id))        
        UsDat.MMetadata.Properties = [UsDat.MMetadata.Properties(:); UsDat.qc_conf(i).file];
        UsDat.MMetadata.Values = [UsDat.MMetadata.Values(:); num2str(UsDat.qc_conf(i).parm(:)')];         
   else
        UsDat.MMetadata.Properties{id} = UsDat.qc_conf(i).file;
        UsDat.MMetadata.Values{id} = num2str(UsDat.qc_conf(i).parm(:)');         
   end
end
%DLG
h = msgbox([UsDat.PARAMETERS(val).Name '''s QC array saved']);
set(handles.figure1,'UserData',UsDat);
guidata(hObject,handles);

% --- Executes on button press in pushbutton_conf.
function pushbutton_conf_Callback(hObject, eventdata, handles)
%Open configuration text file
edit autoqc_conf.txt
%check os
%osh=[ispc isunix ismac];
%if osh == [1 0 0]    
%    system('write Common/autoqc_conf.txt');    
%elseif osh == [0 1 0]    
%    system('gedit Common/autoqc_conf.txt');    
%elseif osh == [0 0 1]      
%    system('open Common/autoqc_conf.txt');        
%end

% --- Executes on button press in pushbutton_help.
function pushbutton_help_Callback(hObject, eventdata, handles)
%msgbox
s={'1 : Global range : test passed if min < value < max',...
    '2 : Change rate : test passed if |Vn - Vn-1| + |Vn - Vn+1| <= 2*threshold',...
    '3 : Stationary test : test passed if N successive values vary',...
    '4 : Median filter : test passed if (median - Val STD) < value < (median + Val STD) on N points',...
    '5 : Impossible date : test passed if min < time < max',...
    '6 : QC derived from one or multiple parameters'};
msgbox(s,'Auto QC');
%av les différents test décris

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
%delete(hObject);
uiresume(handles.figure1);


% --------------------------------------------------------------------
function uitoggletool4_ClickedCallback(hObject, eventdata, handles)
zoom;

% --------------------------------------------------------------------
function uipushtool2_ClickedCallback(hObject, eventdata, handles)
zoom out;

% --------------------------------------------------------------------
function uitoggletool5_ClickedCallback(hObject, eventdata, handles)
pan;
