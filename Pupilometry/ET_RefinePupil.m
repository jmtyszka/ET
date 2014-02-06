function p_new = ET_RefinePupil(fr, p_old, options)
% Find regions, identify pupil and fit ellipse to boundary
%
% ARGS:
% fr         = grayscale video frame, range [0,1]
% pupil_init = previous (or estimated) pupil parameters
% options    = pupile refinement options structure
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 10/14/2011 JMT From scratch
%          01/14/2013 JMT Turn into option for core ET_PupilFit function
%          01/28/2013 JMT Return to regions method only
%          02/07/2013 JMT Move pupil search to here
%          02/08/2013 JMT Change to refinement of pupil
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
% Copyright 2011-2013 California Institute of Technology

% Default arguments
if nargin < 3
  p_new = p_old;
  return
end

% Create default options structure if absent
if nargin < 3
  options.pupil_se = strel('disk',fix(size(fr,2) * 0.05));
  options.thresh_mode = 'histogram';
  options.manual_thresh = 0.15;
  options.debug = false;
end

% Robust range adjustment [1,99] percentile
fr = imadjust(fr);

% Find and remove glints first
[bw_glint, fr_noglints] = ET_FindRemoveGlints(fr, options);

%% Segment pupil within ROI

% Binarize image and update threshold (if requested)
[bw_pupil, p_old.thresh] = ET_SegmentPupil(fr_noglints, p_old.thresh, options);

% Try fitting pupil ellipse to segmented image
p_new = ET_FitPupil(bw_pupil, p_old);

% Identify main glint
glint = ET_IdentifyMainGlint(bw_glint, p_new, options);

% Fill glint fields
p_new.gx     = glint.gx;
p_new.gy     = glint.gy;
p_new.gd_eff = glint.d_eff;
