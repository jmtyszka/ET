function cal_fixations = ET_LoadCalFixations(handles)
% Load predefined calibration fixation order from file
%
% USAGE : fix_order = ET_LoadCalFixOrder(handles)
%
% RETURNS:
% calibration = calibration structure containing matrix, fixations, etc
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 2014-02-08 JMT From scratch
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

% Construct calibration fixations filename
[vpath, vstub, ~] = fileparts(handles.cal_video_path);
cal_fix_file = fullfile(vpath, [vstub '.fix']);

if exist(cal_fix_file,'file')
    
    % Load x and y fixation points from file
    % x and y are in range [0,1] in gaze space
    % Row 1 is x, row 2 is y
    C = importdata(cal_fix_file);
    cal_fixations.fx = C(1,:);
    cal_fixations.fy = C(2,:);
    
    nf = size(C,2);
    fprintf('ET : Loaded %d target fixations from %s\n', nf, cal_fix_file);

else
    
    % Assume 9-point fixation, book order
    cal_fixations.fx = [0.1 0.5 0.9 0.1 0.5 0.9 0.1 0.5 0.9];
    cal_fixations.fy = [0.9 0.9 0.9 0.5 0.5 0.5 0.1 0.1 0.1];
    
end