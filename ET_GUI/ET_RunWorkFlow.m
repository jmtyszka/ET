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

dbstop if error

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
  
  set(handles.Calibration_Axis_Title,'String','Calibration');
  % Run autocalibration
  %     calibration = ET_AutoCalibrate([handles.cal_pupils.px], [handles.cal_pupils.py], [handles.Calibration_Axes]);
  calibration = ET_AutoCalibrate(handles.cal_pupils,handles);
  
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
  
  % Display the current calibration model in the GUI
  set(handles.Calibration_Axis_Title,'String','Calibration');
  ET_ShowCalibration(handles);
  
else
  
  fprintf('ET : Calibration model already loaded\n');
  
end




%% JD : use Validation video if present


if sum(get(handles.Val_Video_File,'ForegroundColor')==[0 0.75 0])==3
  
  % Check to see if gaze pupilometry structure has been created and filled
  do_val_pupils = false;
  if isfield(handles,'val_pupils')
    if isempty(handles.val_pupils)
      do_val_pupils = true;
    end
  else
    do_val_pupils = true;
  end
  
  if do_val_pupils
    
    % Input video file name
    video_infile = handles.val_video_path;
    
    % Initialize gaze video, ROI and update GUI
    handles = ET_InitVideo(video_infile, handles);
    
    % Output video file name
    video_outfile = fullfile(handles.gaze_dir,'Val_Pupils');
    
    % Only check MR clean flag for gaze movie analysis
    do_mrclean    = 'false';
    
    % Run pupilometry on calibration video
    val_pupils = ET_Video_Pupilometry(...
      video_infile,...
      video_outfile, ...
      handles.val_pupils_file, ...
      handles.roi, ...
      handles.p_run, ...
      handles.calibration.C, ...
      do_mrclean, ...
      handles);
    
    % Save gaze pupils in GUI
    handles.val_pupils = val_pupils;
    
    % Update GUI checks
    handles = ET_CheckFiles(handles);
    
  else
    
    fprintf('ET : Validation pupilometry already loaded\n');
  end
  
  %% Validation model
  
  % Check to see if the validation model has been created and filled
  do_validation = false;
  if isfield(handles,'validation')
    if isempty(handles.validation)
      do_validation = true;
    end
  else
    do_validation = true;
  end
  
  % Perform validation model fitting as required
  if do_validation
    
    % Calculate calibration model and add to handles
    fprintf('ET : Creating validation model\n');
    set(handles.Calibration_Axis_Title,'String','Validation');
    
    % Run autocalibration
    %         validation = ET_AutoCalibrate([handles.val_pupils.px], [handles.val_pupils.py], handles);
    validation = ET_AutoCalibrate(handles.val_pupils, handles);
    
    % Return if ET_Cal is empty (problem with auto calibration)
    if isempty(validation.C)
      fprintf('ET : *** Problem creating validation model\n');
      return
    end
    
    % Save validation model
    save(handles.validation_file, 'validation');
    handles.validation = validation;
    
    % Update GUI checks
    handles = ET_CheckFiles(handles);
    
    set(handles.Calibration_Axis_Title,'String','Validation');
    ET_ShowValidation(handles);
  else
    
    fprintf('ET : Validation model already loaded\n');
    
  end
  
  
end


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
  
  % Only check MR clean flag for gaze movie analysis
  do_mrclean    = get(handles.MRClean_Popup,'Value') == 2;
  
  set(handles.Calibration_Axis_Title,'String','Calibration');
  ET_ShowCalibration(handles);
  
  video_outfile = fullfile(handles.gaze_dir,'Gaze_Pupils');
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
  
else
  
  fprintf('ET : Gaze pupilometry already loaded\n');
end

if 1
  % edit JD: clean up before reapplying models -- this is in place so we can easily
  % update the calibration model with motion estimates and reapply it
  fprintf('ET : Cleaning up before re-applying models\n');
  pupils=handles.gaze_pupils;
  pupils=rmfield(pupils,{'gaze_x'});%,'gaze_y','gaze_a0'});
  if isfield(pupils,'gazeVal_x')
    pupils=rmfield(pupils,{'gazeVal_x'});%,'gazeVal_y','gazeVal_a0'});
  end
  if isfield(pupils,'gazeVal_filt_x')
    pupils=rmfield(pupils,{'gazeVal_filt_x'});%,'gazeVal_filt_y','gazeVal_filt_a0'});
  end
  if isfield(pupils,'gaze_filt_x')
    pupils=rmfield(pupils,{'gaze_filt_x'});%,'gaze_filt_y','gaze_filt_a0'});
  end
  save(handles.gaze_pupils_file,'pupils','-append');
  handles.gaze_pupils=pupils;
end


% apply Calibration model to the raw pupils
if sum(get(handles.Cal_Video_File,'ForegroundColor')==[0 0.75 0])==3 && ~isfield(handles.gaze_pupils,'gaze_x')
  fprintf('ET : Applying Calibration model\n');
  pupils=handles.gaze_pupils;
  for ifr=1:length(pupils)
    % Use validation model
    [pupils(ifr).gaze_x,pupils(ifr).gaze_y] = ET_ApplyCalibration(pupils(ifr).px, pupils(ifr).py, handles.calibration.C);
  end
  save(handles.gaze_pupils_file,'pupils','-append');
  handles.gaze_pupils=pupils;
else
  fprintf('ET : Calibration model missing or already applied\n');
end


% apply validation model as well to the pupils
if sum(get(handles.Val_Video_File,'ForegroundColor')==[0 0.75 0])==3 && ~isfield(handles.gaze_pupils,'gazeVal_x')
  fprintf('ET : Applying Validation model\n');
  pupils=handles.gaze_pupils;
  for ifr=1:length(pupils)
    % Use validation model
    [pupils(ifr).gazeVal_x,pupils(ifr).gazeVal_y] = ET_ApplyCalibration(pupils(ifr).px, pupils(ifr).py, handles.validation.C);
  end
  save(handles.gaze_pupils_file,'pupils','-append');
  handles.gaze_pupils=pupils;
else
  fprintf('ET : Validation model missing or already applied\n');
end

%% Run spike and drift corrections
if isfield(handles.gaze_pupils,'gaze_x') && ~isfield(handles.gaze_pupils,'gaze_filt_x')
  % CALIBRATION MODEL
  % Sampling interval
  t = [handles.gaze_pupils.t];
  dt = t(2) - t(1);
  % Uncorrected gaze timeseries
  x  = [handles.gaze_pupils.gaze_x];
  y  = [handles.gaze_pupils.gaze_y];
  a0 = [handles.gaze_pupils.area_correct];
  % Despike and drift correct
  gaze_filt = ET_SpikeDriftCorrect(x,y,a0,dt);
  pupils=handles.gaze_pupils;
  for ifr=1:length(pupils)
    pupils(ifr).gaze_filt_x=gaze_filt.x(ifr);
    pupils(ifr).gaze_filt_y=gaze_filt.y(ifr);
    pupils(ifr).gaze_filt_a0=gaze_filt.a0(ifr);
  end
  save(handles.gaze_pupils_file,'pupils','-append');
  handles.gaze_pupils=pupils;
else
  fprintf('ET : Spike/drift correction already applied\n');
end

if isfield(handles.gaze_pupils,'gazeVal_x') && ~isfield(handles.gaze_pupils,'gazeVal_filt_x')
  % VALIDATION MODEL
  % Uncorrected gaze timeseries
  x  = [handles.gaze_pupils.gazeVal_x];
  y  = [handles.gaze_pupils.gazeVal_y];
  % Despike and drift correct
  gaze_filt = ET_SpikeDriftCorrect(x,y,a0,dt);
  pupils=handles.gaze_pupils;
  for ifr=1:length(pupils)
    pupils(ifr).gazeVal_filt_x=gaze_filt.x(ifr);
    pupils(ifr).gazeVal_filt_y=gaze_filt.y(ifr);
    pupils(ifr).gazeVal_filt_a0=gaze_filt.a0(ifr);
  end
  save(handles.gaze_pupils_file,'pupils','-append');
  handles.gaze_pupils=pupils;
end

%% Create HTML report

ET_PupilometryReport(handles);

%% Export text results

ET_ExportGaze(handles);

%% Postamble

fprintf('ET : Completed workflow at %s\n', datestr(now));
fprintf('-----------------------------\n');
fprintf('\n');

