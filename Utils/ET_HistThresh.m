function th = ET_HistThresh(s)
% Perform k-means segmentation of central eye
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/21/2013 JMT From scratch. Similar to 
%
% REFERENCES : Swirski L, Bulling A and Dodgson N 2012
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

% Get coarse histogram of image
[n, xc] = hist(s(:),32);

% Smooth histogram
ns = smooth(n,5);

% First derivative of histogram
dns = [0 diff(ns)'];

% Find first positive value of derivative
pos_inds = find(dns > 0);
first_pos = pos_inds(1);

% Map index to intensity threshold
th = xc(first_pos);
