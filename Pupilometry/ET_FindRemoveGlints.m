function [bw_glint, fr_noglints] = ET_FindRemoveGlints(fr, DEBUG)
% Find and remove glints in frame
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 01/18/2013 JMT Extract from ET_FitPupilGlint_Regions.m
%                         Add glint removal
%
% Copyright 2013 California Institute of Technology
% All rights reserved.

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
