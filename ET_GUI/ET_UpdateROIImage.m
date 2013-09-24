function handles = ET_UpdateROIImage(handles)
% Update ROI image in GUI, including rotation
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/22/2013 JMT From scratch
%
% Copyright 2013 California Institute of Technology
% All rights reserved.

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

% Find pupil in frame
[p_init, handles.roi] = ET_FindPupilInFrame(fr, handles.pd_range, roi_hw);

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

