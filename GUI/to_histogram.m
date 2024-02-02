function varargout = to_histogram(varargin)
%
% HISTOGRAM MATLAB code for histogram.fig
% Last Modified by GUIDE v2.5 19-Jan-2017 15:06:20
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_histogram_OpeningFcn, ...
                   'gui_OutputFcn',  @to_histogram_OutputFcn, ...
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

% --- Executes just before histogram is made visible.
function to_histogram_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% Choose default command line output for histogram
handles.output = hObject;

%GET INPUT PARAMETERS;
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
UsDat.MDim = varargin{1}.MDim_in;
%SAVE IN FIGURE
set(handles.figure1,'UserData',UsDat);  
%GUI STUFF
set(handles.popupmenu1,'String',UsDat.ParamList,'Max',length(UsDat.ParamList));
set(handles.popupmenu1,'Value',1);
set(handles.popupmenu_lev1,'String',num2str([1:size(UsDat.PARAMETERS(1).Data,1)]'));
set(handles.popupmenu_lev1,'Value',1);
if length(UsDat.ParamList)>1
    set(handles.popupmenu2,'String',UsDat.ParamList,'Max',length(UsDat.ParamList));
    set(handles.popupmenu2,'Value',2);
    set(handles.popupmenu_lev2,'String',num2str([1:size(UsDat.PARAMETERS(2).Data,1)]'));
    set(handles.popupmenu_lev2,'Value',1);
end
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes spectrum wait for user response (see UIRESUME)
%uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = to_histogram_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;
%delete(hObject);

function popupmenu1_Callback(hObject, eventdata, handles)
%GET INPUT DATA
UsDat=get(handles.figure1,'UserData');
%Get value
val=get(hObject,'Value');
%SET POPUP LEVEL
set(handles.popupmenu_lev1,'String',num2str([1:size(UsDat.PARAMETERS(val).Data,1)]'));
set(handles.popupmenu_lev1,'Value',1);

function popupmenu2_Callback(hObject, eventdata, handles)
%GET INPUT DATA
UsDat=get(handles.figure1,'UserData');
%Get value
val=get(hObject,'Value');
%SET POPUP LEVEL
set(handles.popupmenu_lev2,'String',num2str([1:size(UsDat.PARAMETERS(val).Data,1)]'));
set(handles.popupmenu_lev2,'Value',1);

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
rval=round(get(hObject,'Value'));
set(handles.text2,'String',['Bin Number : ' num2str(rval)]);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
%SLIDER CREATION PROPERTIES
set(hObject,'Value',2);
set(hObject,'SliderStep',[1/198 5/198]);
set(hObject,'Min',2);
set(hObject,'Max',200);

function checkbox1_Callback(hObject, eventdata, handles)
%
if(get(hObject,'Value')==1)
    set(handles.edit_bs1,'Enable','on');
    set(handles.edit_bs2,'Enable','on');
else
    set(handles.edit_bs1,'Enable','off');
    set(handles.edit_bs2,'Enable','off');
end
%

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
%POINTER THINKING
set(findall(0,'Type','figure'), 'pointer', 'watch'); drawnow;
%GET DIMENSION (1D or 2D) from radio buttons
dim=[get(handles.radiobutton1,'Value') get(handles.radiobutton2,'Value')];
%GET INPUT DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETERS
var1=get(handles.popupmenu1,'Value');        
var2=get(handles.popupmenu2,'Value');   
%GET LEVELS
lev1=get(handles.popupmenu_lev1,'Value');
lev2=get(handles.popupmenu_lev2,'Value');
%GET OPTION 
r3=get(handles.radiobutton3,'Value');
r4=get(handles.radiobutton4,'Value');

%GET LIM
lim1_1=str2num(get(handles.edit1,'String')); 
if(isempty(lim1_1)) 
    if(r3==1)
    lim1_1=min(UsDat.PARAMETERS(var1).Data(lev1,:)); 
    else
    lim1_1=min(UsDat.PARAMETERS(var1).Data(lev1,ismember(UsDat.PARAMETERS(var1).QC_Serie(lev1,:),[1 2 3 5 7 8])));
    end
end

lim1_2=str2num(get(handles.edit2,'String')); 
if(isempty(lim1_2)) 
    if (r3==1)
    lim1_2=max(UsDat.PARAMETERS(var1).Data(lev1,:)); 
    else
    lim1_2=max(UsDat.PARAMETERS(var1).Data(lev1,ismember(UsDat.PARAMETERS(var1).QC_Serie(lev1,:),[1 2 3 5 7 8])));
    end
end

lim2_1=str2num(get(handles.edit3,'String')); 
if(isempty(lim2_1)) 
    if(r3==1)
    lim2_1=min(UsDat.PARAMETERS(var2).Data(lev2,:)); 
    else
    lim2_1=min(UsDat.PARAMETERS(var2).Data(lev2,ismember(UsDat.PARAMETERS(var2).QC_Serie(lev2,:),[1 2 3 5 7 8])));
    end
end

lim2_2=str2num(get(handles.edit4,'String')); 
if(isempty(lim2_2)) 
    if(r3==1)
    lim2_2=max(UsDat.PARAMETERS(var2).Data(lev2,:)); 
    else
    lim2_2=max(UsDat.PARAMETERS(var2).Data(lev2,ismember(UsDat.PARAMETERS(var2).QC_Serie(lev2,:),[1 2 3 5 7 8])));
    end
end

%GET BIN NUMBERS
if(get(handles.checkbox1,'Value')==1)
    %CALCULATE NUMBER OF BINS WITH SIZE
    binsize1=str2num(get(handles.edit_bs1,'String'));
    binsize2=str2num(get(handles.edit_bs2,'String'));
    
    if(isempty(binsize1))||(isempty(binsize2))
        warndlg('Bin size should be numeric');
        set(findall(0,'Type','figure'), 'pointer', 'arrow'); drawnow;
        return;
    end
    
    sval1=round(abs(lim1_2-lim1_1)/binsize1);
    sval2=round(abs(lim2_2-lim2_1)/binsize2);
else
    %SLIDER
    sval1=round(get(handles.slider1,'Value'));
    sval2=sval1;
end
%1D CASE
if(dim==[1 0])   
    if(r3==1)
        Arr2Plot=UsDat.PARAMETERS(var1).Data(lev1,:);
    else
        %check for good data
        if(length(UsDat.PARAMETERS(var1).Data(lev1,ismember(UsDat.PARAMETERS(var1).QC_Serie(lev1,:),[1 2 3 5 7 8])))>3)
             Arr2Plot=UsDat.PARAMETERS(var1).Data(lev1,ismember(UsDat.PARAMETERS(var1).QC_Serie(lev1,:),[1 2 3 5 7 8]));
        else
            warndlg('No good data !');
            set(findall(0,'Type','figure'), 'pointer', 'arrow'); drawnow;
            return;
        end
    end
    histogram(Arr2Plot,sval1,'BinLimits',[lim1_1 lim1_2]);
    grid on;
    l=xlabel([UsDat.ParamList{var1} ' (' UsDat.PARAMETERS(var1).Unit ')']); set(l,'interpreter','none');
    ylabel('Count');
%2D CASE (calls hist2d routine)   
elseif(dim==[0 1])               
    %CHECK SIZES
    if(length(UsDat.PARAMETERS(var1).Data(lev1,:)) ~= length(UsDat.PARAMETERS(var2).Data(lev2,:)))
        warndlg('Size problem');
        set(findall(0,'Type','figure'), 'pointer', 'arrow'); drawnow;
        return;        
    end        
    %OPTION
    if(r3==1)
        Arr2Plot_1=UsDat.PARAMETERS(var1).Data(lev1,:);
        Arr2Plot_2=UsDat.PARAMETERS(var2).Data(lev2,:);
    else                
        ind=ismember(UsDat.PARAMETERS(var1).QC_Serie(lev1,:),[1 2 3 5 7 8]).*ismember(UsDat.PARAMETERS(var2).QC_Serie(lev2,:),[1 2 3 5 7 8]);
        ind=boolean(ind);
        % check for good data        
        if((length(UsDat.PARAMETERS(var1).Data(lev1,ind))>5)&&(length(UsDat.PARAMETERS(var2).Data(lev2,ind))>5))
             Arr2Plot_1=UsDat.PARAMETERS(var1).Data(lev1,ind);
             Arr2Plot_2=UsDat.PARAMETERS(var2).Data(lev2,ind);
        else
            warndlg('No good data !');
            set(findall(0,'Type','figure'), 'pointer', 'arrow'); drawnow;
            return;
        end                
    end  
    
    %CHECK SIZES
    if(length(Arr2Plot_1) ~= length(Arr2Plot_2))
        warndlg('Size problem');
        set(findall(0,'Type','figure'), 'pointer', 'arrow'); drawnow;
        return;        
    end    
    
    %WITH LIM DEFINED
    [Xv,Yv,Hv]=hist2d([Arr2Plot_1',Arr2Plot_2'],sval1,sval2,[lim1_1 lim1_2],[lim2_1 lim2_2]);
    pcolor(Xv(2:end-1),Yv(2:end-1),Hv(2:end-1,2:end-1));
    colorbar; shading faceted; grid on;
    l=xlabel([UsDat.ParamList{var1} ' (' UsDat.PARAMETERS(var1).Unit ')']); set(l,'interpreter','none');
    l=ylabel([UsDat.ParamList{var2} ' (' UsDat.PARAMETERS(var2).Unit ')']); set(l,'interpreter','none');    
end
%POINTER READY
set(findall(0,'Type','figure'), 'pointer', 'arrow'); drawnow;  

% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET DIMENSION (1D or 2D) from radio buttons
dim=[get(handles.radiobutton1,'Value') get(handles.radiobutton2,'Value')];
%GET SELECTED PARAMETERS
var1=get(handles.popupmenu1,'Value');        
var2=get(handles.popupmenu2,'Value');   
%1D CASE
if(dim==[1 0])   
    defaultName=[strrep(UsDat.MDim.FileName,'.','-') '-histo-' UsDat.ParamList{var1}];
elseif(dim==[0 1])   
    defaultName=[strrep(UsDat.MDim.FileName,'.','-') '-histo-' UsDat.ParamList{var1} '-' UsDat.ParamList{var2}];    
end
    
%SAVE FIGURE
[FileName,PathName] = uiputfile({'*.pdf';'*.eps';'*.png';'*.tiff';'*.jpeg';'*.bmp'},'Save as',defaultName);
if isequal(FileName,0) 
    return; 
end
export_fig(handles.axes1,[PathName FileName]);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
%uiresume(hObject);
delete(hObject);
