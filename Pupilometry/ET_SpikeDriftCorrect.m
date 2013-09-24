function filt = ET_SpikeDriftCorrect(x, y, a0, dt)
% Remove spike artifacts and baseline drift from gaze centroid timeseries
%
% USAGE : p0 = ET_SpikeDriftCorrect(p)
%
% ARGS:
% p = pupilometry structure array containing timeseries
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 05/10/2013 JMT From scratch
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

% Despike gaze on a 1s timescale
fprintf('ET : Removing gaze spikes\n');
km = fix(1 / dt);
xm = medfilt1(x, km);
ym = medfilt1(y, km);

% Despike pupil area on a 1s timescale
fprintf('ET : Removing pupil area spikes\n');
a0m = medfilt1(a0, km);

% Estimate gaze baseline on a 10 second timescale
fprintf('ET : Removing gaze drift\n');
kb = fix(10 / dt);
xb = medfilt1(x, kb);
yb = medfilt1(y, kb);

% Subtract baseline from each channel
% Assume central fixation dominates at (0.5, 0.5)
filt.x = xm - xb + 0.5;
filt.y = ym - yb + 0.5;
filt.a0 = a0m;


