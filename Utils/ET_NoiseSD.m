function sd_n = ET_NoiseSD(x)
% Estimate the noise sd using wavelet decomposition and MAD of the detail coeffs
%
% sd_n = noisesd(x)
% 
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 01/26/2001 JMT Extract from normnoise.m
%          01/17/2006 JMT M-Lint corrections
%          05/03/2013 JMT Port to ET environment
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

% Single-level wavelet decomposition of x
[~,cd] = dwt(x(:),'sym4');

% Estimate the noise sd using the MAD of the detail coefficients (cd)
sd_n = median(abs(cd(:) - median(cd(:)))) / 0.6745; 
