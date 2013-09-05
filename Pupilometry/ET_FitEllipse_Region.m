function p_fit = ET_FitEllipse_Region(bw_pupil, p_init)
% Ellipse fit using regional segmentation
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/28/2013 JMT Extract from ET_FitPupil.m
%
% Copyright 2013 California Institute of Technology
% All rights reserved.

% Circularity limits
min_circularity = 0.5;
max_circularity = 1.0;

% Pupil area limits 1% to 50% of ROI area
n_pix = numel(bw_pupil);
min_area = n_pix * 0.01;
max_area = n_pix * 0.50;

% Init fitted pupil structure
p_fit = p_init;

% Set blink flag
p_fit.blink = true;

% Detect object boundaries
[B_pupil, L_pupil] = bwboundaries(bw_pupil, 'noholes');

% Number of potential pupil objects
n_pupils = length(B_pupil);

%% Score candidate pupil regions

if n_pupils > 0
  
  % Gather useful stats from identified regions - pupil will be one of them
  pupil_stats = regionprops(L_pupil,'Area','Centroid','Perimeter',...
    'MajorAxisLength','MinorAxisLength','Orientation');
  
  % Parse stats structure
  area = [pupil_stats.Area];
  peri = [pupil_stats.Perimeter];
  
  % Circularity metric : 4 * pi * area / (perimeter^2)
  % Equal to one by definition for circle
  circularity = 4 * pi * area ./ peri.^2;
  
  % Determine which pupil candidates meet criteria
  % for both area and circularity
  good_pupils = circularity > min_circularity & circularity < max_circularity & ...
    area > min_area & area < max_area;
  
  % Score candidates using position within bounds for area and circularity
  pupil_score = ...
    ((circularity - min_circularity) / (1 - min_circularity) + ...
    (area - min_area) / (max_area - min_area)) .* good_pupils;
  
  % Find best score
  [~, best] = max(pupil_score);
  
  % Save max liklihood centroid and fitted ellipse pars
  p_fit.px = pupil_stats(best).Centroid(1);
  p_fit.py = pupil_stats(best).Centroid(2);
  
  % Note : regionprops orientation is the angle in degrees between the x-axis
  % (columns) and the major axis of the ellipse.
  % phi = 0 would be a horizontal major axis
  % Save ellipse info as [SemiMajor SemiMinor Orientation]
  p_fit.ra = pupil_stats(best).MajorAxisLength/2;
  p_fit.rb = pupil_stats(best).MinorAxisLength/2;
  p_fit.phi = -pupil_stats(best).Orientation * pi/180;
  
  p_fit.circularity = circularity(best);
  p_fit.area = area(best);
  p_fit.area_correct = pi * (p_fit.ra)^2;
  p_fit.pd_eff = 2 * sqrt(p_fit.ra * p_fit.rb);
  
  % Eye-camera angle from ratio of semiminor to semimajor axes
  p_fit.eye_camera_angle = acos(p_fit.rb / p_fit.ra) * 180/pi;
  
  % Set blink flag if no candidate meet criteria
  p_fit.blink = (max(good_pupils) == 0);
  
else
  
  % No regions detected
  % Set blink flag, but keep previous pupilometry
  p_fit.blink = true;
  
end
