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

%% Show calibration heat map and fixation overlay in GUI

% Extract fixations from calibration structure
fx        = handles.calibration.fx;
fy        = handles.calibration.fy;
fixations = handles.calibration.fixations;

% Smoothed heatmap in GUI calibration axes
axes(handles.Calibration_Axes); cla;
imagesc(fixations.xv, fixations.yv, fixations.hmap);
axis equal ij manual off
hold on

% Overlay calibration points
for fc = 1:length(fx)
  plot(fx(fc), fy(fc), 'o', 'MarkerFaceColor','g','MarkerEdgeColor','k','MarkerSize',8);
end
hold off
