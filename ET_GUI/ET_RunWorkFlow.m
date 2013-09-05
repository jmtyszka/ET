function ET_RunWorkFlow(handles)
% Run complete eye tracking workflow
% - make sure that all called functions save their own data and can be used
%   without the GUI
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 09/12/2012 JMT From scratch
%
% Copyright 2012 California Institute of Technology
% All rights reserved.

fprintf('\n');
fprintf('----------------------------\n');
fprintf('ET : Starting workflow at %s\n', datestr(now));

%% Calibration pupilometry

% Check to see if 
if isempty(handles.cal_pupils)
  
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
  
  % Update GUI checks
  handles = ET_CheckFiles(handles);
  
else
  
  fprintf('ET : Calibration pupilometry already loaded');
  
end

%% Calibration model

if isempty(handles.calibration)
  
  % Calculate calibration model and add to handles
  fprintf('ET : Creating calibration model\n');
  
  % Run autocalibration
  calibration = ET_AutoCalibrate([cal_pupils.px], [cal_pupils.py]);
  
  % Return if ET_Cal is empty (problem with auto calibration)
  if isempty(calibration.C)
    fprintf('ET : *** Problem creating calibration model\n');
    return
  end
  
  ET_ShowCalibration(calibration, handles);
  
  % Save calibration model
  save(handles.calibration_file, 'calibration');
  
  % Update GUI checks
  handles = ET_CheckFiles(handles);
  
end

%% Gaze video analysis

if isempty(handles.gaze_pupils)
  
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
    calibration.C, ...
    do_mrclean, ...
    handles);
  
end

%% Run spike and drift corrections

% Sampling interval
t = [gaze_pupils.t];
dt = t(2) - t(1);

% Uncorrected gaze timeseries
x = [gaze_pupils.gaze_x];
y = [gaze_pupils.gaze_y];
a0 = [gaze_pupils.area_correct];

% Despike and drift correct
gaze_filt = ET_SpikeDriftCorrect(x,y,a0,dt);

%% Create HTML report

ET_PupilometryReport(handles.gaze_dir, cal_pupils, calibration, gaze_pupils, gaze_filt);

%% Export text results

ET_ExportGaze(handles.gaze_dir, gaze_pupils, gaze_filt);

%% Postamble

fprintf('ET : Completed workflow at %s\n', datestr(now));
fprintf('-----------------------------\n');
fprintf('\n');

