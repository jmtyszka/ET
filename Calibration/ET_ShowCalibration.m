function ET_ShowCalibration(handles)
% Show calibration in GUI
%
% ET_ShowCalibration(calibration, handles)
%
% ARGS:
% calibration = calibration structure
% handles     = UI handles (for manual correction)
%
% RETURNS:
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 06/27/2013 JMT From scratch
%                     JMT Switch to showing calibration without edits
%
% Copyright 2013 California Institute of Technology
% All rights reserved.

%% Show calibration heat map and fixation overlay in GUI

% Extract fixations from calibration structure
fx        = handles.calibration.fx;
fy        = handles.calibration.fy;
fixations = handles.calibration.fixations;

% Smoothed heatmap in GUI calibration axes
imagesc(fixations.xv, fixations.yv, fixations.hmap, 'parent', handles.Calibration_Axes)
axis equal ij tight

% Overlay calibration points
hold on
for fc = 1:length(fx)
  plot(fx(fc), fy(fc), 'o', 'MarkerFaceColor','g','MarkerEdgeColor','k','MarkerSize',8);
end
hold off
