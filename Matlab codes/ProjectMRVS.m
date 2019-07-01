function varargout = ProjectMRVS(varargin)
% PROJECTMRVS MATLAB code for ProjectMRVS.fig
%      PROJECTMRVS, by itself, creates a new PROJECTMRVS or raises the existing
%      singleton*.
%
%      H = PROJECTMRVS returns the handle to a new PROJECTMRVS or the handle to
%      the existing singleton*.
%
%      PROJECTMRVS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJECTMRVS.M with the given input arguments.
%
%      PROJECTMRVS('Property','Value',...) creates a new PROJECTMRVS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ProjectMRVS_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ProjectMRVS_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ProjectMRVS

% Last Modified by GUIDE v2.5 30-Mar-2019 19:45:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ProjectMRVS_OpeningFcn, ...
    'gui_OutputFcn',  @ProjectMRVS_OutputFcn, ...
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


% --- Executes just before ProjectMRVS is made visible.
function ProjectMRVS_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ProjectMRVS (see VARARGIN)


% Choose default command line output for ProjectMRVS
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ProjectMRVS wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ProjectMRVS_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in searchButton.
function searchButton_Callback(hObject, eventdata, handles)
% hObject    handle to searchButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global i; global j; global a;
global cam1; global cam2;
global r1;global r2;global l1;global l2;


Radius1=0; Radius2=0; bool=0;

while 1
    
    digitalWrite(a,r1,1);
    digitalWrite(a,r2,0);
    digitalWrite(a,l1,0);
    digitalWrite(a,l2,1);
    pause(0.25);
    digitalWrite(a,r1,0);
    digitalWrite(a,r2,0);
    digitalWrite(a,l1,0);
    digitalWrite(a,l2,0);
    
    i=i+1;
    j=j+1;
    
    img = snapshot(cam1);
    img = imrotate(img,90);
    imwrite(img,sprintf('%d.jpg',i));
    img2 = snapshot(cam2);
    img2 = imrotate(img2,90);
    imwrite(img2,sprintf('%d.jpg',j));
    
    
    testI =imread(sprintf('%d.jpg',i));
    testII=imread(sprintf('%d.jpg',j));
    
    I1=rgb2gray(testI);
    I2=rgb2gray(testII);
    
    [I1,I2] = rectifyStereoImages(I1,I2,calibrationSession.CameraParameters);



    

    %finding circles:
    [Center1,Radius1]=imfindcircles(I1,[10 100],'ObjectPolarity',...
        'dark', 'Sensitivity',0.8);
    
    [Center2,Radius2]=imfindcircles(I2,[10 100],'ObjectPolarity',...
        'dark', 'Sensitivity',0.8);
    
    %processing
    sizeRadius1=size(Radius1);
    sizeRadius2=size(Radius2);
    
    if mean(Radius1) > 0 && mean(Radius2) > 0
        break;
    end
    
    
    
    if i > 17
        bool=1;
        %display that 360 degree done and no circles
        break
    end
    
end %end while

if bool ==0 %if there is one or more circles
    
    
    if sizeRadius1(1) == 1 && sizeRadius2(1) ==1
        %there is one circle:
        
        %finding disparity:
        disparityRange = [0 128]; % arbitrary number and divisable by 8, max = 128
        disparityMap = disparity(I1,I2,'BlockSize', 15,'DisparityRange',disparityRange);

        set(handles.messageBox,'String','Circle Found!');
        
        %showing proper images:
        %left
        axes1
        imshow(testI)
        h1 = viscircles(Center1,Radius1);
        
        %right
        axes2
        imshow(testII)
        h2 = viscircles(Center2,Radius2);

        %both
        axes3
        imshow(stereoAnaglyph(I1,I2))
        
        %disparity
        axes4
        imshow(disparityMap,disparityRange);
        colormap(gca,jet) 
        colorbar
        
        %more processing:
        theCenter=(Center1+Center2)/2;
        x=floor(theCenter(1));
        y=floor(theCenter(2));

        f=846;
        b=9.6;

        distance=f*b/disparityMap(y,x);

        %showing messages:
        set(handles.messageBox,'String','Circle Found!');
        set(handles.distanceBox,'String',num2string(distance));


        
    elseif sizeRadius1(1) > 1 && sizeRadius2(1) > 1
        %if there are multiple circles.
        set(handles.messageBox,'String','There are more than one Circle!');
    end
    
    
else
    %there is no circle
    set(handles.messageBox,'String','No circles found.');
    
end

guidata(hObject, handles);



% --- Executes on button press in goButton.
function goButton_Callback(hObject, eventdata, handles)
% hObject    handle to goButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in connectButton.
function connectButton_Callback(hObject, eventdata, handles)
% hObject    handle to connectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global a;
global sensor;
global i; global j;
i=0;j=100;
global r1;global r2;global l1;global l2;global m1;global m2;
global m3; global m4; global dly; global trigPin;
global echoPin;

load('calibrationSession5.mat');

a= arduino('COM4');
% global cam1;
cam1 = webcam(1);
%preview(cam1)

% global cam2;
cam2 = webcam(3);
%preview(cam2)



% Right-hand side motors:
r1=2;
r2=4;
% Left-hand side motors:
l1=7;
l2=8;

% Analog signal for motors speed:
m1=10;
m2=3;
m3=6;
m4=9;
dly = 1500;

% Ultrasonic code:
trigPin = 11;    % Trigger
echoPin = 12;    % Echo


%     a = arduino('COM3', 'Uno', 'Libraries', 'JRodrigoTech/HCSR04');
%     sensor = addon(a, 'JRodrigoTech/HCSR04', 'D11', 'D12');

load('calibrationSession5.mat');

a.pinMode(r1, 'output');
a.pinMode(r2, 'output');
a.pinMode(l1, 'output');
a.pinMode(l2, 'output');
a.pinMode(m1, 'output');
a.pinMode(m2, 'output');
a.pinMode(m3, 'output');
a.pinMode(m4, 'output');



a.pinMode(trigPin, 'output');
a.pinMode(echoPin, 'input');

analogWrite(a,m1,255);
analogWrite(a,m2,233);
analogWrite(a,m3,230);
analogWrite(a,m4,255);

guidata(hObject, handles);




% --- Executes on button press in disconnectButton.
function disconnectButton_Callback(hObject, eventdata, handles)
% hObject    handle to disconnectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(instrfind({'Port'},{'COM4'}))
clear




function messageBox_Callback(hObject, eventdata, handles)
% hObject    handle to messageBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of messageBox as text
%        str2double(get(hObject,'String')) returns contents of messageBox as a double


% --- Executes during object creation, after setting all properties.
function messageBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to messageBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function distanceBox_Callback(hObject, eventdata, handles)
% hObject    handle to distanceBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of distanceBox as text
%        str2double(get(hObject,'String')) returns contents of distanceBox as a double


% --- Executes during object creation, after setting all properties.
function distanceBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to distanceBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
