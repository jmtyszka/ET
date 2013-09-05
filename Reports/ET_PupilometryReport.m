function ET_PupilometryReport(gaze_dir, cal_pupils, calibration, gaze_pupils, gaze_filt)
%ET_PUPILOMETRYREPORT Create an HTML report for a pupilometry run
%
% ET_PupilometryReport(gaze_dir, cal_pupils, calibration, gaze_pupils, gaze_0)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech 
% DATES  : 01/28/2013 JMT From scratch
%
% Copyright 2013 California Institute of Technology
% All rights reserved.

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

fprintf(fd,'<h2>CALIBRATION</h2>\n');

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

% Generate calibration figure
cal_hmap_stub = fullfile(gaze_dir,'cal_hmap');
ET_PlotCalibration(px_cal, py_cal, calibration, cal_hmap_stub);

% Add calibration heatmaps to page
fprintf(fd,'<h3>Calibration Heatmaps<h3>\n');
fprintf(fd,'<table><tr>\n');
fprintf(fd,'<td><img src=cal_hmap_raw.png width=640>\n');
fprintf(fd,'<td><img src=cal_hmap_cal.png width=640>\n');
fprintf(fd,'</tr></table>\n');

%% Gaze Pupilometry Report

fprintf(fd,'<hr>');
fprintf(fd,'<h2>GAZE</h2>\n');

% Calculate basic pupilometry stats
gaze_stats = ET_PupilometryStats(gaze_pupils);

fprintf(fd,'<table>\n');
fprintf(fd,'<tr><td>Video duration <td>%0.3f seconds\n', gaze_stats.t_dur);
fprintf(fd,'<tr><td>Video rate <td>%0.3f fps\n', gaze_stats.fps);
fprintf(fd,'</table>\n');

% Extract timeseries
t      = [gaze_pupils.t];
gaze_x = [gaze_pupils.gaze_x];
gaze_y = [gaze_pupils.gaze_y];
a0     = [gaze_pupils.area_correct];

% Filtered timeseries
filt_x  = gaze_filt.x;
filt_y  = gaze_filt.y;
filt_a0 = gaze_filt.a0;

% Generate gaze timeseries plots
ET_PlotTimeseries(t, gaze_x, [], 'Calibrated Gaze X', fullfile(gaze_dir, 'gaze_x.png'));
ET_PlotTimeseries(t, gaze_y, [], 'Calibrated Gaze Y', fullfile(gaze_dir, 'gaze_y.png'));
ET_PlotTimeseries(t, a0,     [], 'Corrected Pupil Area', fullfile(gaze_dir, 'a0.png'));
ET_PlotTimeseries(t, filt_x, [0 1], 'Filtered Gaze X', fullfile(gaze_dir, 'gaze_filt_x.png'));
ET_PlotTimeseries(t, filt_y, [0 1], 'Filtered Gaze Y', fullfile(gaze_dir, 'gaze_filt_y.png'));
ET_PlotTimeseries(t, filt_a0, [], 'Filtered Corrected Pupil Area', fullfile(gaze_dir, 'filt_a0.png'));

% Add gaze timeseries to page
fprintf(fd,'<h3>Gaze Timeseries<h3>\n');

fprintf(fd,'<table>\n');
fprintf(fd,'<tr>\n');
fprintf(fd,'<td><img src=gaze_x.png width=640>\n');
fprintf(fd,'<td><img src=gaze_y.png width=640>\n');
fprintf(fd,'<tr>\n');
fprintf(fd,'<td><img src=gaze_filt_x.png width=640>\n');
fprintf(fd,'<td><img src=gaze_filt_y.png width=640>\n');
fprintf(fd,'<tr>\n');
fprintf(fd,'<td><img src=a0.png width=640>\n');
fprintf(fd,'<td><img src=filt_a0.png width=640>\n');
fprintf(fd,'</table>\n');

%% Postamble

% Close HTML page
fprintf(fd,'</body></hmtl>\n');

% Tidy up
fclose(fd);

%% Open report in Matlab web browser
web(report_file);
