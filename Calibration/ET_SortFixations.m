function [fx, fy] = ET_SortFixations(fixations)
% Sort fixations into appropriate grid
%
% RETURNS:
% fx,fy = fixation coordinate vectors
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/27/2013 JMT Merge 4 and 9-point grid sorting code
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

% Extract fixation coords
fx_raw = fixations.x;
fy_raw = fixations.y;

% Number of fixations
n_fix = length(fx_raw);

% Need at least four fixations
if n_fix < 4
  fx = [];
  fy = [];
  return
end

% Choose model order depending on number of fixations
% A good 9-point calibration session will have exactly 9 fixations
if n_fix == 9
  fit_order = 9;
else
  fit_order = 4;
end

% Sort fixations according to model order
switch fit_order
  
  case 4
    
    % Calculate convex hull
    K = convhull(fx_raw,fy_raw);
    
    % Extract convhull vertices
    chx = fx_raw(K); chy = fy_raw(K);
    
    % Construct slightly dilated bounding box
    xmin = min(chx) * 0.9; xmax = max(chx) * 1.1;
    ymin = min(chy) * 0.9; ymax = max(chy) * 1.1;
    
    % Assumptions:
    % 1. Eye is correctly oriented in frame (superior up)
    % 2. Diagonal corners are well fixated
    % 3. Video image origin is top left
    
    % Find convhull vertices closest to bounding box corners
    dx2_min = (chx-xmin).^2; dx2_max = (chx-xmax).^2;
    dy2_min = (chy-ymin).^2; dy2_max = (chy-ymax).^2;
    [~,top_left] = min(sqrt(dx2_min + dy2_min));
    [~,bot_left] = min(sqrt(dx2_min + dy2_max));
    [~,top_right] = min(sqrt(dx2_max + dy2_min));
    [~,bot_right] = min(sqrt(dx2_max + dy2_max));
    
    % Book reading order from top right (top left for subject)
    % 2 1
    % 4 3
    %
    % Note the mirroring of the grid order since we're looking towards the eye
    % We also assume that the camera isn't rotated > +/- 45 degrees
    
    grid_order = [top_right top_left bot_right bot_left];
    
    % Fill fixation grid structure
    fx = chx(grid_order);
    fy = chy(grid_order);
    
  case 9
    
    % Find closest point to grand centroid of all fixations
    gfx = mean(fx_raw);
    gfy = mean(fy_raw);
    
    dx = fx_raw - gfx;
    dy = fy_raw - gfy;
    dr = sqrt(dx.*dx + dy.*dy);
    
    [~, dr_order] = sort(dr);
    
    % Center point
    middle = dr_order(1);
    
    % Transform to center point frame
    cx0 = fx_raw - fx_raw(middle);
    cy0 = fy_raw - fy_raw(middle);

    % *** Invert y axis at this point (video frame has top left origin) ***
    % *** Everything from here on has a bottom left origin ***
    cy0 = -cy0;
    
    % Distances from center to all other fixations
    dr = sqrt(cx0.*cx0 + cy0.*cy0);
    
    % Ascending order of distance from center
    [~, dr_asc_order] = sort(dr);
    
    % First point is center, 2-5 are edge centers, 6-9 are corners
    edge_centers = dr_asc_order(2:5); 
    
    % Find right edge center
    [~, idx] = max(cx0(edge_centers));
    center_right = edge_centers(idx);
    
    % Calculate angles of all points relative to center right
    phi = atan2(cy0, cx0) * 180/pi;
    phi(middle) = NaN;
    phi = phi - phi(center_right); 
    phi = mod(phi + 360,360);

    % Sort points into CCW order from center right
    [~, ccw_order] = sort(phi);
    
    % Spatial arrangement of fixation grid points in video frame:
    % CCW    Grid
    % 4 3 2  3 2 1
    % 5 9 1  6 5 4
    % 6 7 8  9 8 7
    % Note the mirroring of the grid order since we're looking towards the eye
    % We also assume that the camera isn't rotated > +/- 45 degrees
    
    grid_order = ccw_order([2 3 4 1 9 5 8 7 6]);
    
    % Fill fixation grid structure
    fx = fx_raw(grid_order);
    fy = fy_raw(grid_order);
    
end

% Force row vectors
fx = fx(:)';
fy = fy(:)';
