function handles = ET_LoadEverything(handles)
% Load all available data and results once calibration video has been selected
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 12/18/2012 JMT Extract from ET.m
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
% Copyright 2013 California Institute of Technology

% Open a file browser
% edit JD 9/27/13 added .mp4
[fname, dir_name] = uigetfile({'*.mov;*.avi;*.mpg;*.mp4','Supported video formats'},...
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
set(handles.Val_Video_File, 'String', [Study_Name '_Val' Video_Ext]);
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
    
    % Set rotation value saved in calibration pupilometry
    rots = [0 90 -90 180];
    % Set rotation from GUI
    set(handles.ROI_Rotation_Popup, 'Value',find(rots==handles.roi.rotation));
end

% Check for calibration model. Load calibration heatmap and fixations if
% available.

if get(handles.Cal_Model_Checkbox,'Value')
    
    % Load calibration model
    fprintf('ET : Loading calibration model\n');
    in = load(handles.calibration_file, 'calibration');
    handles.calibration = in.calibration;
    
end


% Check for validation pupilometry.

if get(handles.Val_Pupils_Checkbox,'Value')
    
    try
        fprintf('ET : Loading validation pupilometry\n');
        in = load(handles.val_pupils_file);
        handles.val_pupils = in.pupils;
    catch VAL_PUPILS_LOAD
        fprintf('ET : *** Problem loading validation pupilometry data\n');
    end
    
end

if get(handles.Val_Model_Checkbox,'Value')
    
    % Load validation model
    fprintf('ET : Loading validation model\n');
    in = load(handles.validation_file, 'validation');
    handles.validation = in.validation;
    
end

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
