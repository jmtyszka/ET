function pupils = ET_Video_Pupilometry(video_infile, video_outfile, pupils_file, p_init, C, handles)
% Perform pupilometry on all frames of a video
%
% USAGE : pupils = ET_Video_Pupilometry(video_infile, pupils_file, video_outfile, p_init, C, handles)
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
% Copyright 2011-2013 California Institute of Technology

% Defaults
if nargin < 5; C = []; end
if nargin < 6; handles = []; end

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
        
        case {'PCWIN','PCWIN4'}
            v_in = VideoReader(video_infile);
            
        case {'GLNXA64'}
            v_in = VideoReader(video_infile);
            
        case {'MACI64'}
            v_in = VideoPlayer(video_infile, 'Verbose', false, 'ShowTime', false);
            
        otherwise
            fprintf('ET_Video_Pupilometry : *** Unknown platform (%s)\n', computer);
            return
            
    end
    
catch VIDEO_IN_OPEN
    
    fprintf('ET_Video_Pupilometry : *** Problem opening input video file\n');
    rethrow(VIDEO_IN_OPEN);
    
end

% Create output video object
% Use video_infile to generate a file stub
try
    if ~ismac
        v_out = VideoWriter(video_outfile);
        open(v_out);
    else
        v_out = VideoRecorder(video_outfile, 'Format', 'mov', 'Size', [256 256]);
    end
    
catch VIDEO_OUT_OPEN
    
    fprintf('*** Problem opening output video file\n');
    rethrow(VIDEO_OUT_OPEN);
    
end

% Get input video info
% Calculate frame count, FPS and frame time after interleaved to
% progressive conversion
switch computer
    
    case {'PCWIN','PCWIN64'}
        n_frames = v_in.NumberOfFrames;
        fps = v_in.FrameRate;
        
    case {'GLNXA64'}
        n_frames = v_in.NumberOfFrames;
        fps = v_in.FrameRate;
        
    case 'MACI64'
        n_frames  = v_in.NumFrames;
        fps = v_in.FramesPerSecond;
        
    otherwise
        fprintf('ET_Video_Pupilometry : *** Unknown platform (%s)\n', computer);
        return
        
end

% Setup refine pupil options from GUI
options = ET_GetRefinePupilOptions(handles);

%% Start scanning for pupils

fprintf('Processing %s\n', video_infile);

% Preallocate pupil structure array covering all frames
pupils(1:n_frames) = ET_NewPupil;

% Running frame count
fc = 1;

%% MAIN LOOPS

% Init running pupil structure
p_run = p_init;

% Init progress bar
if ~isempty(handles.Progress_Bar)
    set(handles.Progress_Bar,'Value', 0);
end

% Reinit gaze axes
% Plot 10, 50 and 90% ticks
if ~isempty(C)
    ET_PlotGaze([], handles.Gaze_Axes, 'init');
end

% Start splash
fprintf('--------------------------\n');
fprintf('Video pupilometry started at %s\n', datestr(now));

% Start timer for processed FPS
tic;

% Loop over interlaced frame pairs of movie
keep_going = true;

while keep_going
    
    fr = ET_LoadFrame(v_in, fc);
    
    if isempty(fr)
        % may happen in the progressive case
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
    
    if mod(fc,10) == 0
        
        % Overlay pupil, glint and ROI onto frame image
        pupil_overlay = ET_OverlayPupil(fr, p_run);
        imshow(pupil_overlay, [0,255], 'parent', handles.Eye_Video_Axes);
        
        % Show calibrated gaze position in GUI if calibration model exists
        if ~isempty(C)
            ET_PlotGaze(p_run, handles.Gaze_Axes, 'plot');
        end
        
        drawnow;
        
        % Write frame to output video file
        %%% edit JD 9/26/13
        if ~ismac
            writeVideo(v_out,pupil_overlay);
        else
            v_out.addFrame(pupil_overlay);
        end
        %%%
        % Update progress bar
        if ~isempty(handles.Progress_Bar)
            set(handles.Progress_Bar,'Value', fc/n_frames);
        end
        
        % Show current threshold in GUI
        set(handles.Pupil_Threshold,'String',sprintf('%0.3f', p_run.thresh));
        
        % Set threshold to NaN to refresh pupil threshold on next frame
        p_run.thresh = NaN;
        
    end
    
    % Check for stop button press
    handles = guidata(handles.Main_Figure);
    if handles.stop_pressed
        
        % Reset stop button flag and exit loop
        fprintf('ET : Stop detected in video pupilometry - exiting\n');
        handles.stop_pressed = false;
        break
        
    end
    
    video_mode = 'interlaced';
    switch video_mode
        case 'interlaced'
            fc = fc + 1;
        case 'progressive'
            fc = fc + 2;
    end
end % Movie loop

% Stop timer
tt = toc;

% Complete progress bar
if ~isempty(handles.Progress_Bar)
    set(handles.Progress_Bar,'Value', 1);
end

if ~ismac
    close(v_out);
end

% Report processing metrics
fprintf('--------------------------\n');
fprintf('Video pupilometry finished at %s\n', datestr(now));
fprintf('Total time : %0.1f s\n', tt);
fprintf('Mean rate  : %0.1f fps\n', n_frames * 2 / tt);

% Save pupilometry results in Gaze subdirectory
save(pupils_file,'pupils');

% Clean up
clear v_in
clear v_out

fprintf('Done\n');
end
