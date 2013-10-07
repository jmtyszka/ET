function convert_mpg2_to_mp4(moviefile_in,moviefile_out)
% convert file from mpeg2-interlaced to mp4-progressive, for ET
% USAGE : convert_mp2_to_mp4(moviefile_in,moviefile_out)
% where moviefile_in is .mpg and moviefile_out is .mp4
% DATE : 10/07/2013 
% AUTHOR : JD, from scratch

   
% use mmread from the file exchange to read MPEG2
% make sure the toolbox is in the path

% open videoWriter object to write new file
v_out = VideoWriter(moviefile_out,'MPEG-4');
set(v_out,'FrameRate',2*29.97,'Quality',100);
open(v_out);
    
chunksize=1000;
% read 1000 frames at a time to avoid running into RAM trouble
ii=0;
tic;
endreached=0;
while 1
    clear video
    video = mmread(moviefile_in,ii+1:ii+chunksize,[],false,true); %disable audio
    
    for i=1:chunksize,
        try
            fr = rgb2gray(video.frames(i).cdata);
        catch
            endreached=1;
            break
        end
        [fr_odd,fr_even]=ET_Deinterlace(fr);
        writeVideo(v_out,fr_odd);
        writeVideo(v_out,fr_even);
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

