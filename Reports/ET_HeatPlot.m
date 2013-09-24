function ET_HeatPlot(x, y, sigma, is_calibrated)
% Display heat map and gaze trajectory
%
% USAGE : ET_HeatPlot(p, xmax, ymax, do_trajectory, do_smooth, is_calibrated)
%
% ARGS :
% x,y = centroid coord timeseries
% do_smooth = flag for smoothing heatmap
% h = axis handle
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 11/03/2011 JMT From scratch
%          09/18/2012 JMT Integrate with ET GUI
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

if nargin < 2; x = []; y = []; end
if nargin < 3; sigma = 0; end
if nargin < 4; is_calibrated = false; end

if isempty(sigma); sigma = 0; end

% Create heat map from pupil trajectory
[heat_map, xv, yv] = ET_HeatMap(x, y, sigma, true);

% Display image
imagesc(xv, yv, heat_map);
axis equal xy tight

% Add grid at 10%, 50%, 90% to each axis if calibrated (x and y max = 100%)
if is_calibrated

  % Vertical grid lines
  line([0.1 0.1 NaN 0.5 0.5 NaN 0.9 0.9], [0 1 NaN 0 1 NaN 0 1], 'color', 'w');
  
  % Horizontal grid lines
  line([0 1 NaN 0 1 NaN 0 1], [0.1 0.1 NaN 0.5 0.5 NaN 0.9 0.9], 'color', 'w');
  
end
