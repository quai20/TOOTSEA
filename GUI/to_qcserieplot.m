function varargout = to_qcserieplot(varargin)
%
% QCSERIEPLOT MATLAB code for qcserieplot.fig
%      QCSERIEPLOT, by itself, creates a new QCSERIEPLOT or raises the existing
%      singleton*.
%
%      H = QCSERIEPLOT returns the handle to a new QCSERIEPLOT or the handle to
%      the existing singleton*.
%
%      QCSERIEPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QCSERIEPLOT.M with the given input arguments.
%
%      QCSERIEPLOT('Property','Value',...) creates a new QCSERIEPLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before qcserieplot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to qcserieplot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help qcserieplot

% Last Modified by GUIDE v2.5 22-May-2018 09:08:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @to_qcserieplot_OpeningFcn, ...
                   'gui_OutputFcn',  @to_qcserieplot_OutputFcn, ...
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


% --- Executes just before qcserieplot is made visible.
function to_qcserieplot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% Choose default command line output for qcserieplot
handles.output = hObject;
%GET INPUT PARAMETERS
UsDat.ParamList = varargin{1}.ParamList_in;
UsDat.PARAMETERS = varargin{1}.PARAMETERS_in;
UsDat.MDim = varargin{1}.MDim_in;
%
set(handles.popupmenu_param,'String',UsDat.ParamList,'Max',length(UsDat.ParamList));
set(handles.popupmenu_param,'Value',1);
set(handles.popupmenu_lev,'String',num2str([1:size(UsDat.PARAMETERS(1).Data,1)]'));
set(handles.popupmenu_lev,'Value',1);
%
plot(handles.axes1,UsDat.PARAMETERS(1).Time,UsDat.PARAMETERS(1).QC_Serie(1,:),'linewidth',2);
dateNtick;
ylabel([UsDat.ParamList{1} ' QC']); 
%SAVE IN FIGURE
set(handles.figure1,'UserData',UsDat);  
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = to_qcserieplot_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in popupmenu1.
function popupmenu_param_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
%GET DATA
UsDat=get(handles.figure1,'UserData');
p1=get(handles.popupmenu_param,'Value');
%
set(handles.popupmenu_lev,'String',num2str([1:size(UsDat.PARAMETERS(p1).Data,1)]'));
set(handles.popupmenu_lev,'Value',1);
%
plot(handles.axes1,UsDat.PARAMETERS(p1).Time,UsDat.PARAMETERS(p1).QC_Serie(1,:),'linewidth',2);
dateNtick;
ylabel([UsDat.ParamList{p1} ' QC']); 


% --- Executes on selection change in popupmenu1.
function popupmenu_lev_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
%GET DATA
UsDat=get(handles.figure1,'UserData');
p1=get(handles.popupmenu_param,'Value');
l1=get(handles.popupmenu_lev,'Value');
%
plot(handles.axes1,UsDat.PARAMETERS(p1).Time,UsDat.PARAMETERS(p1).QC_Serie(l1,:),'linewidth',2);
dateNtick;
ylabel([UsDat.ParamList{p1} ' QC']); 


