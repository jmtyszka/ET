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
% Copyright 2013 California Institute of Technology.
% All rights reserved.

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


