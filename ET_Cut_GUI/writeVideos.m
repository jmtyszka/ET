function writeVideos(input_file)
dbstop if error
if nargin<1
    [input_file,input_dir] = uigetfile('*.mp4','Select the uncut mp4 video');
    if isequal(input_dir,0)
        return
    end
end
rootname = input_file(1:end-4);

if ~exist(fullfile(input_dir,'prepare.mat'),'file')
    fprintf('%s : no preparation file found, skipping...\n',rootname);
    return
end

% initialize FrameRate variable (avoiding conflict with a PsychToolbox function)
FrameRate=29.97;
load(fullfile(input_dir,'prepare.mat'));

% check if this video has already been processed
if exist(fullfile(input_dir,[rootname,'_GAZE.mp4']),'file')
    switch computer
        case {'PCWIN','PCWIN64','GLNXA64'}
            v_tmp       =  VideoReader(fullfile(input_dir,[rootname,'_GAZE.mp4']));
            nFrames     =  v_tmp.NumberOfFrames;
        case 'MACI64'
            v_tmp       =  VideoPlayer(fullfile(input_dir,[rootname,'_GAZE.mp4']), 'Verbose', false, 'ShowTime', false);
            nFrames = v_tmp.NumFrames;
    end
    if nFrames ~= GAZEend-GAZEstart+1,
        fprintf('%s: GAZE video exists but different number of frames from prepare.mat -- OVERWRITING\n',rootname);
    else
        fprintf('%s: GAZE video exists  -- SKIPPING\n',rootname);
        return
    end
else
    fprintf('%s: writing CAL, VAL, GAZE videos\n',rootname);
end

switch computer
    case {'PCWIN','PCWIN64','GLNXA64'}
        v_in       =  VideoReader(fullfile(input_dir,[rootname,'.mp4']));
    case 'MACI64'
        v_in         =  VideoPlayer(fullfile(input_dir,[rootname,'.mp4']), 'Verbose', false, 'ShowTime', false);
        currentFrame = 1;
end

% read the start and end of each video, and write them!
tic
numFrames=CALend-CALstart+1;
video_outfile = fullfile(input_dir,[rootname,'_CAL.mp4']);
switch computer
    case {'PCWIN','PCWIN64','GLNXA64'}
        v_out = VideoWriter(video_outfile,'MPEG-4');
        set(v_out,'FrameRate',FrameRate,'Quality',100);
        open(v_out);
        for k = 1 : numFrames
            writeVideo(v_out,read(v_in, CALstart+k-1));
        end
        % Close the file.
        close(v_out);
    case 'MACI64'
        v_in = v_in + (CALstart-1);
        currentFrame = CALstart;
        v_out = VideoRecorder(video_outfile(1:end-4),'Format','mp4');
        for k = 1 : numFrames
            v_out.addFrame(v_in.Frame);
            v_in = v_in +1;
            currentFrame = currentFrame + 1;
        end
        clear v_out
end
elapsed=toc;
fprintf('\t\tFinished writing CAL movie in %.1fs\n',elapsed);

tic
numFrames=VALend-VALstart+1;
video_outfile = fullfile(input_dir,[rootname,'_VAL.mp4']);
switch computer
    case {'PCWIN','PCWIN64','GLNXA64'}
        v_out = VideoWriter(video_outfile,'MPEG-4');
        set(v_out,'FrameRate',FrameRate,'Quality',100);
        open(v_out);
        for k = 1 : numFrames
            writeVideo(v_out,read(v_in, VALstart+k-1));
        end
        % Close the file.
        close(v_out);
    case 'MACI64'
        v_in = v_in + (VALstart-currentFrame);
        currentFrame = VALstart;
        v_out = VideoRecorder(video_outfile(1:end-4),'Format','mp4');
        for k = 1 : numFrames
            v_out.addFrame(v_in.Frame);
            v_in = v_in +1;
            currentFrame = currentFrame + 1;
        end
        clear v_out
end
elapsed=toc;
fprintf('\t\tFinished writing VAL movie in %.1fs\n',elapsed);

tic
numFrames=GAZEend-GAZEstart+1;
video_outfile = fullfile(input_dir,[rootname,'_GAZE.mp4']);
switch computer
    case {'PCWIN','PCWIN64','GLNXA64'}
        v_out = VideoWriter(video_outfile,'MPEG-4');
        set(v_out,'FrameRate',FrameRate,'Quality',100);
        open(v_out);
        for k = 1 : numFrames
            writeVideo(v_out,read(v_in, GAZEstart+k-1));
        end
        % Close the file.
        close(v_out);
    case 'MACI64'
        v_in = v_in + (GAZEstart-currentFrame);
        currentFrame = GAZEstart;
        v_out = VideoRecorder(video_outfile(1:end-4),'Format','mp4');
        for k = 1 : numFrames
            v_out.addFrame(v_in.Frame);
            if k < numFrames
                v_in = v_in +1;
                currentFrame = currentFrame + 1;
            end
        end
        clear v_out
end
elapsed=toc;
fprintf('\t\tFinished writing GAZE movie in %.1fs\n',elapsed);

