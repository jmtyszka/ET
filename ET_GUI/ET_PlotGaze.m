function ET_PlotGaze(p, h, mode)
% Overlay calibrated gaze position in gaze axes
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech 
% DATES  : 03/04/2013 JMT From scratch
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

switch lower(mode)
  
  case 'plot'
    
    % Remember to use plot handle for all operations, focus may shift
    hold(h,'on');
    plot(p.gaze_x, p.gaze_y,'go',...
      'markersize',3,...
      'markerfacecolor','g',...
      'parent',h);
    hold(h,'off');
    
  case 'init'
    
    % Plot graticule and set background to black
    hold(h,'off');
    plot([0.1 0.5 0.9 0.1 0.5 0.9 0.1 0.5 0.9], [0.1 0.1 0.1 0.5 0.5 0.5 0.9 0.9 0.9], 'w+', 'parent', h);
    set(h,'color','k');
    set(h,'xlim',[0 1],'ylim',[0 1]);
  
  otherwise
    % Do nothing
    
end
    
