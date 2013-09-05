function th = ET_KmeansThresh(s)
% Perform k-means segmentation of central eye (see Swirski et al)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/21/2013 JMT Extract from ET_SegmentPupil.m
%
% REFERENCES : Swirski L, Bulling A and Dodgson N 2012
%
% Copyright 2013 California Institute of Technology
% All rights reserved.

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
