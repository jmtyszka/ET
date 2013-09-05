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
% Copyright 2011-2013 California Institute of Technology.
% All rights reserved.

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
