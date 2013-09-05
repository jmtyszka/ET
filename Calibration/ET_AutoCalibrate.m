function calibration = ET_AutoCalibrate(px, py)
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
% Copyright 2012-2013 California Institute of Technology
% All rights reserved.

% Init return argument
calibration.C = [];
calibration.fixations = [];

%% Calibration in video frame of reference

% Raw fixations in video frame of reference
fixations = ET_FindFixations_Heat(px, py);

% Sort fixations
[fx, fy] = ET_SortFixations(fixations);

% Biquadratic fit to calibration fixations
C = ET_CalibrationFit(fx, fy);

% Save results in structure
calibration.C         = C;
calibration.fixations = fixations;
calibration.fx        = fx;
calibration.fy        = fy;

