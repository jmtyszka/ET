function fixations = ET_PickFixations(fixations,handles)
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
axis equal ij tight


% Overlay possible fixations (peaks of heatmap)
hold on
for ifix = 1:length(fixations.x)
  plot(fixations.x(ifix), fixations.y(ifix), 'o', 'MarkerFaceColor','b','MarkerEdgeColor','k','MarkerSize',8);
end

% use ginput to select good fixations
% (left) click on good fixations
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
            indkeep=[indkeep whichfix];
        else
            % plot it in blue to mark it as accepted
            plot(fixations.x(whichfix), fixations.y(whichfix), 'o', 'MarkerFaceColor','b','MarkerEdgeColor','k','MarkerSize',8);
            % remove from list of good fixations
            indkeep=indkeep(indkeep~=whichfix);
        end
    end
end

fixations.x=fixations.x(indkeep);
fixations.y=fixations.y(indkeep);

