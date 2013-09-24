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
