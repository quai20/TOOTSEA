function varargout = to_spectrum(varargin)
%
% SPECTRUM MATLAB code for spectrum.fig
% Last Modified by GUIDE v2.5 13-Jan-2017 15:05:33
%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_spectrum_OpeningFcn, ...
                   'gui_OutputFcn',  @to_spectrum_OutputFcn, ...
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

% --- Executes just before spectrum is made visible.
function to_spectrum_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% Choose default command line output for spectrum
handles.output = hObject;
%GET INPUT PARAMETERS
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
UsDat.MDim = varargin{1}.MDim_in;
%SAVE IN FIGURE
set(handles.figure1,'UserData',UsDat);
%SEARCH FOR dT
if(UsDat.PARAMETERS(1).dT ~= 0)
    set(handles.edit_dt,'String',num2str(UsDat.PARAMETERS(1).dT));
else
    set(handles.edit_dt,'String',['dT irregular (' num2str(UsDat.PARAMETERS(1).dTi) ')']);
end
%GUI STUFF
set(handles.popupmenu_param,'String',UsDat.ParamList,'Max',length(UsDat.ParamList));
set(handles.popupmenu_param,'Value',1);
set(handles.popupmenu_lev,'String',num2str([1:size(UsDat.PARAMETERS(1).Data,1)]'));
set(handles.popupmenu_lev,'Value',1);
%SLIDERs INIT
try
    slidersinit(handles, UsDat, 1, 2, 0 , 0);
catch
    %
end
% Update handles structure
guidata(hObject, handles);
cla(handles.axes1,'reset');
% UIWAIT makes spectrum wait for user response (see UIRESUME)
%uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = to_spectrum_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% Get default command line output from handles structure
varargout{1} = handles.output;
%NO UI WAIT BECAUSE NO OUTPUT, WE'RE JUST USING THE DATA, NOT CHANGING IT

% --- Executes on change in popup menu
function popupmenu_param_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
varp=get(hObject,'Value');
%SET POPUP LEVEL
set(handles.popupmenu_lev,'String',num2str([1:size(UsDat.PARAMETERS(varp).Data,1)]'));
set(handles.popupmenu_lev,'Value',1);
set(handles.checkbox1,'Value',0);
%SLIDERs INIT
slidersinit(handles, UsDat, varp, 1, get(handles.checkbox1,'Value'));

function popupmenu_lev_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
varp=get(handles.popupmenu_param,'Value');
varl=get(hObject,'Value');
set(handles.checkbox1,'Value',0);
%SLIDERs INIT
slidersinit(handles, UsDat, varp, varl, get(handles.checkbox1,'Value'));

function checkbox1_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
varp=get(handles.popupmenu_param,'Value');
varl=get(handles.popupmenu_lev,'Value');
if(get(hObject,'Value')==1)
    rgt=find(UsDat.PARAMETERS(varp).QC_Serie(varl,:)==1);
    if(isempty(rgt))
        helpdlg('No good data found');
        set(handles.checkbox1,'Value',0);
    end
end
% Update handles structure
guidata(hObject, handles);
%SLIDERs INIT
slidersinit(handles, UsDat, varp, varl, get(handles.checkbox1,'Value'));

% --- Executes on button press in pushbutton_plot.
function pushbutton_plot_Callback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
%GET SELECTED PARAMETERS
vartp=get(handles.popupmenu_param,'Value');
varlv=get(handles.popupmenu_lev,'Value');
%GET OPTIONS
qcone=get(handles.checkbox1,'Value');
%GET dT & SLIDERS
dtime=str2num(get(handles.edit_dt,'String'));
if(~isempty(dtime))
    WINDOW=floor(get(handles.slider1,'Value'));
    NOVERL=floor(get(handles.slider2,'Value'));
    NFFT=floor(get(handles.slider3,'Value'));
    CONFL=get(handles.slider4,'Value')/100;
    %CALLING TimeSerie.tspectrum
    UsDat.PARAMETERS(vartp).tspectrum(dtime,WINDOW,NOVERL,NFFT,CONFL,varlv,qcone);
    set(handles.axes1,'XLim',[0 str2num(get(handles.edit2,'String'))]);
    %GET LOG AXIS
    sv=get(handles.checkbox_logx,'value');
    if(sv==1) 
        set(handles.axes1,'xscale','log');
    else
        set(handles.axes1,'xscale','linear');
    end
    sv=get(handles.checkbox_logy,'value');
    if(sv==1) 
        set(handles.axes1,'yscale','log');
    else
        set(handles.axes1,'yscale','linear');
    end
else
    warndlg('dT not set');
    return;
end

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
rval=round(get(hObject,'Value'));
set(handles.text1,'String',['Window length : ' num2str(rval)]);
%SLIDER2
mmax=get(handles.slider1,'Value')-1;
mmin=0;
set(handles.slider2,'Value',floor(mmax/2));
set(handles.text2,'String',['nOverlap : ' num2str(get(handles.slider2,'Value'))]);
set(handles.slider2,'SliderStep',[1/(mmax-mmin) 100/(mmax-mmin)]);
set(handles.slider2,'Min',mmin); set(handles.slider2,'Max',mmax);
set(handles.slider3,'Min',100); set(handles.slider3,'Value',rval); set(handles.slider3,'Max',rval);
set(handles.slider3,'SliderStep',[1/(rval-100) 100/(rval-100)]);
set(handles.text3,'String',['NFFT : ' num2str(get(handles.slider3,'Value'))]);
%
guidata(hObject, handles);

% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
rval=round(get(hObject,'Value'));
set(handles.text2,'String',['nOverlap : ' num2str(rval)]);
guidata(hObject, handles);

% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
rval=round(get(hObject,'Value'));
set(handles.text3,'String',['NFFT : ' num2str(rval)]);
guidata(hObject, handles);

% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
rval=round(get(hObject,'Value'));
set(handles.text4,'String',['Confidence : ' num2str(rval)]);
guidata(hObject, handles);

% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
%GET DATA
UsDat=get(handles.figure1,'UserData');
p1=get(handles.popupmenu_param,'Value');
defaultName=[strrep(UsDat.MDim.FileName,'.','-') '-spectrum-' UsDat.ParamList{p1}];
%SAVE FIGURE
[FileName,PathName] = uiputfile({'*.pdf';'*.eps';'*.png';'*.tiff';'*.jpeg';'*.bmp'},'Save as',defaultName);
export_fig(handles.axes1,[PathName FileName]);

%GUI FUNCTION
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
%uiresume(hObject);
delete(hObject);

% --- Executes when user attempts to close figure1.
function sxlim_Callback(hObject, eventdata, handles)
xlimm=str2num(get(hObject,'String'));
set(handles.axes1,'XLim',[0 xlimm]);

function slidersinit(handles, UsDat, vparm, varl, qcone)
%SLIDER1
if(qcone==1)    
    t1=UsDat.PARAMETERS(vparm).Time(UsDat.PARAMETERS(vparm).QC_Serie(varl,:)<4);    
    x1=UsDat.PARAMETERS(vparm).Data(varl,UsDat.PARAMETERS(vparm).QC_Serie(varl,:)<4);    
    x=interp1(t1(~isnan(x1)),x1(~isnan(x1)),UsDat.PARAMETERS(vparm).Time,'linear');
    x=x(~isnan(x));
    mmax=length(x)-1;
elseif(qcone==0)
    t1=UsDat.PARAMETERS(vparm).Time;
    x1=UsDat.PARAMETERS(vparm).Data(varl,:);    
    x=interp1(t1(~isnan(x1)),x1(~isnan(x1)),UsDat.PARAMETERS(vparm).Time,'linear');
    x=x(~isnan(x));
    mmax=length(x)-1;
end
mmin=round(mmax/100);
set(handles.slider1,'Value',mmax);
set(handles.text1,'String',['Window length : ' num2str(get(handles.slider1,'Value'))]);
set(handles.slider1,'SliderStep',[1/(mmax-mmin) 100/(mmax-mmin)]);
set(handles.slider1,'Min',mmin); set(handles.slider1,'Max',mmax);
%SLIDER2
mmax=get(handles.slider1,'Value')-1;
mmin=0;
set(handles.slider2,'Value',floor(mmax/2));
set(handles.text2,'String',['nOverlap : ' num2str(get(handles.slider2,'Value'))]);
set(handles.slider2,'SliderStep',[1/(mmax-mmin) 100/(mmax-mmin)]);
set(handles.slider2,'Min',mmin); set(handles.slider2,'Max',mmax);
%SLIDER3
mmax=get(handles.slider1,'Value');
mmin=100;
set(handles.slider3,'Value',mmax);
set(handles.text3,'String',['NFFT : ' num2str(get(handles.slider3,'Value'))]);
set(handles.slider3,'SliderStep',[1/(mmax-mmin) 100/(mmax-mmin)]);
set(handles.slider3,'Min',mmin); set(handles.slider3,'Max',mmax);
%SLIDER4
set(handles.slider4,'Value',95);
set(handles.text4,'String',['Confidence : ' num2str(get(handles.slider4,'Value'))]);
set(handles.slider4,'SliderStep',[1/98 5/98]);
set(handles.slider4,'Min',1); set(handles.slider4,'Max',99);
%
guidata(handles.popupmenu_lev, handles);

function checkbox_logx_Callback(hObject, eventdata, handles)
%
sv=get(hObject,'value');
if(sv==1)
    set(handles.axes1,'xscale','log');
else
    set(handles.axes1,'xscale','linear');
end

function checkbox_logy_Callback(hObject, eventdata, handles)
%
sv=get(hObject,'value');
if(sv==1)
    set(handles.axes1,'yscale','log');
else
    set(handles.axes1,'yscale','linear');
end
