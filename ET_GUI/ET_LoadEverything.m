function handles = ET_LoadEverything(handles)
% Load all available data and results once calibration video has been selected
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 12/18/2012 JMT Extract from ET.m
%
% Copyright 2013 California Institute of Technology
% All rights reserved.

% Open a file browser
[fname, dir_name] = uigetfile({'*.mov;*.avi;*.mpg','Supported video formats'},...
  'Select calibration video file');
if isequal(fname,0) || isequal(dir_name,0)
  return
end

% Parse filename stub from calibration video filename
% Expecting filenames of form *_Cal.* and *_Gaze.*
[~, Study_Name, Video_Ext] = fileparts(fname);
Study_Name = Study_Name(1:(end-4));

% Save study name (prefix for video file names)
handles.Study_Name = Study_Name;

% Fill GUI file and path fields
set(handles.CWD,       'String', dir_name);
set(handles.Cal_Video_File, 'String', [Study_Name '_Cal' Video_Ext]);
set(handles.Gaze_Video_File, 'String', [Study_Name '_Gaze' Video_Ext]);

% Check whether videos and analysis files exist for this selection
% This function also fills handles fields with data file names
handles = ET_CheckFiles(handles);

% Use the checkboxes set by ET_CheckFiles to guide loading of available
% data into the GUI.

% Check for calibration pupilometry and load into GUI if available
% Current ROI is set to the calibration video ROI stored in the calibration
% pupils MAT-file.

if get(handles.Cal_Pupils_Checkbox,'Value')
  
  % Load calibration pupilometry into GUI
  fprintf('ET : Loading calibration pupilometry and ROI\n');
  in = load(handles.cal_pupils_file);
  handles.cal_pupils = in.pupils;
  handles.roi = in.roi;
  
end

% Check for calibration model. Load calibration heatmap and fixations if
% available.

if get(handles.Cal_Model_Checkbox,'Value')
  
  % Load calibration model
  fprintf('ET : Loading calibration model\n');
  in = load(handles.calibration_file, 'calibration');
  handles.calibration = in.calibration;
  
end

% Check for gaze pupilometry.

if get(handles.Gaze_Pupils_Checkbox,'Value')
  
  % Load gaze pupilometry
  try
    fprintf('ET : Loading gaze pupilometry\n');
    in = load(handles.gaze_pupils_file);
    handles.gaze_pupils = in.pupils;
  catch GAZE_PUPILS_LOAD
    fprintf('ET : *** Problem loading gaze pupilometry data\n');
  end

end

% Init video, ROI and update GUI
handles = ET_InitVideo(handles.cal_video_path, handles);

% Init gaze plot axes
ET_PlotGaze([], handles.Gaze_Axes, 'init');
