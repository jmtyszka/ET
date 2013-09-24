function stats = ET_PupilometryStats(pupils)
% Calculate various statistics from pupilometry structure
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech 
% DATES  : 01/28/2013 JMT From scratch
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

% Timing stats
t = [pupils.t];
stats.t_dur = max(t) - min(t);
stats.fps = 1 / (t(2) - t(1));
