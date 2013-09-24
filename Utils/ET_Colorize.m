function rgb = ET_Colorize(s, cmap)
% Colorize scalar image using a colormap
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/27/2013 JMT From scratch
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

% Image size
[ny, nx] = size(s);

% Number of color levels
ncol = size(cmap,1);

% Map s to range 1..ncol
smin = min(s(:));
smax = max(s(:));
s = fix((s - smin) / (smax - smin) * (ncol - 1)) + 1;

% Create colorized RGB image
rgb = cmap(s(:), :);

% Reshape to original image size
rgb = reshape(rgb, [ny nx 3]);
