function handles = ET_InitVideo(vname, handles)
% Initialize gaze video analysis
% - Load first frame
% - Locate pupil and generate ROI
% - Apply correct rotation to ROI
% - Display first frame pupilometry in GUI
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 12/18/2012 JMT Extract from ET_LoadEverything.m
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
% Copyright 2013 California Institute of Technology

% Check that video file exists
if ~exist(vname, 'file')
    fprintf('ET : Could not find %s\n', vname);
    return
end

% Create input video object
try
    switch computer
        
        case {'PCWIN','PCWIN64'}
            
            % Matlab built-in
            v_in = VideoReader(vname);
            
        case 'GLNXA64'
        
            % Matlab built-in
            v_in = VideoReader(vname);
            
        case 'MACI64'
            
            % VideoUtils package
            v_in = VideoPlayer(vname, 'Verbose', false, 'ShowTime', false);
    
    end
    
catch VIDEO_IN_OPEN
    
    fprintf('ET : *** Problem opening input video file\n');
    rethrow(VIDEO_IN_OPEN);
    
end

% Load video frame
fr = ET_LoadFrame(v_in, 1);

% Save first frame as video poster frame
handles.video_poster_frame = fr;

% Close video file
clear v_in

% Update poster frame in GUI
handles = ET_UpdatePosterFrame(handles);

