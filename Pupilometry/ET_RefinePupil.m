function p_new = ET_RefinePupil(fr, roi, p_init, thresh_mode, options)
% Find regions, identify pupil and fit ellipse to boundary
%
% ARGS:
% fr         = grayscale video frame, range [0,1]
% pupil_init = previous (or estimated) pupil parameters
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 10/14/2011 JMT From scratch
%          01/14/2013 JMT Turn into option for core ET_PupilFit function
%          01/28/2013 JMT Return to regions method only
%          02/07/2013 JMT Move pupil search to here
%          02/08/2013 JMT Change to refinement of pupil
%
% Copyright 2011-2013 California Institute of Technology
% All rights reserved.

% Flags
DEBUG = true;

% Default arguments
if nargin < 3
  p_new = p_init;
  return
end

if nargin < 4
  options.pupil_se = strel('disk',fix(p_init/2));
end

% Extract ROI from frame
fr_roi = fr(roi.yrng, roi.xrng);

% Rotate ROI
fr_roi = rot90(fr_roi, fix(roi.rotation/90));

% Robust range adjustment [1,99] percentile
fr_roi = imadjust(fr_roi);

% Find and remove glints first
[bw_glint, fr_roi_noglints] = ET_FindRemoveGlints(fr_roi, DEBUG);

%% Segment pupil within ROI

% Binarize image
% Estimate threshold by kmeans if currently NaN
[bw_pupil, p_seg] = ET_SegmentPupil(fr_roi_noglints, p_init, options.pupil_se, thresh_mode, DEBUG);

% Try fitting pupil ellipse to segmented image
p_new = ET_FitPupil(bw_pupil, p_seg);

% Fill ROI fields
p_new.rx0 = roi.x0;
p_new.rx1 = roi.x1;
p_new.ry0 = roi.y0;
p_new.ry1 = roi.y1;
  
% Identify main glint
glint = ET_IdentifyMainGlint(bw_glint, p_new, DEBUG);

% Fill glint fields
p_new.gx     = glint.gx;
p_new.gy     = glint.gy;
p_new.gd_eff = glint.d_eff;
