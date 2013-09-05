function p_fit = ET_FitEllipse_RANSAC(bw_pupil, p_init)
% Ellipse fit using Random Sample Consensus (RANSAC)
% - implements approach of Swirski et al
% - use Matlab bwmorph 'remove' operator to isolate edges
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/25/2013 JMT Implement from Swirski and Gal ellipse fit
%                         Switch to bwmorph/remove for edges
%
% REFERENCES : Swirski L, Bulling A and Dodgson N 2012
%
% Copyright 2013 California Institute of Technology
% All rights reserved.

% Flags
DEBUG = false;

rgb_in = repmat(double(bw_pupil), [1 1 3]);

% Init pupil structure
p_fit = p_init;

% Number of RANSAC and refinement iterations
n_ransac = 10;
n_refines = 2;

% Simple edge voxel identification
edges = bwmorph(bw_pupil,'remove');

% Size of image
[ny, nx] = size(edges);

% Extract indices of edge points
edge_inds = find(edges);

% Edge point coords
[y, x] = ind2sub([ny nx], edge_inds);

% Number of edge points
n_edge = length(edge_inds);

if n_edge < 5
  return
end

% Init iteration variables
iter = 1;
keep_going = true;
best_support = -Inf;
best_ellipse = [1 1 1 1 0];

while keep_going
  
  % Random sample of 5 edge points
  samp = randsample(n_edge,5);
  xs = x(samp);
  ys = y(samp);
  
  % Fit conic-form ellipse to edge sample
  [ParG, ParA] = fitellipse(xs, ys);
  
  if DEBUG && ~isempty(ParA)
    
    figure(10);
    
    cx = ParG(1);
    cy = ParG(2);
    ra = ParG(3);
    rb = ParG(4);
    phi = ParG(5);
    
    % Plot final ellipse over BW image
    rgb_out = ET_DrawEllipse(rgb_in, [1 0 0 ], ra, rb, phi, cx, cy);
    imshow(rgb_out);
    
    % Overlay sample points
    hold on
    plot(xs,ys,'o');
    hold off
    drawnow
    
    rgb_in = rgb_out;
    
  end
  
  % Refine inliers
  for rc = 1:n_refines
    
    if keep_going
      
      % Absolute EOF2 cost function over all edge points
      cost = abs(EOF2(ParA, x, y));
      
      if ~isempty(cost)
        
        % Identify inliers from EOF2
        inliers = cost < 1;
        n_in = sum(inliers);
        
        % Early termination for > 95% inliers
        if n_in / n_edge > 0.95
          if DEBUG; fprintf('ET : inlier condition met\n'); end
          keep_going = false;
        else
          % Rerun ellipse fit on inliers
          [ParG, ParA] = fitellipse(x(inliers), y(inliers));
        end
        
      end
      
    end
    
  end
  
  % Image-based ellipse support would go here
  % Use 1 / absolute EOF2 for now
  support = sum(1 / (abs(EOF2(ParA, x, y)) + eps));
  if support > best_support
    if DEBUG; fprintf('Best support : %0.3f\n', support); end
    best_support = support;
    best_ellipse = ParG;
  end
  
  % Increment iteration counter
  iter = iter + 1;
  
  % Set exit flag if iteration maximum exceeded
  if iter > n_ransac
    keep_going = false;
  end
  
end

% Fill missing fields in pupil structure
p_fit.px  = best_ellipse(1);
p_fit.py  = best_ellipse(2);
p_fit.ra  = best_ellipse(3);
p_fit.rb  = best_ellipse(4);
p_fit.phi = best_ellipse(5); % Radians

% Derived parameters
p_fit.area = pi * p_fit.ra * p_fit.rb;
p_fit.area_correct = pi * (p_fit.ra)^2;
p_fit.pd_eff = 2 * sqrt(p_fit.ra * p_fit.rb);

% Eye-camera angle from ratio of semiminor to semimajor axes
p_fit.eye_camera_angle = acos(p_fit.rb / p_fit.ra) * 180/pi;

% Set blink flag if no candidate meet criteria
p_fit.blink = false;
