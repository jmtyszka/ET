function calibration = ET_AutoCalibrate(pupils, handles)
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

% Reinitialize Gaze Axes
ET_PlotGaze([], handles.Gaze_Axes, [], 'init');

%% Calibration in video frame of reference

% Raw fixations in video frame of reference

% JMT older version
% fixations = ET_FindFixations_Heat(pupils);

% JD 10/03/13 : combining fixations detected in spatial and time domains
% in case the heatmap doesn't suffice; since the points are picked
% manually, it is not a problem to have too many
fixationsH = ET_FindFixations_Heat(pupils);
fixationsT = ET_FindFixations_Time(pupils);
fixations.x = [fixationsH.x fixationsT.x];
fixations.y = [fixationsH.y fixationsT.y];
fixations.hmap = fixationsH.hmap;
fixations.xv = fixationsH.xv;
fixations.yv = fixationsH.yv;

%%
% Old version
% Manual fixation picking (not in order)
% just pick 9 fixations, they are sorted automatically
% if there are less than 9 fixations, the automatic sorting is
% problematic
%
% fixations = ET_PickFixations(fixations, handles);
%
% Sort fixations
% [fx, fy] = ET_SortFixations(fixations);

%%
% Manual fixation picking in order
% left click on the fixation that corresponds to the currently
% highlighted point in the gaze window; then press return
% if there is no detected fixation at that point, just press return and
% the point will be ignored (ok if we have 1 or 2 missing fixations)
% this assumes that we have a 9-point calibration

fixations = ET_PickFixationsOrder(fixations, handles);
fx = fixations.x;
fy = fixations.y;

% Biquadratic fit to calibration fixations
C = ET_CalibrationFit(fx, fy);
    
% Save results in structure
calibration.C         = C;
calibration.fixations = fixations;
calibration.fx        = fx;
calibration.fy        = fy;

