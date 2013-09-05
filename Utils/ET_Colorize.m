function rgb = ET_Colorize(s, cmap)
% Colorize scalar image using a colormap
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/27/2013 JMT From scratch
%
% Copyright 2013 California Institute of Technology
% All rights reserved

% Image size
[ny, nx] = size(s);

% Number of color levels
ncol = size(cmap,1);

% Map s to range 1..ncol
smin = min(s(:));
smax = max(s(:));
s = fix((s - smin) / (smax - smin) * (ncol - 1)) + 1;

% Create colorized RGB image
rgb = cmap(s(:), :);

% Reshape to original image size
rgb = reshape(rgb, [ny nx 3]);
