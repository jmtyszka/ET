function xopt = fitCameraImage_calibrated(params,nIt)
% WHAT DOES THIS PROGRAM DO?
% Fit camera plane and right eyeball coordinates
% the camera center is the origin of world coordinates [X,Y,Z] = [0,0,0]
% the unknowns that we need to fit are the rotation of the camera plane and
% the coordinates of the eyeball center
% => 6 parameters to optimize, given the 9 calibration points
% * normal vector to the camera plane [Nx  Ny  Nz]
% * coordinates of the eye center     [Ex  Ey  Ez]
% simply use the following projection equation to get the image of the
% pupil center on the camera
% [px]  =  K' * [R11 R12 R13 0] * [ X ]
% [py]          [R21 R22 R23 0]   [ Y ]
% [1 ]          [R31 R32 R33 0]   [ Z ]
%               [ 0   0   0  1]   [ 1 ]
% px,py will be in pixels
% the rotation matrix transforms [0 0 1] to [Nx Ny Nz]:
% Rmat = vrrotvec2mat(vrrotvec([0 0 1],[Nx Ny Nz]))
%
% Julien Dubois from scratch 04/29/2014
% to be included in the ET toolbox (Mike Tyszka Caltech 2013-2014)

dbstop if error

% implement multidimensional optimization
% BOUNDS FOR THE SEARCH
%      [ alpha   beta   gamma    Ex   Ey  Ez   screenCenterdy  screenCenterdz    rotationinimageplane
LOW  = [-pi/2/18*[1 1 1]       -50 -250  30        0            -100            0.001      ];
UPP  = [ pi/2/18*[1 1 1]        50  -30 250        0             100            2*pi       ];
params.plotScene = 0;
opts = optimoptions(@fmincon,'MaxFunEvals',10000,'MaxIter',10000);%'display','iter',
count = 0;
xopts    = cell(1,10);
fval = Inf*ones(1,10);
while min(fval)>0.03 && count<nIt,
    count = count+1;
    tic
    [xopts{count},fval(count),~,~] = fminsearchbnd(@(x) computeDistance(x,params),LOW+rand(1,length(LOW)).*(UPP-LOW),LOW,UPP,opts);
    elapsed = toc;
    fprintf('Optimization %d finished in %.1fs -- minimum distance achieved so far %.3f\n',count,elapsed,min(fval));
    fprintf('\tNormal to the image plane:\t %.3f %.3f %.3f\n',xopts{count}(1),xopts{count}(2),xopts{count}(3));
    fprintf('\tCenter of the eyeball    :\t %.3f %.3f %.3f\n',xopts{count}(4),xopts{count}(5),xopts{count}(6));
    fprintf('\tScreen center            :\t dy = %.3f \t dz = %.3f\n',xopts{count}(7),xopts{count}(8));
    fprintf('\tCamera rotation          :\t theta = %.3f \n',xopts{count}(9)/pi*180);
    fprintf('\tOptimized RMS            :\t %.3f\n',fval(count));
    fprintf('-------------------------------------\n');
    
end
[~,indmini]= min(fval);xopt = xopts{indmini};

% show final result
params.plotScene = 1;
distance = computeDistance(xopt,params);
fprintf('Normal to the image plane:\t %.3f %.3f %.3f\n',xopt(1),xopt(2),xopt(3));
fprintf('Center of the eyeball    :\t %.3f %.3f %.3f\n',xopt(4),xopt(5),xopt(6));
fprintf('Screen center            :\t dy = %.3f \t dz = %.3f\n',xopt(7),xopt(8));
fprintf('Camera rotation          :\t theta = %.3f \n',xopt(9)/pi*180);
fprintf('Optimized RMS            :\t %.3f\n',distance);



function distance = computeDistance(OPT,params)
% SETUP FOR 3d scene
%%%%%%%%%%%%%%%
% eyeballs setup
[eyeballx,eyebally,eyeballz] = sphere;
%%%%%%%%%%%%%%%
% screen setup
% normal to the screen
normalS = [0 1 0]; % the screen is in the (x,z) plane
% center of the screen
pointS  = [OPT(4)-params.intereyeD/2 OPT(5)+params.D+OPT(7) OPT(6)-params.screenH/2+OPT(8)]; 
% x: centered between the two eyes (should be approximately true)
% y: at a certain distance from the eye -- optimize (can fix by having
% bounds = 0 on both ends
% z: where is the center of the screen
% size of the screen
xLim = pointS(1)+[-params.screenW/2 params.screenW/2];
zLim = pointS(3)+[-params.screenH/2 params.screenH/2];
[XS,ZS] = meshgrid(xLim,zLim);
% implement equation of the plane
YS = (normalS(1)*XS + normalS(3)*ZS -dot(normalS,pointS))/(-normalS(2));
% calibration points
XCal=zeros(1,size(params.calPoints,1));
ZCal=zeros(1,size(params.calPoints,1));
for i = 1:size(params.calPoints,1)
    XCal(i) = pointS(1) - params.screenW/2 + params.calPoints(i,1)*params.screenW;
    ZCal(i) = pointS(3) - params.screenH/2 + params.calPoints(i,2)*params.screenH;
end
% I could also just set YCal to YS(1)
YCal = (normalS(1)*XCal + normalS(3)*ZCal - dot(normalS,pointS))/(-normalS(2));
%%%%%%%%%%%%%%%
% camera setup
% CONSTRAINT: the optical axis needs to pass close to the eyeball center
% % if the optimization is on the rotation angles about the 3 axes,
% starting from the direction to the eyeball center
normal_init = OPT(4:6)/sqrt(sum(OPT(4:6).^2)); % unit vector in the direction of the eyeball center
% nudge it around
Rx = [1 0 0 0;0 cos(OPT(1)) -sin(OPT(1)) 0;0 sin(OPT(1)) cos(OPT(1)) 0; 0 0 0 1];
Ry = [cos(OPT(2)) 0 sin(OPT(2)) 0;0 1 0 0;-sin(OPT(2)) 0 cos(OPT(2)) 0;0 0 0 1];
Rz = [cos(OPT(3)) -sin(OPT(3)) 0 0;sin(OPT(3)) cos(OPT(3)) 0 0;0 0 1 0;0 0 0 1];
tmp = Rx * Ry * Rz * [normal_init 1]';
normal = tmp(1:3)';
% % if the optimization is on the coordinates of the normal vector
% normal = [OPT(1) OPT(2) OPT(3)]/sqrt(sum(OPT(1:3).^2)); % normalized normal
% % what is the rotation matrix?
Rmat = vrrotvec2mat(vrrotvec([0 0 1],normal));


% camera image plane
L = createLine3d(0, 0, 0, normal(1), normal(2), normal(3));
% point on the image plane
pointImPlane = intersectLineSphere(L, [0, 0, 0, 5]);
% "5" is just for show; I don't actually have the focal length of the camera.
% but, from the calibration, I have the intrinsic matrix
% keep negative y
pointImPlane = pointImPlane(pointImPlane(:,2)<0,:);
% display size of the image plane
xLim = pointImPlane(1)+[-10 10];
zLim = pointImPlane(3)+[-10 10];
[XP,ZP] = meshgrid(xLim,zLim);
YP = (normal(1)*XP + normal(3)*ZP -dot(normal,pointImPlane))/(-normal(2));
% create a plane (in the format that the geom3d toolbox likes)
ImPlane = createPlane(pointImPlane,normal);


%--------------
% plot in 3d
%--------------
if params.plotScene
    figure(1000);
    clf;hold on;
    % 3d scene, overview
    subplot(1,3,[1 2]);hold on;title('3d scene');
    % eyeball (R, tracked)
    surf(OPT(4)+params.Er*eyeballx, OPT(5)+params.Er*eyebally, OPT(6)+params.Er*eyeballz, eyebally);shading interp;
    % eyeball (L, untracked) -- for show
    surf(OPT(4)+params.Er*eyeballx-params.intereyeD, OPT(5)+params.Er*eyebally, OPT(6)+params.Er*eyeballz, eyebally);shading interp; % assumes head is perfectly placed in magnet, may need to adjust
    reOrder = [1 2 4 3];
    % screen
    patch(XS(reOrder),YS(reOrder),ZS(reOrder),'k');
    % calibration points
    plot3(XCal,YCal,ZCal,'b.','Markersize',10);
    % camera image plane
    patch(XP(reOrder),YP(reOrder),ZP(reOrder),'g','EdgeColor','none');
    % normal to the image plane
    drawLine3d(L,'Color','g');
    % camera focal point
    plot3(0,0,0,'g.','Markersize',20);
    % project center of eyeball
    plot3([OPT(4) 0],[OPT(5) 0],[OPT(6) 0],'k');
    xlabel('x');
    ylabel('y');
    zlabel('z');
    grid on
    axis equal
    view(45,10);
    alpha(.3);
    axis([-500 500 -200 1000 -400 400]);
    
    subplot(1,3,3);hold on;title('Camera view');axis equal;
end

% now do a few projections
% project the pupil on the eyeball, for the 9 calibration points
calPointsP_px_calc = zeros(size(params.calPoints,1),2);
for i = 1:size(params.calPoints,1)
    % line from eyeball center to calibration point
    L = createLine3d([OPT(4) OPT(5) OPT(6)], [XCal(i) YCal(i) ZCal(i)]);
    % intersect line with eyeball
    pointE = intersectLineSphere(L,[OPT(4) OPT(5) OPT(6) params.Er]);
    % largest y
    [~,indmaxi] = max(pointE(:,2));
    pointE = pointE(indmaxi,:);
    if params.plotScene
        % plot
        subplot(1,3,[1 2]);hold on;plot3(pointE(1),pointE(2),pointE(3),'b.','Markersize',5);
    end
      
    tmp =  params.K * [eye(3) [0 0 0]'] *[ [Rmat(1:3,1:3)';0 0 0] [0 0 0 1]'] * [pointE 1]';
    calPointsP_px_calc(i,:) = tmp(1:2)/tmp(3);
end

% fixations points
fx = params.fixations.x;
fy = params.fixations.y;

% % compute center of mass and recenter measured 9-point pattern
cf = mean([fx' fy'],1);
fx_c = fx - cf(1);
fy_c = fy - cf(2);

% % compute center of mass and recenter fitted 9-point pattern
c = mean([calPointsP_px_calc(:,1) calPointsP_px_calc(:,2)],1);
calPointsP_c = [calPointsP_px_calc(:,1)-c(1) calPointsP_px_calc(:,2)-c(2)];

% % rotate fitted 9-point pattern to minimize distance
% thetas = 2*pi/120 : 1*pi/120 : 2*pi; % every 3 degrees
% distances = nan(1,length(thetas));
% for itheta = 1:length(thetas)
%     R = [cos(thetas(itheta)) -sin(thetas(itheta));sin(thetas(itheta)) cos(thetas(itheta))];
%     calPointsP_c_rot = (R * calPointsP_c')';
%     distances(itheta) = sqrt(mean((fx_c-calPointsP_c_rot(:,1)').^2 + (fy_c-calPointsP_c_rot(:,2)').^2));
% end
% % implement distance measure
% [distance,indmini] = min(distances);

R = [cos(OPT(9)) -sin(OPT(9));sin(OPT(9)) cos(OPT(9))];
calPointsP_c = (R * calPointsP_c')';

distance = sqrt(mean((fx_c-calPointsP_c(:,1)').^2 + (fy_c-calPointsP_c(:,2)').^2));

% % another thing I could do is look at maximizing the heatmap
xv_c = params.fixations.xv-cf(1);
yv_c = params.fixations.yv-cf(2);
% score = 0;
% for i = 1:size(calPointsP_c,1)
%     [~,indminix] = min(abs(calPointsP_c(i,1)-xv_c));
%     [~,indminiy] = min(abs(calPointsP_c(i,2)-yv_c));
%     score = score + params.fixations.hmap(indminiy,indminix);
% end
% distance = 100*distance-score;


if params.plotScene
%     R = [cos(thetas(indmini)) -sin(thetas(indmini));sin(thetas(indmini)) cos(thetas(indmini))];
%     calPointsP_c = (R * calPointsP_c')';
   
    subplot(1,3,3);imagesc(xv_c,yv_c,params.fixations.hmap);hold on;
    for i = 1:length(calPointsP_c)
%         plot(calPointsP_c(i,1),calPointsP_c(i,2),'g.');
        text(calPointsP_c(i,1),calPointsP_c(i,2),num2str(i),'Color','g','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',20);
%         plot(fx_c(i),fy_c(i),'r.');
        text(fx_c(i),fy_c(i),num2str(i),'Color','r','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',20);
    end
    axis([min(calPointsP_c(:,1))-10 max(calPointsP_c(:,1))+10 min(calPointsP_c(:,2))-10 max(calPointsP_c(:,2))+10]);
%     legend({'fitted','measured'},'Location','EastOutside');
    
    annotation('textbox',[0.1 0.95 0.66 0.05],'String',sprintf('Normal to the image plane :\t %.3f %.3f %.3f',OPT(1),OPT(2),OPT(3)),'EdgeColor','none');
    annotation('textbox',[0.1 0.9 0.66 0.05],'String', sprintf('Center of the eyeball  mm):\t %.3f %.3f %.3f',OPT(4),OPT(5),OPT(6)),'EdgeColor','none');
    annotation('textbox',[0.1 0.85 0.66 0.05],'String', sprintf('Screen center (mm)       :\t dy = %.3f \t dz = %.3f',OPT(7),OPT(8)),'EdgeColor','none');
    annotation('textbox',[0.1 0.8 0.66 0.05],'String', sprintf('Camera rotation (degrees) :\t theta = %.3f \n',OPT(9)/pi*180),'EdgeColor','none');
    annotation('textbox',[0.1 0.75 0.66 0.05],'String',sprintf('RMS = \t %.3f',distance),'EdgeColor','none');
end


