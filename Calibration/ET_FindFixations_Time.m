function fixations = ET_FindFixations_Time(pupils, handles)
% Identify fixations in time domain (dormant thread)
%
% USAGE : ET_Fix = ET_FindFixations_Time(pupils, targets)
%
% ARGS :
% pupils = pupilometry structure array
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/14/2013 JMT Spin off time-domain fixation finder
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

% if nargin < 2
%   % Classic 9-point clockwise from top left
  targets = [...
    0.1 0.5 0.9 0.1 0.5 0.9 0.1 0.5 0.9; ...
    0.9 0.9 0.9 0.5 0.5 0.5 0.1 0.1 0.1];
% end

% Flags
verbose = false;

% Init return structure
ET_Fix = [];

% Number of fixations to search for
n_fix = size(targets,2);

% Extract pupil timeseries
t     = [pupils.t];
blink = [pupils.blink];

px = [pupils.px];
py = [pupils.py];

% Frame duration
dt = t(2)-t(1);

% Number of frames
nt = length(t);

%% Find fixations

% Set 500 ms kernel width
k = fix(0.5 / dt);
if verbose; fprintf('Kernel width : %d samples\n', k); end


% Moving median filter (500 ms kernel)
if verbose; fprintf('Moving median filter pupil center timeseries\n'); end
cxm = ET_MovingMedFilt(px,k);
cym = ET_MovingMedFilt(py,k);

% Low pass filter (approx 2 Hz cutoff)
if verbose; fprintf('Low pass filter pupil center timeseries\n'); end
cxms = smooth(cxm, k);
cyms = smooth(cym, k);

% Calculate pixel velocity of pupil
vx = [0 diff(cxms)'];
vy = [0 diff(cyms)'];

% Pupil voxel speed
ps = sqrt(vx.*vx + vy.*vy);

% Find possible fixations (ps < 0.1 pixels/frame)
ps_th = 0.1;
eye_fix = ps < 0.1;

% Force final fixation to end with video
eye_fix(end) = 0;

% Assume moving before video
eye_fix    = [0 eye_fix];

% Fixation state changes
eye_change = diff(eye_fix);

% Find indices of start and end of fixations
fix_start  = find(eye_change > 0);
fix_end   = find(eye_change < 0);

% Fixations durationsd
fix_dur = fix_end - fix_start;

% Eliminate fixations shorter than 500 ms
min_fix_dur = fix(0.5 / dt);
good_fix = fix_dur > min_fix_dur;
n_good_fix = sum(good_fix);

if verbose; fprintf('Found %d possible fixations\n', n_good_fix); end

% Extract start, end and duration (in frames) of good fixations
fix_start_good = fix_start(good_fix);
fix_end_good = fix_end(good_fix);
fix_dur_good = fix_dur(good_fix);

% Find fixation centroids
for fc = 1:n_good_fix
  
  % Frame range of fixation
  f0 = fix_start_good(fc);
  f1 = fix_end_good(fc) - 1;
  
  % Pupil center within fixation
  pxf = px(f0:f1);
  pyf = py(f0:f1);
  
  % Mean and sd of fixation center
%   fx_mean(fc) = mean(pxf);
%   fy_mean(fc) = mean(pyf);
%   fx_sd(fc)   = std(pxf);
%   fy_sd(fc)   = std(pyf);
  
    fixations.x(fc) = mean(pxf);
  fixations.y(fc) = mean(pyf);

end

if verbose
  
  figure(40); clf
  
  % Raw pupil center coords over time
  subplot(221), plot(t,px,t,py);
  axis tight
  set(gca,'YDir','reverse');
  legend('CX','CY');
  xlabel('Time (s)');
  
  % Smoothed centers over time
  subplot(222), plot(t,pxms,t,pyms);
  axis tight
  set(gca,'YDir','reverse');
  legend('Smooth CX','Smooth CY');
  xlabel('Time (s)');
  
  % Pupil center velocity
  subplot(223), plot(t,ps);
  axis tight
  legend('Pupil Speed');
  xlabel('Time (s)');
  hold on
  line([min(t) max(t)],[0.1 0.1],'color','r');
  hold off
  
%   Fixation ellipses
%   subplot(224);
%   hold on
%   for fc = 1:n_good_fix
%     ellipse(fx_sd(fc),fy_sd(fc),0,fx_mean(fc),fy_mean(fc));
%   end
%   axis ij
%   hold off
  
end
