function fr_pair_roi = ET_Prep_ApplyROI(handles, fr_pair)
% Apply ROI with rotation
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 2014-01-28 JMT From scratch
%          2014-01-29 JMT Expand to full processing
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
% Copyright 2014 California Institute of Technology

% Init output frame image
fr_pair_roi = [];

% Check for empty input
if isempty(fr_pair)
  return
end

% Get ROI parameters from GUI
roi_x = str2double(get(handles.Pupil_X, 'String'));
roi_y = str2double(get(handles.Pupil_Y, 'String'));
roi_w = str2double(get(handles.ROI_size, 'String'));

% Convert to x and y pixel ranges
hw = fix(roi_w / 2);
w_rng = (-hw):(hw-1);
x_rng = w_rng + round(roi_x);
y_rng = w_rng + round(roi_y);

% Clamp limits
[ny, nx, ~] = size(fr_pair);
x_rng(x_rng < 1 | x_rng > nx)  = [];
y_rng(y_rng < 1 | y_rng > ny)  = [];

% Extract ROI from input frame
fr_pair_roi = fr_pair(y_rng, x_rng, :);

% Rotate according to UI popup
% Apply to each frame separately 
rot_val = get(handles.Rotate_ROI_Popup,'Value');
switch rot_val
    case 2
        fr_pair_roi(:,:,1) = rot90(fr_pair_roi(:,:,1),3);
        fr_pair_roi(:,:,2) = rot90(fr_pair_roi(:,:,2),3);
    case 3
        fr_pair_roi(:,:,1) = rot90(fr_pair_roi(:,:,1),2);
        fr_pair_roi(:,:,2) = rot90(fr_pair_roi(:,:,2),2);
    case 4
        fr_pair_roi(:,:,1) = rot90(fr_pair_roi(:,:,1),1);
        fr_pair_roi(:,:,2) = rot90(fr_pair_roi(:,:,2),1);
    otherwise
        % Do nothing
end

% Update ROI width to actual value used (even number)
set(handles.ROI_size, 'String', sprintf('%d', 2*hw));
