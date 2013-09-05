function ET_PlotCalibration(px, py, calibration, plot_stub)
% Plot video and gaze heatmaps with overlayed fixations to a file
%
% USAGE : ET_PlotCalibration(px, py, C, fx, fy, plot_file)
%
% ARGS:
% px, py    = pupile centroids in video or glint FoR
% C         = calibration matrix in video or glint FoR
% plot_file = output filename for plot (PNG image)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 04/16/2013 JMT Extract from ET_AutoCalibrate.m
%
% Copyright 2013 California Institute of Technology.
% All rights reserved.

% Heatmap smoothing (Gaussian sigma)
hmap_sigma = 3.0;

% Extract calibration fields
C         = calibration.C;
fx        = calibration.fx;
fy        = calibration.fy;
fixations = calibration.fixations;

%% Apply calibration to raw fixations

% Extract pupil centroids
[gaze_x, gaze_y] = ET_ApplyCalibration(px, py, C);

%% Plot raw and calibrated heat maps with used fixations

% Create a new hidden figure
hf = figure(100);
set(hf,'Position',[100 100 640 320]);
set(hf,'PaperPositionMode','auto','Visible','off');

clf; colormap(hot)

% Smoothed heatmap
imagesc(fixations.xv, fixations.yv, fixations.hmap)
axis equal ij tight

% Overlay calibration points
hold on
for fc = 1:length(fx)
  plot(fx(fc), fy(fc), 'o', 'MarkerFaceColor','g','MarkerEdgeColor','k','MarkerSize',8);
end
hold off

% Print figure
hmap_raw_png = [plot_stub '_raw.png'];
fprintf('ET : Printing calibration figure to %s\n', hmap_raw_png);
print(hf, hmap_raw_png, '-dpng', '-r200');

% Draw calibrated heat map
ET_HeatPlot(gaze_x, gaze_y, hmap_sigma, true);

% Print figure
hmap_cal_png = [plot_stub '_cal.png'];
print(hf, hmap_cal_png, '-dpng', '-r200');

% Close figure
close(hf);
