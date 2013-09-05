function pupil = ET_NewPupil
% Create a new pupil structure
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/08/2013 JMT From scratch
%
% Copyright 2013 California Institute of Technology
% All rights reserved.

% Timestamp
pupil.t   = NaN;

% Ellipse parameters
pupil.px  = NaN;
pupil.py  = NaN;
pupil.ra  = NaN;
pupil.rb  = NaN;
pupil.phi = NaN;

% Calibrated gaze position [0,100]
pupil.gaze_x  = NaN;
pupil.gaze_y  = NaN;

% Calculated pupil metrics
pupil.pd_eff       = NaN;
pupil.area         = NaN;
pupil.area_correct = NaN;
pupil.pd_eff       = NaN;
pupil.circularity  = NaN;
pupil.eye_camera_angle = NaN;

% Segmentation
pupil.thresh = NaN;

% Blink flag
pupil.blink = false;

% Glint parameters
pupil.gx     = NaN;
pupil.gy     = NaN;
pupil.gd_eff = NaN;

% ROI parameters
pupil.rx0 = NaN;
pupil.rx1 = NaN;
pupil.ry0 = NaN;
pupil.ry1 = NaN;
