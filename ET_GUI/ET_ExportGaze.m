function ET_ExportGaze(handles)
% Export subset of gaze timeseries as space-delimited text into Gaze
% directory

if nargin < 1; return; end

% Extract relevant fields from handles structure
gaze_dir    = handles.gaze_dir;
gaze_pupils = handles.gaze_pupils;
gaze_filt   = handles.gaze_filt;

if ~exist(gaze_dir,'dir')
  fprintf('ET : Gaze directory does not exist - returning\n');
  return
end

% Output text file
gaze_text = fullfile(gaze_dir,'Gaze_Pupils.txt');
fprintf('ET : Exporting gaze results to %s\n', gaze_text);

% Extract essential timeseries
t         = [gaze_pupils.t];
gaze_x    = [gaze_pupils.gaze_x];
gaze_y    = [gaze_pupils.gaze_x];
area_corr = [gaze_pupils.area_correct];
px        = [gaze_pupils.px];
py        = [gaze_pupils.py];
gx        = [gaze_pupils.gx];
gy        = [gaze_pupils.gy];
area      = [gaze_pupils.area];
blink     = [gaze_pupils.blink];

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
