function rgb_out = ET_DrawLine(rgb_in, col, xx, yy)
% Draw a colored line into an RGB image
%
% AUTHOR : Mike Tyszka
% PLACE  : Caltech
% DATES  : 02/20/2013 JMT From scratch

% Separate channels
r_in = rgb_in(:,:,1);
g_in = rgb_in(:,:,2);
b_in = rgb_in(:,:,3);

% Image channel dimensions
[ny, nx] = size(r_in);

% Line end point differences
dx = diff(xx);
dy = diff(yy);

% Line length
l = sqrt(dx*dx + dy*dy);

% Catch zero length lines
if l < eps
  rgb_out = rgb_in;
  return
end

% Parameterize the line
t = 0:l;

% Create x and y vectors for line points
x = t/l * dx + xx(1);
y = t/l * dy + yy(1);

% Clamp limits
oob = x < 1 | x > nx | y < 1 | y > ny;
x(oob) = [];
y(oob) = [];

% Map line points to image indices for each channel
inds = sub2ind([ny nx], round(y), round(x));

% Paint line points
r_in(inds) = col(1);
g_in(inds) = col(2);
b_in(inds) = col(3);

% Composite returned RGB image
rgb_out = cat(3,r_in,g_in,b_in);
