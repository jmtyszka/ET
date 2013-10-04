function handles = ET_UpdateROIImage(handles)
% Update ROI image in GUI, including rotation
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

% Grab PD range from GUI
pd_min = str2double(get(handles.PD_Min,'String'));
pd_max = str2double(get(handles.PD_Max,'String'));
handles.pd_range = [pd_min pd_max];

% Use existing ROI size if available
if isfield(handles,'roi')
  roi_hw = handles.roi.hw;
else
  roi_hw = [];
end

%Find pupil in frame
[p_init, roi] = ET_FindPupilInFrame(fr, handles.pd_range, roi_hw);

% JD 10/3/13 : do not change the ROI if one is available already from
% calibration. This may cause a problem if there has been a lot of motion between CAL and GAZE videos 
% BUG: this means the p_init may be off but I believe this is ok
if ~isfield(handles,'roi')
    handles.roi=roi;
    fprintf('ET : New ROI : %d %d %d %d\n',handles.roi.x0,handles.roi.x1,handles.roi.y0,handles.roi.y1)
end

% Rotations in degrees in same order as popup menu selections
rots = [0 90 -90 180];


% Set rotation from GUI
handles.roi.rotation = rots(get(handles.ROI_Rotation_Popup, 'Value'));

% Setup refine options
options = ET_GetRefinePupilOptions(handles);

% Refine pupil parameter estimates
handles.p_run = ET_RefinePupil(fr, handles.roi, p_init, options);
 
% Display ROI image with pupilometry overlay
fr_over = ET_OverlayPupil(fr, handles.roi, handles.p_run);
imshow(fr_over, 'parent', handles.Eye_Video_Axes);

% Save refine pupil options in handles structure
handles.refine_options = options;

