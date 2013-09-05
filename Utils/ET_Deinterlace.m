function [fr_odd, fr_even] = ET_Deinterlace(fr)
% Redraw and save video ROI definition
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/07/2013 JMT From scratch
%
% Copyright 2013 California Institute of Technology
% All rights reserved.

% Flags
do_even_correction = false;

% Deinterlace into odd and even rows
% Downsample rows to preserve aspect ratio
fr_A = fr(1:2:end,1:2:end);
fr_B = fr(2:2:end,1:2:end);

%% Even frame position correction

if do_even_correction
  
  [nr,nc] = size(fr_B);
  
  % Transpose to place rows in first dimension
  fr_B = fr_B';
  
  fr_1 = fr_B(:,1);
  fr_n = fr_B(:,nr);
  fr_flat = fr_B(:);
  
  % Place flattened rows into first and second column of B
  % First column is padded at top, second column is padded at bottom
  B = zeros((nr + 1) * nc, 2);
  B(:,1) = [ fr_1; fr_flat ];
  B(:,2) = [ fr_flat; fr_n ];
  
  % Row mean
  Bm = mean(B,2);
  Bm = reshape(Bm(1:(nr * nc)), [nc nr]);
  
  fr_odd  = fr_A;
  fr_even = Bm';
  
else
  
  fr_odd = fr_A;
  fr_even = fr_B;
  
end
