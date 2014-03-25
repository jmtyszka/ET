function glint = ET_IdentifyMainGlint(bw_glint, p, options)
% Select best candidate for main glint from glints list
% - allow for saturated glint ring down (L-R raster)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/22/2013 JMT From scratch
%          04/30/2013 JMT Add glint saturation tail handling
%          01/28/2014 JMT Increased maximum glint radius to 16 for Wolfgang
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
% Copyright 2013-2014 California Institute of Technology.

if nargin < 3; options.debug = false; end

% Init glint return structure
glint.gx    = NaN;
glint.gy    = NaN;
glint.d_eff = NaN;

% Detect glint boundaries
[B_glint, L_glint] = bwboundaries(bw_glint, 'noholes');

% Number of glint candidates in frame
n_glints = length(B_glint);

% Identify glint object
if n_glints > 0
    
    % Bounding box for each glint
    % Comet artifact is guaranteed x oriented (L-R raster)
    rp = regionprops(L_glint,'BoundingBox');
    
    % Pupil centroid within ROI
    px = p.px;
    py = p.py;
    
    % Allocate corrected glint centroid and radius
    gx = zeros(1,n_glints);
    gy = zeros(1,n_glints);
    gr = zeros(1,n_glints);
    
    for bc = 1:n_glints
        
        % Bounding box returned as [xmin, ymin, w, h]
        bb = rp(bc).BoundingBox;
        
        % Parse bounding box
        bb_x0 = bb(1);
        bb_y0 = bb(2);
        bb_w  = bb(3);
        bb_h  = bb(4);

        % RESOLVED
        % 2014-03-24 JMT,JD
        % Adopt Julien Dubois' algorithm for judging orientation of
        % comet-tailed glint (due to burn-in effects on old ResTech IR
        % camera). The true glint is the head of the "comet". Once the
        % comet orientation has been determined, the center of the head can
        % be estimated from the height or width of the bounding box.
        % Drop asymmetry metric - it's difficult to normalize. Just use BB
        % aspect ratio.
        
        % Extract binary image within glint BB
        glint_bb = bw_glint(floor(bb_y0):ceil(bb_y0+bb_h),floor(bb_x0):ceil(bb_x0+bb_w));
        
        % Glint aspect ratio
        glint_ar = bb_w / (bb_h + eps);
        
        % Determine most asymmetric dimension (in terms of projection)
        if glint_ar > 1

            % Horizontal comet (AR > 1)
            
            if options.debug
                fprintf('GLINT : horizontal comet (%0.1f)\n', glint_ar);
            end
            
            % Half height of BB - actual glint radius
            glint_r = bb_h/2;
            
            tmpleft  = sum(sum(glint_bb(:,1:floor(end/2))));
            tmpright = sum(sum(glint_bb(:,ceil(end/2):end)));
            
            if tmpleft > tmpright
                gx(bc) = bb_x0 + glint_r;
            else
                gx(bc) = bb_x0 + bb_w - glint_r;
            end
            
            gy(bc) = bb_y0 + glint_r;
            gr(bc) = glint_r;
            
        else
            
            % Vertical comet (AR <= 1)
            
            if options.debug
                fprintf('GLINT : vertical comet (%0.1f)\n', glint_ar);
            end
            
            % Half width of BB - actual glint radius
            glint_r = bb_w/2;
            
            tmplower = sum(sum(glint_bb(:,1:floor(end/2))));
            tmpupper = sum(sum(glint_bb(:,ceil(end/2):end)));
            
            if tmplower > tmpupper
                gy(bc) = bb_y0 + glint_r;
            else
                gy(bc) = bb_y0 + bb_h - glint_r;
            end
            
            gx(bc) = bb_x0 + glint_r;
            gr(bc) = glint_r;
            
        end
       
    end
    
    % Glint-pupil vector components - glint below pupil in video has gpvy < 0
    gpvx = px-gx;
    gpvy = py-gy;
    
    % Glint to pupil centroid distance
    d = sqrt(gpvx.^2 + gpvy.^2);
    
    % Select glints by area
    % TODO: probably should improve this criterion; should not allow glint
    % to be outside of the eyeball, for instance...
    % 2014-01-28 JMT Increased glint radius limit to 16 pixels for Wolfgang
    
    good_glints = find(gr < 16 & gpvy < 0);
    
    if ~isempty(good_glints)
        
        d_good = d(good_glints);
        
        % Find good glint closest to pupil centroid
        [~, imin] = min(d_good);
        
        % Get original index of best glint
        best_glint = good_glints(imin);
        
        % Load return glint structure
        glint.gx = gx(best_glint);
        glint.gy = gy(best_glint);
        glint.d_eff = 2 * gr(best_glint);
        
    else
        
        % No good glints found
        
    end
    
end
