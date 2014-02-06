function pupil = ET_NewPupil
% Create a new pupil structure
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/08/2013 JMT From scratch
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
