function fr0_pair = ET_MRClean(fr_pair, DEBUG)
% Remove MRI RF artifacts by comparing neighboring frames
%
% USAGE : fr0_pair = ET_MRClean(fr_pair)
%
% ARGS :
% fr_pair = n x m x 2 matrix containing the n x m odd and even frames
%
% Target artifact is a horizontal bright band, approximately 8 scan lines
% in duration (500us) in typical fMRI EPI sequences.
%
% The artifact is detected in the horizontal projection of the difference image
% between successive frames. Since the artifact is essential constant
% across the the frame, it generates a strong positive or negative approx
% 8-point bulge in the projection.
%
% Correction is by replacement of the artifact with equivalent lines from
% the intact frame in the pair.
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 11/17/2011 JMT From scratch
%          10/01/2012 JMT Add a priori knowledge of artifact types
%
% Copyright 2012 California Institute of Technology.
% All rights reserved.

% Debug flag
if nargin < 2; DEBUG = 0; end

% Frame height in rows
[n_rows,n_cols,~] = size(fr_pair);

% Split out odd and even frames
fr_even = fr_pair(:,:,1);
fr_odd  = fr_pair(:,:,2);

% Difference image (even - odd)
df = fr_even - fr_odd;

% Mean row difference
mdf = mean(df,2);

% Estimate noise SD from detail coeffs of wavelet decomposition
sd_n = ET_NoiseSD(mdf);

% Set artifact threshold at +/- 5 * sd_n
art_thresh = sd_n * 5;

%% Locate artifact blocks in row means

% Two possible artifact blocks in mean row difference:
%   1. Narrow, high magnitude : Positive RF Pulse
%   2. Wide, low magnitude    : Negative, EPI echo train

% Significant deviations from baseline difference
art_row_mask = abs(mdf) > art_thresh;

% Find rising and falling edges of row mask
% Assume mask is zero outside bounds - pad mask vector with zeros
% This forces an equal number of rising and falling edges
dmask = diff([0; art_row_mask; 0]);
art_on  = find(dmask > 0);
art_off = find(dmask < 0)-1;

% Artifact widths in rows
art_width = art_on - art_off;

% Number of artifacts in frame pair
n_arts = length(art_width);

% Init output frames
fr0_odd  = fr_odd;
fr0_even = fr_even;

% Loop over artifacts
for bc = 1:n_arts
  
  r0 = art_on(bc);
  r1 = art_off(bc);
  
  % Artifact rows
  art = mdf(r0:r1);
  
  % Max artifact deviation from zero
  min_art = min(art);
  max_art = max(art);
  if abs(min_art) > abs(max_art)
    max_art = min_art;
  end
  
  % Frame mask for this artifact
  row_mask = false(n_rows,1);
  row_mask(r0:r1,1) = 1;
  art_frame_mask = repmat(row_mask,[1 n_cols]);

  % Check amplitude of artifact against frame maximum
  if abs(max_art) > 0.25
    
    % Type 1 : High magnitude, positive, narrow
    if max_art > 0
      fr0_even(art_frame_mask) = fr0_odd(art_frame_mask);
    else
      fr0_odd(art_frame_mask) = fr0_even(art_frame_mask);
    end
    
  else

    % Type 2 : Low magnitidue, negative, wide
    if max_art < 0
      fr0_even(art_frame_mask) = fr0_odd(art_frame_mask);
    else
      fr0_odd(art_frame_mask) = fr0_even(art_frame_mask);
    end
  
  end
  
end

% Reconstitute corrected frame pair
fr0_pair = cat(3,fr0_odd,fr0_even);

if DEBUG
  
  figure(11); clf; colormap(gray);
  subplot(321), imagesc(fr_odd); axis image; title('Odd frame');
  subplot(323), imagesc(fr_even); axis image; title('Even frame');
  subplot(325), imagesc(df); axis image; title('Difference');
  
  subplot(322), imagesc(fr0_odd); axis image; title('Odd frame corrected');
  subplot(324), imagesc(fr0_even); axis image; title('Even frame corrected');
  
  r = 1:n_rows;
  mdf_art = mdf;
  mdf_art(~art_row_mask) = NaN;
  
  subplot(326), plot(r, mdf);
  set(gca,'YLim',[-1 1]);
  hold on
  subplot(326), plot(r, mdf_art, 'r', 'linewidth', 2);
  hold off
  
end
