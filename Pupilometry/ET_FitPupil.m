function p_fit = ET_FitPupil(bw_pupil, p_init)
% Identify pupil within eye ROI
%
% ARGS:
% bw_pupil = binary segmentation of eye ROI
% roi      = ROI structure used to generate bw_pupil
%
% RETURNS:
% p_new = fitted pupil structure
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 01/30/2013 JMT Extract from ET_Pupilometry
%
% Copyright 2013 California Institute of Technology.
% All rights reserved.

% Ellipse fitting method : 'region' or 'ransac'
fit_method = 'region';

switch lower(fit_method)
  
  case 'region'
    p_fit = ET_FitEllipse_Region(bw_pupil, p_init);
    
  case 'ransac'
    p_fit = ET_FitEllipse_RANSAC(bw_pupil, p_init);
    
  otherwise
    fprintf('ET : Unsupported fit method %s - returning\n', fit_method);
    return
    
end
