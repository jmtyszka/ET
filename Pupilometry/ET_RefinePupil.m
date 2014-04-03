function p_new = ET_RefinePupil(fr, p_init, options)
% Find regions, identify pupil and fit ellipse to boundary
%
% ARGS:
% fr      = grayscale video frame, range [0,1]
% p_init  = initial (previous or estimated) pupil parameters [auto estimate]
% options = pupil refinement options structure [auto default]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 10/14/2011 JMT From scratch
%          01/14/2013 JMT Turn into option for core ET_PupilFit function
%          01/28/2013 JMT Return to regions method only
%          02/07/2013 JMT Move pupil search to here
%          02/08/2013 JMT Change to refinement of pupil
%          02/08/2014 JMT New default p_init and options handling
%          03/21/2014 JMT Move intensity scaling to ET_Prep
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
% Copyright 2011-2014 California Institute of Technology

% Do nothing if p_init or options arguments missing
if nargin < 3
    p_new = p_init;
    return
end

% 2014-03-21 JMT Move this to ET_Prep_ProcessVideo
% Robust range adjustment [1,99] percentile
% fr = imadjust(fr);

% Find and remove glints first
[bw_glint, fr_noglints] = ET_FindRemoveGlints(fr, options);

%% Segment pupil within ROI

% Binarize image and update threshold (if requested)
[bw_pupil, p_init.thresh] = ET_SegmentPupil(fr_noglints, p_init.thresh, options);

% Try fitting pupil ellipse to segmented image
p_new = ET_FitPupil(bw_pupil, p_init,fr);

% Identify main glint
glint = ET_IdentifyMainGlint(bw_glint, p_new, options);

% Fill glint fields
p_new.gx     = glint.gx;
p_new.gy     = glint.gy;
p_new.gd_eff = glint.d_eff;

% Optional pupilometry metrics report to command window
if options.debug
   
    fprintf('PUPIL : circ = %0.3f ecc = %0.3f area = %0.1f blink = %d\n', ...
        p_new.circularity, p_new.eccentricity, p_new.area, p_new.blink);
    
end
