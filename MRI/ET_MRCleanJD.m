function fr0_pair = ET_MRCleanJD(fr_pair, prev_fr_pair, DEBUG)
% Remove MRI RF artifacts by comparing neighboring frames
%
% USAGE : fr0_pair = ET_MRCleanJD(fr_pair, prev_fr_pair)
%
% ARGS :
% fr_pair = n x m x 2 matrix containing the n x m odd and even frames
% prev_fr_pair = n x m x 2 matrix containing the n x m odd and even frames
% from the previous frame
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
% There are different artifact types. Given the different ways to set up the camera, 
% it is rather difficult to find a good heuristic to distinguish the
% different types. 
% The approach taken here is to also use the previous frames to determine
% which of the two current frames (even or odd) needs to be corrected.
%
% TODO: it seems that compression of the original .mpg movies into .mov
% leads to contamination of the interlaced frame by the artifact. This is
% problematic as it becomes impossible to totally clean the video. In cases
% when the previous video frame does not have any artifacts at this
% location, it is used instead of the interlaced frame.
%
% AUTHOR : Julien Dubois, Ph.D.
% PLACE  : Caltech
% DATES  : 10/04/2013 JD from JMT's ET_MRClean 
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
% Copyright 2012-2013 California Institute of Technology.

% Debug flag
if nargin < 2; fr0_pair=fr_pair;return; end
if nargin < 3; DEBUG = 0; end

% Frame height in rows
[n_rows,n_cols,~] = size(fr_pair);

% Split out odd and even frames
fr_odd  = fr_pair(:,:,1);
fr_even = fr_pair(:,:,2);

% prev_fr_even = prev_fr_pair(:,:,1);
prev_fr_odd  = prev_fr_pair(:,:,1);
prev_fr_even  = prev_fr_pair(:,:,2);

% Difference image (even - odd)
df_eo   = fr_even - fr_odd;
df_pepo   = prev_fr_even - prev_fr_odd;
df_epo  = fr_even - prev_fr_odd;
df_opo  = fr_odd  - prev_fr_odd;
df_epe  = fr_even - prev_fr_even;
df_ope  = fr_odd  - prev_fr_even;

% Mean row difference
mdf_eo = mean(df_eo,2);
mdf_pepo = mean(df_pepo,2);
mdf_epo = mean(df_epo,2);
mdf_opo = mean(df_opo,2);
mdf_epe = mean(df_epe,2);
mdf_ope = mean(df_ope,2);

% Estimate noise SD from detail coeffs of wavelet decomposition
sd_n_eo = ET_NoiseSD(mdf_eo);
sd_n_pepo = ET_NoiseSD(mdf_pepo);
sd_n_epo = ET_NoiseSD(mdf_epo);
sd_n_opo = ET_NoiseSD(mdf_opo);
sd_n_epe = ET_NoiseSD(mdf_epe);
sd_n_ope = ET_NoiseSD(mdf_ope);

% Set artifact threshold at +/- 5 * sd_n
art_thresh_eo = sd_n_eo * 5;
art_thresh_pepo = sd_n_pepo * 5;
art_thresh_epo = sd_n_epo * 5;
art_thresh_opo = sd_n_opo * 5;
art_thresh_epe = sd_n_epe * 5;
art_thresh_ope = sd_n_ope * 5;

%% Locate artifact blocks in row means

% Significant deviations from baseline difference
art_row_mask_eo = abs(mdf_eo) > art_thresh_eo;
art_row_mask_pepo = abs(mdf_pepo) > art_thresh_pepo;
art_row_mask_epo = abs(mdf_epo) > art_thresh_epo;
art_row_mask_opo = abs(mdf_opo) > art_thresh_opo;
art_row_mask_epe = abs(mdf_epe) > art_thresh_epe;
art_row_mask_ope = abs(mdf_ope) > art_thresh_ope;

% Find rising and falling edges of row mask
% Assume mask is zero outside bounds - pad mask vector with zeros
% This forces an equal number of rising and falling edges
dmask = diff([0; art_row_mask_eo; 0]);
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
    art = mdf_eo(r0:r1);
    
    % Max artifact deviation from zero
    [min_art, indmin] = min(art);
    [max_art, indmax] = max(art);
    if abs(min_art) > abs(max_art)
        %       max_art = min_art;
        indmax = indmin+r0-1;
    else
        indmax = indmax+r0-1;
    end
    
    % Frame mask for this artifact
    row_mask = false(n_rows,1);
    row_mask(r0:r1,1) = 1;
    art_frame_mask = repmat(row_mask,[1 n_cols]);
    
    if (art_row_mask_epo(indmax) && sign(mdf_epo(indmax))==sign(mdf_eo(indmax)) && (abs(mdf_epo(indmax)-mdf_eo(indmax)) < abs(mdf_opo(indmax)+mdf_eo(indmax)))) || ...
            (art_row_mask_epe(indmax) && sign(mdf_epe(indmax))==sign(mdf_eo(indmax)) && (abs(mdf_epe(indmax)-mdf_eo(indmax)) < abs(mdf_ope(indmax)+mdf_eo(indmax)))),
        % artifact is in fr_even
        if art_row_mask_opo(indmax) && art_row_mask_ope(indmax) && sum(art_row_mask_pepo(row_mask))==0
            % there is a good chance fr_odd is compromised too 
            % replace with prev_fr_even
            fr0_even(art_frame_mask) = prev_fr_even(art_frame_mask);
            % also correct odd frame 
            fr0_odd(art_frame_mask) = prev_fr_even(art_frame_mask);
        else
            fr0_even(art_frame_mask) = fr_odd(art_frame_mask);
        end
    elseif (art_row_mask_opo(indmax) && sign(mdf_opo(indmax))~=sign(mdf_eo(indmax)) && (abs(mdf_opo(indmax)+mdf_eo(indmax)) < abs(mdf_epo(indmax)-mdf_eo(indmax)))) || ...
            (art_row_mask_ope(indmax) && sign(mdf_ope(indmax))~=sign(mdf_eo(indmax)) && (abs(mdf_ope(indmax)+mdf_eo(indmax)) < abs(mdf_epe(indmax)-mdf_eo(indmax)))),
        % artifact is in fr_odd
        if art_row_mask_epo(indmax) && art_row_mask_epe(indmax) && sum(art_row_mask_pepo(row_mask))==0   
            % there is a good chance fr_even is compromised too 
            % replace with prev_fr_even if no artifact
            fr0_odd(art_frame_mask) = prev_fr_even(art_frame_mask);
            % also correct even frame
            fr0_even(art_frame_mask) = prev_fr_even(art_frame_mask);
        else
            fr0_odd(art_frame_mask) = fr0_even(art_frame_mask);
        end
    else
        % artifact is not reproducible; don't correct
    end
end

% figure(1);clf
% subplot(221);imagesc(fr_odd);
% subplot(222);imagesc(fr_even);
% subplot(223);imagesc(fr0_odd);
% subplot(224);imagesc(fr0_even);
% pause
% figure(2);clf;hold on;
% plot(mdf_eo,1:length(mdf_eo),'k');
% plot(mdf_epo,1:length(mdf_eo),'r');
% plot(-mdf_opo,1:length(mdf_eo),'b');axis ij;

% Reconstitute corrected frame pair
fr0_pair = cat(3,fr0_odd,fr0_even);

if DEBUG
    
    figure(11); clf; colormap(gray);
    subplot(321), imagesc(fr_odd); axis image; title('Odd frame');
    subplot(323), imagesc(fr_even); axis image; title('Even frame');
    subplot(325), imagesc(df_eo); axis image; title('Difference');
    
    subplot(322), imagesc(fr0_odd); axis image; title('Odd frame corrected');
    subplot(324), imagesc(fr0_even); axis image; title('Even frame corrected');
    
    r = 1:n_rows;
    mdf_art = mdf_eo;
    mdf_art(~art_row_mask_eo) = NaN;
    
    subplot(326), plot(r, mdf_eo);
    set(gca,'YLim',[-1 1]);
    hold on
    subplot(326), plot(r, mdf_art, 'r', 'linewidth', 2);
    hold off
    
end
