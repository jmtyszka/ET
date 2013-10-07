function ET_PlotCalibration(px, py, calibration, plot_stub, VID, plotheatmap)
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

if nargin < 5; VID = []; end
if nargin < 6; plotheatmap = true; end

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

if plotheatmap
  
  clf;
  colormap(hot)
  
  % Smoothed heatmap
  imagesc(fixations.xv, fixations.yv, fixations.hmap);
  axis equal ij tight
  hold on
  
  % Overlay calibration points
  for fc = 1:length(fx)
    plot(fx(fc), fy(fc), 'o', 'MarkerFaceColor','g','MarkerEdgeColor','k','MarkerSize',5);
  end
  hold off
  
  % Print figure
  hmap_raw_png = [plot_stub '_hmap_raw.png'];
  fprintf('ET : Printing calibration figure to %s\n', hmap_raw_png);
  print(hf, hmap_raw_png, '-dpng', '-r200');
  
  clf;
  colormap hot
  
  % Draw calibrated heat map
  ET_HeatPlot(gaze_x, gaze_y, hmap_sigma, true);
  
  % Print figure
  hmap_cal_png = [plot_stub '_hmap_cal.png'];
  print(hf, hmap_cal_png, '-dpng', '-r200');
  
end

if ~isempty(VID)
  
  clf
  
  imshow(VID);
  
  axis equal ij tight
  
  % Overlay calibration points
  hold on
  for fc = 1:length(fx)
    plot(fx(fc), fy(fc), 'o', 'MarkerFaceColor','g','MarkerEdgeColor','k','MarkerSize',5);
  end
  hold off
  
  % Print figure
  fix_png = [plot_stub '_fix.png'];
  print(hf, fix_png, '-dpng', '-r200');
  
end


% Close figure
close(hf);
