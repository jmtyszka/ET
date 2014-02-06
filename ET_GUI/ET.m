function varargout = ET(varargin)
% ET MATLAB code for ET.fig
%      ET, by itself, creates a new ET or raises the existing
%      singleton*.
%
%      H = ET returns the handle to a new ET or the handle to
%      the existing singleton*.
%
%      ET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ET.M with the given input arguments.
%
%      ET('Property','Value',...) creates a new ET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ET_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ET_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% This file is part of ET.
% 
%     ET is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     ET is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
%
% Copyright 2013 California Institute of Technology.
%
% Edit the above text to modify the response to help ET

% Last Modified by GUIDE v2.5 05-Oct-2013 22:43:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @ET_OpeningFcn, ...
  'gui_OutputFcn',  @ET_OutputFcn, ...
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


% --- Executes just before ET is made visible.
function ET_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ET (see VARARGIN)

% Choose default command line output for ET
handles.output = hObject;

% Init stop button flag to false
handles.stop_pressed = false;

% Update handles structure
guidata(hObject, handles);

% Set base image colormap
colormap(hot);

% UIWAIT makes ET wait for user response (see UIRESUME)
% uiwait(handles.Main_Figure);


% --- Outputs from this function are returned to the command line.
function varargout = ET_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Select_Cal_Video_Button.
function Select_Cal_Video_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Select_Cal_Video_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Call universal loader function
handles = ET_LoadEverything(handles);

% Resave handles structure in GUI
guidata(hObject, handles);


% --- Executes on button press in Go_Button.
function Go_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Go_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Call video preparation function with GUI parameters
if isfield(handles,'p_run')
  
  % Run workflow
  ET_RunWorkFlow(handles);
  
  % Update file checks
  ET_CheckFiles(handles);
  
  % Save updates in GUI
  guidata(hObject,handles);
  
else
  
  fprintf('ET : *** No initial pupil structure detected\n');
  return
  
end


function PD_Min_Callback(hObject, eventdata, handles)
% hObject    handle to PD_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PD_Min as text
%        str2double(get(hObject,'String')) returns contents of PD_Min as a double


% --- Executes during object creation, after setting all properties.
function PD_Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PD_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end


function PD_Max_Callback(hObject, eventdata, handles)
% hObject    handle to PD_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PD_Max as text
%        str2double(get(hObject,'String')) returns contents of PD_Max as a double


% --- Executes during object creation, after setting all properties.
function PD_Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PD_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function Progress_Bar_Callback(hObject, eventdata, handles)
% hObject    handle to Progress_Bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function Progress_Bar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Progress_Bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in Gaze_Pupils_Checkbox.
function Gaze_Pupils_Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Gaze_Pupils_Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Gaze_Pupils_Checkbox

% Get state of Calibration Model checkbox
if get(hObject,'Value') == 0
  
  % State just changed to zero

  button = questdlg('Do you want to delete the gaze pupilometry?',...
    'Confirm Delete','Yes','No','No');

  if isfield(handles,'gaze_pupils_file')
    
    switch lower(button)
      case 'yes'
        % Delete gaze pupilometry data in Gaze subdirectory and GUI
        delete(fullfile(handles.gaze_dir,'Gaze*'));
        delete(fullfile(handles.gaze_dir,'gaze*'));
        handles.gaze_pupils = [];
        fprintf('ET : Gaze pupilometry deleted\n');
      otherwise
        % Do nothing
    end
    
  else
    
    fprintf('ET : Gaze pupilometry file undefined in GUI\n');
    
  end

  % Refresh file checks
  handles=ET_CheckFiles(handles);
  % Resave handles
  guidata(hObject, handles);
  
else
  
  % Checkbox just set - can't be done manually, so unset again
  set(hObject,'Value', 0);
  
end

% --- Executes on button press in Cal_Pupils_Checkbox.
function Cal_Pupils_Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Cal_Pupils_Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Cal_Pupils_Checkbox

% Get state of Calibration Model checkbox
if get(hObject,'Value') == 0
  
  % State just changed to zero

  button = questdlg('Do you want to delete the calibration pupilometry?',...
    'Confirm Delete','Yes','No','No');

  switch lower(button)
    case 'yes'
      % Delete calibration pupilometry data and model in Gaze subdirectory and GUI
      delete(fullfile(handles.gaze_dir,'Cal*'));
      delete(fullfile(handles.gaze_dir,'cal*'));
      handles.cal_pupils = [];
      fprintf('ET : Calibration pupilometry deleted\n');
    otherwise
      % Do nothing
  end

   % Refresh file checks
  handles=ET_CheckFiles(handles);
  % Resave handles
  guidata(hObject, handles);
  
else
  
  % Checkbox just set - can't be done manually, so unset again
  set(hObject,'Value', 0);
  
end


% --- Executes on button press in Cal_Model_Checkbox.
function Cal_Model_Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Cal_Model_Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Cal_Model_Checkbox

% Get state of Calibration Model checkbox
if get(hObject,'Value') == 0
  
  % State just changed to zero

  button = questdlg('Do you want to delete the calibration model?',...
    'Confirm Delete','Yes','No','No');

  calibration_file = handles.calibration_file;
  
  switch lower(button)
    case 'yes'
      if exist(calibration_file,'file')
        delete(calibration_file);
        fprintf('ET : Calibration model deleted\n');
      end
      if isfield(handles,'calibration')
          handles=rmfield(handles,'calibration');
      end
      otherwise
      % Do nothing
  end

   % Refresh file checks
  handles=ET_CheckFiles(handles);
  % Resave handles
  guidata(hObject, handles);
  
else
  
  % Checkbox just set - can't be done manually, so unset again
  set(hObject,'Value', 0);
  
end

% --- Executes on button press in Val_Pupils_Checkbox.
function Val_Pupils_Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Cal_Pupils_Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Cal_Pupils_Checkbox

% Get state of Calibration Model checkbox
if get(hObject,'Value') == 0
  
  % State just changed to zero

  button = questdlg('Do you want to delete the validation pupilometry?',...
    'Confirm Delete','Yes','No','No');

  switch lower(button)
    case 'yes'
      % Delete calibration pupilometry data and model in Gaze subdirectory and GUI
      delete(fullfile(handles.gaze_dir,'Val*'));
      delete(fullfile(handles.gaze_dir,'val*'));
      handles.val_pupils = [];
      fprintf('ET : Validation pupilometry deleted\n');
    otherwise
      % Do nothing
  end

   % Refresh file checks
  handles=ET_CheckFiles(handles);
  % Resave handles
  guidata(hObject, handles);
  
else
  
  % Checkbox just set - can't be done manually, so unset again
  set(hObject,'Value', 0);
  
end


% --- Executes on button press in Cal_Model_Checkbox.
function Val_Model_Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Cal_Model_Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Cal_Model_Checkbox

% Get state of Validation Model checkbox
if get(hObject,'Value') == 0
  
  % State just changed to zero

  button = questdlg('Do you want to delete the validation model?',...
    'Confirm Delete','Yes','No','No');

  validation_file = handles.validation_file;
  
  switch lower(button)
    case 'yes'
      if exist(validation_file,'file')
        delete(validation_file);
        fprintf('ET : Validation model deleted\n');
       handles=rmfield(handles,'validation');     
     end
    otherwise
      % Do nothing
  end

   % Refresh file checks
  handles=ET_CheckFiles(handles);
  % Resave handles
  guidata(hObject, handles);
  
else
  
  % Checkbox just set - can't be done manually, so unset again
  set(hObject,'Value', 0);
  
end



function Screen_Width_Callback(hObject, eventdata, handles)
% hObject    handle to Screen_Width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Screen_Width as text
%        str2double(get(hObject,'String')) returns contents of Screen_Width as a double


% --- Executes during object creation, after setting all properties.
function Screen_Width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Screen_Width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Screen_Height_Callback(hObject, eventdata, handles)
% hObject    handle to Screen_Height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Screen_Height as text
%        str2double(get(hObject,'String')) returns contents of Screen_Height as a double


% --- Executes during object creation, after setting all properties.
function Screen_Height_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Screen_Height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function eyetocamera_Callback(hObject, eventdata, handles)
% hObject    handle to eyetocamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eyetocamera as text
%        str2double(get(hObject,'String')) returns contents of eyetocamera as a double


% --- Executes during object creation, after setting all properties.
function eyetocamera_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eyetocamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function eyetoscreen_Callback(hObject, eventdata, handles)
% hObject    handle to eyetocamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eyetocamera as text
%        str2double(get(hObject,'String')) returns contents of eyetoscreen as a double
% --- Executes during object creation, after setting all properties.


function eyetoscreen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eyetocamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in Pupil_Thresh_Popup.
function Pupil_Thresh_Popup_Callback(hObject, eventdata, handles)
% hObject    handle to Pupil_Thresh_Popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Pupil_Thresh_Popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Pupil_Thresh_Popup

% Ungray manual threshold input if Hard (option 4) selected
switch get(hObject,'Value')
  case 4
    set(handles.Pupil_Threshold,'Enable','on');
  otherwise
    set(handles.Pupil_Threshold,'Enable','off');
end

thresh_modes = get(handles.Pupil_Thresh_Popup, 'String');
thresh_mode = thresh_modes{get(handles.Pupil_Thresh_Popup, 'Value')};
fprintf('ET : Pupil threshold method set to %s\n', thresh_mode);

% Update ROI image in GUI using new threshold
handles = ET_UpdateROIImage(handles);

% Resave handles
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function Pupil_Thresh_Popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pupil_Thresh_Popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Pupil_Threshold_Callback(hObject, eventdata, handles)
% hObject    handle to Pupil_Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Pupil_Threshold as text
%        str2double(get(hObject,'String')) returns contents of Pupil_Threshold as a double

% Update ROI image in GUI using new manual threshold
handles = ET_UpdateROIImage(handles);

% Resave handles
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function Pupil_Threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pupil_Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over axes background.
function Calibration_Axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Calibration_Axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Respond to mouse only during edit phase
if handles.Edit_Phase
  
  fprintf('ET : Edit phase mouse button down');
  
end


% --- Executes on button press in Accept_Edits_Button.
function Accept_Edits_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Accept_Edits_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Stop_Button.
function Stop_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Stop_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fprintf('ET : Stop button pressed\n');
handles.stop_pressed = true;

% Resave handles data
guidata(hObject, handles);


% --- Executes on button press in Debug_Toggle.
function Debug_Toggle_Callback(hObject, eventdata, handles)
% hObject    handle to Debug_Toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Debug_Toggle





% --- Executes on button press in Quit_Button.
function Quit_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Quit_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fprintf('ET : Exiting normally\n');
close(handles.Main_Figure);

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


% --- Executes on button press in do_pupilometry_only.
function do_pupilometry_only_Callback(hObject, eventdata, handles)
% hObject    handle to do_pupilometry_only (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of do_pupilometry_only
