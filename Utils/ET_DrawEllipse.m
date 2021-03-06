function rgb_out = ET_DrawEllipse(rgb_in, col, ra, rb, phi, cx, cy)
% Draw a colored line into an RGB image
%
% ARGS:
% ra, rb = semimajor, semiminor axis lengths
% phi    = ellipse rotation CCW relative to x axis in radians
% cx, cy = ellipse center
%
% AUTHOR : Mike Tyszka
% PLACE  : Caltech
% DATES  : 02/20/2013 JMT From scratch
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

% Separate channels
r_in = rgb_in(:,:,1);
g_in = rgb_in(:,:,2);
b_in = rgb_in(:,:,3);

% Image channel dimensions
[ny, nx] = size(r_in);

% Perimeter estimate (Ramanujan)
perim = pi*(3*(ra+rb)-sqrt((3*ra+rb)*(ra+3*rb)));

% Angle vector (10% oversampled)
th = linspace(0,2*pi,round(perim * 1.1));

% Cosine and sine vectors
ct = cos(th);
st = sin(th);

% Create x and y vectors for line points
x = ra * ct;
y = rb * st;

% Rotate ellipse
cp = cos(phi); sp = sin(phi);
xr = x * cp - y * sp;
yr = y * cp + x * sp;

% Displace ellipse
x = xr + cx;
y = yr + cy;

% Clamp limits
oob = x < 1 | x > nx | y < 1 | y > ny;
x(oob) = [];
y(oob) = [];

% Map line points to image indices for each channel
inds = sub2ind([ny nx], round(y), round(x));

% Paint line points
r_in(inds) = col(1);
g_in(inds) = col(2);
b_in(inds) = col(3);

% Composite returned RGB image
rgb_out = cat(3,r_in,g_in,b_in);
