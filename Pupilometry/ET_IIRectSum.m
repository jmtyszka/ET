function s = ET_IIRectSum(ii, x, y, w, h)
% Calculate rectangle sum from integral image
%
% AUTHOR : Mike Tyszka
% PLACE  : Caltech
% DATES  : 02/08/2013 JMT Implement idea from Viola-Jones
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

hw = fix(w/2);
hh = fix(h/2);

% Rectangle corner locations
x0 = fix(x - hw);
x1 = fix(x + hw);
y0 = fix(y - hh);
y1 = fix(y + hh);

% Check bounds
[ny,nx] = size(ii);
if x0 < 1 ; x0 = 1; end
if x0 > nx; x0 = nx; end
if x1 < 1 ; x1 = 1; end
if x1 > nx; x1 = nx; end
if y0 < 1 ; y0 = 1; end
if y0 > ny; y0 = ny; end
if y1 < 1 ; y1 = 1; end
if y1 > ny; y1 = ny; end

% Calculate rectangle mean
s = (ii(y1,x1) - ii(y0,x1) - ii(y1,x0) + ii(y0,x0)) / (w * h);
