function [ error, ellipseGrid, maskOverlap ] = ET_ellipseFitCost( x,target,mask )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[r,c] = size(target);

[rows, cols] = meshgrid(1:r,1:c);
rows = rows-x(1);
cols = cols-x(2);
rowsP = cos(x(5))*rows + sin(x(5))*cols;
colsP = cos(x(5))*cols - sin(x(5))*rows;

ellipseGrid = ((rowsP.^2)/x(3)^2 + (colsP.^2)/x(4)^2) < 1;

error = sum(sum(abs((ellipseGrid-target).*mask)));
maskOverlap = ellipseGrid.*(~mask);
maskOverlap = sum(maskOverlap(:))/sum(ellipseGrid(:));
end

