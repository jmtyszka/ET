function ET_PlotGaze(p, h, mode)
% Overlay calibrated gaze position in gaze axes
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech 
% DATES  : 03/04/2013 JMT From scratch
%
% Copyright 2013 California Institute of Technology
% All rights reserved.

switch lower(mode)
  
  case 'plot'
    hold on
    plot(p.gaze_x, p.gaze_y,'go',...
      'markersize',3,...
      'markerfacecolor','g',...
      'parent',h);
    hold off
    
  case 'init'
    plot([0.1 0.5 0.9 0.1 0.5 0.9 0.1 0.5 0.9], [0.1 0.1 0.1 0.5 0.5 0.5 0.9 0.9 0.9], 'w+', 'parent', h);
    set(h,'color','k');
    set(h,'xlim',[0 1],'ylim',[0 1]);
  
  otherwise
    % Do nothing
    
end
    
