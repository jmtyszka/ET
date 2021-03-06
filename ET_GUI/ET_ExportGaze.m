function ET_ExportGaze(handles)
% Export gaze timeseries as space-delimited text into Gaze directory
%
% AUTHOR : Mike Tyszka
% PLACE  : Caltech
% DATES  : 03/01/2013 JMT From scratch
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
% Copyright 2013 California Institute of Technology.

if nargin < 1; return; end

% Extract relevant fields from handles structure
gaze_dir    = handles.gaze_dir;
gaze_pupils = handles.gaze_pupils;


if ~exist(gaze_dir,'dir')
  fprintf('ET : Gaze directory does not exist - returning\n');
  return
end

% Output text file
gaze_text = fullfile(gaze_dir,'Gaze_Pupils.txt');
fprintf('ET : Exporting gaze results to %s\n', gaze_text);

%% CALIBRATION MODEL
% Extract essential timeseries
t         = [gaze_pupils.t];
gaze_x    = [gaze_pupils.gaze_x];
gaze_y    = [gaze_pupils.gaze_y];
try
gazeVal_x    = [gaze_pupils.gazeVal_x];
gazeVal_y    = [gaze_pupils.gazeVal_y];
end
area_corr = [gaze_pupils.area_correct];
px        = [gaze_pupils.px];
py        = [gaze_pupils.py];
gx        = [gaze_pupils.gx];
gy        = [gaze_pupils.gy];
area      = [gaze_pupils.area];
blink     = [gaze_pupils.blink];
% % Spike and drift corrected gaze timeseries
gaze_filt_x = [gaze_pupils.gaze_filt_x];
gaze_filt_y = [gaze_pupils.gaze_filt_y];
try
gazeVal_filt_x = [gaze_pupils.gazeVal_filt_x];
gazeVal_filt_y = [gaze_pupils.gazeVal_filt_y];
end
% Open text output file
fd = fopen(gaze_text,'w');
if fd < 0
  fprintf('ET : Could not open %s to write\n', gaze_text);
  return
end

fprintf('ET : Exporting gaze pupilometry to %s\n', gaze_text);

if ~exist('gazeVal_x','var')

    % Write column headers
    fprintf(fd,'%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s\n',...
        'Time_s','gaze_x','gaze_y','filt_x','filt_y','area_corr','px','py','gx','gy','area','blink');
    for tc = 1:length(t)
        fprintf(fd,'%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10d\n',...
            t(tc),gaze_x(tc),gaze_y(tc),gaze_filt_x(tc), gaze_filt_y(tc), area_corr(tc),...
            px(tc),py(tc),gx(tc),gy(tc),area(tc),blink(tc));
    end

else
    
    % Write column headers
    fprintf(fd,'%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s\n',...
        'Time_s','gaze_x','gaze_y','filt_x','filt_y','area_corr','px','py','gx','gy','area','blink','gazeVal_x','gazeVal_y','filtVal_x','filtVal_y');
    for tc = 1:length(t)
        fprintf(fd,'%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10.3f%-10d\n',...
            t(tc),gaze_x(tc),gaze_y(tc),gaze_filt_x(tc), gaze_filt_y(tc), area_corr(tc),...
            px(tc),py(tc),gx(tc),gy(tc),area(tc),blink(tc),gazeVal_x(tc),gazeVal_y(tc),gazeVal_filt_x(tc), gazeVal_filt_y(tc));
    end
    
end
% Clean up
fclose(fd);




fprintf('ET : Export complete\n');
