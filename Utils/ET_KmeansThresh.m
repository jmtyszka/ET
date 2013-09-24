function th = ET_KmeansThresh(s)
% Perform k-means segmentation of central eye (see Swirski et al)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/21/2013 JMT Extract from ET_SegmentPupil.m
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

% Number of k-means clusters
n_clusters = 3;

% k-means segmentation of image
warning('off','stats:kmeans:EmptyCluster');
[idx, m] = kmeans(s(:)', n_clusters,...
  'start','cluster',...
  'emptyaction', 'singleton');
warning('on','stats:kmeans:EmptyCluster');

% Sort clusters by mean, ascending
[m_sort, m_order] = sort(m, 'ascend');

% Estimate optimal threshold between first and second cluster
sd_1 = std(s(idx == m_order(1)));
sd_2 = std(s(idx == m_order(2)));

% Place threshold at estimated minimum between Gaussians
th = m_sort(1) + (m_sort(2)-m_sort(1)) * sd_1 / (sd_1+sd_2);
