function [gaze_x, gaze_y] = ET_ApplyCalibration(px, py, C)
% Apply calibrated correction to raw pupil centroids or pupil-glint vectors
%
% ARGS:
% px, py = pupil centroids in video or glint FoR
% C      = calibration matrix in video or glint FoR
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 11/01/2011 JMT From scratch
%          02/27/2013 JMT Simplify arguments and returns
%          04/16/2013 JMT Switch to generalized form, independent of FoR
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

% Number of sampled centroids
n = length(px);

% Model order from C
model_order = size(C,2);

switch model_order
  
  case 3 % Bilinear
    
    % Construct bilinear R
    R = [px; py; ones(1,n)];
    
  case 6 % Biquadratic

    % Additional binomial coordinates
    px2 = px .* px;
    py2 = py .* py;
    pxy = px .* py;
    
    % Construct biquadratic R
    R = [px2; pxy; py2; px; py; ones(1,n)];

end

% Apply transformation
R0 = C * R;

% Unpack calibrated gaze coordinates
gaze_x = R0(1,:);
gaze_y = R0(2,:);
