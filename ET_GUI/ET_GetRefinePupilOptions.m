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
% Copyright 2013 California Institute of Technology

% Get video frame width for reference
if isfield(handles,'video_poster_frame')
    fr_width = size(handles.video_poster_frame,2);
else
    fprintf('ET_GetRefinePupilOptions : no poster frame yet - exiting\n');
    options = [];
end

% Structured elemetns for pupil and glint preprocessing
options.pupil_se = strel('disk', fix(fr_width * 0.05));
options.glint_se = strel('disk', 2);

% Set threshold mode and get optional manual threshold from GUI
thresh_modes = get(handles.Pupil_Thresh_Popup, 'String');
options.thresh_mode = thresh_modes{get(handles.Pupil_Thresh_Popup, 'Value')};
options.manual_thresh = str2double(get(handles.Pupil_Threshold,'String'));

% GUI debug flag
options.debug = logical(get(handles.Debug_Toggle,'Value'));
