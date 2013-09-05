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
% Copyright 2011-2012 California Institute of Technology.
% All rights reserved.

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
