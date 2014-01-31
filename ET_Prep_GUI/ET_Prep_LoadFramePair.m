function fr_pair = ET_Prep_LoadFramePair(v_in)
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
    fr = v_in.Frame;
catch
    fprintf('ET_Prep : problem loading input video frame pair\n');
    return
end

% Increment input video frame
v_in + 1;

% Collapse color channels
fr = mean(fr,3);

% Deinterlace into pair of downsampled frames
fr_pair = ET_Prep_Deinterlace(fr);
