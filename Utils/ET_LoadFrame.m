function fr = ET_LoadFrame(v_in, currentFrame)
% Load single or interlaced frame pair from video object
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/05/2013 JMT From scratch
%          01/24/2014 JMT Add Wolfgang Pauli's exception handling for progressive
%          02/05/2014 JMT Switch to progressive only (ET_Prep deinterlaces)
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

if nargin < 1; fr = []; return; end
if nargin < 2, currentFrame = 1; end

% Init return frame
fr = [];

% Flags
do_intensity_normalize = true;

% Platform dependent video frame read

switch computer
    
    case {'GLNXA64','PCWIN','PCWIN64'}
        
        % Windows/Linux video IO
        
        try
            
            % Read single progressive frame
            fr = double(read(v_in, currentFrame));
            
        catch
            fprintf('ET_LoadFrame : problem reading video frame\n');
            return
        end
        
    case 'MACI64'
        
        % Use VideoUtils_v1.2.4 for Mountain Lion onwards
        try
            
            % Read single progressive frame
            fr = v_in.Frame;
            
            % Increment stream counter
            v_in = v_in + 1;
            
        catch
            
            fprintf('ET_LoadFrame : problem reading video frame\n');
            return
            
        end
        
    otherwise
        
        fprintf('ET_LoadFrame : unsupported architecture (%s)\n', computer);
        return
        
end

% Average color channels
fr = mean(fr,3);

% Optional intensity range normalization to [0,1]
if do_intensity_normalize
    
    min_fr = min(fr(:));
    max_fr = max(fr(:));
    fr = (fr - min_fr) / (max_fr - min_fr);
    
end
