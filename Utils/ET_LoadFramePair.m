function [fr_pair, keep_going] = ET_LoadFramePair(v_in, imode, currentFrame)
% Load single or interlaced frame pair from video object
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/05/2013 JMT From scratch
%          01/24/2014 JMT Add Wolfgang Pauli's exception handling for progressive
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

if nargin < 1; fr_pair = []; return; end
if nargin < 2; imode = 'interlaced'; end
if nargin < 3, currentFrame = 1; end

fr_pair=[];

% Flags
do_intensity_normalize = false;

% Get raw video frame size
nx0 = v_in.Width;
ny0 = v_in.Height;

% Handle interlaced and progressive frames
switch lower(imode)
    case 'interlaced'
        
        % Load one frame from raw video (interlaced or progressive)
        if ~ismac
            fr = (read(v_in, currentFrame));
            keep_going = (currentFrame+1)<=v_in.NumberOfFrames;
        else
            fr = v_in.Frame;
            keep_going = v_in.nextFrame;
        end
        % Collapse RGB to scalar doubles
        fr = mean(fr,3);
        
        % Deinterlace with row position correction
        [fr_odd, fr_even] = ET_Deinterlace(fr);
        
    case 'progressive'
        
        % Load two frames from progressive video
        
        switch computer
            
            case {'GLNXA64','PCWIN','PCWIN64'}
                    
                % Windows/Linux video IO
                % Handle lack of second frame in pair using try-catch
                % Thanks Wolfgang!
                
                keep_going = true;
                
                try
                    fr_odd = (read(v_in, currentFrame));
                catch
                    fprintf('ET_LoadFramePair : problem reading odd frame\n');
                    keep_going = false;
                    return
                end

                try
                    fr_even = (read(v_in, currentFrame+1));
                catch
                    fprintf('ET_LoadFramePair : problem reading even frame\n');
                    keep_going = false;
                    return
                end
                
            case 'MACI64'
                
                % Use VideoUtils_v1.2.4 for Mountain Lion onwards
                fr_odd = v_in.Frame;
                keep_going = v_in.nextFrame;
                
                if keep_going
                    fr_even = v_in.Frame;
                    keep_going = v_in.nextFrame;
                else
                    return;
                end
                
            otherwise
                
                fprintf('ET_LoadFramePair : unsupported architecture (%s)\n', computer);
                return
                
        end
        
        % Collapse RGB to scalar doubles
        fr_odd = mean(fr_odd,3);
        fr_even = mean(fr_even,3);
        
    otherwise
        
        % Return empty frames
        fr_odd = nan(ny0, nx0);
        fr_even = fr_odd;
        keep_going = false;
        
end

% Stack frame pair in 3rd dimension
% Even frame comes first in time
fr_pair = cat(3,fr_even,fr_odd);

if ~ismac
    fr_pair=fr_pair/255;
end

% Normalize intensities to range [0,1]
if do_intensity_normalize
    min_fr = min(fr_pair(:));
    max_fr = max(fr_pair(:));
    fr_pair = (fr_pair - min_fr) / (max_fr - min_fr);
end
