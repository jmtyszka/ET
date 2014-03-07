function [fr0_pair, artifact_detected] = ET_Prep_MRClean(fr_pair, fr_pair_prev, DEBUG)
% Remove MRI RF artifacts by comparing neighboring frames
%
% USAGE : [fr0_pair, artifact_detected] = ET_MRClean(fr_pair, fr_pair_prev)
%
% ARGS :
% fr_pair      = n x m x 2 matrix containing the n x m odd and even frames
% fr_pair_prev = previous frame pair
% DEBUG        = debuggin output flag
%
% Correction is by replacement of the artifact with equivalent lines from
% the intact frame in the pair.
%
% AUTHOR : Mike Tyszka, Ph.D. and Julien Dubois, Ph.D.
% PLACE  : Caltech
% DATES  : 11/17/2011 JMT From scratch
%          10/01/2012 JMT Add a priori knowledge of artifact types
%          01/30/2014 JMT Merge Julien's prior frame approach with z-score
%                         analysis.
%                         Drop artifact pattern matching approach
%                         Improve performance (drop wavelet SD estimation)
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
% Copyright 2012-2014 California Institute of Technology.

% Debug flag
if nargin < 3; DEBUG = false; end

% Other flags
do_smooth  = true;
do_medfilt = false;
do_robust  = false;

% Empirical z threshold for frame row differences
z_thresh = 1.0;

% Split out odd and even frames
fr_odd  = fr_pair(:,:,1);
fr_even = fr_pair(:,:,2);
fr_even_prev = fr_pair_prev(:,:,2);

% Frame differences between odd, even and previous even frames
% dA : even - odd frame
% dB : odd - previous even frame
% dC : even - previous even frame
dA = fr_even - fr_odd;
dB = fr_odd - fr_even_prev;
dC = fr_even - fr_even_prev;

% Calculate z-score of rows in all three difference images
% with null hypothesis of zero mean difference
if do_robust
    
    % Replace mean with median and SD with IQR/2
    
    pA = prctile(dA,[25 50 75],2);
    zA = pA(:,2) ./ (pA(:,3) - pA(:,1)) * 2;
    
    pB = prctile(dB,[25 50 75],2);
    zB = pB(:,2) ./ (pB(:,3) - pB(:,1)) * 2;
    
    pC = prctile(dC,[25 50 75],2);
    zC = pC(:,2) ./ (pC(:,3) - pC(:,1)) * 2;

else
    
    zA = mean(dA, 2) ./ std(dA, 0, 2);
    zB = mean(dB, 2) ./ std(dB, 0, 2);
    zC = mean(dC, 2) ./ std(dC, 0, 2);

end

% Spatially row z scores
if do_smooth
    
    span = 5;
    zA = smooth(zA, span, 'moving');
    zB = smooth(zB, span, 'moving');
    zC = smooth(zC, span, 'moving');

end

% Calculate signed suprathreshold z (h)
%  z  >=  z_thresh -> h = +1
% |z| <   z_thresh -> h =  0
%  z  <= -z_thresh -> h = -1

hA = (zA >= z_thresh) - (zA <= -z_thresh);
hB = (zB >= z_thresh) - (zB <= -z_thresh);
hC = (zC >= z_thresh) - (zC <= -z_thresh);

%% Artifact identification and frame localization
% Work out which rows are contaminated by a row artifact from
% all three frame difference pairings (A, B, C).

% LOGIC:
% - Calculated on a row-wise basis
% - Assumes each row has at least 2/3 normal frames
%
% Key:
%
% Type | hA  hB  hC | Conclusion               | Action
% I    | 0   0   0  | no artifact              | Do nothing
% II   | 0   +-  +- | +- artifact in prev even | Do nothing
% III  | -+  +-  00 | +- artifact in odd       | Replace odd row with even row
% IV   | +-  0   +- | +- artifact in even      | Replace even row with odd

% Type_I   = ~hA & ~hB & ~hc;
% Type_II  = ~hA & (((hB > 0) & (hC > 0)) | ((hb < 0) & (hC < 0)));
Type_III = ~hC & (((hA < 0) & (hB > 0)) | ((hA > 0) & (hB < 0)));
Type_IV  = ~hB & (((hA > 0) & (hC > 0)) | ((hA < 0) & (hC < 0)));

% Median filter artifact type (kernel width 3) under assumption
% artifacts are caused by continuous RF pulses
if do_medfilt
    k = 3;
    Type_III = logical(medfilt1(double(Type_III),k));
    Type_IV  = logical(medfilt1(double(Type_IV),k));
end

% Init output frames
fr0_odd  = fr_odd;
fr0_even = fr_even;

% Replace rows appropriately for Type III and IV artifacts
Type_III_Present = any(Type_III);
if Type_III_Present
    fr0_odd(Type_III, :) = fr_even(Type_III,:);
end
Type_IV_Present = any(Type_IV);
if Type_IV_Present
    fr0_even(Type_IV, :) = fr_odd(Type_IV, :);
end

% Set artifact flag
artifact_detected = Type_III_Present || Type_IV_Present;

% Reconstitute corrected frame pair
fr0_pair = cat(3,fr0_odd,fr0_even);

if DEBUG
  
  figure(11); clf; colormap(gray);
  set(gcf,'Position',[200 200 900 1100]);
  xlims = [1 length(zA)]; 
  
  subplot(5,3,1), imshow(fr_even_prev); title('Even Previous');
  subplot(5,3,2), imshow(fr_odd); title('Odd');
  subplot(5,3,3), imshow(fr_even); title('Even');
  
  ylims = [-5 5];
  subplot(5,3,4), plot(zA); title('zA'); set(gca,'XLim',xlims,'YLim',ylims);
  subplot(5,3,5), plot(zB); title('zB'); set(gca,'XLim',xlims,'YLim',ylims);
  subplot(5,3,6), plot(zC); title('zC'); set(gca,'XLim',xlims,'YLim',ylims);
  
  ylims = [-1.1 1.1];
  subplot(5,3,7), plot(hA); title('hA'); set(gca,'XLim',xlims,'YLim',ylims);
  subplot(5,3,8), plot(hB); title('hB'); set(gca,'XLim',xlims,'YLim',ylims);
  subplot(5,3,9), plot(hC); title('hC'); set(gca,'XLim',xlims,'YLim',ylims);
  
  ylims = [-0.1 1.1];
  subplot(5,3,10), plot(Type_III); title('Type III'); set(gca,'XLim',xlims,'YLim',ylims);
  subplot(5,3,11), plot(Type_IV); title('Type IV'); set(gca,'XLim',xlims,'YLim',ylims);
  
  subplot(5,3,14), imshow(fr0_odd); title('Odd Clean');
  subplot(5,3,15), imshow(fr0_even); title('Even Clean');
  
  drawnow
  
end
