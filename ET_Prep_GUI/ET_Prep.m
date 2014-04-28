function varargout = ET_Prep(varargin)
% ET_PREP MATLAB code for ET_Prep.fig
%      ET_PREP, by itself, creates a new ET_PREP or raises the existing
%      singleton*.
%
%      H = ET_PREP returns the handle to a new ET_PREP or the handle to
%      the existing singleton*.
%
%      ET_PREP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ET_PREP.M with the given input arguments.
%
%      ET_PREP('Property','Value',...) creates a new ET_PREP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ET_Prep_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ET_Prep_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ET_Prep

% Last Modified by GUIDE v2.5 21-Mar-2014 12:34:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ET_Prep_OpeningFcn, ...
    'gui_OutputFcn',  @ET_Prep_OutputFcn, ...
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
dbstop if error

% --- Executes just before ET_Prep is made visible.
function ET_Prep_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ET_Prep (see VARARGIN)

% Choose default command line output for ET_Prep
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ET_Prep wait for user response (see UIRESUME)
% uiwait(handles.Main_Figure);


% --- Outputs from this function are returned to the command line.
function varargout = ET_Prep_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Select_Input_Cal_Video.
function Select_Input_Cal_Video_Callback(hObject, eventdata, handles)
% hObject    handle to Select_Input_Cal_Video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open a file browser
[fname, dir_name] = uigetfile({'*.mov;*.avi;*.mpg;*.mp4','Supported video formats'},...
    'Select calibration video file');
if isequal(fname,0) || isequal(dir_name,0)
    return
end

% Parse filename stub from calibration video filename
% Expecting filenames of form *_Cal.* and *_Gaze.*
[~, Study_Name, Video_Ext] = fileparts(fname);

% Trim "_Cal" from cal video filename to yield study name
Study_Name = Study_Name(1:(end-4));

% Save study name (prefix for video file names)
handles.Study_Name = Study_Name;

% Video file names
input_cal_vfile   = [Study_Name '_Cal' Video_Ext];
input_gaze_vfile  = [Study_Name '_Gaze' Video_Ext];
output_cal_vfile  = [Study_Name, '_prepped_Cal.mp4'];
output_gaze_vfile = [Study_Name, '_prepped_Gaze.mp4'];

% Fill GUI file and path fields
set(handles.CWD,       'String', dir_name);
set(handles.Input_Cal_Video_Name,   'String', input_cal_vfile);
set(handles.Input_Gaze_Video_Name,  'String', input_gaze_vfile);
set(handles.Output_Cal_Video_Name,  'String', output_cal_vfile);
set(handles.Output_Gaze_Video_Name, 'String', output_gaze_vfile);

% Store full paths to video files
handles.input_cal_vfile   = fullfile(dir_name, input_cal_vfile);
handles.input_gaze_vfile  = fullfile(dir_name, input_gaze_vfile);
handles.output_cal_vfile  = fullfile(dir_name, output_cal_vfile);
handles.output_gaze_vfile = fullfile(dir_name, output_gaze_vfile);

% misc
handles.currentFrame = 1;

% Platform-dependent video IO

switch computer
    
    case {'MACI64','GLNXA64'}
        
        % Use VideoUtils 1.2.4 until Matlab performance improves
        try
            v_in = VideoPlayer(handles.input_cal_vfile);
        catch READ_CAL_VIDEO
            fprintf('ET_Prep : Problem opening calibration video to read\n');
            rethrow(READ_CAL_VIDEO);
        end
        
        % Load first frame pair
        poster_frame_pair = ET_Prep_LoadFramePair(v_in);
        
        % Close file
        clear v_in
        
    otherwise
        
        % Use builtin Matlab video reader (R2013b)
        try
            v_in = VideoReader(handles.input_cal_vfile);
        catch READ_CAL_VIDEO
            fprintf('ET_Prep : Problem opening calibration video to read\n');
            rethrow(READ_CAL_VIDEO);
        end
        
        % Load first frame pair
        [poster_frame_pair, handles] = ET_Prep_LoadFramePair(v_in,handles);
        
        % Close video stream
        clear v_in;
        
end

% Show odd frame in input axes with robust intensity scaling
imshow(imadjust(poster_frame_pair(:,:,1)), 'parent', handles.Input_Frame);

% Save first frame pair for ROI updating in GUI
handles.poster_frame_pair = poster_frame_pair;
guidata(handles.Main_Figure, handles);


% --- Executes on button press in MR_Clean_Radio.
function MR_Clean_Radio_Callback(hObject, eventdata, handles)
% hObject    handle to MR_Clean_Radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MR_Clean_Radio


% --- Executes on selection change in Rotate_ROI_Popup.
function Rotate_ROI_Popup_Callback(hObject, eventdata, handles)
% hObject    handle to Rotate_ROI_Popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Rotate_ROI_Popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Rotate_ROI_Popup

% Set ROI rotation and refresh sample output frame

% Update output frame
ET_Prep_UpdateOutputFrame(handles);


% --- Executes during object creation, after setting all properties.
function Rotate_ROI_Popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rotate_ROI_Popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Prep_Videos_Button.
function Prep_Videos_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Prep_Videos_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check that input video has been selected
if ~isfield(handles,'input_cal_vfile')
    fprintf('ET_Prep : Input calibration video file not yet specified\n');
    return
end

% Set output cal filename to orange
set(handles.Output_Cal_Video_Name,'ForegroundColor',[1.0 0.5 0.0]);

% Process calibration video
v_infile  = handles.input_cal_vfile;
v_outfile = handles.output_cal_vfile;
ET_Prep_ProcessVideo(handles, v_infile, v_outfile);

% Set output cal filename to green
set(handles.Output_Cal_Video_Name,'ForegroundColor',[0.0 1.0 0.0]);

% Set output gaze filename to orange
set(handles.Output_Gaze_Video_Name,'ForegroundColor',[1.0 0.5 0.0]);

% Process gaze video
v_infile  = handles.input_gaze_vfile;
v_outfile = handles.output_gaze_vfile;
ET_Prep_ProcessVideo(handles, v_infile, v_outfile);

% Set output gaze filename to green
set(handles.Output_Gaze_Video_Name,'ForegroundColor',[0.0 1.0 0.0]);

% --- Executes on button press in Quit_Button.
function Quit_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Quit_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.Main_Figure);


function Pupil_X_Callback(hObject, eventdata, handles)
% hObject    handle to Pupil_X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Pupil_X as text
%        str2double(get(hObject,'String')) returns contents of Pupil_X as a double


% --- Executes during object creation, after setting all properties.
function Pupil_X_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pupil_X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Select_Pupil_Center_Button.
function Select_Pupil_Center_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Select_Pupil_Center_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% User indicates center of pupil in raw frame
p = ginput(1);
p = round(p);

% Update GUI pupil center
set(handles.Pupil_X, 'String', sprintf('%d', p(1)));
set(handles.Pupil_Y, 'String', sprintf('%d', p(2)));

% Update output frame
ET_Prep_UpdateOutputFrame(handles);


function Pupil_Y_Callback(hObject, eventdata, handles)
% hObject    handle to Pupil_Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Pupil_Y as text
%        str2double(get(hObject,'String')) returns contents of Pupil_Y as a double


% --- Executes during object creation, after setting all properties.
function Pupil_Y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pupil_Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_size_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_size as text
%        str2double(get(hObject,'String')) returns contents of ROI_size as a double

% Force ROI size to be a multiple of 8 (MPEG-4 VideoUtils limitation)
roi_w = str2double(get(handles.ROI_size,'String'));
roi_w = round(roi_w/8)*8;
if roi_w < 8; roi_w = 8; end
set(handles.ROI_size,'String',sprintf('%d',roi_w));

% Update output frame using new ROI size
ET_Prep_UpdateOutputFrame(handles);


% --- Executes during object creation, after setting all properties.
function ROI_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Denoise_Radio.
function Denoise_Radio_Callback(hObject, eventdata, handles)
% hObject    handle to Denoise_Radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Denoise_Radio

% Refresh output frame
ET_Prep_UpdateOutputFrame(handles);
