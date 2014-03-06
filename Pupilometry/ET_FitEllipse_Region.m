function p_fit = ET_FitEllipse_Region(bw_pupil, p_init)
% Ellipse fit using regional segmentation
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/28/2013 JMT Extract from ET_FitPupil.m
%          03/06/2014 JMT Remove max circularity limit
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
% Copyright 2013-2014 California Institute of Technology.

% Circularity limits
min_circularity = 0.5;

% Pupil area limits 1% to 15% of video frame area
n_pix = numel(bw_pupil);
min_area = n_pix * 0.01;
max_area = n_pix * 0.15;

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
  good_pupils = circularity > min_circularity & area > min_area & area < max_area;
  
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
