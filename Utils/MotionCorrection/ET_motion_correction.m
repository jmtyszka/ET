function ET_motion_correction
% ET motion correction using the EPI motion correction parameters
% this cannot deal with motion during the calibration phase, or
% between the calibration phase and the first volume...
makevid = 1;

scrsz = get(0,'ScreenSize');

calibrationFile      = 'F:\eyetracking\RA0849_socialA_run1\Gaze\Calibration.mat';
cameraParametersFile = 'D:\data\autism\eyetracking\scripts\calibration_043014\cameraParameters.mat';
rawNiiFile           = 'F:\preprocLBnew\Ra0849\1socialA_run1\Ra0849_1socialA_run1_raw.nii';
motionDir            = 'F:\preprocLBnew\Ra0849\1socialA_run1\prestats.feat\mc\prefiltered_func_data_mcf.mat';
nVolDel              = 2;
videoFile            = 'F:\eyetracking\RA0849_socialA_run1\RA0849_socialA_run1_prepped_Gaze.mp4';% in the fixation coordinates
TR                   = 2.5;

% not needed any longer, right now
% prepFile             = 'F:\eyetracking\RA0849_socialA_run1\RA0849_socialA_run1_Cal_Prep.mat';
% cutFile              = 'F:\eyetracking\RA0849_socialA_run1\prepare.mat';


addpath(genpath('D:\data\toolbox\ET'));
addpath(genpath(fullfile(pwd,'geom3d_2013-08-01')))
addpath(genpath(fullfile(pwd,'FMINSEARCHBND')))
addpath(genpath(fullfile(pwd,'estimateRigidTransform')))
addpath(genpath('D:\data\toolbox\spm8'));

% procedure :
%--------
% BEFORE using this program
% Calibrate the camera using a checkerboard and the cameraCalibrator app
% (computer vision system toolbox) => intrinsic matrix K
% K = [ fx   0    0]
%     [ s    fy   0]
%     [ cx   cy   1]
% where F is the focal length in world units (mm here)
%       [sx,sy] are the number of pixels per world unit in the x and y
%       direction respectively
%       s is the skew parameter (0 if x and y axes are exactly
%       perpendicular
%       [cx, cy] are the coordinates of the optical center (principal point), in pixels
%-----------

%------------------
% fixed parameters (may depend on study)
%------------------
params.Er           = 12; % radius of the eyeball - THIS COULD BE SUBJECT SPECIFIC
params.intereyeD    = 64; % intereye distance (does not matter for calculations
params.D            = 875 + 100; % distance from screen to eye, in mm
% distance screen to mirror + **distance eye to mirror** (how to measure accurately??) + radius of eyeball
params.screenW      = 15.75*2.54*10;% mm
params.screenH      = 11.75*2.54*10;% mm
params.cameraRes    = [720 480];
%------------------
% subject specific parameters
%------------------
load(cameraParametersFile);
params.K            = cameraParameters.IntrinsicMatrix';
load(calibrationFile)
params.fixations = calibration.fixations;

% calibration points (in the order of fixations.x)
params.calPoints = [...
    0.9 0.9;...
    0.5 0.9;...
    0.1 0.9;...
    0.9 0.5;...
    0.5 0.5;...
    0.1 0.5;...
    0.9 0.1;...
    0.5 0.1;...
    0.1 0.1 ...
    ];

% convert fx,fy back to coordinates in the true image plane
% (undo the ROI cropping and rotation)
% load(prepFile);
% switch info.roi_rot
%     case 90
%         tmp = params.fixations.x;
%         params.fixations.x = (info.roi_w+1)-params.fixations.y;
%         params.fixations.y = tmp;
%         tmp = params.fixations.xv;
%         params.fixations.xv = (info.roi_w+1)-params.fixations.yv;
%         params.fixations.yv = tmp;
%         % first row becomes last col
%         params.fixations.hmap = rot90(params.fixations.hmap ,-1);
%         params.fixations.hmap = params.fixations.hmap(:,end:-1:1);
%     case 180
%         params.fixations.x = (info.roi_w+1)-params.fixations.x;
%         params.fixations.y = (info.roi_w+1)-params.fixations.y;
%         params.fixations.xv = (info.roi_w+1)-params.fixations.xv;
%         params.fixations.yv = (info.roi_w+1)-params.fixations.yv;
%         params.fixations.hmap = rot90(params.fixations.hmap ,-2);
%     case 270
%         tmp = params.fixations.y;
%         params.fixations.y = params.fixations.x;
%         params.fixations.x = (info.roi_w+1)-tmp;
%         tmp = params.fixations.yv;
%         params.fixations.yv = params.fixations.xv;
%         params.fixations.xv = (info.roi_w+1)-tmp;
%         params.fixations.hmap = rot90(params.fixations.hmap ,-3);
%         params.fixations.hmap = params.fixations.hmap(end:-1:1,:);
% end
% params.fixations.x = 2*(params.fixations.x + info.roi_x - (info.roi_w/2));
% params.fixations.y = 2*(params.fixations.y + info.roi_y - (info.roi_w/2));
% params.fixations.xv = 2*(params.fixations.xv + info.roi_x - (info.roi_w/2));
% params.fixations.yv = 2*(params.fixations.yv + info.roi_y - (info.roi_w/2));

% account for deinterlacing
params.fixations.x = 2*params.fixations.x;
params.fixations.y = 2*params.fixations.y;
params.fixations.xv = 2*params.fixations.xv;
params.fixations.yv = 2*params.fixations.yv;


xopt = fitCameraImage_calibrated(params,5);


% call "getRightEyeBallMotion.m"
% => coordinates of the eyeball at each fMRI volume
Et = getRightEyeballMotion(rawNiiFile,motionDir,nVolDel);

% reference eye position to Et(1) :
Et = Et - repmat(Et(:,1),1,size(Et,2));

% at each volume, update Ex Ey Ez (add Et(ivol))
Et = repmat(xopt(4:6)',1,size(Et,2)) + Et;

% show the calibration points on the image plane over time

% screen setup
% normal to the screen
normalS = [0 1 0]; % the screen is in the (x,z) plane
% center of the screen
% I THINK I NEED TO THINK ABOUT THIS A BIT MORE, TO BE ACCURATE
pointS  = [xopt(4)-params.intereyeD/2 xopt(5)+params.D+xopt(7) xopt(6)-params.screenH/2+xopt(8)];
% supposes that center of the eyes corresponds to center of screen in x
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
normal_init = xopt(4:6)/sqrt(sum(xopt(4:6).^2)); % unit vector in the direction of the eyeball center
% nudge it around
Rx = [1 0 0 0;0 cos(xopt(1)) -sin(xopt(1)) 0;0 sin(xopt(1)) cos(xopt(1)) 0; 0 0 0 1];
Ry = [cos(xopt(2)) 0 sin(xopt(2)) 0;0 1 0 0;-sin(xopt(2)) 0 cos(xopt(2)) 0;0 0 0 1];
Rz = [cos(xopt(3)) -sin(xopt(3)) 0 0;sin(xopt(3)) cos(xopt(3)) 0 0;0 0 1 0;0 0 0 1];
tmp = Rx * Ry * Rz * [normal_init 1]';
normal = tmp(1:3)';
% % if the optimization is on the coordinates of the normal vector
% normal = [xopt(1) xopt(2) xopt(3)]/sqrt(sum(xopt(1:3).^2)); % normalized normal
% % what is the rotation matrix?
Rmat = vrrotvec2mat(vrrotvec([0 0 1],normal));


%% SHOW THE CALIBRATION POINTS
if makevid
    if ~isunix
        vidObj = VideoWriter('exampleCorrectedCalibrationProj.mp4','MPEG-4');
    else
        vidObj = VideoWriter('exampleCorrectedCalibrationProj.avi','Motion JPEG AVI');
    end
    set(vidObj,'FrameRate',10);
    open(vidObj);
end
figure('Position',[1 1 scrsz(3) scrsz(4)])


tform = cell(1,size(Et,2));
for ivol = 1:size(Et,2),
    % project the pupil on the eyeball, for the 9 calibration points
    calPointsP_px_calc = zeros(size(params.calPoints,1),2);
    for i = 1:size(params.calPoints,1)
        % line from eyeball center to calibration point
        L = createLine3d(Et(1:3,ivol)', [XCal(i) YCal(i) ZCal(i)]);
        % intersect line with eyeball
        pointE = intersectLineSphere(L,[Et(1:3,ivol)' params.Er]);
        % largest y
        [~,indmaxi] = max(pointE(:,2));
        pointE = pointE(indmaxi,:);
        tmp =  params.K * [eye(3) [0 0 0]'] *[ [Rmat';0 0 0] [0 0 0 1]'] * [pointE 1]';
        calPointsP_px_calc(i,:) = tmp(1:2)/tmp(3);% flip both
    end
    [T, ~] = estimateRigidTransform([params.fixations.x/2;params.fixations.y/2;ones(1,length(params.fixations.x))], [calPointsP_px_calc'/2;ones(1,size(calPointsP_px_calc,1))]);
    tform{ivol} = affine2d(T([1 2 4],[1 2 4])');
%     fitgeotrans([params.fixations.x' params.fixations.y']/2,calPointsP_px_calc/2,'NonreflectiveSimilarity');
    % note the /2 here, to account of deinterlacing (we are showing the
    % deinterlaced videos)
    if ivol == 1,
        calPointsP_ref = calPointsP_px_calc;
    end
    
    subplot(121);cla;hold on;
    for i = 1:length(calPointsP_px_calc)
        plot(calPointsP_ref(i,1),calPointsP_ref(i,2),'ko');
        text(calPointsP_ref(i,1),calPointsP_ref(i,2),num2str(i),'Color','k','HorizontalAlignment','left','VerticalAlignment','baseline');
        plot(calPointsP_px_calc(i,1),calPointsP_px_calc(i,2),'g.','Markersize',5);
    end
    axis equal;
    if ivol == 1
        v = axis + [-100 100 -100 100];
    end
    axis(v);
    title(sprintf('Volume %d/%d', ivol, size(Et,2)));
    set(gca,'XGrid','on','YGrid','on');
    
    % fit and apply calibration model (from the first volume)
    if ivol == 1
        Cref = ET_CalibrationFit(calPointsP_px_calc(:,1)',calPointsP_px_calc(:,2)');
        [gazeref_x, gazeref_y] = ET_ApplyCalibration(calPointsP_px_calc(:,1)', calPointsP_px_calc(:,2)', Cref);
    end
    [gazeold_x, gazeold_y] = ET_ApplyCalibration(calPointsP_px_calc(:,1)', calPointsP_px_calc(:,2)', Cref);
    C = ET_CalibrationFit(calPointsP_px_calc(:,1)',calPointsP_px_calc(:,2)');
    [gazenew_x, gazenew_y] = ET_ApplyCalibration(calPointsP_px_calc(:,1)', calPointsP_px_calc(:,2)', C);
    subplot(122);cla;hold on;
    % true positions
    plot(params.calPoints(:,1)*params.screenW,params.calPoints(:,2)*params.screenH,'ko');
    % reconstructed positions
    plot(gazeref_x*params.screenW,gazeref_y*params.screenH,'k+');
    plot(gazeold_x*params.screenW,gazeold_y*params.screenH,'r+');
    plot(gazenew_x*params.screenW,gazenew_y*params.screenH,'g+');
    title('Reconstructed gaze');
    set(gca,'XGrid','on','YGrid','on');
    axis equal;
    axis([-200 params.screenW+200 -200 params.screenH+200]);
    line([0 0],[0 params.screenH],'Color','k');
    line([params.screenW params.screenW],[0 params.screenH],'Color','k');
    line([0 params.screenW],[0 0],'Color','k');
    line([0 params.screenW],[params.screenH params.screenH],'Color','k');
    
    drawnow
    if makevid,writeVideo(vidObj,getframe(gcf));end
end
if makevid,close(vidObj);end

% keyboard

%% MAKE AN EYE MOTION VIDEO
if makevid
    if ~isunix
        vidObj = VideoWriter('exampleRightEyeMovement.mp4','MPEG-4');
    else
        vidObj = VideoWriter('exampleRightEyeMovement.avi','Motion JPEG AVI');
    end
    set(vidObj,'FrameRate',10);
    open(vidObj);
end
figure('Position',[1 1 scrsz(3) scrsz(4)])

video=VideoReader(videoFile);
% load(cutFile);
t = (1:1:video.numberOfFrames)/video.FrameRate;
% re-reference t so that it is 0 when the movie starts
% need to account for dummy scans after the first artefact
ndummy=1;
while ndummy*TR<3,
    ndummy=ndummy+1;
end
% also need to account for the removed volumes
t = t - t(2*151); % always leave 150 frames in ET_cut; + deinterlacing  
t = t - ndummy*TR;
t = t - nVolDel*TR;
t = t - .5 * TR; % reference to the end of the volume

Jorigall=[];
Jregall=[];
D = nan(1,size(Et,2));
for ivol = 1:size(Et,2)
    tfMRI = TR*(ivol-1);
    
    % which video frame corresponds to this?
    [~,thisframe] = min(abs(tfMRI-t));
    
    D(ivol) = sqrt(sum((Et(:,ivol) - Et(:,1)).^2));
    
    clf;
    subplot(341);hold on;title(sprintf('Volume %d/%d',ivol, size(Et,2)));
    plot(Et(1,1:ivol));line([1 size(Et,2)],[Et(1,1) Et(1,1)]);
    axis([1 size(Et,2) Et(1,1)-3 Et(1,1)+3]);
    xlabel('x')
    subplot(345);hold on;
    plot(Et(2,1:ivol));line([1 size(Et,2)],[Et(2,1) Et(2,1)]);
    axis([1 size(Et,2) Et(2,1)-3 Et(2,1)+3]);
    xlabel('y')
    subplot(349);hold on;
    plot(Et(3,1:ivol));line([1 size(Et,2)],[Et(3,1) Et(3,1)]);
    axis([1 size(Et,2) Et(3,1)-3 Et(3,1)+3]);
    xlabel('z')
    % compute distance
    subplot(3,4,[2 6 10]);
    plot(1:size(Et,2),D);hold on;
    line([1 size(Et,2)],[0 0],'LineStyle','--','Color','k');
    xlim([1 size(Et,2)]);ylim([0 5]);
    xlabel('Volume #');
    ylabel('distance of right eye center to reference');
    
    subplot(3,4,[3 4]);
    Jorig = rgb2gray(read(video, thisframe));
    Jorigall = cat(3,Jorigall,Jorig);
    imshow(Jorig);
    
    % show the corrected video
    subplot(3,4,[11 12]);
    Jreg = imwarp(Jorig,tform{ivol},'OutputView',imref2d([400 400]));
    imshow(Jreg);
    Jregall = cat(3,Jregall,Jreg);
    title('Corrected Video');
    
    drawnow
    writeVideo(vidObj,getframe(gcf));
end
if makevid,close(vidObj);end

keyboard



