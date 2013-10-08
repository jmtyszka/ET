function convert_mpg2_to_mp4_mac
% Batch convert interlaced MPEG-2 videos to progressive MPEG-4
%
% AUTHOR : Mike Tyszka and Julien Dubois
% PLACE  : Caltech
% DATES  : 10/07/2013 JMT Use VideoUtils library

[fname, dname] = uigetfile('*.mpg','Select MPEG-2 videos to convert','Multiselect','on');

if isequal(fname,0) || isequal(dname,0)
  return
end

% Count videos
if iscell(fname)
  nvid = length(fname);
else
  nvid = 1;
end

% Loop over all selected videos
for vc = 1:nvid
  
  if nvid > 1
    v_input_file = fullfile(dname,fname{vc});
  else
    v_input_file = fullfile(dname,fname);
  end
  
  % Construct output video name
  [in_path, in_name] = fileparts(v_input_file);
  v_output_file = fullfile(in_path, in_name);
  
  fprintf('Converting %s to %s.mp4\n', v_input_file, v_output_file);
  
  % Open video input (MPEG-2, interlaced)
  v_in = VideoPlayer(v_input_file);
  
  % Hardwired NTSC framerate
  in_fps  = 29.97; 
  
  % Deinterlaced, progressive video framerate (twice interlaced)
  out_fps = in_fps * 2;
  
  % Open video out (MPEG-4, progressive)
  v_out = VideoWriter(v_output_file, 'MPEG-4');
  v_out.Quality = 75;
  v_out.FrameRate = out_fps;
  
  open(v_out);
  
  while (true)
    
    fr = v_in.Frame;
    
    % Deinterlace
    fr_odd = fr(1:2:end,1:2:end,:);
    fr_even = fr(2:2:end,1:2:end,:);
    
    writeVideo(v_out, fr_odd);
    writeVideo(v_out, fr_even);
    
    if (~v_in.nextFrame)
      break;
    end
    
  end
  
  % Close input and output video streams
  clear v_in
  close(v_out);
  
end
