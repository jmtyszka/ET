function err = EOF2(ParA, x, y)
% EOF2 cost function from Rosin's survey
% See Swirski et al 2012 for more details
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/26/2013 JMT Implement from Swirksi
%                     JMT Add analytic gradient of Q
%
% Copyright 2013 California Institute of Technology
% All rights reserved

if isempty(ParA)
  err = [];
  return
end

% Force column vectors
x = x(:);
y = y(:);
ParA = ParA(:);

% Number of points
n = length(x);

% Design matrix
X = [ x.^2, x.*y, y.^2, x, y, ones(n, 1) ];

% Algebraic point to ellipse distance
Q = X * ParA;

% Analytic gradient of Q
dQ_dx = 2*ParA(1)*x + ParA(2)*y + ParA(4);
dQ_dy = ParA(2)*x + 2*ParA(3)*y + ParA(5);
absgradQ = sqrt(dQ_dx.*dQ_dx + dQ_dy.*dQ_dy);

% EOF2 cost function without scaling
err = Q ./ absgradQ;




