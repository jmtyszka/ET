function [bw, p_seg] = ET_SegmentPupil(s, p_init, options)
% Segment pupil within image
%
% Various threshold estimations offered including:
% - histogram threshold (first minimum above zero)
% - kmeans approach from Swirski et al
% - percentile (15% of histogram)
% - hard (fixed manual threshold)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 01/30/2013 JMT Implement approach suggested by Swirkski et al.
%          02/20/2013 JMT Add percentile and histogram threshold estimates
%
% REFERENCES : Swirski L, Bulling A and Dodgson N 2012
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
% Copyright 2013 California Institute of Technology

% Default arguments
if nargin < 4; options.debug = false; end

% Morphological opening on scale of pupil
% JMT Omit for now - slows down frame rate significantly
% s = imopen(s, options.pupil_se);

% Init return pupil
p_seg = p_init;

% Extract current pupil threshold
th = p_init.thresh;

if isnan(th)
  
  switch lower(options.thresh_mode)
          
    case 'k-means'
      % Three cluster 1D k-means segmentation of image
      th = ET_KmeansThresh(s);
      
    case 'percentile'
      % Pupil should occupy approx darkest 15% of pixels within ROI
      th = ET_Percentile(s, 15);
      
    case 'histogram'
      % First minimum of smoothed histogram
      th = ET_HistThresh(s);
      
    case 'manual'
      
      % Manual fixed threshold
      th = options.manual_thresh;
      
    otherwise
      
      % Set a fixed threshold at 15% full scale
      th = 0.15;
      
  end
  
  if options.debug
    fprintf('ET : Pupil threshold estimated at %0.3f (%s)\n', th, options.thresh_mode);
  end
  
end

% Set threshold to 0 if estimate is outside [0.1,0.5] range
% Zero threshold generates no pupil region candidates
% Limits based on typical dark-pupil contrast video
if th < 0.1 || th > 0.5
  th = 0;
end

% Binarize frame at threshold
bw_raw = s < th;

% Binary morph open
bw = imopen(bw_raw, options.pupil_se);

% Save threshold in returned pupil structure
p_seg.thresh = th;

if options.debug
  
  figure(30); colormap(gray)
  
  subplot(234), imagesc(s); axis image; title('Raw');
  subplot(235), imagesc(bw_raw); axis image; title('BW Raw');
  subplot(236), imagesc(bw); axis image; title('BW Open');
  
end
