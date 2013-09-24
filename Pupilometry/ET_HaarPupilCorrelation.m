function [s_max, x_max, y_max] = ET_HaarPupilCorrelation(ii, pd)
% Create correlation image for given pupil diameter
%
% AUTHOR : Mike Tyszka
% PLACE  : Caltech
% DATES  : 02/08/2013 JMT From scratch
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

% Flags
DEBUG = false;

% Integral image dimensions
[ny, nx] = size(ii);

% Init correlation image
s = zeros(size(ii));

% Haar window width is three times the pupil diameter
w = 3 * pd;

% Loop over all image
for x = 1:nx
  for y = 1:ny
    s(y,x) = ET_IIRectSum(ii, x, y, w, w) - ET_IIRectSum(ii, x, y, pd, pd);
  end
end

% Find maximum correlation in flattened image
[s_max, i_max] = max(s(:));

% Convert index to (x,y) coordinate
[y_max, x_max] = ind2sub([ny nx], i_max);

if DEBUG
  % Show correlation image with maximum marked
  figure(30); clf; colormap(hot)
  imagesc(s); axis image
  hold on
  plot(x_max, y_max, 'k+');
  pause
end
