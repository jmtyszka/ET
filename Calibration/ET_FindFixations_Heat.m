function fixations = ET_FindFixations_Heat(px, py)
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
% Copyright 2011-2013 California Institute of Technology.
% All rights reserved.

% Gaussian smoothing sigma for initial fixation map
% TODO : Make this adaptive if necessary
sigma = 3.0;

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
