function C = ET_CalibrationFit(fx, fy)
% Biquadratic fit to grid ordered calibration fixation centroids
%
% ARGS :
% ET_CalFixGrid = structure containing grid ordered fixation centroids
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 11/01/2012 JMT From scratch
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


% Number of fixations
n_fix = length(fx);

notnan=~isnan(fx);

switch n_fix
  
    case 4
    
    % BILINEAR CALIBRATION MODEL
    %
    % We need to solve the matrix equation C * R = R0
    % C = bilinear coefficients (2 x 3)
    % R = binomial coordinate matrix (3 x 4) - one column per fixation
    % R0 = corrected screen coordinates (2 x 4)
    %
    % Six bilinear coefficients : x, y, 1
    %
    % R has rows x_i, y_i, 1 (i = 1..n)
    % x0_j = R_1j = C11 * x_j + C12 * y_j + C13
    % y0_j = R_2j = C21 * x_j + C22 * y_j + C23
    
    % Construct R
    R = [ fx; fy; ones(1,n_fix) ];
    
    % Moore-Penrose pseudoinverse of R
    Rinv = pinv(R);
    
    % Fractional gaze coordinates (book-style ordering)
    % Use percent full screen for calibrated coordinates
    %
    % Grid Point Arrangement (note L-R flip for subject)
    %     0.1 0.9
    % 0.9  2   1 
    % 0.1  4   3
    
    x0 = [0.1 0.9 0.1 0.9];
    y0 = [0.9 0.9 0.1 0.1];
  
  case 9
    
    % BIQUADRATIC CALIBRATION MODEL
    %
    % We need to solve the matrix equation C * R = R0
    % C = biquadratic coefficients (2 x 6)
    % R = binomial coordinate matrix (6 x 9) - one column per centroid
    % R0 = corrected screen coordinates (2 x 9)
    %
    % Twelve biquadratic coefficients: x2, xy, y2, xy, x, y, 1
    %
    % R has rows x2_i, xy_i, y2_i, x_i, y_i, 1 (i = 1..9)
    % x0_j = R_1j = C11 * x_j^2 + C12 * x_j * y_j + ... + C16
    % y0_j = R_2j = C21 * x_j^2 + C22 * x_j * y_j + ... + C26
    
    % Additional binomial coordinates
    fx2 = fx .* fx;
    fy2 = fy .* fy;
    fxy = fx .* fy;
    
    % Construct R
    R = [ fx2; fxy; fy2; fx; fy; ones(1,n_fix) ];
    
    % Moore-Penrose pseudoinverse of R
    Rinv = pinv(R (:,notnan));
    
    % Fractional gaze coordinates (book-style ordering)
    % Use percent full screen for calibrated coordinates
    %
    % Grid Point Arrangement
    %     0.1 0.5 0.9
    % 0.9   3   2   1
    % 0.5   6   5   4
    % 0.1   9   8   7
    
    x0 = [0.9 0.5 0.1 0.9 0.5 0.1 0.9 0.5 0.1];
    y0 = [0.9 0.9 0.9 0.5 0.5 0.5 0.1 0.1 0.1];
    
    x0= x0(notnan);
    y0= y0(notnan);
    
  otherwise
    
    fprintf('Unsupported calibration model : %d points\n', n_fix);
    
end

% Construct R0 from flattened coordinate matrices
R0 = [x0; y0];

% Solve for C
C = R0 * Rinv;
