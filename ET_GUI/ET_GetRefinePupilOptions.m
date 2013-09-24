function options = ET_GetRefinePupilOptions(handles)
% Get options for refining pupil estimate from GUI
% - thresholding method and manual settings
% - debug flag
% - morph-op structured elements
%
% Requires that ET_FindPupilInFrame has been run (generating ROI structure)
%
% USAGE : options = ET_GetRefinePupilOptions(handles)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 10/14/2011 JMT Pull from ET_Video_Pupilometry - used in several
%                         functions
%
% Copyright 2013 California Institute of Technology
% All rights reserved.

% Morph-op structured elements
% Reverse engineer pupil diameter estimate from ROI half-width
% ROI width is roi.scale times the PD estimate
roi = handles.roi;
pd_est = roi.hw * 2 / roi.scale;
options.pupil_se = strel('disk',fix(pd_est/8));
options.glint_se = strel('disk',2);

% Set threshold mode and get optional manual threshold from GUI
thresh_modes = get(handles.Pupil_Thresh_Popup, 'String');
options.thresh_mode = thresh_modes{get(handles.Pupil_Thresh_Popup, 'Value')};
options.manual_thresh = str2double(get(handles.Pupil_Threshold,'String'));

% GUI debug flag
options.debug = logical(get(handles.Debug_Toggle,'Value'));
