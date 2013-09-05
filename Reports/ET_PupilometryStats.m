function stats = ET_PupilometryStats(pupils)
% Calculate various statistics from pupilometry structure
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech 
% DATES  : 01/28/2013 JMT From scratch
%
% Copyright 2013 California Institute of Technology
% All rights reserved.

% Timing stats
t = [pupils.t];
stats.t_dur = max(t) - min(t);
stats.fps = 1 / (t(2) - t(1));
