function handles = ET_CheckFiles(handles)
% Check existance of videos and analysis files for the current directory
% - update GUI checkboxes for data files
% - add data file names to handles structure
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 10/09/2012 JMT Extract from ET.m
%          12/18/2012 JMT Add data filenames to handles
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
% Copyright 2012 California Institute of Technology

% Full paths to videos
dir_name = get(handles.CWD,'String');
cal_video_path = fullfile(dir_name, get(handles.Cal_Video_File,'String'));
gaze_video_path = fullfile(dir_name, get(handles.Gaze_Video_File,'String'));

% Check that calibration and gaze videos exist - color green if present, red if absent
if exist(cal_video_path,'file')
  set(handles.Cal_Video_File, 'ForegroundColor', [0 0.75 0]);
else
  set(handles.Cal_Video_File, 'ForegroundColor','r');
end

if exist(gaze_video_path,'file')
  set(handles.Gaze_Video_File, 'ForegroundColor', [0 0.75 0]);
else
  set(handles.Gaze_Video_File, 'ForegroundColor','r');
end

% Create and save data filenames in the Gaze subdirectory
gaze_dir = fullfile(dir_name, 'Gaze');
report_dir       = fullfile(gaze_dir,'Report');
cal_pupils_file  = fullfile(gaze_dir,'Cal_Pupils.mat');
calibration_file = fullfile(gaze_dir,'Calibration.mat');
gaze_pupils_file = fullfile(gaze_dir,'Gaze_Pupils.mat');

% Update check boxes in GUI
set(handles.Cal_Pupils_Checkbox,  'Value', exist(cal_pupils_file,'file')  > 0);
set(handles.Cal_Model_Checkbox,   'Value', exist(calibration_file,'file') > 0);
set(handles.Gaze_Pupils_Checkbox, 'Value', exist(gaze_pupils_file,'file') > 0);

% Save filenames and paths in handles structure
handles.gaze_dir = gaze_dir;
handles.report_dir = report_dir;
handles.cal_video_path = cal_video_path;
handles.gaze_video_path = gaze_video_path;
handles.cal_pupils_file = cal_pupils_file;
handles.calibration_file = calibration_file;
handles.gaze_pupils_file = gaze_pupils_file;

