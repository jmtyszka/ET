function [bw, th_new] = ET_SegmentPupil(s, th_old, options)
% Segment pupil within image
%
% Various threshold estimations offered including:
% - histogram threshold (first minimum above zero)
% - kmeans approach from Swirski et al
% - percentile (15% of histogram)
% - hard (fixed manual threshold)
%
% ARGS :
% s       = image to segment
% th_old  = current adaptive pupil threshold (NaN forces estimate) [NaN]
% options = options structure
%
% RETURNS :
% bw     = segmented image (pupil = 1)
% th_new = updated pupil threshold
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 01/30/2013 JMT Implement approach suggested by Swirkski et al.
%          02/20/2013 JMT Add percentile and histogram threshold estimates
%          02/05/2014 JMT Replace pupil structure with threshold
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
% Copyright 2013-2014 California Institute of Technology

% Default arguments
if nargin < 3
    fprintf('USAGE : [bw, th_new] = ET_SegmentPupil(s, th_old, options)\n');
    return
end

% Morphological opening on scale of pupil
% JMT Omit for now - slows down frame rate significantly
% s = imopen(s, options.pupil_se);

if isnan(th_old)
  
  switch lower(options.thresh_mode)
          
    case 'k-means'
      % Three cluster 1D k-means segmentation of image
      th_new = ET_KmeansThresh(s);
      
    case 'percentile'
      % Pupil should occupy approx darkest 15% of pixels within ROI
      th_new = ET_Percentile(s, 15);
      
    case 'histogram'
      % First minimum of smoothed histogram
      th_new = ET_HistThresh(s);
      
    case 'manual'
      
      % Manual fixed threshold
      th_new = options.manual_thresh;
      
    otherwise
      
      % Set a fixed threshold at 15% full scale
      th_new = 0.15;
      
  end
  
  % Report threshold update
  if options.debug
    fprintf('ET : Pupil threshold estimated at %0.3f (%s)\n', th_new, options.thresh_mode);
  end
  
else
    
    % Pass current threshold forward
    th_new = th_old;
    
end

% Set threshold to 0 if estimate is outside [0.1,0.5] range
% Zero threshold generates no pupil region candidates
% Limits based on typical dark-pupil contrast video
if th_new < 0.1 || th_new > 0.5
  th_new = 0;
end

% Binarize frame at threshold
bw_raw = s < th_new;

% Binary morph open
bw = imopen(bw_raw, options.pupil_se);

if options.debug
  
  figure(30); colormap(gray)
  
  subplot(234), imagesc(s);      axis image; title('Raw');
  subplot(235), imagesc(bw_raw); axis image; title('BW Raw');
  subplot(236), imagesc(bw);     axis image; title('BW Open');
  
end
