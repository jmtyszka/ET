function handles = ET_UpdatePosterFrame(handles)
% Update poster frame in GUI with pupil overlay if available
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/22/2013 JMT From scratch
%          02/08/2014 JMT Estimate pupil from frame size
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
% Copyright 2014 California Institute of Technology.

% Get poster frame from GUI
if isfield(handles,'video_poster_frame')
  fr = handles.video_poster_frame;
else
  fprintf('ET : No video poster frame detected - returning\n');
  return
end

% Initial pupil estimate at center of frame
p_init = ET_NewPupil;      % NaN-filled pupil structure
p_init.px = size(fr,2)/2;  % Horizontal frame center
p_init.py = size(fr,1)/2;  % Vertical frame center
p_init.thresh = NaN;       % NaN forces threshold re-estimate

% Default refinement options
options = ET_GetRefinePupilOptions(handles);

% Refine initial pupil estimate
p = ET_RefinePupil(fr, p_init, options);

% Show current threshold in GUI
set(handles.Pupil_Threshold,'String',sprintf('%0.3f', p.thresh));

% Display ROI image with pupilometry overlay
fr_over = ET_OverlayPupil(fr, p);
imshow(fr_over, 'parent', handles.Eye_Video_Axes);

% Save first running pupil estimate and options in handles structure
handles.p_run = p;
handles.refine_options = options;

