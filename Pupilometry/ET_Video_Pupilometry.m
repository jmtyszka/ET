function [pupils, stop_pressed] = ET_Video_Pupilometry(video_infile, video_outfile, pupils_file, p_init, C, handles)
% Perform pupilometry on all frames of a video
%
% USAGE : [pupils, stop_pressed] = ET_Video_Pupilometry(video_infile, pupils_file, video_outfile, p_init, C, handles)
%
% - find pupil and fit ellipse
% - find main glint and fit circle
% - return all fitted parameters in an array of pupil structures
%
% Note that return argument is pupils structure, not updated handles
% Allows function to be used for both calibration and tracking
% Remember to store returned pupils structure in handles
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 10/14/2011 JMT From scratch
%          09/12/2012 JMT Integrate with GUI
%          01/17/2013 JMT Integrate Starburst-RANSAC functions
%          01/28/2013 JMT Rewrite to allow standalone operation
%          02/01/2013 JMT Switch to VideoUtils for I/O
%          04/18/2013 JMT Add glint use for moco
%          09/26/2013  JD use VideoWriter instead of VideoRecorder
%          02/07/2014 JMT Add multiplatform video I/O
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
% Copyright 2011-2014 California Institute of Technology

% Defaults
if nargin < 5; C = []; end
if nargin < 6; handles = []; end

% Init stop button flag
stop_pressed = false;

% Containing directory for video file
dir_name = fileparts(video_infile);
if isempty(dir_name)
    dir_name = pwd;
end

% Check for Gaze subdirectory
gaze_dir = fullfile(dir_name, 'Gaze');
if ~exist(gaze_dir,'dir')
    fprintf('ET : Creating Gaze subdirectory\n');
    mkdir(gaze_dir);
end

%% Setup videos

% Create input video object
try
    
    switch computer
        
        case {'PCWIN','PCWIN4','GLNXA64'}
            v_in = VideoReader(video_infile);
            n_frames = v_in.NumberOfFrames;
            fps = v_in.FrameRate;
            
        case {'MACI64'}
            v_in = VideoPlayer(video_infile, 'Verbose', false, 'ShowTime', false);
            n_frames = v_in.NumFrames;
            
            % VideoUtils does not support non-integer fps
            % Get true fps from conversion info file
            [v_path, v_stub, ~] = fileparts(video_infile);
            info_file = fullfile(v_path, [v_stub '_Prep.mat']);
            
            if exist(info_file,'file');
                load(info_file);
                fps = info.fps_p;
            else
                % Default deinterlaced NTSC (2 x 29.97 fps)
                fps = 59.94;
            end
            
        otherwise
            fprintf('ET_Video_Pupilometry : *** Unknown platform (%s)\n', computer);
            return
            
    end
    
catch VIDEO_IN_OPEN
    
    fprintf('ET_Video_Pupilometry : *** Problem opening input video file\n');
    rethrow(VIDEO_IN_OPEN);
    
end

% Create output video object
try
    
    switch computer
        
        case {'PCWIN','PCWIN64','GLNXA64'}
            v_out = VideoWriter(video_outfile);
            open(v_out);
            
        case 'MACI64'
            
            % Get size of video frame from GUI
            [frh, frw] = size(handles.video_poster_frame);
            
            v_out = VideoRecorder(video_outfile, 'Format', 'mp4', 'Size', [frh frw]);
            
    end
    
catch VIDEO_OUT_OPEN
    
    fprintf('ET_Video_Pupilometry : *** Opening output video %s : %s\n', ...
        video_outfile, VIDEO_OUT_OPEN.identifier);
    rethrow(VIDEO_OUT_OPEN);
    
end

% Setup refine pupil options from GUI
options = ET_GetRefinePupilOptions(handles);

%% Start scanning for pupils

fprintf('Processing %s\n', video_infile);

% Preallocate pupil structure array covering all frames
pupils(1:n_frames) = ET_NewPupil;

%% MAIN LOOPS

% Init running pupil structure
p_run = p_init;

% Initialize axes and running heat map
if ~isempty(C)
    running_hmap = ET_PlotGaze([], handles.Gaze_Axes, []);
end

% Start splash
fprintf('--------------------------\n');
fprintf('Video pupilometry started at %s\n', datestr(now));

% Start timer for processed FPS
t0 = tic;

for fc = 1:n_frames
    
    % Load single frame from video stream
    fr = ET_LoadFrame(v_in, fc);
    
    % Break out of for loop if empty frame returned
    if isempty(fr)
        break
    end
    
    % Refine pupil parameter estimates
    p_new = ET_RefinePupil(fr, p_run, options);
    
    % Add timestamp for this pupil
    p_new.t = fc / fps;
    
    if ~isempty(C)
        % Use appropriate calibration matrix for pupil-only or pupil-glint
        [p_new.gaze_x, p_new.gaze_y] = ET_ApplyCalibration([p_new.px], [p_new.py], C);
    end
    
    % Save pupil in array
    pupils(fc) = p_new;
    
    % New pupil becomes running pupil
    p_run = p_new;
    
    % Update progress every 10 progressive frames
    if mod(fc, 10) == 0
        
        % Overlay pupil, glint and ROI onto frame image
        pupil_overlay = ET_OverlayPupil(fr, p_run);
        imshow(pupil_overlay, 'parent', handles.Eye_Video_Axes);
        
        % Show calibrated gaze position in GUI if calibration model exists
        if ~isempty(C)
            running_hmap = ET_PlotGaze(p_run, handles.Gaze_Axes, running_hmap);
        end
        
        % Update GUI
        drawnow
        
        % Write frame to output video file
        %%% edit JD 9/26/13
        if ismac
            v_out.addFrame(pupil_overlay);
        else
            writeVideo(v_out, pupil_overlay);
        end
        
        % Update progress panel
        set(handles.Frame_Number,'String',sprintf('%05d / %05d', fc, n_frames));
        set(handles.Percent_Complete,'String',sprintf('%0.1f %%', fc/n_frames * 100));
        set(handles.Processing_Speed,'String',sprintf('%0.1f fps', fc / toc(t0)));
        
        % Show current threshold in GUI
        set(handles.Pupil_Threshold,'String',sprintf('%0.3f', p_run.thresh));
        
        % Set threshold to NaN to refresh pupil threshold on next frame
        p_run.thresh = NaN;

        % Check for stop button press
        tmp = guidata(handles.Main_Figure);
        if tmp.stop_pressed
            stop_pressed = true;
            fprintf('ET : Stop button pressed - exiting pupilometry\n');
            return
        end
            
    end
    
end % Movie loop

% Stop timer
tt = toc(t0);

% Report processing metrics
fprintf('--------------------------\n');
fprintf('Video pupilometry finished at %s\n', datestr(now));
fprintf('Total time : %0.1f s\n', tt);
fprintf('Mean rate  : %0.1f fps\n', n_frames / tt);

% Save pupilometry results in Gaze subdirectory
save(pupils_file, 'pupils');

% Clean up
if ismac
    clear v_in v_out
else
    close(v_out);
end

fprintf('ET : Completed pupilometry\n');
