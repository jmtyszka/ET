function th = ET_HistThresh(s)
% Perform k-means segmentation of central eye
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/21/2013 JMT From scratch. Similar to 
%
% REFERENCES : Swirski L, Bulling A and Dodgson N 2012
%
% Copyright 2013 California Institute of Technology
% All rights reserved.

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