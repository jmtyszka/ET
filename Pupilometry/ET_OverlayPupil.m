function fr_over = ET_OverlayPupil(fr, roi, p)
% Draw pupil and glint overlayed on video frame
%
% RETURNS:
% h = handle of new figure axes
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/04/2013 JMT Extract from ET_Pupilometry.m
%
% Copyright 2013 California Institute of Technology
% All rights reserved.

% Cross width
w = 10;

% Extract ROI
fr_roi = fr(roi.yrng, roi.xrng);

% Rotate ROI
fr_roi = rot90(fr_roi,fix(roi.rotation/90));

% Robust range adjustment [1,99] percentile
fr_roi = imadjust(fr_roi);

% Init RGB image
fr_over = repmat(fr_roi,[1 1 3]);

if ~p.blink
  
  % Pupil center
  px = p.px; py = p.py;
  
  % Glint center
  gx = p.gx; gy = p.gy;
  
  % Draw pupil-glint vector (if glint present)
  if ~isnan(gx)
    fr_over = ET_DrawLine(fr_over, [0 1 1], [px gx], [py gy]);
  end
  
  % Draw pupil boundary ellipse in yellow
  fr_over = ET_DrawEllipse(fr_over, [1 1 0], p.ra, p.rb, p.phi, px, py);
  
  % Draw pupil center cross in white
  fr_over = ET_DrawLine(fr_over, [1 1 1], [px-w px+w], [py py]);
  fr_over = ET_DrawLine(fr_over, [1 1 1], [px px], [py-w py+w]);
  
end
