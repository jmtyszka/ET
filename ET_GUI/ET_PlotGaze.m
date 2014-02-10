function hmap = ET_PlotGaze(p, h, hmap, mode)
% Overlay calibrated gaze position in gaze axes
%
% ARGS :
% p    = pupilometry structure to plot
% h    = axis handle for plot
% hmap = heatmap underlay
% mode = plot mode ('init' or 'plot')
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 03/04/2013 JMT From scratch
%          02/09/2014 JMT Add running heatmap underlay
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
% Copyright 2014 California Institute of Technology.

switch lower(mode)
    
    case 'init'
        
        % Init running heatmap
        hmap = zeros(100,100);
        
        % Overlay graticule
        hold(h,'on');
        plot([0.1 0.5 0.9 0.1 0.5 0.9 0.1 0.5 0.9], [0.1 0.1 0.1 0.5 0.5 0.5 0.9 0.9 0.9], 'w+', 'parent', h);
        set(h,'xlim',[0 1],'ylim',[0 1]);
        set(h,'color','k');
        hold(h,'off');
        
    case 'plot'
        
        % Add current gaze location to heatmap
        x = fix(p.gaze_x * 100);
        y = fix(p.gaze_y * 100);
        
        % Clamp coordinate to bounds
        if x >= 1 && x <= 100 && y >= 1 && y <= 100
            hmap(y,x) = hmap(y,x) + 1;
        end
        
        % Remember to use plot handle for all operations, focus may shift
        hold(h,'on');
        
        % Draw running heat map underlay
        imagesc([0 1], [0 1], hmap, 'parent', h);
        
        plot(p.gaze_x, p.gaze_y,'go',...
            'markersize',3,...
            'markerfacecolor','g',...
            'parent',h);
        
        hold(h,'off');
        
    otherwise
        
        % Do nothing
        
end

