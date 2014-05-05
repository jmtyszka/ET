function varargout = ET_cut(varargin)
% ET_CUT MATLAB code for ET_cut.fig
%      ET_CUT, by itself, creates a new ET_CUT or raises the existing
%      singleton*.
%
%      H = ET_CUT returns the handle to a new ET_CUT or the handle to
%      the existing singleton*.
%
%      ET_CUT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ET_CUT.M with the given input arguments.
%
%      ET_CUT('Property','Value',...) creates a new ET_CUT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ET_cut_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ET_cut_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ET_cut

% Last Modified by GUIDE v2.5 05-May-2014 07:49:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ET_cut_OpeningFcn, ...
                   'gui_OutputFcn',  @ET_cut_OutputFcn, ...
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


% --- Executes just before ET_cut is made visible.
function ET_cut_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ET_cut (see VARARGIN)

%make sure the ET toolbox is on the path
addpath(genpath(fullfile(pwd,'..')));
% Choose default command line output for ET_cut
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ET_cut wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ET_cut_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function GAZE_start_frame_Callback(hObject, eventdata, handles)
% hObject    handle to GAZE_start_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GAZE_start_frame as text
%        str2double(get(hObject,'String')) returns contents of GAZE_start_frame as a double
set(handles.GAZE_start_time,'String',sprintf('%.3f',str2double(get(handles.GAZE_start_frame,'String'))/handles.FrameRate));
set(handles.GAZE_duration_time,'String',sprintf('%.3f',str2double(get(handles.GAZE_end_time,'String'))-str2double(get(handles.GAZE_start_time,'String'))));


% --- Executes during object creation, after setting all properties.
function GAZE_start_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GAZE_start_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GAZE_end_frame_Callback(hObject, eventdata, handles)
% hObject    handle to GAZE_end_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GAZE_end_frame as text
%        str2double(get(hObject,'String')) returns contents of GAZE_end_frame as a double
set(handles.GAZE_end_time,'String',sprintf('%.3f',str2double(get(handles.GAZE_end_frame,'String'))/handles.FrameRate));
set(handles.GAZE_duration_time,'String',sprintf('%.3f',str2double(get(handles.GAZE_end_time,'String'))-str2double(get(handles.GAZE_start_time,'String'))));


% --- Executes during object creation, after setting all properties.
function GAZE_end_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GAZE_end_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GAZE_current_frame_Callback(hObject, eventdata, handles)
% hObject    handle to GAZE_current_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GAZE_current_frame as text
%        str2double(get(hObject,'String')) returns contents of GAZE_current_frame as a double
set(handles.GAZE_current_time,'String',sprintf('%.3f',str2double(get(handles.GAZE_current_frame,'String'))/handles.FrameRate));
fr_pair = ET_LoadFramePair(handles.v_in, handles.videomode, str2double(get(handles.GAZE_current_frame,'String')));
imshow(fr_pair(:,:,1),'parent',handles.GAZE_axes_1);
% show df
df = fr_pair(:,:,2)-fr_pair(:,:,1);
imagesc(df,'parent',handles.GAZE_axes_2);axis(handles.GAZE_axes_2,'off');
% show mdf
mdf = mean(df,2);
plot(mdf,1:length(mdf),'parent',handles.MDF_axes);axis(handles.MDF_axes,'ij','tight');


% --- Executes during object creation, after setting all properties.
function GAZE_current_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GAZE_current_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GAZE_current_time_Callback(hObject, eventdata, handles)
% hObject    handle to GAZE_current_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GAZE_current_time as text
%        str2double(get(hObject,'String')) returns contents of GAZE_current_time as a double
set(handles.GAZE_current_frame,'String',sprintf('%.3f',round(str2double(get(handles.GAZE_current_time,'String'))*handles.FrameRate)));
fr_pair = ET_LoadFramePair(handles.v_in, handles.videomode, str2double(get(handles.GAZE_current_frame,'String')));
imshow(fr_pair(:,:,1),'parent',handles.GAZE_axes);


% --- Executes during object creation, after setting all properties.
function GAZE_current_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GAZE_current_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CAL_current_frame_Callback(hObject, eventdata, handles)
% hObject    handle to CAL_current_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CAL_current_frame as text
%        str2double(get(hObject,'String')) returns contents of CAL_current_frame as a double
set(handles.CAL_current_time,'String',sprintf('%.3f',str2double(get(handles.CAL_current_frame,'String'))/handles.FrameRate));
fr_pair = ET_LoadFramePair(handles.v_in, handles.videomode, str2double(get(handles.CAL_current_frame,'String')));
imshow(fr_pair(:,:,1),'parent',handles.CAL_axes);

% --- Executes during object creation, after setting all properties.
function CAL_current_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CAL_current_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CAL_current_time_Callback(hObject, eventdata, handles)
% hObject    handle to CAL_current_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CAL_current_time as text
%        str2double(get(hObject,'String')) returns contents of CAL_current_time as a double
set(handles.CAL_current_frame,'String',sprintf('%.3f',round(str2double(get(handles.CAL_current_time,'String'))*handles.FrameRate)));
fr_pair = ET_LoadFramePair(handles.v_in, handles.videomode, str2double(get(handles.CAL_current_frame,'String')));
imshow(fr_pair(:,:,1),'parent',handles.CAL_axes);


% --- Executes during object creation, after setting all properties.
function CAL_current_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CAL_current_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VAL_current_frame_Callback(hObject, eventdata, handles)
% hObject    handle to VAL_current_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VAL_current_frame as text
%        str2double(get(hObject,'String')) returns contents of VAL_current_frame as a double
set(handles.VAL_current_time,'String',sprintf('%.3f',str2double(get(handles.VAL_current_frame,'String'))/handles.FrameRate));
fr_pair = ET_LoadFramePair(handles.v_in, handles.videomode, str2double(get(handles.VAL_current_frame,'String')));
imshow(fr_pair(:,:,1),'parent',handles.VAL_axes);

% --- Executes during object creation, after setting all properties.
function VAL_current_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VAL_current_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VAL_current_time_Callback(hObject, eventdata, handles)
% hObject    handle to VAL_current_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VAL_current_time as text
%        str2double(get(hObject,'String')) returns contents of VAL_current_time as a double
set(handles.VAL_current_frame,'String',sprintf('%.3f',round(str2double(get(handles.VAL_current_time,'String'))*handles.FrameRate)));
fr_pair = ET_LoadFramePair(handles.v_in, handles.videomode, str2double(get(handles.VAL_current_frame,'String')));
imshow(fr_pair(:,:,1),'parent',handles.VAL_axes);


% --- Executes during object creation, after setting all properties.
function VAL_current_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VAL_current_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CAL_start_frame_Callback(hObject, eventdata, handles)
% hObject    handle to CAL_start_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CAL_start_frame as text
%        str2double(get(hObject,'String')) returns contents of CAL_start_frame as a double
set(handles.CAL_start_time,'String',sprintf('%.3f',str2double(get(handles.CAL_start_frame,'String'))/handles.FrameRate));
set(handles.CAL_duration_time,'String',sprintf('%.3f',str2double(get(handles.CAL_end_time,'String'))-str2double(get(handles.CAL_start_time,'String'))));



% --- Executes during object creation, after setting all properties.
function CAL_start_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CAL_start_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CAL_end_frame_Callback(hObject, eventdata, handles)
% hObject    handle to CAL_end_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CAL_end_frame as text
%        str2double(get(hObject,'String')) returns contents of CAL_end_frame as a double
set(handles.CAL_end_time,'String',sprintf('%.3f',str2double(get(handles.CAL_end_frame,'String'))/handles.FrameRate));
set(handles.CAL_duration_time,'String',sprintf('%.3f',str2double(get(handles.CAL_end_time,'String'))-str2double(get(handles.CAL_start_time,'String'))));


% --- Executes during object creation, after setting all properties.
function CAL_end_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CAL_end_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CAL_start_time_Callback(hObject, eventdata, handles)
% hObject    handle to CAL_start_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CAL_start_time as text
%        str2double(get(hObject,'String')) returns contents of CAL_start_time as a double


% --- Executes during object creation, after setting all properties.
function CAL_start_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CAL_start_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CAL_end_time_Callback(hObject, eventdata, handles)
% hObject    handle to CAL_end_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CAL_end_time as text
%        str2double(get(hObject,'String')) returns contents of CAL_end_time as a double


% --- Executes during object creation, after setting all properties.
function CAL_end_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CAL_end_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VAL_start_frame_Callback(hObject, eventdata, handles)
% hObject    handle to VAL_start_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VAL_start_frame as text
%        str2double(get(hObject,'String')) returns contents of VAL_start_frame as a double
set(handles.VAL_start_time,'String',sprintf('%.3f',str2double(get(handles.VAL_start_frame,'String'))/handles.FrameRate));
set(handles.VAL_duration_time,'String',sprintf('%.3f',str2double(get(handles.VAL_end_time,'String'))-str2double(get(handles.VAL_start_time,'String'))));


% --- Executes during object creation, after setting all properties.
function VAL_start_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VAL_start_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VAL_end_frame_Callback(hObject, eventdata, handles)
% hObject    handle to VAL_end_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VAL_end_frame as text
%        str2double(get(hObject,'String')) returns contents of VAL_end_frame as a double
set(handles.VAL_end_time,'String',sprintf('%.3f',str2double(get(handles.VAL_end_frame,'String'))/handles.FrameRate));
set(handles.VAL_duration_time,'String',sprintf('%.3f',str2double(get(handles.VAL_end_time,'String'))-str2double(get(handles.VAL_start_time,'String'))));


% --- Executes during object creation, after setting all properties.
function VAL_end_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VAL_end_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VAL_start_time_Callback(hObject, eventdata, handles)
% hObject    handle to VAL_start_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VAL_start_time as text
%        str2double(get(hObject,'String')) returns contents of VAL_start_time as a double


% --- Executes during object creation, after setting all properties.
function VAL_start_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VAL_start_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VAL_end_time_Callback(hObject, eventdata, handles)
% hObject    handle to VAL_end_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VAL_end_time as text
%        str2double(get(hObject,'String')) returns contents of VAL_end_time as a double


% --- Executes during object creation, after setting all properties.
function VAL_end_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VAL_end_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GAZE_start_time_Callback(hObject, eventdata, handles)
% hObject    handle to GAZE_start_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GAZE_start_time as text
%        str2double(get(hObject,'String')) returns contents of GAZE_start_time as a double


% --- Executes during object creation, after setting all properties.
function GAZE_start_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GAZE_start_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function matfile_Callback(hObject, eventdata, handles)
% hObject    handle to GAZE_end_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GAZE_end_time as text
%        str2double(get(hObject,'String')) returns contents of GAZE_end_time as a double


% --- Executes during object creation, after setting all properties.
function matfile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GAZE_end_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function GAZE_end_time_Callback(hObject, eventdata, handles)
% hObject    handle to GAZE_end_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GAZE_end_time as text
%        str2double(get(hObject,'String')) returns contents of GAZE_end_time as a double


% --- Executes during object creation, after setting all properties.
function GAZE_end_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GAZE_end_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function trigger_frame_Callback(hObject, eventdata, handles)
% hObject    handle to trigger_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trigger_frame as text
%        str2double(get(hObject,'String')) returns contents of trigger_frame as a double
set(handles.GAZE_start_frame,'String',num2str(str2double(get(handles.trigger_frame,'String'))-ceil(5*handles.FrameRate)));
    

% --- Executes during object creation, after setting all properties.
function trigger_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trigger_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function trigger_time_Callback(hObject, eventdata, handles)
% hObject    handle to trigger_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trigger_time as text
%        str2double(get(hObject,'String')) returns contents of trigger_time as a double


% --- Executes during object creation, after setting all properties.
function trigger_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trigger_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CAL_duration_time_Callback(hObject, eventdata, handles)
% hObject    handle to CAL_duration_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CAL_duration_time as text
%        str2double(get(hObject,'String')) returns contents of CAL_duration_time as a double


% --- Executes during object creation, after setting all properties.
function CAL_duration_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CAL_duration_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VAL_duration_time_Callback(hObject, eventdata, handles)
% hObject    handle to VAL_duration_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VAL_duration_time as text
%        str2double(get(hObject,'String')) returns contents of VAL_duration_time as a double


% --- Executes during object creation, after setting all properties.
function VAL_duration_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VAL_duration_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GAZE_duration_time_Callback(hObject, eventdata, handles)
% hObject    handle to GAZE_duration_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GAZE_duration_time as text
%        str2double(get(hObject,'String')) returns contents of GAZE_duration_time as a double


% --- Executes during object creation, after setting all properties.
function GAZE_duration_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GAZE_duration_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in play_CAL.
function play_CAL_Callback(hObject, eventdata, handles)
% hObject    handle to play_CAL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pause_CAL,'Value',0);

istart=str2double(get(handles.CAL_start_frame,'String'));
iend=str2double(get(handles.CAL_end_frame,'String'));

ifr=istart;
while ifr<iend
    if get(handles.pause_CAL,'Value')==1
        break
    end
    set(handles.CAL_current_frame,'String',num2str(ifr));
    set(handles.CAL_current_time,'String',sprintf('%.3f',str2double(get(handles.CAL_current_frame,'String'))/handles.FrameRate));
    fr_pair = ET_LoadFramePair(handles.v_in, handles.videomode, str2double(get(handles.CAL_current_frame,'String')));
    imshow(fr_pair(:,:,1),'parent',handles.CAL_axes);
    ifr=ifr+5;
    if strcmp(handles.videomode,'progressive')
        ifr=ifr+5;
    end
   drawnow
end

        
% --- Executes on button press in pause_CAL.
function pause_CAL_Callback(hObject, eventdata, handles)
% hObject    handle to pause_CAL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in play_VAL.
function play_VAL_Callback(hObject, eventdata, handles)
% hObject    handle to play_VAL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pause_VAL,'Value',0);

istart=str2double(get(handles.VAL_start_frame,'String'));
iend=str2double(get(handles.VAL_end_frame,'String'));

ifr=istart;
while ifr<iend
    if get(handles.pause_VAL,'Value')==1
        break
    end
    set(handles.VAL_current_frame,'String',num2str(ifr));
    set(handles.VAL_current_time,'String',sprintf('%.3f',str2double(get(handles.VAL_current_frame,'String'))/handles.FrameRate));
    fr_pair = ET_LoadFramePair(handles.v_in, handles.videomode, str2double(get(handles.VAL_current_frame,'String')));
    imshow(fr_pair(:,:,1),'parent',handles.VAL_axes);
    ifr=ifr+5;
    if strcmp(handles.videomode,'progressive')
        ifr=ifr+5;
    end
   drawnow
end



% --- Executes on button press in pause_VAL.
function pause_VAL_Callback(hObject, eventdata, handles)
% hObject    handle to pause_VAL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in play_GAZE.
function play_GAZE_Callback(hObject, eventdata, handles)
% hObject    handle to play_GAZE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pause_GAZE,'Value',0);

istart=str2double(get(handles.GAZE_start_frame,'String'));
iend=str2double(get(handles.GAZE_end_frame,'String'));

ifr=istart;
while ifr<iend
    if get(handles.pause_GAZE,'Value')==1
        break
    end
    set(handles.GAZE_current_frame,'String',num2str(ifr));
    set(handles.GAZE_current_time,'String',sprintf('%.3f',str2double(get(handles.GAZE_current_frame,'String'))/handles.FrameRate));
    fr_pair = ET_LoadFramePair(handles.v_in, handles.videomode, str2double(get(handles.GAZE_current_frame,'String')));
    imshow(fr_pair(:,:,1),'parent',handles.GAZE_axes_1);
    % show df
    df = fr_pair(:,:,2)-fr_pair(:,:,1);
    imagesc(df,'parent',handles.GAZE_axes_2);axis(handles.GAZE_axes_2,'off');
    % show mdf
    mdf = mean(df,2);
    plot(mdf,1:length(mdf),'parent',handles.MDF_axes);axis(handles.MDF_axes,'ij','tight');

    ifr=ifr+5;
    if strcmp(handles.videomode,'progressive')
        ifr=ifr+5;
    end
   drawnow
end



% --- Executes on button press in pause_GAZE.
function pause_GAZE_Callback(hObject, eventdata, handles)
% hObject    handle to pause_GAZE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_and_exit.
function save_and_exit_Callback(hObject, eventdata, handles)
% hObject    handle to save_and_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% CAL
CALstart=str2double(get(handles.CAL_start_frame,'String'));
CALend=str2double(get(handles.CAL_end_frame,'String'));
% VAL
VALstart=str2double(get(handles.VAL_start_frame,'String'));
VALend=str2double(get(handles.VAL_end_frame,'String'));
% GAZE
GAZEstart=str2double(get(handles.GAZE_start_frame,'String'));
GAZEend =str2double(get(handles.GAZE_end_frame,'String'));
firstart =  str2double(get(handles.trigger_frame,'String'));
startACQ =  firstart-GAZEstart+1;


FrameRate = handles.FrameRate;

% save all the info (time of start acquisition!) in a .mat
save(fullfile(handles.dir_name,'prepare.mat'),...
    'CALstart','CALend','VALstart','VALend','GAZEstart','GAZEend',...
    'firstart','startACQ','FrameRate');

set(handles.matfile,'ForegroundColor','g')

return

% --- Executes on selection change in videomode_popup.
function videomode_popup_Callback(hObject, eventdata, handles)
% hObject    handle to videomode_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns videomode_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from videomode_popup


% --- Executes during object creation, after setting all properties.
function videomode_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to videomode_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fps_Callback(hObject, eventdata, handles)
% hObject    handle to fps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fps as text
%        str2double(get(hObject,'String')) returns contents of fps as a double


% --- Executes during object creation, after setting all properties.
function fps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_video.
function load_video_Callback(hObject, eventdata, handles)
% hObject    handle to load_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[handles.fname, handles.dir_name] = uigetfile({'*.mp4','Supported video formats'},...
    'Select eyetracking video file');
if isequal(handles.fname,0) || isequal(handles.dir_name,0)
    return
end


% switch computer
%     case {'GLNXA64','PCWIN','PCWIN64'}
handles.v_in       =  VideoReader(fullfile(handles.dir_name,handles.fname));
handles.nFrames    =  handles.v_in.NumberOfFrames;
handles.FrameRate  =  handles.v_in.FrameRate;
handles.vidHeight  =  handles.v_in.Height;
handles.vidWidth   =  handles.v_in.Width;
%     case 'MACI64'
% handles.v_in       =  VideoPlayer(fullfile(handles.dir_name,handles.fname),'Verbose',false,'ShowTime',false);
% handles.nFrames    =  handles.v_in.NumFrames;
% handles.FrameRate  =  handles.v_in.NumFrames/handles.v_in.TotalTime;
% handles.vidHeight  =  handles.v_in.Height;
% handles.vidWidth   =  handles.v_in.Width;
% end
videomodes = get(handles.videomode_popup,'String');
handles.videomode = videomodes{get(handles.videomode_popup,'Value')};
% set the fps field to handles.FrameRate
set(handles.fps,'String',num2str(handles.FrameRate));

if exist(fullfile(handles.dir_name,'prepare.mat'),'file')
    load(fullfile(handles.dir_name,'prepare.mat'));
    % CAL
    set(handles.CAL_start_frame,'String',num2str(CALstart));
    set(handles.CAL_end_frame,'String',num2str(CALend));
    % VAL
    set(handles.VAL_start_frame,'String',num2str(VALstart));
    set(handles.VAL_end_frame,'String',num2str(VALend));
    % GAZE
    set(handles.trigger_frame,'String',num2str(firstart));
    % change color of text
    set(handles.matfile,'ForegroundColor','g')
else
    set(handles.matfile,'ForegroundColor','r')
end
set(handles.GAZE_end_frame,'String',num2str(handles.nFrames));
set(handles.GAZE_start_frame,'String',num2str(str2double(get(handles.trigger_frame,'String'))-ceil(5*handles.FrameRate)));
        


% load the current frame for each axis
% CAL
fr_pair = ET_LoadFramePair(handles.v_in, handles.videomode, str2double(get(handles.CAL_current_frame,'String')));
imshow(fr_pair(:,:,1),'parent',handles.CAL_axes);
% VAL
fr_pair = ET_LoadFramePair(handles.v_in, handles.videomode, str2double(get(handles.VAL_current_frame,'String')));
imshow(fr_pair(:,:,1),'parent',handles.VAL_axes);
% GAZE
fr_pair = ET_LoadFramePair(handles.v_in, handles.videomode, str2double(get(handles.GAZE_current_frame,'String')));
imshow(fr_pair(:,:,1),'parent',handles.GAZE_axes_1);
% show df
df = fr_pair(:,:,2)-fr_pair(:,:,1);
imagesc(df,'parent',handles.GAZE_axes_2);axis(handles.GAZE_axes_2,'off');
% show mdf
mdf = mean(df,2);
plot(mdf,1:length(mdf),'parent',handles.MDF_axes);axis(handles.MDF_axes,'ij','tight');

% update all the time fields
set(handles.CAL_current_time,'String',sprintf('%.3f',str2double(get(handles.CAL_current_frame,'String'))/handles.FrameRate));
set(handles.CAL_start_time,'String',sprintf('%.3f',str2double(get(handles.CAL_start_frame,'String'))/handles.FrameRate));
set(handles.CAL_end_time,'String',sprintf('%.3f',str2double(get(handles.CAL_end_frame,'String'))/handles.FrameRate));
set(handles.CAL_duration_time,'String',sprintf('%.3f',str2double(get(handles.CAL_end_time,'String'))-str2double(get(handles.CAL_start_time,'String'))));

set(handles.VAL_current_time,'String',sprintf('%.3f',str2double(get(handles.VAL_current_frame,'String'))/handles.FrameRate));
set(handles.VAL_start_time,'String',sprintf('%.3f',str2double(get(handles.VAL_start_frame,'String'))/handles.FrameRate));
set(handles.VAL_end_time,'String',sprintf('%.3f',str2double(get(handles.VAL_end_frame,'String'))/handles.FrameRate));
set(handles.VAL_duration_time,'String',sprintf('%.3f',str2double(get(handles.VAL_end_time,'String'))-str2double(get(handles.VAL_start_time,'String'))));

set(handles.GAZE_current_time,'String',sprintf('%.3f',str2double(get(handles.GAZE_current_frame,'String'))/handles.FrameRate));
set(handles.GAZE_start_time,'String',sprintf('%.3f',str2double(get(handles.GAZE_start_frame,'String'))/handles.FrameRate));
set(handles.GAZE_end_time,'String',sprintf('%.3f',str2double(get(handles.GAZE_end_frame,'String'))/handles.FrameRate));
set(handles.GAZE_duration_time,'String',sprintf('%.3f',str2double(get(handles.GAZE_end_time,'String'))-str2double(get(handles.GAZE_start_time,'String'))));

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in CAL_nextframe.
function CAL_nextframe_Callback(hObject, eventdata, handles)
% hObject    handle to CAL_nextframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current=str2double(get(handles.CAL_current_frame,'String'));
set(handles.CAL_current_frame,'String',num2str(current+1));
set(handles.CAL_current_time,'String',sprintf('%.3f',str2double(get(handles.CAL_current_frame,'String'))/handles.FrameRate));

fr_pair = ET_LoadFramePair(handles.v_in, handles.videomode, str2double(get(handles.CAL_current_frame,'String')));
imshow(fr_pair(:,:,1),'parent',handles.CAL_axes);


% --- Executes on button press in CAL_prevframe.
function CAL_prevframe_Callback(hObject, eventdata, handles)
% hObject    handle to CAL_prevframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current=str2double(get(handles.CAL_current_frame,'String'));
set(handles.CAL_current_frame,'String',num2str(current-1));
set(handles.CAL_current_time,'String',sprintf('%.3f',str2double(get(handles.CAL_current_frame,'String'))/handles.FrameRate));

fr_pair = ET_LoadFramePair(handles.v_in, handles.videomode, str2double(get(handles.CAL_current_frame,'String')));
imshow(fr_pair(:,:,1),'parent',handles.CAL_axes);

% --- Executes on button press in VAL_nextframe.
function VAL_nextframe_Callback(hObject, eventdata, handles)
% hObject    handle to VAL_nextframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current=str2double(get(handles.VAL_current_frame,'String'));
set(handles.VAL_current_frame,'String',num2str(current+1));
set(handles.VAL_current_time,'String',sprintf('%.3f',str2double(get(handles.VAL_current_frame,'String'))/handles.FrameRate));

fr_pair = ET_LoadFramePair(handles.v_in, handles.videomode, str2double(get(handles.VAL_current_frame,'String')));
imshow(fr_pair(:,:,1),'parent',handles.VAL_axes);

% --- Executes on button press in VAL_prevframe.
function VAL_prevframe_Callback(hObject, eventdata, handles)
% hObject    handle to VAL_prevframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current=str2double(get(handles.VAL_current_frame,'String'));
set(handles.VAL_current_frame,'String',num2str(current-1));
set(handles.VAL_current_time,'String',sprintf('%.3f',str2double(get(handles.VAL_current_frame,'String'))/handles.FrameRate));

fr_pair = ET_LoadFramePair(handles.v_in, handles.videomode, str2double(get(handles.VAL_current_frame,'String')));
imshow(fr_pair(:,:,1),'parent',handles.VAL_axes);

% --- Executes on button press in GAZE_nextframe.
function GAZE_nextframe_Callback(hObject, eventdata, handles)
% hObject    handle to GAZE_nextframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current=str2double(get(handles.GAZE_current_frame,'String'));
set(handles.GAZE_current_frame,'String',num2str(current+1));
set(handles.GAZE_current_time,'String',sprintf('%.3f',str2double(get(handles.GAZE_current_frame,'String'))/handles.FrameRate));

fr_pair = ET_LoadFramePair(handles.v_in, handles.videomode, str2double(get(handles.GAZE_current_frame,'String')));
imshow(fr_pair(:,:,1),'parent',handles.GAZE_axes_1);
% show df
df = fr_pair(:,:,2)-fr_pair(:,:,1);
imagesc(df,'parent',handles.GAZE_axes_2);axis(handles.GAZE_axes_2,'off');
% show mdf
mdf = mean(df,2);
plot(mdf,1:length(mdf),'parent',handles.MDF_axes);axis(handles.MDF_axes,'ij','tight');


% --- Executes on button press in GAZE_prevframe.
function GAZE_prevframe_Callback(hObject, eventdata, handles)
% hObject    handle to GAZE_prevframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current=str2double(get(handles.GAZE_current_frame,'String'));
set(handles.GAZE_current_frame,'String',num2str(current-1));
set(handles.GAZE_current_time,'String',sprintf('%.3f',str2double(get(handles.GAZE_current_frame,'String'))/handles.FrameRate));

fr_pair = ET_LoadFramePair(handles.v_in, handles.videomode, str2double(get(handles.GAZE_current_frame,'String')));
imshow(fr_pair(:,:,1),'parent',handles.GAZE_axes_1);
% show df
df = fr_pair(:,:,2)-fr_pair(:,:,1);
imagesc(df,'parent',handles.GAZE_axes_2);axis(handles.GAZE_axes_2,'off');
% show mdf
mdf = mean(df,2);
plot(mdf,1:length(mdf),'parent',handles.MDF_axes);axis(handles.MDF_axes,'ij','tight');


% --- Executes on button press in writevideos.
function writevideos_Callback(hObject, eventdata, handles)
% hObject    handle to writevideos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% CAL
CALstart=str2double(get(handles.CAL_start_frame,'String'));
CALend=str2double(get(handles.CAL_end_frame,'String'));
% VAL
VALstart=str2double(get(handles.VAL_start_frame,'String'));
VALend=str2double(get(handles.VAL_end_frame,'String'));
% GAZE
GAZEstart=str2double(get(handles.GAZE_start_frame,'String'));
GAZEend =str2double(get(handles.GAZE_end_frame,'String'));
firstart =  str2double(get(handles.trigger_frame,'String'));
startACQ =  firstart-GAZEstart+1;

% save all the info (time of start acquisition!) in a .mat
save(fullfile(handles.dir_name,'prepare.mat'),...
    'CALstart','CALend','VALstart','VALend','GAZEstart','GAZEend',...
    'firstart','startACQ');
set(handles.matfile,'ForegroundColor','g')



% read the start and end of each video, and write them!
tic
numFrames=CALend-CALstart+1;
video_outfile = strrep(fullfile(handles.dir_name,handles.fname),'.mp4','_CAL.mp4');
% switch computer
%     case {'PCWIN','PCWIN64','GLNXA64'}
        % write a new video object
        v_out = VideoWriter(video_outfile,'MPEG-4');
        set(v_out,'FrameRate',handles.FrameRate,'Quality',100);
        open(v_out);
                for k = 1 : numFrames
                    writeVideo(v_out,read(handles.v_in, CALstart+k-1));
                end
%         writeVideo(v_out,read(handles.v_in, [CALstart (CALstart+numFrames-1)]));
        % Close the file.
        close(v_out);
%     case 'MACI64'
%         [frh,frw] = size(read(handles.v_in,1));
%         v_out = VideoRecorder(video_outfile,'Format','mp4','Size',[frh frw]);
%         for k = 1 : numFrames
%             v_out.addFrame(read(handles.v_in, CALstart+k-1));
%         end
%         clear v_out
% end
elapsed=toc;
fprintf('ET_prepare : Finished writing CAL movie in %.1fs\n',elapsed);

tic
numFrames=VALend-VALstart+1;
video_outfile = strrep(fullfile(handles.dir_name,handles.fname),'.mp4','_VAL.mp4');
% switch computer
%     case {'PCWIN','PCWIN64','GLNXA64'}
        % write a new video object
        v_out = VideoWriter(video_outfile,'MPEG-4');
        set(v_out,'FrameRate',handles.FrameRate,'Quality',100);
        open(v_out);
                for k = 1 : numFrames
                    writeVideo(v_out,read(handles.v_in, VALstart+k-1));
                end
%         writeVideo(v_out,read(handles.v_in, [VALstart (VALstart+numFrames-1)]));
        % Close the file.
        close(v_out);
%     case 'MACI64'
%         [frh,frw] = size(read(handles.v_in,1));
%         v_out = VideoRecorder(video_outfile,'Format','mp4','Size',[frh frw]);
%         for k = 1 : numFrames
%             v_out.addFrame(read(handles.v_in, VALstart+k-1));
%         end
%         clear v_out
% end
elapsed=toc;
fprintf('ET_prepare : Finished writing VAL movie in %.1fs\n',elapsed);

tic
numFrames=GAZEend-GAZEstart+1;
video_outfile = strrep(fullfile(handles.dir_name,handles.fname),'.mp4','_GAZE.mp4');
% switch computer
%     case {'PCWIN','PCWIN64','GLNXA64'}
        % write a new video object
        v_out = VideoWriter(video_outfile,'MPEG-4');
        set(v_out,'FrameRate',handles.FrameRate,'Quality',100);
        open(v_out);
                for k = 1 : numFrames
                    writeVideo(v_out,read(handles.v_in, GAZEstart+k-1));
                end
%         writeVideo(v_out,read(handles.v_in, [GAZEstart min(GAZEstart+numFrames-1,handles.nFrames)]));
        % Close the file.
        close(v_out);
%     case 'MACI64'
%         [frh,frw] = size(read(handles.v_in,1));
%         v_out = VideoRecorder(video_outfile,'Format','mp4','Size',[frh frw]);
%         for k = 1 : numFrames
%             v_out.addFrame(read(handles.v_in, GAZEstart+k-1));
%         end
%         clear v_out
% end
elapsed=toc;
fprintf('ET_prepare : Finished writing GAZE movie in %.1fs\n',elapsed);

return
