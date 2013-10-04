function fixations = ET_PickFixationsOrder(fixations,handles)
% If the number of fixations is neither 4 nor 9, do a manual check; 
% click (left click) on the 4 or 9 "true" fixations
% if you made a mistae and want to start over, press 'esc'
% when you are done clicking, press the return key
%
% RETURNS:
% fixations = updated fixations structure, with "false alarm" fixations removed
%
% AUTHOR : Julien Dubois, Ph.D.
% PLACE  : Caltech
% DATES  : 09/27/2013 JD from scratch
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

dbstop if error

% % no need for a manual edit if the number of fixations is 4 or 9
% if n_fix == 4 || n_fix==9
%     return
% end

% Smoothed heatmap in GUI calibration axes
axes(handles.Calibration_Axes);cla;
imagesc(fixations.xv, fixations.yv, fixations.hmap);%, 'parent',handle)
axis equal ij;axis manual;hold on

% Overlay possible fixations (peaks of heatmap)
for ifix = 1:length(fixations.x)
  plot(fixations.x(ifix), fixations.y(ifix), 'o', 'MarkerFaceColor','b','MarkerEdgeColor','k','MarkerSize',8);
end

% THESE ARE THE COORDINATES OF THE 9 calibration points
x0 = [0.9 0.5 0.1 0.9 0.5 0.1 0.9 0.5 0.1];
y0 = [0.9 0.9 0.9 0.5 0.5 0.5 0.1 0.1 0.1];

orderedfixations.x = nan(1,length(x0));
orderedfixations.y = nan(1,length(x0));
% use ginput to select good fixations
for iCal=1:length(x0),
    % Circle the fixation to be defined
    axes(handles.Gaze_Axes);axis([0 1 0 1]);axis manual;hold on;
    plot(x0(iCal),y0(iCal),'o','MarkerFaceColor','b','MarkerEdgeColor','k','MarkerSize',12);
    
    % (left) click on corresponding fixation
    axes(handles.Calibration_Axes);
    indkeep=[];
    button=1;
    while ~isempty(button) 
        % button becomes empty when the return key is pressed
        [x,y,button]=ginput(1);
        if button==1 % left click
            % find the closest fixation to the clicked point
            d=sqrt((x-fixations.x).^2+(y-fixations.y).^2);
            [~,whichfix]=min(d);
            if ~ismember(whichfix,indkeep)
                % plot it in blue to mark it as accepted
                plot(fixations.x(whichfix), fixations.y(whichfix), 'o', 'MarkerFaceColor','g','MarkerEdgeColor','k','MarkerSize',8);
                % add it to the list of good fixations
                indkeep=whichfix;
            else
                % plot it in blue to mark it as accepted
                plot(fixations.x(whichfix), fixations.y(whichfix), 'o', 'MarkerFaceColor','b','MarkerEdgeColor','k','MarkerSize',8);
                % remove from list of good fixations
                indkeep=indkeep(indkeep~=whichfix);
            end
        end
    end
    
    axes(handles.Gaze_Axes);
    if isempty(indkeep)
        plot(x0(iCal),y0(iCal),'o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',12);
    else
        plot(x0(iCal),y0(iCal),'o','MarkerFaceColor','g','MarkerEdgeColor','k','MarkerSize',12);
        orderedfixations.x (iCal) = fixations.x(indkeep);
        orderedfixations.y (iCal) = fixations.y(indkeep);
    end
    drawnow
end

axes(handles.Gaze_Axes);
for iCal=1:length(x0)
    plot(x0(iCal),y0(iCal),'o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',12);
    plot(x0(iCal),y0(iCal),'w+','MarkerSize',12);
end

orderedfixations.hmap = fixations.hmap;
orderedfixations.xv = fixations.xv;
orderedfixations.yv = fixations.yv;

fixations = orderedfixations;


