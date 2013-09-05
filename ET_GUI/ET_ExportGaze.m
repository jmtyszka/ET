function ET_ExportGaze(gaze_dir, gaze, gaze_filt)
% Export subset of gaze timeseries as space-delimited text into Gaze
% directory

if nargin < 1; return; end

if ~exist(gaze_dir,'dir')
  fprintf('ET : Gaze directory does not exist - returning\n');
  return
end

% Output text file
gaze_text = fullfile(gaze_dir,'Gaze_Pupils.txt');
fprintf('ET : Exporting gaze results to %s\n', gaze_text);

% Extract essential timeseries
t         = [gaze.t];
gaze_x    = [gaze.gaze_x];
gaze_y    = [gaze.gaze_x];
area_corr = [gaze.area_correct];
px        = [gaze.px];
py        = [gaze.py];
gx        = [gaze.gx];
gy        = [gaze.gy];
area      = [gaze.area];
blink     = [gaze.blink];

% Spike and drift corrected gaze timeseries
gaze_filt_x = gaze_filt.x;
gaze_filt_y = gaze_filt.y;

% Open text output file
fd = fopen(gaze_text,'w');
if fd < 0
  fprintf('ET : Could not open %s to write\n', gaze_text);
  return
end

fprintf('ET : Exporting gaze pupilometry to %s\n', gaze_text);

% Write column headers
fprintf(fd,'%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s\n',...
  'Time_s','gaze_x','gaze_y','filt_x','filt_y','area_corr','px','py','gx','gy','area','blink');

for tc = 1:length(t)
  fprintf(fd,'%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10d\n',...
    t(tc),gaze_x(tc),gaze_y(tc),gaze_filt_x(tc), gaze_filt_y(tc), area_corr(tc),...
    px(tc),py(tc),gx(tc),gy(tc),area(tc),blink(tc));
end

% Clean up
fclose(fd);

fprintf('ET : Export complete\n');
