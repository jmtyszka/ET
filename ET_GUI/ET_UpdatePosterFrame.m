function handles = ET_UpdatePosterFrame(handles)
% Update poster frame in GUI with pupil overlay if available
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/22/2013 JMT From scratch
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

% Get poster frame from GUI
if isfield(handles,'video_poster_frame')
  fr = handles.video_poster_frame;
else
  fprintf('ET : No video poster frame detected - returning\n');
  return
end

% Setup refine options
options = ET_GetRefinePupilOptions(handles);

% Refine pupil parameter estimates
handles.p_run = ET_RefinePupil(fr, ET_NewPupil, options);
 
% Display ROI image with pupilometry overlay
fr_over = ET_OverlayPupil(fr, handles.p_run);
imshow(fr_over, 'parent', handles.Eye_Video_Axes);

% Save refine pupil options in handles structure
handles.refine_options = options;

