function p_fit = ET_FitEllipse_Ben(bw_pupil, p_init, gray_pupil)
% Ellipse fit using fminsearch to optimize match between segmented pupil and
% BW ellipse
%
% AUTHOR : Ben Harrison.
% PLACE  : Remote
% DATES  : 04/02/2014 BJH create
%
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
% Copyright 2013-2014 California Institute of Technology.

% Init fitted pupil structure
p_fit = p_init;

% Set blink flag
p_fit.blink = true;

% Create a simple mask to obscure the glint. This avoids pupil fit from
% being deflected by the glint if there is an overlap between the two.
mask = (gray_pupil<(220/255));

% Optimize position and size of circle
x_starting = [75 75 30 30 0];
myFun = @(x)ET_ellipseFitCost(x,bw_pupil,mask);
x = fminsearch(myFun,x_starting);

% This loop is here because it can be useful to repeat execution of the
% solver from a new and improved starting point. Increasing the number of
% extra solves is costly in computational time and generally offers minimal
% gain.
numberOfExtraSolves = 0;
for jj = 1:numberOfExtraSolves; x = fminsearch(myFun,x);end

% x is returned as x = [x,y,a,b,phi], with x and y being center
% coordinates, a and b being the semi-major and semi-minor axes, and phi
% being the angle to a. Note that a and b are not constrained with respect
% to each other, so we need to do some post-processing to work out the semi
% -major and semi-minor axes
[~,~,overlap] = myFun(x);
if x(4) > x(3)
    x([3 4]) = x([4 3]);
    x(5) = x(5) +pi/2;
end
x_coord = x(1);
y_coord = x(2);
major = x(3);
minor = x(4);
angle = x(5);

%% Score candidate pupil regions


% Parse stats structure
area = pi*major*minor;

ecc  = sqrt(1-minor^2/major^2);


p_fit.px = x_coord;
p_fit.py = y_coord;

% Note : regionprops orientation is the angle in degrees between the x-axis
% (columns) and the major axis of the ellipse.
% phi = 0 would be a horizontal major axis
% Save ellipse info as [SemiMajor SemiMinor Orientation]
p_fit.ra = major;
p_fit.rb = minor;
p_fit.phi = angle;

p_fit.circularity = [];
p_fit.eccentricity = ecc;
p_fit.area = area;
p_fit.area_correct = area;
p_fit.pd_eff = 2 * sqrt(p_fit.ra * p_fit.rb);

% Eye-camera angle from ratio of semiminor to semimajor axes
p_fit.eye_camera_angle = acos(p_fit.rb / p_fit.ra) * 180/pi;

% Set blink flag if no candidate meet criteria
if overlap > 0.5;
    p_fit.blink = true;
else
    p_fit.blink = false;
end


end
