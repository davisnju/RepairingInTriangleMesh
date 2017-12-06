function varargout = demo(varargin)
% DEMO M-file for demo.fig
%      DEMO, by itself, creates a new DEMO or raises the existing
%      singleton*.
%
%      H = DEMO returns the handle to a new DEMO or the handle to
%      the existing singleton*.
%
%      DEMO('Property','Value',...) creates a new DEMO using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to demo_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      DEMO('CALLBACK') and DEMO('CALLBACK',hObject,...) call the
%      local function named CALLBACK in DEMO.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help demo

% Last Modified by GUIDE v2.5 13-Jun-2004 23:14:23

% Author: Vikas Sindhwani (vikass@cs.uchicago.edu)
% Depatment of Computer Science, University of Chicago
% http://www.cs.uchicago.edu/~vikass
% June 2004 


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @demo_OpeningFcn, ...
                   'gui_OutputFcn',  @demo_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before demo is made visible.
function demo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for demo
handles.output = hObject;

% Update handles structure


% UIWAIT makes demo wait for user response (see UIRESUME)
% uiwait(handles.figure1);
handles.data = load('2moons.mat');
handles.mode=2; % fully supervised
handles.kernel='rbf';
handles.kernelparam=0.35;
handles.algo='rlsc';
handles.lab=2;
handles.generate=1;
handles.Y=handles.data.y;
set(handles.radiobutton2,'Value',1);
set(handles.lambda1,'Value', 0.4511); handles.gamma_A=0.014362;
set(handles.gamma_A_value,'String',num2str(handles.gamma_A));
set(handles.lambda2,'Value',0.7852); handles.gamma_I=0.7852;
set(handles.gamma_I_value,'String',num2str(handles.gamma_I));
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = demo_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function lambda1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lambda1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 0;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function lambda1_Callback(hObject, eventdata, handles)
% hObject    handle to lambda1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
p=get(hObject,'Value');
handles.gamma_A=10^(7*p-5)-10^(-5);
set(handles.gamma_A_value,'String',num2str(handles.gamma_A));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function lambda2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lambda2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function lambda2_Callback(hObject, eventdata, handles)
% hObject    handle to lambda2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


p=get(hObject,'Value');
handles.gamma_I=10^(7*p-5)-10^(-5);
set(handles.gamma_I_value,'String',num2str(handles.gamma_I));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function select_algo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_algo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in select_algo.
function select_algo_Callback(hObject, eventdata, handles)
% hObject    handle to select_algo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns select_algo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_algo

contents = get(hObject,'String');
handles.algo=contents{get(hObject,'Value')};
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function enter_kernelparams_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enter_kernelparams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function enter_kernelparams_Callback(hObject, eventdata, handles)
% hObject    handle to enter_kernelparams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enter_kernelparams as text
%        str2double(get(hObject,'String')) returns contents of enter_kernelparams as a double
handles.kernelparam=str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles


X=handles.data.x;
Y=handles.data.y;
handles.mode

options.NN=6;
options.gamma_A=handles.gamma_A;
options.gamma_I=handles.gamma_I;
options.Kernel=handles.kernel;
options.KernelParam=handles.kernelparam;
options.GraphDistanceFunction='euclidean';
options.GraphWeights='binary';
options.GraphNormalize=1;
options.GraphWeightParam=1;

method=handles.algo;

switch handles.mode
    
    case 2 % supervised
        disp('Running in Supervised Mode');
        Y1=Y;
        handles.Y=Y1;
        handles.generate=1;
    case 1 % unsupervised
        method='clustering';
        Y1=zeros(length(Y),1);
        handles.Y=Y1;
        handles.generate=1;
    case 3 % semi-supervised
 
      gen=handles.generate;  
      if gen==1
            
        ipos=find(Y>0);
        ineg=find(Y<0);
        lab=handles.lab;
        rpos=randperm(length(ipos)); rneg=randperm(length(ineg));
        Y1=zeros(length(Y),1);
        Y1(ipos(rpos(1:lab)))=1;
        Y1(ineg(rneg(1:lab)))=-1;
        handles.generate=0;
        handles.Y=Y1;
 
    else
        handles.generate=0;
    end
    
    end

classifier=ml_train(X,handles.Y,options,method);

xmin=min(X(:,1)); ymin=min(X(:,2)); rmin=min(xmin,ymin)-0.2;
xmax=max(X(:,1)); ymax=max(X(:,2)); rmax=max(xmax,ymax)+0.2;
steps=(rmax-rmin)/100;
xrange=rmin:steps:rmax;
yrange=rmin:steps:rmax;

plotclassifiers(classifier,xrange,yrange); title(method,'Color','w'); 
hold on;h=gca; set(h,'Xcolor','w'); set(h,'Ycolor','w')
unlab=find(handles.Y==0); 
plot2D(X(unlab,:),handles.Y(unlab),10); hold on;
lab=find(handles.Y);
plot2D(X(lab,:),handles.Y(lab),17);
hold off; 
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function select_dataset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_dataset (see GCBO)z
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in select_dataset.
function select_dataset_Callback(hObject, eventdata, handles)
% hObject    handle to select_dataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns select_dataset contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_dataset

contents = get(hObject,'String');
dataset=contents{get(hObject,'Value')};
handles.data=load([dataset '.mat']);
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function numlabeled_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numlabeled (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function numlabeled_Callback(hObject, eventdata, handles)
% hObject    handle to numlabeled (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numlabeled as text
%        str2double(get(hObject,'String')) returns contents of numlabeled as a double

handles.lab=str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function rbfwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbfwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function rbfwidth_Callback(hObject, eventdata, handles)
% hObject    handle to rbfwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rbfwidth as text
%        str2double(get(hObject,'String')) returns contents of rbfwidth as a double

handles.kernelparam=str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
off = [handles.radiobutton2,handles.radiobutton3];
mutual_exclude(off)
handles.mode=1; % fully supervised
guidata(hObject,handles);
% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2

off = [handles.radiobutton1,handles.radiobutton3];
mutual_exclude(off)
handles.mode=2; % unsupervised
guidata(hObject,handles);
% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
off = [handles.radiobutton1,handles.radiobutton2];
mutual_exclude(off)
handles.mode=3; % semisupervised
guidata(hObject,handles);

function mutual_exclude(off)
set(off,'Value',0)


% --- Executes on button press in generate.
function generate_Callback(hObject, eventdata, handles)
% hObject    handle to generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.generate=1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function gamma_A_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gamma_A_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function gamma_A_value_Callback(hObject, eventdata, handles)
% hObject    handle to gamma_A_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gamma_A_value as text
%        str2double(get(hObject,'String')) returns contents of gamma_A_value as a double


% --- Executes during object creation, after setting all properties.
function gamma_I_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gamma_I_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function gamma_I_value_Callback(hObject, eventdata, handles)
% hObject    handle to gamma_I_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gamma_I_value as text
%        str2double(get(hObject,'String')) returns contents of gamma_I_value as a double


