function convert_mpg2_to_mp4(FPSi)
% convert file from mpeg2-interlaced to mp4-interlaced and mp4-progressive, for ET
% USAGE : convert_mp2_to_mp4(moviefile_in,moviefile_out)
% where moviefile_in is .mpg and moviefile_out is .mp4
% DATE : 10/07/2013 
% AUTHOR : JD, from scratch

if nargin<1
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
  v_output_file_I = fullfile(in_path, [in_name,'I']);
  v_output_file_D = fullfile(in_path, [in_name,'D']);
  
  fprintf('Converting %s to %s.mp4\n', v_input_file, v_output_file_I);
  % open videoWriter object to write new file
  v_out_I = VideoWriter(v_output_file_I,'MPEG-4');
  set(v_out_I,'FrameRate',FPSi,'Quality',100);
  open(v_out_I);
  %
  v_out_D = VideoWriter(v_output_file_D,'MPEG-4');
  set(v_out_D,'FrameRate',2*FPSi,'Quality',100);
  open(v_out_D);
 
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
          writeVideo(v_out_I,fr);
          [fr_odd,fr_even]=ET_Deinterlace(fr);
          writeVideo(v_out_D,fr_odd);
          writeVideo(v_out_D,fr_even);
      end
      if endreached
          break
      end
      ii=ii+chunksize;
      if mod(v_out_D.FrameCount,1000)==0,
          elapsed=toc;
          fprintf('Processed %d frames in %.1fs\n',v_out_D.FrameCount,elapsed);
      end
  end
  
  % Close the file.
  close(v_out_I);
  close(v_out_D);

end