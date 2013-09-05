function pupils = ET_Video_Pupilometry(video_infile, video_outfile, pupils_file, roi, p_init, C, do_mrclean, handles)
% Perform pupilometry on all frames of a video
%
% USAGE : pupils = ET_Video_Pupilometry(video_infile, pupils_file, video_outfile, roi, p_init, C, do_mrclean, handles)
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
%
% Copyright 2011-2013 California Institute of Technology
% All rights reserved.

% Defaults
if nargin < 6; C = []; end
if nargin < 7; do_mrclean = false; end
if nargin < 8; handles = []; end

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
  v_in = VideoPlayer(video_infile, 'Verbose', false, 'ShowTime', false);
catch VIDEO_IN_OPEN
  fprintf('ET : *** Problem opening input video file\n');
  rethrow(VIDEO_IN_OPEN);
end

% Create output video object (AVI file)
% Use video_infile to generate a file stub
try
  v_out = VideoRecorder(video_outfile, 'Format', 'mov', 'Size', [256 256]);
catch VIDEO_OUT_OPEN
  fprintf('*** Problem opening output video file\n');
  rethrow(VIDEO_OUT_OPEN);
end

% Get input video info
% Calculate frame count, FPS and frame time after interleaved to
% progressive conversion
n_frames  = v_in.NumFrames;

% Hardcode for now - VideoPlayer doesn't read FPS info from video
video_mode = 'interlaced';   % Assume interlaced source for now
fps_p      = 29.98;          % Progressive frame rate
fps_i      = 2 * fps_p;      % Interlaced frame rate

%% Refine pupil options
refine_options.pupil_se = strel('disk',fix(p_init.pd_eff/8));
refine_options.glint_se = strel('disk',2);

%% Start scanning for pupils

fprintf('Processing %s\n', video_infile);

% Preallocate pupil structure array covering all frames
pupils(1:n_frames) = ET_NewPupil;

% Running progressive frame count
fc = 0;

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

% Start timer for FPS
tic;

% Loop over interlaced frame pairs of movie
for pc = 1:n_frames
  
  fr_pair = ET_LoadFramePair(v_in, video_mode);
  
  % Clean MR artifacts
  if do_mrclean
    fr_pair = ET_MRClean(fr_pair);
  end
  
  % Loop over each interleaved frame
  for ic = 1:2
    
    % Increment frame counter
    fc = fc + 1;
    
    % Current frame
    fr = fr_pair(:,:,ic);
    
    % Refine pupil parameter estimates
    p_new = ET_RefinePupil(fr, roi, p_run, refine_options);
    
    % Add timestamp for this pupil
    switch lower(video_mode)
      case 'interlaced'
        p_new.t = fc / fps_i;
      case 'progressive'
        p_new.t = fc / fps_p;
    end
    
    if ~isempty(C)
      
      % Use appropriate calibration matrix for pupil-only or pupil-glint
      [p_new.gaze_x, p_new.gaze_y] = ET_ApplyCalibration([p_new.px], [p_new.py], C);
      
    end

    
    % Save pupil in array
    pupils(fc) = p_new;
    
    % New pupil becomes running pupil
    p_run = p_new;
    
  end % Frame interleaf loop
  
  % Update progress every 10 progressive frames
  
  if mod(fc,10) == 0
    
    % Overlay pupil, glint and ROI onto frame image
    pupil_overlay = ET_OverlayPupil(fr, roi, p_run);
    imshow(pupil_overlay, 'parent', handles.Eye_Video_Axes);
    
    % Show calibrated gaze position in GUI
    if ~isempty(C)
      ET_PlotGaze(p_run, handles.Gaze_Axes, 'plot');
    end
    
    drawnow;
    
    % Write frame to output video file
    v_out.addFrame(pupil_overlay);
    
    % Update progress bar
    if ~isempty(handles.Progress_Bar)
      set(handles.Progress_Bar,'Value', pc/n_frames);
    end
    
    % Show current threshold in GUI
    set(handles.Pupil_Threshold,'String',sprintf('%0.3f', p_run.thresh));
    
    % Set threshold to NaN to refresh pupil threshold on next frame
    p_run.thresh = NaN;
    
  end
  
end % Movie loop

% Stop timer
tt = toc;

% Complete progress bar
if ~isempty(handles.Progress_Bar)
  set(handles.Progress_Bar,'Value', 1);
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
