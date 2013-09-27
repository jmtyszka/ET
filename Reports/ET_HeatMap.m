function [heat_map, xv, yv] = ET_HeatMap(x, y, sigma, is_calibrated)
% Plot gaze heat map from pupilometry data
%
% USAGE : [heat_map, xm, ym] = ET_HeatMap(x, y, do_smooth)
%
% ARGS :
% pupils = structure array of pupil information for each frame
% do_smooth = smoothing flag (for fixation search)
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


if nargin < 2; sigma = 0; end
if nargin < 4; is_calibrated = false; end
if isempty(sigma); sigma = 0; end

% Histogram bins
n = 128;

% Allocate gaze heat map
heat_map = zeros(n, n);

if is_calibrated
  
  min_x = 0; max_x = 1;
  min_y = 0; max_y = 1;
  
else
  
  % Find robust limits for input coordinates
%   xp = percentile(x,[1 99]);
%   yp = percentile(y,[1 99]);
   xp = prctile(x,[1 99]);
  yp = prctile(y,[1 99]);
  min_x = xp(1); max_x = xp(2);
  min_y = yp(1); max_y = yp(2);
  
end

% Drop OOB coordinates
oob = x < min_x | x > max_x | y < min_y | y > max_y;
x(oob) = [];
y(oob) = [];

% X and Y axis vectors
xv = linspace(min_x, max_x, n);
yv = linspace(min_y, max_y, n);

% Linear video space to heat map mapping
bx = (n-1) / (max_x - min_x);
ax = 1;
by = (n-1) / (max_y - min_y);
ay = 1;

% Mapped centroids
xh = fix(bx * (x - min_x) + ax);
yh = fix(by * (y - min_y) + ay);

% Loop over all pupil centroids
for fc = 1:length(xh)
  
  % Add one count to the gaze heat map
  if ~isnan(xh(fc)) && ~isnan(yh(fc))
    heat_map(yh(fc),xh(fc)) = heat_map(yh(fc),xh(fc)) + 1;
  end
  
end

% Apply Gaussian smoothing using the provided sigma
if sigma > 0
  k = fix(sigma * 2 + 1);
  h = fspecial('gaussian',[k k],sigma);
  heat_map = imfilter(heat_map, h);
end
