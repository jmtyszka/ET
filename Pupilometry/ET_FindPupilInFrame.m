function [pupil, roi] = ET_FindPupilInFrame(fr, pd_range, roi_hw)
% Find best candidate for pupil within frame
% - start with optional pupil estimate
%
% ARGS:
% fr     = scalar double video frame
% pd_rng = fractional pupil size range [0.1 0.2]
% roi_hw  = optional forced half-width for ROI (in pixels)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/07/2013 JMT Extract and rewrite
%          03/07/2013 JMT Add optional ROI width argument
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

% Default PD range (10% to 30% of frame width)
if nargin < 2; pd_range = [0.1 0.3]; end
if nargin < 3; roi_hw = []; end

% Initialize pupil structure
pupil = ET_NewPupil;

% Input frame width 
[ny,nx] = size(fr);

% Scale factor mapping input frame to 100 pixels width
sf = 100 / nx; 

% Linear interpolate frame to 100 pixels width
frd = imresize(fr,sf);

% Get downsampled frame width
nxd = size(frd,2);

% Number of pd steps
n_pd = 5;

% Pupil diameter search vector
pd = fix(linspace(min(pd_range), max(pd_range), n_pd) * nxd);

% Create integral image
ii = cumsum(cumsum(frd,1),2);
ii = padarray(ii,[1 1],0,'pre');

% Init feature mask sums
s_max = zeros(n_pd,1);
x_max = s_max;
y_max = s_max;

% Loop over pupil diameters
for pc = 1:n_pd
  [s_max(pc), x_max(pc), y_max(pc)] = ET_HaarPupilCorrelation(ii, pd(pc));
end

% Find best correlation
[~, best] = max(s_max);

pd_best = pd(best) / sf;
x_best = x_max(best) / sf;
y_best = y_max(best) / sf;

% Fill return pupil structure with rescaled center and diameter
pupil.px     = x_best;
pupil.py     = y_best;
pupil.pd_eff = pd_best;

%% Setup ROI around pupil center

% ROI width in pupil diameters
roi.scale = 3.0;

% Use ROI half width calculated from PD or provided by user
if isempty(roi_hw)
  roi.hw = pd_best * roi.scale / 2;
else
  roi.hw = roi_hw;
end

roi.x0 = fix(x_best - roi.hw);
roi.x1 = fix(x_best + roi.hw);
roi.y0 = fix(y_best - roi.hw);
roi.y1 = fix(y_best + roi.hw);

% ROI index vectors
xrng = roi.x0:roi.x1;
yrng = roi.y0:roi.y1;

% Out of bounds protection
xrng(xrng < 1)  = 1;
xrng(xrng > nx) = nx;
yrng(yrng < 1)  = 1;
yrng(yrng > ny) = ny;

% Store ROI pixel ranges
roi.xrng = xrng;
roi.yrng = yrng;

% Set ROI rotation (degrees)
roi.rotation = 0;

