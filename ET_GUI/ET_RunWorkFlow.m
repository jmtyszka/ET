function ET_RunWorkFlow(handles)
% Run complete eye tracking workflow
% - make sure that all called functions save their own data and can be used
%   without the GUI
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 09/12/2012 JMT From scratch
%          02/08/2013 JMT Depricate validation for now (use calibration
%                         only)
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
% Copyright 2012-2014 California Institute of Technology

fprintf('\n');
fprintf('----------------------------\n');
fprintf('ET : Starting workflow at %s\n', datestr(now));

% Refresh file existance checkboxes in GUI
handles = ET_CheckFiles(handles);

%% Calibration pupilometry
% Check to see if the calibration model has been created and filled
do_cal_pupils = false;

if isfield(handles,'cal_pupils')
    if isempty(handles.cal_pupils)
        % calibration exists but is empty - run calibration
        do_cal_pupils = true;
    end
else
    % calibration doesn't exist - run calibration
    do_cal_pupils = true;
end

% Perform calibration analysis if necessary
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
    
    % Run pupilometry on calibration video
    [cal_pupils, stop_pressed] = ET_Video_Pupilometry(...
        video_infile,...
        video_outfile, ...
        handles.cal_pupils_file, ...
        handles.p_run, ...
        [], ... % No calibration yet
        handles);
    
    % Save calibration pupils in GUI
    handles.cal_pupils = cal_pupils;
    
    % Check for stop button press 
    if stop_pressed
        return
    end
    
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
        % calibration exists but is empty - run calibration
        do_calibration = true;
    end
else
    % calibration doesn't exist - run calibration
    do_calibration = true;
end

% Perform calibration model fitting as required
if do_calibration
    
    % Calculate calibration model and add to handles
    fprintf('ET : Creating calibration model\n');

    % Init calibration axis title
    set(handles.Calibration_Axis_Title,'String','Calibration');

    % Run autocalibration
    calibration = ET_AutoCalibrate(handles.cal_pupils, handles);
    
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
    
    set(handles.Calibration_Axis_Title,'String','Calibration');
    ET_ShowCalibration(handles);
    
    video_outfile = fullfile(handles.gaze_dir,'Gaze_Pupils');
    
    [gaze_pupils, stop_pressed] = ET_Video_Pupilometry(...
        video_infile,...
        video_outfile, ...
        handles.cal_pupils_file, ...
        handles.p_run, ...
        handles.calibration.C, ...
        handles);

    % Save gaze pupils in GUI
    handles.gaze_pupils = gaze_pupils;
    
    % Check for stop button press 
    if stop_pressed
        return
    end
    
    % Update GUI checks
    handles = ET_CheckFiles(handles);
    
else
    
    fprintf('ET : Gaze pupilometry already loaded\n');
    
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
gaze_filt = ET_SpikeDriftCorrect(x,y,a0,dt);

% Add temporally filtered gaze to pupils structure array
pupils = handles.gaze_pupils;
    
for pc = 1:length(pupils)
    pupils(pc).gaze_filt_x  = gaze_filt.x(pc);
    pupils(pc).gaze_filt_y  = gaze_filt.y(pc);
    pupils(pc).gaze_filt_a0 = gaze_filt.a0(pc);
end

% Save full pupils structure including temporally filtered gaze
save(handles.gaze_pupils_file,'pupils');

% Resave filtered pupils in handles structure
handles.gaze_pupils = pupils;

%% Create HTML report

ET_PupilometryReport(handles);

%% Export text results

ET_ExportGaze(handles);

%% Postamble

fprintf('ET : Completed workflow at %s\n', datestr(now));
fprintf('-----------------------------\n');
fprintf('\n');

