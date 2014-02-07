function [fr_pair, handles] = ET_Prep_LoadFramePair(v_in,handles)
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 2014-01-29 JMT From scratch
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
% Copyright 2014 California Institute of Technology

% Init return frame
fr_pair = [];

% Check for empty video object
if isempty(v_in)
    return
end

% Load input video frame
try
    switch computer
        
        case {'GLNXA64','PCWIN','PCWIN64'}
            
            % Read interlaced frame
            fr = double(read(v_in, handles.currentFrame));
            
            % Normalize intensity to [0,1]
            % PC and Linux frame values are in range [0,255]
            fr = fr / 255.0;
            
        case 'MACI64'
            
            % Read interlaced frame
            fr = v_in.Frame;
            
        otherwise
            
            fprintf('ET_LoadFramePair : unsupported architecture (%s)\n', computer);
            return
            
    end
catch
    fprintf('ET_Prep : problem loading input video frame pair\n');
    return
end

% Increment input video frame
switch computer
    
    case {'GLNXA64','PCWIN','PCWIN64'}
        handles.currentFrame = handles.currentFrame + 1;
        
    case 'MACI64'
        
        v_in + 1;
        
    otherwise
        
        fprintf('ET_LoadFramePair : unsupported architecture (%s)\n', computer);
        return
        
end

% Collapse color channels
fr = mean(fr,3);

% Deinterlace into pair of downsampled frames
fr_pair = ET_Prep_Deinterlace(fr);
