function handles = ET_InitVideo(vname, handles)
% Initialize gaze video analysis
% - Load first frame
% - Locate pupil and generate ROI
% - Apply correct rotation to ROI
% - Display first frame pupilometry in GUI
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 12/18/2012 JMT Extract from ET_LoadEverything.m
%
% Copyright 2013 California Institute of Technology
% All rights reserved.

% Check that video file exists
if ~exist(vname, 'file')
  fprintf('ET : Could not find %s\n', vname);
  return
end

% Create input video object
try
  v_in = VideoPlayer(vname, 'Verbose', false, 'ShowTime', false);
catch VIDEO_IN_OPEN
  fprintf('ET : *** Problem opening input video file\n');
  rethrow(VIDEO_IN_OPEN);
end

% Load interlaced video frame
fr_pair = ET_LoadFramePair(v_in,'interlaced');

% Close video file
clear v_in

% Save odd frame as video poster frame
fr = fr_pair(:,:,1);
handles.video_poster_frame = fr;

% Update ROI image in GUI
handles = ET_UpdateROIImage(handles);
