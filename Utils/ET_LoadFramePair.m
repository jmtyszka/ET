function [fr_pair, keep_going] = ET_LoadFramePair(v_in, imode)
% Load single or interlaced frame pair from video object
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/05/2013 JMT From scratch
%
% Copyright 2013 California Institute of Technology
% All rights reserved.

if nargin < 1; fr_pair = []; return; end
if nargin < 2; imode = 'interlaced'; end

% Flags
do_intensity_normalize = false;

% Get raw video frame size
nx0 = v_in.Width;
ny0 = v_in.Height;

% Handle interlaced and progressive frames
switch lower(imode)
  
  case 'interlaced'
    
    % Load one frame from raw video (interlaced or progressive)
    fr = v_in.Frame;
    keep_going = v_in.nextFrame;
    
    % Collapse RGB to scalar doubles
    fr = mean(fr,3);

    % Deinterlace with row position correction
    [fr_odd, fr_even] = ET_Deinterlace(fr);
    
  case 'progressive'
    
    % Load two frames
    fr_odd = v_in.Frame;
    keep_going = v_in.nextFrame;
    fr_even = v_in.Frame;
    keep_going = v_in.nextFrame;
    
    % Collapse RGB to scalar doubles
    fr_odd = mean(fr_odd,3);
    fr_even = mean(fr_even,3);
    
  otherwise
    
    % Return empty frames
    fr_odd = nan(ny0, nx0);
    fr_even = fr_odd;
    keep_going = false;
    
end

% Stack frame pair in 3rd dimension
% Even frame comes first in time
fr_pair = cat(3,fr_even,fr_odd);
    
% Normalize intensities to range [0,1]
if do_intensity_normalize
  min_fr = min(fr_pair(:));
  max_fr = max(fr_pair(:));
  fr_pair = (fr_pair - min_fr) / (max_fr - min_fr);
end
