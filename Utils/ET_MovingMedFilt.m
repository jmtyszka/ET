function y = ET_MovingMedFilt(x, k)
% 1D median filter x using a w sample kernel, ignoring NaNs
%
% USAGE : y = ET_MovingMedFilt(x, k)
%
% ARGS :
% x = vector of uniformly sampled values
% k = filter kernel width [3]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte, CA
% DATES  : 05/31/00 Add index range
%          06/01/00 Remove index range
%          08/09/00 Add defaults and syntax message
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

if nargin < 1
   fprintf('SYNTAX: y = ET_MovingMedFilt(x,k)\n');
   return;
end

% Default kernel width of 3 samples
if nargin < 2
   k = 3;
end

nx = length(x);

% Half the kernel width rounded down
hk = floor(k/2);

% Create start and end points for each window position
p0 = (1:nx) - hk;
p1 = (1:nx) + hk;

% Keep start and end points within bounds
p0(p0 < 1) = 1;
p1(p1 > nx) = nx;

% Allocate space
y = zeros(1,nx);

% Run median window over vector
for p = 1:nx
   y(p) = nanmedian(x(p0(p):p1(p)));
end
