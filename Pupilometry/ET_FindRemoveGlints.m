function [bw_glint, fr_noglints] = ET_FindRemoveGlints(fr, DEBUG)
% Find and remove glints in frame
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 01/18/2013 JMT Extract from ET_FitPupilGlint_Regions.m
%                         Add glint removal
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

% Defaults
if nargin < 2; DEBUG = false; end

% Hard fraction intensity threshold
% Bright regions other than glints can cause problems for percentile
% thresholding
th = 0.9;
bw = fr > th;

% Create glint removal mask
glint_mask = bwmorph(bw,'dilate',3);

% Remove glint signal within frame by filling from glint edges
fr_noglints = roifill(fr, glint_mask);

% Shrink glint regions
bw_glint = bwmorph(bw,'erode');

if DEBUG
  
  figure(30);
  
  subplot(231), imshow(fr); title('Glint');
  subplot(232), imshow(bw_glint); title('BW');
  subplot(233), imshow(fr_noglints); title('No Glints');
  
end
