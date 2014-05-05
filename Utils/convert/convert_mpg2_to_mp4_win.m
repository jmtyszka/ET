function convert_mpg2_to_mp4_win(put_video_in_folder,cleanup,FPSi)
% convert file from mpeg2-interlaced to mp4-interlaced (for Windows)
% USAGE : convert_mp2_to_mp4(moviefile_in,moviefile_out)
% where moviefile_in is .mpg and moviefile_out is .mp4
% DATE : 10/07/2013 
% AUTHOR : JD, from scratch
% 4/28/14 : amended to output mp4 interlaced, to match current ET workflow

if nargin<1
    put_video_in_folder = 0;
end
if nargin<2
    cleanup = 0;
end
if nargin<3
    FPSi = 29.97;
end


if isempty(strfind(path,fullfile('.','mmread'))),
    addpath(genpath(fullfile('.','mmread')));
end
   
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
  % open videoWriter object to write new file
  v_out = VideoWriter(v_output_file,'MPEG-4');
  set(v_out,'FrameRate',FPSi,'Quality',100);
  open(v_out);
  %
  chunksize=1000;
  % read 1000 frames at a time to avoid running into RAM trouble
  ii=0;
  tic;
  endreached=0;
  while 1
      clear video
      video = mmread(v_input_file,ii+1:ii+chunksize,[],false,true); %disable audio
      
      for i=1:chunksize,
          try
              fr = rgb2gray(video.frames(i).cdata);
          catch
              endreached=1;
              break
          end
          writeVideo(v_out,fr);
%           [fr_odd,fr_even]=ET_Deinterlace(fr);
%           writeVideo(v_out_D,fr_odd);
%           writeVideo(v_out_D,fr_even);
      end
      if endreached
          break
      end
      ii=ii+chunksize;
      if mod(v_out.FrameCount,1000)==0,
          elapsed=toc;
          fprintf('Processed %d frames in %.1fs\n',v_out.FrameCount,elapsed);
      end
  end
  
  % Close the file.
  close(v_out);
  
  % clean up: delete .mpg 
  if cleanup
      delete(v_input_file);
  end
  
  if put_video_in_folder
      mkdir(fullfile(in_path,in_name));
      movefile([v_output_file,'.mp4'],fullfile(in_path,in_name,[in_name,'.mp4']));
  end
end