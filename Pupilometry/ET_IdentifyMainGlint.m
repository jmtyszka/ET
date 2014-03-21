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
        
        bb = rp(bc).BoundingBox;
        
        % Bounding box returned as [xmin, ymin, w, h]
        % JD : edit 9/28/2013
        % TODO: check this!
        % MT : was assuming height correct, width overestimated 
        % JD think this is likely dependent on how the camera was placed  
        % => be agnostic and determine which is overestimated
        % also need to find out which half of the glint is "weightier"
        tmp = bw_glint(floor(bb(2)):ceil(bb(2)+bb(4)),floor(bb(1)):ceil(bb(1)+bb(3)));
        collapseh = sum(tmp,1);ssh=sum((collapseh-collapseh(end:-1:1)).^2);
        collapsew = sum(tmp,2);ssw=sum((collapsew-collapsew(end:-1:1)).^2);
        
        if ssh > ssw,
            % height should be trusted
            rr=bb(4)/2;
            tmpleft=sum(sum(tmp(:,1:floor(end/2))));
            tmpright=sum(sum(tmp(:,ceil(end/2):end)));
            if tmpleft>tmpright
                gx(bc) = bb(1) + rr;
            else
                gx(bc) = bb(1) + bb(3) - rr;
            end
            gy(bc) = bb(2) + rr;
            gr(bc) = rr;
         else
            % width should be trusted
            rr=bb(3)/2;
            tmptop=sum(sum(tmp(1:floor(end/2),:)));
            tmpbottom=sum(sum(tmp(ceil(end/2):end,:)));
            if tmptop>tmpbottom
                gy(bc) = bb(2) + rr;
            else
                gy(bc) = bb(2) + bb(4) - rr;
            end
            gx(bc) = bb(1) + rr;
            gr(bc) = rr;
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
