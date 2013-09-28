function calibration = ET_AutoCalibrate(px, py, handle)
% Calculate video to gaze calibration model
%
% calibration = ET_AutoCalibrate(px, py)
%
% ARGS:
% px,py     = pupil centroid timeseries in video space
% plot_file = output calibration figure file
%
% RETURNS:
% calibration = calibration structure containing matrix, fixations, etc
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 10/15/2011 JMT From scratch
%          09/14/2012 JMT Integrate with ET GUI
%          01/31/2013 JMT Return to standalone function
%          05/01/2013 JMT Simplify arguments and returns
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

% Init return argument
calibration.C = [];
calibration.fixations = [];

%% Calibration in video frame of reference

% Raw fixations in video frame of reference
fixations = ET_FindFixations_Heat(px, py);

% Manual fixation picking
fixations = ET_PickFixations(fixations, handle);

% Sort fixations
[fx, fy] = ET_SortFixations(fixations);

% Biquadratic fit to calibration fixations
C = ET_CalibrationFit(fx, fy);

% Save results in structure
calibration.C         = C;
calibration.fixations = fixations;
calibration.fx        = fx;
calibration.fy        = fy;

