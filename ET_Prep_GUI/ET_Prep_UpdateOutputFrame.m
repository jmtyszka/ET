function ET_Prep_UpdateOutputFrame(handles)
% Refresh image in output frame using current ROI parameters
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 2014-01-28 JMT From scratch
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

% Get raw poster frame
if isfield(handles,'poster_frame_pair')

  % Deinterlace, apply ROI, etc
  out_fr_pair = ET_Prep_ApplyROI(handles, handles.poster_frame_pair);
  
  % Show processed odd frame in GUI
  imshow(out_fr_pair(:,:,1), [0,255], 'parent', handles.Output_Frame);
  drawnow
  
end
