function fixations = ET_FindFixations_Heat(pupils,handles)
% Identify fixations in spatial domain using heatmap
%
% USAGE : ET_Fix = ET_FindFixations_Heat(px, py)
%
% ARGS :
% px,py  = pupil centroid
%
% RETURNS :
% fixations = fixations structure
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 10/15/2011 JMT From scratch
%          11/01/2011 JMT Add verbosity and graphing
%          11/15/2011 JMT Switch from heat map to timeseries analysis
%          09/14/2012 JMT Integrate with ET GUI
%          02/01/2013 JMT Return to standalone operation. Add targets
%          02/27/2013 JMT Remove target, fixation sorting, plots
%          04/16/2013 JMT Switch to weighted centroid of fixation spots
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
% Copyright 2011-2013 California Institute of Technology.


% Gaussian smoothing sigma for initial fixation map
% TODO : Make this adaptive if necessary
sigma = 3.0;

px = [pupils.px];
py = [pupils.py];

% Create heatmap over all frames
[hmap, xv, yv] = ET_HeatMap(px, py, sigma, false);

% Binarize heatmap
hmap = hmap / max(hmap(:));
th = graythresh(hmap);
bw = hmap > th;

% Find connected regions
% L  = label image
% nf = number of fixations identified
[L, nf] = bwlabel(bw);

% Setup coordinate meshes (for centroid calculation)
[xm, ym] = meshgrid(xv, yv);

% Setup fixation centroid arrays
fx = zeros(1,nf);
fy = zeros(1,nf);

% Loop over each region, find centroid from heatmap with region mask
for rc = 1:nf
  
  % Extract heat map within region mask (weighting image) 
  w = (L == rc) .* hmap;
  
  fx(rc) = sum(xm(:) .* w(:)) ./ sum(w(:));
  fy(rc) = sum(ym(:) .* w(:)) ./ sum(w(:));
    
end

% Load fixations structure
fixations.x    = fx;
fixations.y    = fy;
fixations.hmap = hmap;
fixations.xv   = xv;
fixations.yv   = yv;
