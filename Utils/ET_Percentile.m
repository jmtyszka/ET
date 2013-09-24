function y = ET_Percentile(x, p)
% Calculate the p'th percentile of the vector x
%
% USAGE : y = ET_Percentile(x, p)
%
% ARGS :
% x = array of values
% p = vector of percentiles to be calculated
%
% RETURNS:
% y = vector of percentiles corresponding to p
%
% AUTHOR  : Mike Tyszka, Ph.D.
% PLACE   : City of Hope, Duarte CA and Caltech
% DATES   : 02/20/2001 From scratch
%           10/09/2001 Add support for multiple percentiles
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
%
%#realonly

% Flatten the vectors
x = x(:);
p = p(:);
n = length(x);

% Catch single point
if n < 2
  y = repmat(x(1),size(p));
  return
end

% Sort the vector
sx = sort(x);

% Find fractional percentile indices
inds = (n * p / 100) + 0.5;

% Keep index in bounds
inds(inds > n) = n;
inds(inds < 1) = 1;

% Interpolate percentile
y = interp1(1:n, sx, inds, '*linear');
