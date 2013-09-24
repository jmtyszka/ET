function ET_RunWorkFlow(handles)
% Run complete eye tracking workflow
% - make sure that all called functions save their own data and can be used
%   without the GUI
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 09/12/2012 JMT From scratch
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
% Copyright 2012-2013 California Institute of Technology

fprintf('\n');
fprintf('----------------------------\n');
fprintf('ET : Starting workflow at %s\n', datestr(now));

%% Calibration pupilometry

% Check to see if the calibration pupilometry structure has been created
% and filled
do_cal_pupils = false;
if isfield(handles,'cal_pupils')
  if isempty(handles.cal_pupils)
    do_cal_pupils = true;
  end
else
  do_cal_pupils = true;
end

% Peform calibration analysis as needed
if do_cal_pupils
  
  % Run calibration pupilometry
  % Results are saved to the Gaze directory
  fprintf('ET : Running calibration pupilometry\n');
  
  % Input video file name
  video_infile = handles.cal_video_path;
  
  % Initialize gaze video, ROI and update GUI
  handles = ET_InitVideo(video_infile, handles);
  
  % Output video file name
  video_outfile = fullfile(handles.gaze_dir,'Cal_Pupils');
  
  % Assumes scanner is not running during calibration
  do_mrclean    = false;
  
  % Run pupilometry on calibration video
  cal_pupils = ET_Video_Pupilometry(...
    video_infile,...
    video_outfile, ...
    handles.cal_pupils_file, ...
    handles.roi, ...
    handles.p_run, ...
    [], ... % No calibration yet
    do_mrclean, ...
    handles);
  
  % Save calibration pupils in GUI
  handles.cal_pupils = cal_pupils;
  
  % Update GUI checks
  handles = ET_CheckFiles(handles);
  
else
  
  fprintf('ET : Calibration pupilometry already loaded\n');
  
end

%% Calibration model

% Check to see if the calibration model has been created and filled
do_calibration = false;
if isfield(handles,'calibration')
  if isempty(handles.calibration)
    do_calibration = true;
  end
else
  do_calibration = true;
end

% Perform calibration model fitting as required
if do_calibration
  
  % Calculate calibration model and add to handles
  fprintf('ET : Creating calibration model\n');
  
  % Run autocalibration
  calibration = ET_AutoCalibrate([handles.cal_pupils.px], [handles.cal_pupils.py]);
  
  % Return if ET_Cal is empty (problem with auto calibration)
  if isempty(calibration.C)
    fprintf('ET : *** Problem creating calibration model\n');
    return
  end
  
  % Save calibration model
  save(handles.calibration_file, 'calibration');
  handles.calibration = calibration;
  
  % Update GUI checks
  handles = ET_CheckFiles(handles);
  
end

% Display the current calibration model in the GUI
ET_ShowCalibration(handles);

%% Gaze video analysis

% Check to see if gaze pupilometry structure has been created and filled
do_gaze_pupils = false;
if isfield(handles,'gaze_pupils')
  if isempty(handles.gaze_pupils)
    do_gaze_pupils = true;
  end
else
  do_gaze_pupils = true;
end

if do_gaze_pupils
  
  % Input video file name
  video_infile = handles.gaze_video_path;
  
  % Initialize gaze video, ROI and update GUI
  handles = ET_InitVideo(video_infile, handles);
  
  % Output video file name
  video_outfile = fullfile(handles.gaze_dir,'Gaze_Pupils');
  
  % Only check MR clean flag for gaze movie analysis
  do_mrclean    = get(handles.MRClean_Popup,'Value') == 2;
  
  % Run pupilometry on calibration video
  gaze_pupils = ET_Video_Pupilometry(...
    video_infile,...
    video_outfile, ...
    handles.gaze_pupils_file, ...
    handles.roi, ...
    handles.p_run, ...
    handles.calibration.C, ...
    do_mrclean, ...
    handles);
  
  % Save gaze pupils in GUI
  handles.gaze_pupils = gaze_pupils;
  
  % Update GUI checks
  handles = ET_CheckFiles(handles);
  
end

%% Run spike and drift corrections

% Sampling interval
t = [handles.gaze_pupils.t];
dt = t(2) - t(1);

% Uncorrected gaze timeseries
x  = [handles.gaze_pupils.gaze_x];
y  = [handles.gaze_pupils.gaze_y];
a0 = [handles.gaze_pupils.area_correct];

% Despike and drift correct
handles.gaze_filt = ET_SpikeDriftCorrect(x,y,a0,dt);

%% Create HTML report

ET_PupilometryReport(handles);

%% Export text results

ET_ExportGaze(handles);

%% Postamble

fprintf('ET : Completed workflow at %s\n', datestr(now));
fprintf('-----------------------------\n');
fprintf('\n');

