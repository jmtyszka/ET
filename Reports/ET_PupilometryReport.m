function ET_PupilometryReport(handles)
%ET_PUPILOMETRYREPORT Create an HTML report for a pupilometry run
%
% ET_PupilometryReport(gaze_dir, cal_pupils, calibration, gaze_pupils, gaze_0)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 01/28/2013 JMT From scratch
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
dbstop if error

% Extract relevant fields from handles structure
gaze_dir    = handles.gaze_dir;

% HTML report filename
report_file = fullfile(gaze_dir,'Report.html');

fprintf('ET : Creating report - %s\n', report_file);

fd = fopen(report_file,'w');
if fd < 0
  fprintf('Could not open %s to write\n', report_file);
  return
end

% Write HTML header
fprintf(fd,'<html>\n');
fprintf(fd, '<head>\n');
fprintf(fd, '<STYLE TYPE="text/css">\n');
fprintf(fd, '<!--\n');
fprintf(fd, 'BODY { font-family:sans-serif; }\n');
fprintf(fd, '-->\n');
fprintf(fd, '</STYLE>\n');
fprintf(fd, '</head>\n');
fprintf(fd, '<body>\n');

fprintf(fd,'<h2>ET PUPILOMETRY REPORT</h2>\n');
fprintf(fd,'<hr>\n');


%% Calibration Report

if get(handles.Cal_Pupils_Checkbox,'Value')
  fprintf(fd,'<h2>CALIBRATION</h2>\n');
  cal_pupils  = handles.cal_pupils;
  
  % Calculate basic pupilometry stats
  cal_stats = ET_PupilometryStats(cal_pupils);
  
  fprintf(fd,'<table>\n');
  fprintf(fd,'<tr><td>Video duration <td>%0.3f seconds\n', cal_stats.t_dur);
  fprintf(fd,'<tr><td>Video rate <td>%0.3f fps\n', cal_stats.fps);
  fprintf(fd,'</table>\n');
  
  % Extract timeseries
  t      = [cal_pupils.t];
  px_cal = [cal_pupils.px];
  py_cal = [cal_pupils.py];
  
  % Generate calibration timeseries plots
  ET_PlotTimeseries(t, px_cal, [], 'Calibration X', fullfile(gaze_dir, 'cal_px.png'));
  ET_PlotTimeseries(t, py_cal, [], 'Calibration Y', fullfile(gaze_dir, 'cal_py.png'));
  
  % Add calibration timeseries to page
  fprintf(fd,'<h3>Calibration Timeseries<h3>\n');
  fprintf(fd,'<table><tr>\n');
  fprintf(fd,'<td><img src=cal_px.png width=640>\n');
  fprintf(fd,'<td><img src=cal_py.png width=640>\n');
  fprintf(fd,'</tr></table>\n');
  
  % Generate calibration heatmaps (raw and calibration applied)
  cal_hmap_stub = fullfile(gaze_dir,'cal');
  
  if ismac
    v_in = VideoPlayer(fullfile(gaze_dir,'Cal_Pupils.mov'), 'Verbose', false, 'ShowTime', false);
    fr_pair = ET_LoadFramePair(v_in, 'interlaced', 1);
  else
    v_in = VideoReader(fullfile(gaze_dir,'Cal_Pupils.avi'));
    fr_pair = ET_LoadFramePair(v_in, 'progressive', 1);
  end

  eyeCAL = fr_pair(:,:,1);
  
  if get(handles.Cal_Model_Checkbox,'Value')
    calibration = handles.calibration;
    
    ET_PlotCalibration(px_cal, py_cal, calibration, cal_hmap_stub, eyeCAL);
    
    % Add calibration heatmaps to page
    fprintf(fd,'<h3>Calibration Heatmaps<h3>\n');
    fprintf(fd,'<table><tr>\n');
    fprintf(fd,'<td><img src=cal_hmap_raw.png width=640>\n');
    fprintf(fd,'<td><img src=cal_hmap_cal.png width=640>\n');
    fprintf(fd,'</tr></table>\n');
  end
end

%% Validation Report

if get(handles.Val_Pupils_Checkbox,'Value')
  fprintf(fd,'<h2>VALIDATION</h2>\n');
  val_pupils  = handles.val_pupils;
  
  % Calculate basic pupilometry stats
  val_stats = ET_PupilometryStats(val_pupils);
  
  fprintf(fd,'<table>\n');
  fprintf(fd,'<tr><td>Video duration <td>%0.3f seconds\n', val_stats.t_dur);
  fprintf(fd,'<tr><td>Video rate <td>%0.3f fps\n', val_stats.fps);
  fprintf(fd,'</table>\n');
  
  % Extract timeseries
  t      = [val_pupils.t];
  px_val = [val_pupils.px];
  py_val = [val_pupils.py];
  
  % Generate calibration timeseries plots
  ET_PlotTimeseries(t, px_val, [], 'Valibration X', fullfile(gaze_dir, 'val_px.png'));
  ET_PlotTimeseries(t, py_val, [], 'Valibration Y', fullfile(gaze_dir, 'val_py.png'));
  
  % Add calibration timeseries to page
  fprintf(fd,'<h3>Validation Timeseries<h3>\n');
  fprintf(fd,'<table><tr>\n');
  fprintf(fd,'<td><img src=val_px.png width=640>\n');
  fprintf(fd,'<td><img src=val_py.png width=640>\n');
  fprintf(fd,'</tr></table>\n');
  
  % Generate calibration figure
  val_hmap_stub = fullfile(gaze_dir,'val');
  
  if ismac
    v_in = VideoPlayer(fullfile(gaze_dir,'Val_Pupils.mov'), 'Verbose', false, 'ShowTime', false);
    fr_pair = ET_LoadFramePair(v_in, 'interlaced', 1);
  else
    v_in=VideoReader(fullfile(gaze_dir,'Val_Pupils.avi'));
    fr_pair = ET_LoadFramePair(v_in, 'progressive', 1);
  end

  eyeVAL=fr_pair(:,:,1);
  
  if get(handles.Val_Model_Checkbox,'Value')
    validation = handles.validation;
    ET_PlotCalibration(px_val, py_val, validation, val_hmap_stub, eyeVAL);
    
    % Add calibration heatmaps to page
    fprintf(fd,'<h3>Validation Heatmaps<h3>\n');
    fprintf(fd,'<table><tr>\n');
    fprintf(fd,'<td><img src=val_hmap_raw.png width=640>\n');
    fprintf(fd,'<td><img src=val_hmap_cal.png width=640>\n');
    fprintf(fd,'</tr></table>\n');
    
  end
end

%% Gaze Pupilometry Report (calibration model)

if get(handles.Gaze_Pupils_Checkbox,'Value')
  fprintf(fd,'<hr>');
  fprintf(fd,'<h2>GAZE</h2>\n');
  gaze_pupils = handles.gaze_pupils;
  
  % Calculate basic pupilometry stats
  gaze_stats = ET_PupilometryStats(gaze_pupils);
  
  fprintf(fd,'<table>\n');
  fprintf(fd,'<tr><td>Video duration <td>%0.3f seconds\n', gaze_stats.t_dur);
  fprintf(fd,'<tr><td>Video rate <td>%0.3f fps\n', gaze_stats.fps);
  fprintf(fd,'</table>\n');
  
  if get(handles.Cal_Model_Checkbox,'Value')
    fprintf(fd,'<h2><td>Calibration model</h2>\n');
    
    % Plot calibration grid on calibration video frame to check alignment
    if ismac
      v_in = VideoPlayer(fullfile(gaze_dir,'Gaze_Pupils.mov'), 'Verbose', false, 'ShowTime', false);
      fr_pair = ET_LoadFramePair(v_in, 'interlaced', 1);
    else
      v_in = VideoReader(fullfile(gaze_dir,'Gaze_Pupils.avi'));
      fr_pair = ET_LoadFramePair(v_in, 'progressive', 1);
    end
    
    eyeGAZE = fr_pair(:,:,1);
    
    stub = fullfile(gaze_dir,'gazecal');
    ET_PlotCalibration(px_cal, py_cal, calibration, stub, eyeGAZE, 0);
    
    fprintf(fd,'<h3>Alignment check<h3>\n');
    fprintf(fd,'<table><tr>\n');
    fprintf(fd,'<td>Calibration video</td><td>Gaze video</td></tr><tr>\n');
    fprintf(fd,'<td><img src=cal_fix.png width=640></td>\n');
    fprintf(fd,'<td><img src=gazecal_fix.png width=640></td>\n');
    fprintf(fd,'</tr></table>\n');
    
    % Extract timeseries
    t      = [gaze_pupils.t];
    gaze_x = [gaze_pupils.gaze_x];
    gaze_y = [gaze_pupils.gaze_y];
    a0     = [gaze_pupils.area_correct];
    
    % Filtered timeseries
    filt_x  = [gaze_pupils.gaze_filt_x];
    filt_y  = [gaze_pupils.gaze_filt_y];
    filt_a0 = [gaze_pupils.gaze_filt_a0];
    
    % Generate gaze timeseries plots
    ET_PlotTimeseries(t, gaze_x, [], 'Calibrated Gaze X', fullfile(gaze_dir, 'gaze_cal_x.png'));
    ET_PlotTimeseries(t, gaze_y, [], 'Calibrated Gaze Y', fullfile(gaze_dir, 'gaze_cal_y.png'));
    ET_PlotTimeseries(t, a0,     [], 'Corrected Pupil Area', fullfile(gaze_dir, 'a0.png'));
    ET_PlotTimeseries(t, filt_x, [0 1], 'Filtered Gaze X', fullfile(gaze_dir, 'gaze_filt_cal_x.png'));
    ET_PlotTimeseries(t, filt_y, [0 1], 'Filtered Gaze Y', fullfile(gaze_dir, 'gaze_filt_cal_y.png'));
    ET_PlotTimeseries(t, filt_a0, [], 'Filtered Corrected Pupil Area', fullfile(gaze_dir, 'filt_a0.png'));
    
    % Add gaze timeseries to page
    fprintf(fd,'<h3>Gaze Timeseries<h3>\n');
    
    fprintf(fd,'<table>\n');
    fprintf(fd,'<tr>\n');
    fprintf(fd,'<td><img src=gaze_cal_x.png width=640>\n');
    fprintf(fd,'<td><img src=gaze_cal_y.png width=640>\n');
    fprintf(fd,'<tr>\n');
    fprintf(fd,'<td><img src=gaze_filt_cal_x.png width=640>\n');
    fprintf(fd,'<td><img src=gaze_filt_cal_y.png width=640>\n');
    fprintf(fd,'<tr>\n');
    fprintf(fd,'<td><img src=a0.png width=640>\n');
    fprintf(fd,'<td><img src=filt_a0.png width=640>\n');
    fprintf(fd,'</table>\n');
    
  end
   
  
  if get(handles.Val_Model_Checkbox,'Value')
    
    fprintf(fd,'<h2><td>Validation model</h2>\n');
    
    % Plot calibration grid on validation video frame to check alignment 
    stub = fullfile(gaze_dir,'gazeval');
    ET_PlotCalibration(px_val, py_val, validation, stub, eyeGAZE, 0);
    
    fprintf(fd,'<h3>Alignment check<h3>\n');
    fprintf(fd,'<table><tr>\n');
    fprintf(fd,'<td>Validation video</td><td>Gaze video</td></tr><tr>\n');
    fprintf(fd,'<td><img src=val_fix.png width=640></td>\n');
    fprintf(fd,'<td><img src=gazeval_fix.png width=640></td>\n');
    fprintf(fd,'</tr></table>\n');
    
    % Extract timeseries
    t      = [gaze_pupils.t];
    gaze_x = [gaze_pupils.gazeVal_x];
    gaze_y = [gaze_pupils.gazeVal_y];
    % Filtered timeseries
    filt_x  = [gaze_pupils.gazeVal_filt_x];
    filt_y  = [gaze_pupils.gazeVal_filt_y];
    % Generate gaze timeseries plots
    ET_PlotTimeseries(t, gaze_x, [], 'Calibrated Gaze X', fullfile(gaze_dir, 'gaze_val_x.png'));
    ET_PlotTimeseries(t, gaze_y, [], 'Calibrated Gaze Y', fullfile(gaze_dir, 'gaze_val_y.png'));
    ET_PlotTimeseries(t, filt_x, [0 1], 'Filtered Gaze X', fullfile(gaze_dir, 'gaze_filt_val_x.png'));
    ET_PlotTimeseries(t, filt_y, [0 1], 'Filtered Gaze Y', fullfile(gaze_dir, 'gaze_filt_val_y.png'));
    
    % Add gaze timeseries to page
    fprintf(fd,'<h3>Gaze Timeseries<h3>\n');
    
    fprintf(fd,'<table>\n');
    fprintf(fd,'<tr>\n');
    fprintf(fd,'<td><img src=gaze_val_x.png width=640>\n');
    fprintf(fd,'<td><img src=gaze_val_y.png width=640>\n');
    fprintf(fd,'<tr>\n');
    fprintf(fd,'<td><img src=gaze_filt_val_x.png width=640>\n');
    fprintf(fd,'<td><img src=gaze_filt_val_y.png width=640>\n');
    fprintf(fd,'</table>\n');
    
  end
  
end


%% Postamble

% Close HTML page
fprintf(fd,'</body></hmtl>\n');

% Tidy up
fclose(fd);

%% Open report in Matlab web browser
web(report_file);
