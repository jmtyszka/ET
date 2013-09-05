function glint = ET_IdentifyMainGlint(bw_glint, p, DEBUG)
% Select best candidate for main glint from glints list
% - allow for saturated glint ring down (L-R raster)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/22/2013 JMT From scratch
%          04/30/2013 JMT Add glint saturation tail handling
%
% Copyright 2013 California Institute of Technology.
% All rights reserved.

if nargin < 3; DEBUG = false; end

% Init glint return structure
glint.gx    = NaN;
glint.gy    = NaN;
glint.d_eff = NaN;

% Detect glint boundaries
[B_glint, L_glint] = bwboundaries(bw_glint, 'noholes');

% Number of glint candidates in frame
n_glints = length(B_glint);

% Identify glint object
if n_glints > 0
  
  % Bounding box for each glint
  % Comet artifact is guaranteed x oriented (L-R raster)
  rp = regionprops(L_glint,'BoundingBox');
  
  % Pupil centroid within ROI
  px = p.px;
  py = p.py;
  
  % Allocate corrected glint centroid and radius
  gx = zeros(1,n_glints);
  gy = zeros(1,n_glints);
  gr = zeros(1,n_glints);
  
  for bc = 1:n_glints
    
    bb = rp(bc).BoundingBox;
    
    % Bounding box returned as [xmin, ymin, w, h]
    % Assume height is correct, width is overestimated, so use height
    rr = bb(4)/2;
    gx(bc) = bb(1) + rr;
    gy(bc) = bb(2) + rr;
    gr(bc) = rr;
    
  end
  
  % Glint-pupil vector components - glint below pupil in video has gpvy < 0
  gpvx = px-gx;
  gpvy = py-gy;
  
  % Glint to pupil centroid distance
  d = sqrt(gpvx.^2 + gpvy.^2);
  
  % Select glints by area
  good_glints = find(gr < 8 & gpvy < 0);
  
  if ~isempty(good_glints)
    
    d_good = d(good_glints);
    
    % Find good glint closest to pupil centroid
    [~, imin] = min(d_good);
    
    % Get original index of best glint
    best_glint = good_glints(imin);
    
    % Load return glint structure
    glint.gx = gx(best_glint);
    glint.gy = gy(best_glint);
    glint.d_eff = 2 * gr(best_glint);
    
    if DEBUG
      fprintf('ET : Best glint (r = %0.1f d = %0.1f)\n', gr(best_glint), d_good(imin));
    end
    
  else
    
    % No good glints found
    
  end
  
end
