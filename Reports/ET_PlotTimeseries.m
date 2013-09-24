function ET_PlotTimeseries(t, y, ylims, title_str, plot_file)
% Plot pupilometry timeseries
%
% USAGE : ET_PlotTimeseries(t, px, py, plot_file)
%
% ARGS:
% px, py    = pupile centroids in video or glint FoR
% C         = calibration matrix in video or glint FoR
% plot_file = output filename for plot (PNG image)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 04/16/2013 JMT Extract from ET_AutoCalibrate.m
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


%% Apply calibration to raw fixations

% Create a new hidden figure
hf = figure(200);
set(hf,'Position',[100 100 640 320]);
set(hf,'PaperPositionMode','auto','Visible','off');

plot(t, y);
set(gca,'XLim',[min(t) max(t)]);
if ~isempty(ylims)
  set(gca,'YLim',ylims);
end
xlabel('Time (s)');
title(title_str);

% Print figure
print(hf, plot_file, '-dpng', '-r200');

% Close figure
close(hf);
