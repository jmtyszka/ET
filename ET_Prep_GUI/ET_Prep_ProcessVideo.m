function ET_Prep_ProcessVideo(handles, v_infile, v_outfile)
% Process all frames from the Calibration and Gaze videos
% - outputs two progressive MPEG-4/H.264 video files
% - deinterlaced, MR artifact cleanup, rotation and ROI applied
%
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

% Debug flag
DEBUG = false;

% Fast NLM denoising parameters (empirical)
NLM_patch_size  = 4;
NLM_window_size = 2;
NLM_sigma       = 0.1;

% MR artifact cleanup flag
do_mrclean = get(handles.MR_Clean_Radio,'Value');

% Video denoise flag
do_denoise = get(handles.Denoise_Radio,'Value');

try
    
    switch computer
        
        case {'MACI64','GLNXA64'}
            
            % Open MPEG-2 video stream using VideoUtils library
            v_in = VideoPlayer(v_infile);
            
            % Hardwire NTSC fps (VideoUtils doesn't read this)
            fps_i = 29.97;
            fprintf('ET_Prep_ProcessVideo : forcing NTSC frame rate to %0.2f\n', fps_i);
            
            % Get total interlaced frame count
            n_frames = v_in.NumFrames;
            
        case {'PCWIN','PCWIN64'}
            
            % Open video stream
            v_in = VideoReader(v_infile);
            
            % Get input video parameters
            fps_i = v_in.FrameRate;
            n_frames = v_in.NumberOfFrames;
            
        otherwise
            
            fprintf('ET_Prep_ProcessVideo : Unknown architecture (%s)\n', computer);
            return
            
    end
    
catch VIDEO_READ_ERROR
    
    fprintf('ET_Prep : *** Reading %s : %s\n', v_infile, VIDEO_READ_ERROR.identifier);
    return
    
end

% Remove any extension from video outfile
[v_outpath, v_outstub, ~] = fileparts(v_outfile);
v_outfile = fullfile(v_outpath, v_outstub);

% Get ROI size
ROI_w = fix(str2double(get(handles.ROI_size,'String')));

% Output deinterlaced progressive framerate (double interlaced fps)
fps_p = 2.0 * fps_i;

try
    switch computer
        
        case 'MACI64'
            
            % VideoUtils doesn't support float fps, so round for output
            % Actual fps_p is saved in ET_Prep_Info.mat file for use by ET
            fprintf('ET_Prep_ProcessVideo : rounding frame rate to %0.2f\n', round(fps_p));
            v_out = VideoRecorder(v_outfile, ...
                'Format', 'mp4', ...
                'Size', [ROI_w ROI_w], ...
                'Fps', round(fps_p));
            
        case {'PCWIN','PCWIN64','GLNXA64'}
            
            % Open video stream
            v_out = VideoWriter(v_outfile);
            
            % Set output video parameters
            v_out.FrameRate = fps_p;
            v_out.Quality = 100;
            v_out.open();
            
        otherwise
            
    end
    
catch VIDEO_WRITE_ERROR
    
    fprintf('ET_Prep : *** Writing %s : %s\n', v_outfile, VIDEO_WRITE_ERROR.identifier);
    return
    
end

% Setup artifact detection array
artifact_detected = zeros(1,n_frames);

% Start timer
t0 = tic;

for fc = 1:n_frames
    
    % Load frame pair from interlaced video stream
    [in_fr_pair, handles] = ET_Prep_LoadFramePair(v_in, handles);
    
    % Remove MR artifact if requested
    if do_mrclean && fc > 1
        [in_fr_pair_clean, artifact_detected(fc)] = ET_Prep_MRClean(in_fr_pair, in_fr_pair_prev, DEBUG);
    else
        in_fr_pair_clean = in_fr_pair;
    end
    
    % Load and process single interlaced frame
    fr_pair_roi = ET_Prep_ApplyROI(handles, in_fr_pair_clean);
    
    % Set global scaling (1st to 99th percentile of intensities)
    if fc == 1
        fr_int_limits = stretchlim(fr_pair_roi(:),[0 0.99]);
        fprintf('ET_Prep : Intensity limits set to [%0.1f, %0.1f]\n', fr_int_limits(1), fr_int_limits(2));
    end
    
    % Separate odd and even frames
    fr_odd_roi  = fr_pair_roi(:,:,1);
    fr_even_roi = fr_pair_roi(:,:,2);
    
    % Denoise odd and even frames if requested
    if do_denoise
        fr_odd  = FAST_NLM_II(fr_odd_roi,  NLM_patch_size, NLM_window_size, NLM_sigma);
        fr_even = FAST_NLM_II(fr_even_roi, NLM_patch_size, NLM_window_size, NLM_sigma);
    else
        fr_odd = fr_odd_roi;
        fr_even = fr_even_roi;
    end
    
    % Adjust intensity using robust limits from first frame
    fr_odd  = imadjust(fr_odd,  fr_int_limits);
    fr_even = imadjust(fr_even, fr_int_limits);
    
    % Create RGB versions of odd and even frames for output
    out_fr_odd  = repmat(fr_odd,[1 1 3]);
    out_fr_even = repmat(fr_even,[1 1 3]);
    
    % Write frame pair to file
    switch computer
        
        case 'MACI64'
            v_out.addFrame(out_fr_odd);
            v_out.addFrame(out_fr_even);
            
        case {'PCWIN','PCWIN64'}
            v_out.addFrame(out_fr_odd);
            v_out.addFrame(out_fr_even);
            
        case 'GLNXA64'
            v_out.writeVideo(out_fr_odd);
            v_out.writeVideo(out_fr_even);
        otherwise
            
    end
    
    % Update GUI every 30 frames
    if mod(fc,30) == 1
        
        % Update raw input and output frames in GUI
        imshow(imadjust(in_fr_pair(:,:,1)), 'Parent', handles.Input_Frame);
        imshow(out_fr_odd, 'Parent', handles.Output_Frame);
        
        % Update frame progress fields in GUI
        set(handles.Processing_FPS,'String',sprintf('%0.1f', fc / toc(t0)));
        set(handles.Frame_Count,'String',sprintf('%d / %d', fc, n_frames));
        set(handles.Percent_Complete,'String',sprintf('%d%%', fix(fc/n_frames*100)));
        
        % Force GUI update
        drawnow
        
    end
    
    % Save current frame as previous frame for next cycle
    in_fr_pair_prev = in_fr_pair;
    
end

%% Post process artifact detection array

% 250 ms median filter kernel
% Note that the artifact vector is for interlaced frame pairs, not single
% progressive frames. Use fps_i.
k = fix(0.25 * fps_i);

% Apply median filter to strip isolated false positives
artifact_detected = medfilt1(artifact_detected, k);

% Find first non-zero value in array
t_first_artifact = find(artifact_detected,1,'first') / fps_i;
if isempty(t_first_artifact); t_first_artifact = NaN; end

fprintf('ET_Prep_ProcessVideo : first artifact detected at %0.3f s\n', t_first_artifact);

%% Save ET_Prep information file for use by ET

% Fill info structure
info.timestamp = datestr(now());
info.v_infile = v_infile;
info.v_outfile = v_outfile;
info.fps_i = fps_i;
info.fps_p = fps_p;
info.t_first_artifact = t_first_artifact;

% Get ROI info from GUI
info.roi_x = str2double(get(handles.Pupil_X, 'String'));
info.roi_y = str2double(get(handles.Pupil_Y, 'String'));
info.roi_w = str2double(get(handles.ROI_size, 'String'));

% ROI rotation
rot_val = get(handles.Rotate_ROI_Popup,'Value');
rot_vals = get(handles.Rotate_ROI_Popup,'String');
info.roi_rot = str2double(rot_vals{rot_val});

% Write video and ROI information to .mat file
fprintf('ET_Prep_ProcessVideo : writing preparation info\n');
[v_path, v_stub, ~] = fileparts(v_infile);
info_file = fullfile(v_path, [v_stub '_Prep.mat']);
save(info_file,'info');

%% Clean up
switch computer
    
    case {'PCWIN','PCWIN64'}
        v_in.close()
        v_out.close()
        
    case 'GLNXA64'
        v_out.close()
        clear v_in
        
    case 'MACI64'
        clear v_in v_out
        
    otherwise
        fprint('ET_Prep_ProcessVideo : Unknown architecture (%s)\n', computer);
        
end


